// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol"; /*requires solidity ^0.8.0 */
import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; /*requires solidity ^0.8.0 */
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; /*requires solidity ^0.8.0 */
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol"; /*requires solidity ^0.8.0 */
import "@openzeppelin/contracts/utils/Context.sol"; /*requires solidity ^0.8.0 */
import "./owner/Operator.sol";

/***

.-. .-. .-. .-. .-. .-. .-.   .-. .-. . . .-. . . .-. .-. 
`-. |-' |-  |    |  |-  |(    |-   |  |\| |-| |\| |   |-  
`-' '   `-' `-'  '  `-' ' '   '   `-' ' ` ` ' ' ` `-' `-' 
                                                          

***/

contract SBond is ERC20Burnable, Operator {
    /**
     * @notice Constructs the SPECTER Bond ERC-20 contract.
     */
    constructor() public ERC20("SBOND", "SBOND") {}

    /**
     * @notice Operator mints basis bonds to a recipient
     * @param recipient_ The address of recipient
     * @param amount_ The amount of basis bonds to mint to
     * @return whether the process has been done
     */
    function mint(address recipient_, uint256 amount_) public onlyOperator returns (bool) {
        uint256 balanceBefore = balanceOf(recipient_);
        _mint(recipient_, amount_);
        uint256 balanceAfter = balanceOf(recipient_);

        return balanceAfter > balanceBefore;
    }

    function burn(uint256 amount) public override {
        super.burn(amount);
    }

    function burnFrom(address account, uint256 amount) public override onlyOperator {
        super.burnFrom(account, amount);
    }
}
