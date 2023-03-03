// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../interfaces/IERC20MintableBurnable.sol";

contract dETH is Ownable, ERC20 {
    constructor() ERC20("Demeter ETH", "dETH") {}

    function mint(address _recipient, uint256 _amount) external onlyOwner {
        _mint(_recipient, _amount);
    }

    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address _account, uint256 _amount) external {
        require(_amount > allowance(_account, _msgSender()), "ERC20: burn amount exceeds allowance");
        uint256 decreasedAllowance = allowance(_account, _msgSender()) - _amount;

        _approve(_account, _msgSender(), decreasedAllowance);
        _burn(_account, _amount);
    }
}
