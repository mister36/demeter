// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

interface IVault {
    // no need for shares
    /* 
       deposit:
       deposit erc20, mints shares
       ============================

       borrow:
       receive synth up to collateralization limit (checked by shares owned)
       ============================

       repay:
       repays with underlying or synth
       ============================

       withdraw
       ============================

       liquidate
       ============================
    


    */
    function deposit(uint amount) external;

    function withdraw(uint amount) external;

    function borrow(uint amount) external;

    function repay(uint _underlyingAmount, uint _synthAmount) external;

    function liquidate(uint amount) external;

    function harvest() external;
}
