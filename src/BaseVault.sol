// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./interfaces/IVault.sol";
import "./interfaces/IERC20MintableBurnable.sol";

abstract contract BaseVault is IVault {
    event TokensDeposited(address account, uint amount);
    event TokensWithdrawn(address account, uint amount);
    event TokensRepaid(address account, uint assetAmount, uint synthAmount);

    /// @dev default collateralization level (2_000_000 = 200%, i.e. loan <= 50% of collateral)
    uint public constant DEFAULT_COLLATERALIZATION = 2_000_000;

    /// @dev underlying asset for vault (stablecoin or weth)
    IERC20 public asset;

    /// @dev synthetic token for vault (dUSD or dETH)
    IERC20MintableBurnable public synth;

    /// @dev total amount of underlying assets deposited onto contract
    uint totalDeposited;

    /// @dev total amount of debt
    uint totalDebt;

    /// @dev represents collateralized debt position
    struct CDP {
        uint256 totalDeposited;
        uint256 totalDebt;
        uint256 totalCredit;
    }

    /// @dev mapping of users to collateralized debt positions
    mapping(address => CDP) private _cdps;

    constructor(IERC20 _asset, IERC20MintableBurnable _synth) {
        asset = _asset;
        synth = _synth;
    }

    // TODO: check whether asset is weth. If so, swap to usdc and buy call option
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
        checkHealth(msg.sender);

        emit TokensWithdrawn(msg.sender, _amount);
    }

    function repay(uint _underlyingAmount, uint _synthAmount) external {
        CDP storage _cdp = _cdps[msg.sender];

        if (_underlyingAmount > 0) {
            asset.transferFrom(msg.sender, address(this), _underlyingAmount);
        }

        if (_synthAmount > 0) {
            synth.burnFrom(msg.sender, _synthAmount);
        }

        uint _totalAmount = _underlyingAmount + _synthAmount;
        _cdp.totalDebt -= _totalAmount;
        totalDebt -= _totalAmount;

        emit TokensRepaid(msg.sender, _underlyingAmount, _synthAmount);
    }

    /// @dev Mints synthetic tokens by either claiming credit or increasing the debt.
    ///
    /// Claiming credit will take priority over increasing the debt.
    ///
    /// This function reverts if the debt is increased and the CDP health check fails.
    ///
    /// @param _amount the amount of synth tokens to borrow.
    function mint(uint256 _amount) external {
        CDP storage _cdp = _cdps[msg.sender];
        uint _totalCredit = _cdp.totalCredit;

        if (_totalCredit < _amount) {
            uint _remainingAmount = _amount - _totalCredit;
            _cdp.totalDebt += _remainingAmount;
            _cdp.totalCredit = 0;

            checkHealth(msg.sender);
        } else {
            _cdp.totalCredit -= _amount;
        }

        synth.mint(msg.sender, _amount);
    }

    function liquidate(uint _amount) external virtual {}

    function harvest() external virtual {}

    /// @dev Assures that the CDP is healthy.
    ///
    /// This function will revert if the CDP is unhealthy.
    function checkHealth(address user) internal view {
        CDP storage _cdp = _cdps[user];

        require(_cdp.totalDeposited / _cdp.totalDebt >= DEFAULT_COLLATERALIZATION, "Unhealthy collateralization ratio");
    }

    function updateCDP(CDP storage _cdp) internal {
        uint _earnedYield = _getEarnedYield();
        if (_earnedYield > _cdp.totalDebt) {
            _cdp.totalDebt = 0;
            _cdp.totalCredit = _earnedYield - _cdp.totalDebt;
        } else {
            _cdp.totalDebt -= _earnedYield;
        }
    }

    function withdrawable(address user) public virtual returns (uint total) {}

    function _getEarnedYield() internal view virtual returns (uint) {}

    /// @notice strategies always ran with USDC
    function _runStrategy(uint _amount) internal virtual;
}
