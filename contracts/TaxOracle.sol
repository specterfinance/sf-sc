// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/***
.-. .-. .-. .-. .-. .-. .-.   .-. .-. . . .-. . . .-. .-. 
`-. |-' |-  |    |  |-  |(    |-   |  |\| |-| |\| |   |-  
`-' '   `-' `-'  '  `-' ' '   '   `-' ' ` ` ' ' ` `-' `-' 
***/

contract SpecterTaxOracle is Ownable {
    using SafeMath for uint256;

    IERC20 public specter;
    IERC20 public wftm;
    address public pair;

    constructor(
        address _specter,
        address _wftm,
        address _pair
    ) public {
        require(_specter != address(0), "specter address cannot be 0");
        require(_wftm != address(0), "wftm address cannot be 0");
        require(_pair != address(0), "pair address cannot be 0");
        specter = IERC20(_specter);
        wftm = IERC20(_wftm);
        pair = _pair;
    }

    function consult(address _token, uint256 _amountIn) external view returns (uint144 amountOut) {
        require(_token == address(specter), "token needs to be specter");
        uint256 specterBalance = specter.balanceOf(pair);
        uint256 wftmBalance = wftm.balanceOf(pair);
        return uint144(specterBalance.div(wftmBalance));
    }

    function setSpecter(address _specter) external onlyOwner {
        require(_specter != address(0), "specter address cannot be 0");
        specter = IERC20(_specter);
    }

    function setWftm(address _wftm) external onlyOwner {
        require(_wftm != address(0), "wftm address cannot be 0");
        wftm = IERC20(_wftm);
    }

    function setPair(address _pair) external onlyOwner {
        require(_pair != address(0), "pair address cannot be 0");
        pair = _pair;
    }
}
