// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./owner/Operator.sol";
import "./interfaces/ITaxable.sol";
import "./interfaces/IUniswapV2Router.sol";
import "./interfaces/IERC20.sol";


/***

.-. .-. .-. .-. .-. .-. .-.   .-. .-. . . .-. . . .-. .-. 
`-. |-' |-  |    |  |-  |(    |-   |  |\| |-| |\| |   |-  
`-' '   `-' `-'  '  `-' ' '   '   `-' ' ` ` ' ' ` `-' `-' 
                                                          

***/

contract TaxOfficeV2 is Operator {
    using SafeMath for uint256;

    address public specter = address(0x6c021Ae822BEa943b2E66552bDe1D2696a53fbB7);
    address public wftm = address(0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83);
    address public uniRouter = address(0xF491e7B69E4244ad4002BC14e878a34207E38c29);

    mapping(address => bool) public taxExclusionEnabled;

    function setTaxTiersTwap(uint8 _index, uint256 _value) public onlyOperator returns (bool) {
        return ITaxable(specter).setTaxTiersTwap(_index, _value);
    }

    function setTaxTiersRate(uint8 _index, uint256 _value) public onlyOperator returns (bool) {
        return ITaxable(specter).setTaxTiersRate(_index, _value);
    }

    function enableAutoCalculateTax() public onlyOperator {
        ITaxable(specter).enableAutoCalculateTax();
    }

    function disableAutoCalculateTax() public onlyOperator {
        ITaxable(specter).disableAutoCalculateTax();
    }

    function setTaxRate(uint256 _taxRate) public onlyOperator {
        ITaxable(specter).setTaxRate(_taxRate);
    }

    function setBurnThreshold(uint256 _burnThreshold) public onlyOperator {
        ITaxable(specter).setBurnThreshold(_burnThreshold);
    }

    function setTaxCollectorAddress(address _taxCollectorAddress) public onlyOperator {
        ITaxable(specter).setTaxCollectorAddress(_taxCollectorAddress);
    }

    function excludeAddressFromTax(address _address) external onlyOperator returns (bool) {
        return _excludeAddressFromTax(_address);
    }
    
    function _excludeAddressFromTax(address _address) private returns (bool) {
        if (!ITaxable(specter).isAddressExcluded(_address)) {
            return ITaxable(specter).excludeAddress(_address);
        }
        
    }

    function includeAddressInTax(address _address) external onlyOperator returns (bool) {
        return _includeAddressInTax(_address);
    }

    function _includeAddressInTax(address _address) private returns (bool) {
        if (ITaxable(specter).isAddressExcluded(_address)) {
            return ITaxable(specter).includeAddress(_address);
        }
    }

    function taxRate() external view returns (uint256) {
        return ITaxable(specter).taxRate();
    }

    function addLiquidityTaxFree(
        address token,
        uint256 amtSpecter,
        uint256 amtToken,
        uint256 amtSpecterMin,
        uint256 amtTokenMin
    )
        external
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        require(amtSpecter != 0 && amtToken != 0, "amounts can't be 0");
        _excludeAddressFromTax(msg.sender);

        IERC20(specter).transferFrom(msg.sender, address(this), amtSpecter);
        IERC20(token).transferFrom(msg.sender, address(this), amtToken);
        _approveTokenIfNeeded(specter, uniRouter);
        _approveTokenIfNeeded(token, uniRouter);

        _includeAddressInTax(msg.sender);

        uint256 resultAmtSpecter;
        uint256 resultAmtToken;
        uint256 liquidity;
        (resultAmtSpecter, resultAmtToken, liquidity) = IUniswapV2Router(uniRouter).addLiquidity(
            specter,
            token,
            amtSpecter,
            amtToken,
            amtSpecterMin,
            amtTokenMin,
            msg.sender,
            block.timestamp
        );

        if (amtSpecter.sub(resultAmtSpecter) > 0) {
            IERC20(specter).transfer(msg.sender, amtSpecter.sub(resultAmtSpecter));
        }
        if (amtToken.sub(resultAmtToken) > 0) {
            IERC20(token).transfer(msg.sender, amtToken.sub(resultAmtToken));
        }
        return (resultAmtSpecter, resultAmtToken, liquidity);
    }

    function addLiquidityETHTaxFree(
        uint256 amtSpecter,
        uint256 amtSpecterMin,
        uint256 amtFtmMin
    )
        external
        payable
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        require(amtSpecter != 0 && msg.value != 0, "amounts can't be 0");
        _excludeAddressFromTax(msg.sender);

        IERC20(specter).transferFrom(msg.sender, address(this), amtSpecter);
        _approveTokenIfNeeded(specter, uniRouter);

        _includeAddressInTax(msg.sender);

        uint256 resultAmtSpecter;
        uint256 resultAmtFtm;
        uint256 liquidity;
        (resultAmtSpecter, resultAmtFtm, liquidity) = IUniswapV2Router(uniRouter).addLiquidityETH{value: msg.value}(
            specter,
            amtSpecter,
            amtSpecterMin,
            amtFtmMin,
            msg.sender,
            block.timestamp
        );

        if (amtSpecter.sub(resultAmtSpecter) > 0) {
            IERC20(specter).transfer(msg.sender, amtSpecter.sub(resultAmtSpecter));
        }
        return (resultAmtSpecter, resultAmtFtm, liquidity);
    }

    function setTaxableSpecterOracle(address _specterOracle) external onlyOperator {
        ITaxable(specter).setSpecterOracle(_specterOracle);
    }

    function transferTaxOffice(address _newTaxOffice) external onlyOperator {
        ITaxable(specter).setTaxOffice(_newTaxOffice);
    }

    function taxFreeTransferFrom(
        address _sender,
        address _recipient,
        uint256 _amt
    ) external {
        require(taxExclusionEnabled[msg.sender], "Address not approved for tax free transfers");
        _excludeAddressFromTax(_sender);
        IERC20(specter).transferFrom(_sender, _recipient, _amt);
        _includeAddressInTax(_sender);
    }

    function setTaxExclusionForAddress(address _address, bool _excluded) external onlyOperator {
        taxExclusionEnabled[_address] = _excluded;
    }

    function _approveTokenIfNeeded(address _token, address _router) private {
        if (IERC20(_token).allowance(address(this), _router) == 0) {
            IERC20(_token).approve(_router, type(uint256).max);
        }
    }
}
