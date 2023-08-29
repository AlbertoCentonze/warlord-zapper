// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {IVault} from "balancer/IVault.sol";
import {EtherUtils} from "src/EtherUtils.sol";

abstract contract Balancer is EtherUtils {
    using SafeTransferLib for ERC20;

    address private constant AURA = 0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF;

    address vault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

    function resetBalancerAllowance() external {
      _resetWethAllowance(vault);
    }

    function removeBalancerAllowance() external {
      _removeWethAllowance(vault);
    }

    function _wethToAura(uint256 amount, uint256 auraOutMin) internal {
        IVault.SingleSwap memory params = IVault.SingleSwap({
          poolId: 0xcfca23ca9ca720b6e98e3eb9b6aa0ffc4a5c08b9000200000000000000000274, // 50/50 WETH/AURA
          kind: 0, // exact input, output given
          assetIn: WETH, 
          assetOut: AURA,
          amount: amount, // Amount to swap
          userData: ""
        });

        IVault.FundManagement memory funds = IVault.FundManagement({
          sender: address(this), // Funds are taken from this contract
          recipient: address(this), // Swapped tokens are sent back to this contract
          fromInternalBalance: false, // Don't take funds from contract LPs (since there's none)
          toInternalBalance: false // Don't LP with swapped funds
        });

        IVault(vault).swap(params, funds, auraOutMin, type(uint256).max);
    }
}
