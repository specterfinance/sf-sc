// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./owner/Operator.sol";
import "./interfaces/ITaxable.sol";

/***
.-. .-. .-. .-. .-. .-. .-.   .-. .-. . . .-. . . .-. .-. 
`-. |-' |-  |    |  |-  |(    |-   |  |\| |-| |\| |   |-  
`-' '   `-' `-'  '  `-' ' '   '   `-' ' ` ` ' ' ` `-' `-' 
***/

contract TaxOffice is Operator {
    address public specter;

    constructor(address _specter) public {
        require(_specter != address(0), "specter address cannot be 0");
        specter = _specter;
    }

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
        return ITaxable(specter).excludeAddress(_address);
    }

    function includeAddressInTax(address _address) external onlyOperator returns (bool) {
        return ITaxable(specter).includeAddress(_address);
    }

    function setTaxableSpecterOracle(address _specterOracle) external onlyOperator {
        ITaxable(specter).setSpecterOracle(_specterOracle);
    }

    function transferTaxOffice(address _newTaxOffice) external onlyOperator {
        ITaxable(specter).setTaxOffice(_newTaxOffice);
    }
}
