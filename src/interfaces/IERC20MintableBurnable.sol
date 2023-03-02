// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

interface IERC20MintableBurnable is IERC20 {
    function mint(address _recipient, uint256 _amount) external;

    function burnFrom(address _account, uint256 _amount) external;
}
