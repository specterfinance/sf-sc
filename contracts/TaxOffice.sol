// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./owner/Operator.sol";
import "./interfaces/ITaxable.sol";

/***
 *     ___  ___  ___  ___  ___  ___  ___     ___  _  _ _  ___  _ _  ___  ___
 *    / __>| . \| __>|  _>|_ _|| __>| . \   | __>| || \ || . || \ ||  _>| __>
 *    \__ \|  _/| _> | <__ | | | _> |   /   | _> | ||   ||   ||   || <__| _>
 *    <___/|_|  |___>`___/ |_| |___>|_\_\   |_|  |_||_\_||_|_||_\_|`___/|___>
 *
 */

contract TaxOffice is Operator {
    address public tomb;

    constructor(address _tomb) public {
        require(_tomb != address(0), "tomb address cannot be 0");
        tomb = _tomb;
    }

    function setTaxTiersTwap(uint8 _index, uint256 _value) public onlyOperator returns (bool) {
        return ITaxable(tomb).setTaxTiersTwap(_index, _value);
    }

    function setTaxTiersRate(uint8 _index, uint256 _value) public onlyOperator returns (bool) {
        return ITaxable(tomb).setTaxTiersRate(_index, _value);
    }

    function enableAutoCalculateTax() public onlyOperator {
        ITaxable(tomb).enableAutoCalculateTax();
    }

    function disableAutoCalculateTax() public onlyOperator {
        ITaxable(tomb).disableAutoCalculateTax();
    }

    function setTaxRate(uint256 _taxRate) public onlyOperator {
        ITaxable(tomb).setTaxRate(_taxRate);
    }

    function setBurnThreshold(uint256 _burnThreshold) public onlyOperator {
        ITaxable(tomb).setBurnThreshold(_burnThreshold);
    }

    function setTaxCollectorAddress(address _taxCollectorAddress) public onlyOperator {
        ITaxable(tomb).setTaxCollectorAddress(_taxCollectorAddress);
    }

    function excludeAddressFromTax(address _address) external onlyOperator returns (bool) {
        return ITaxable(tomb).excludeAddress(_address);
    }

    function includeAddressInTax(address _address) external onlyOperator returns (bool) {
        return ITaxable(tomb).includeAddress(_address);
    }

    function setTaxableTombOracle(address _tombOracle) external onlyOperator {
        ITaxable(tomb).setTombOracle(_tombOracle);
    }

    function transferTaxOffice(address _newTaxOffice) external onlyOperator {
        ITaxable(tomb).setTaxOffice(_newTaxOffice);
    }
}
