// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./interfaces/IVault.sol";
import "./interfaces/IERC20MintableBurnable.sol";

abstract contract BaseVault is IVault {
    event TokensDeposited(address account, uint amount);
    event TokensWithdrawn(address account, uint amount);

    /// @dev underlying asset for vault (stablecoin or weth)
    IERC20MintableBurnable public asset;

    /// @dev synthetic token for vault (dUSD or dETH)
    IERC20MintableBurnable public synth;

    /// @dev total amount of underlying assets deposited onto contract
    uint totalDeposited;

    /// @dev total amount of debt
    uint totalDebt;

    /// @dev default collateralization level (2_000_000 = 200%, i.e. loan <= 50% of collateral)
    uint public constant DEFAULT_COLLATERALIZATION = 2_000_000;

    /// @dev represents collateralized debt position
    struct CDP {
        uint256 totalDeposited;
        uint256 totalDebt;
        uint256 totalCredit;
    }

    /// @dev mapping of users to collateralized debt positions
    mapping(address => CDP) private _cdps;

    constructor(IERC20MintableBurnable _asset, IERC20MintableBurnable _synth) {
        asset = _asset;
        synth = _synth;
    }

    function deposit(uint _amount) external {
        CDP storage _cdp = _cdps[msg.sender];

        asset.transferFrom(msg.sender, address(this), _amount);
        _cdp.totalDeposited += _amount;
        totalDeposited += _amount;

        emit TokensDeposited(msg.sender, _amount);

        _runStrategy(_amount);
    }

    function withdraw(uint _amount) external {
        CDP storage _cdp = _cdps[msg.sender];

        require(withdrawable(msg.sender) >= _amount, "Exceeds withdrawable amounts");
        _cdp.totalDeposited -= _amount;
        require(_cdp.totalDeposited / _cdp.totalDebt >= DEFAULT_COLLATERALIZATION, "Unhealthy collateralization ratio");

        emit TokensWithdrawn(msg.sender, _amount);
    }

    function repay(uint _underlyingAmount, uint _synthAmount) external {
        CDP storage _cdp = _cdps[msg.sender];

        if (_underlyingAmount > 0) {
            asset.transferFrom(msg.sender, address(this), _underlyingAmount);
            _distributeToTransmuter(_underlyingAmount);
        }

        if (_synthAmount > 0) {
            synth.burnFrom(msg.sender, _synthAmount);
        }

        uint _totalAmount = _underlyingAmount + _synthAmount;
        _cdp.totalDebt -= _totalAmount;
        totalDebt -= _totalAmount;
    }

    function _distributeToTransmuter(uint amount) internal {}

    function withdrawable(address user) public virtual returns (uint total) {}

    function _runStrategy(uint amount) internal virtual;
}
