// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "./Owned.sol";
import "./Utils.sol";
import "./interfaces/ITokenHolder.sol";

/**
 * @dev This contract provides a safety mechanism for allowing the owner to
 * send tokens that were sent to the contract by mistake back to the sender.
 *
 * We consider every contract to be a 'token holder' since it's currently not possible
 * for a contract to deny receiving tokens.
 *
 * Note that we use the non standard ERC-20 interface which has no return value for transfer
 * in order to support both non standard as well as standard token contracts.
 * see https://github.com/ethereum/solidity/issues/4116
 */
contract TokenHolder is ITokenHolder, Owned, Utils {
    using SafeERC20 for IERC20;

    IERC20 internal constant ETH_RESERVE_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    /**
     * @dev withdraws tokens held by the contract and sends them to an account
     * can only be called by the owner
     *
     * @param _token   ERC20 token contract address
     * @param _to      account to receive the new amount
     * @param _amount  amount to withdraw
     */
    function withdrawTokens(
        IERC20 _token,
        address _to,
        uint256 _amount
    ) public virtual override ownerOnly validAddress(address(_token)) validAddress(_to) notThis(_to) {
        if (_token == ETH_RESERVE_ADDRESS) {
            payable(_to).transfer(_amount);
        }
        else {
            _token.safeTransfer(_to, _amount);
        }
    }
}
