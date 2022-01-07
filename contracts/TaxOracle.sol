// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/***
 *     ___  ___  ___  ___  ___  ___  ___     ___  _  _ _  ___  _ _  ___  ___
 *    / __>| . \| __>|  _>|_ _|| __>| . \   | __>| || \ || . || \ ||  _>| __>
 *    \__ \|  _/| _> | <__ | | | _> |   /   | _> | ||   ||   ||   || <__| _>
 *    <___/|_|  |___>`___/ |_| |___>|_\_\   |_|  |_||_\_||_|_||_\_|`___/|___>
 *
 */

contract TombTaxOracle is Ownable {
    using SafeMath for uint256;

    IERC20 public tomb;
    IERC20 public wftm;
    address public pair;

    constructor(
        address _tomb,
        address _wftm,
        address _pair
    ) public {
        require(_tomb != address(0), "tomb address cannot be 0");
        require(_wftm != address(0), "wftm address cannot be 0");
        require(_pair != address(0), "pair address cannot be 0");
        tomb = IERC20(_tomb);
        wftm = IERC20(_wftm);
        pair = _pair;
    }

    function consult(address _token, uint256 _amountIn) external view returns (uint144 amountOut) {
        require(_token == address(tomb), "token needs to be tomb");
        uint256 tombBalance = tomb.balanceOf(pair);
        uint256 wftmBalance = wftm.balanceOf(pair);
        return uint144(tombBalance.div(wftmBalance));
    }

    function setTomb(address _tomb) external onlyOwner {
        require(_tomb != address(0), "tomb address cannot be 0");
        tomb = IERC20(_tomb);
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
