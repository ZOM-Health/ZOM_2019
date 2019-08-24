pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./IERC20.sol";
import "./WhitelistedRole.sol";

/**
 * @title Staking smart contract
 */
contract Staking is WhitelistedRole {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // whitelisted users amount
    uint256 private _usersAmount;

    // timestamp when last time deposit was deposited tokens
    uint256 private _lastDepositDone;

    // only once per 30 days depositor can deposit tokens
    uint256 private constant _depositDelay = 30 days;

    // the address of depositor
    address private _depositor;

    // how much deposits depositor done
    uint256 private _depositsAmount;

    struct DepositData {
        uint256 tokens;
        uint256 usersLength;
    }

    // here we store the history of deposits amount per each delay
    mapping(uint256 => DepositData) private _depositedPerDelay;

    // here we store user address => last deposit amount for withdraw calculation
    // if user missed withdrawal of few months he can withdraw all tokens once
    mapping(address => uint256) private _userWithdraws;

    // interface of ERC20 Yazom
    IERC20 private _yazom;

    // events for watching
    event Deposited(uint256 amount);
    event Withdrawen(address indexed user, uint256 amount);

    // -----------------------------------------
    // CONSTRUCTOR
    // -----------------------------------------

    constructor (address depositor, IERC20 yazom) public {
        _depositor = depositor;
        _yazom = yazom;
    }

    // -----------------------------------------
    // EXTERNAL
    // -----------------------------------------

    function () external payable {
        // revert fallback methods
        revert();
    }

    function deposit() external {
        require(msg.sender == _depositor, "deposit: only the depositor can deposit tokens");
        require(block.timestamp >= _lastDepositDone.add(_depositDelay), "deposit: can not deposit now");

        uint256 tokensAmount = _yazom.allowance(_depositor, address(this));
        _yazom.safeTransferFrom(_depositor, address(this), tokensAmount);

        _lastDepositDone = block.timestamp;
        _depositedPerDelay[_depositsAmount] = DepositData(tokensAmount, _usersAmount);
        _depositsAmount += 1;

        emit Deposited(tokensAmount);
    }

    function withdrawn() external onlyWhitelisted {
        address user = msg.sender;
        uint256 userLastWithdrawal = _userWithdraws[user];
        require(userLastWithdrawal < _depositsAmount, "withdrawn: this user already withdraw all available funds");

        uint256 tokensAmount;

        for (uint256 i = userLastWithdrawal; i < _depositsAmount; i++) {
            uint256 tokensPerDelay = _depositedPerDelay[i].tokens.div(_depositedPerDelay[i].usersLength);
            tokensAmount = tokensPerDelay;
        }

        _userWithdraws[user] = _depositsAmount;
        _yazom.safeTransfer(user, tokensAmount);

        emit Withdrawen(user, tokensAmount);
    }

    // -----------------------------------------
    // INTERNAL
    // -----------------------------------------

    function _addWhitelisted(address account) internal {
        _usersAmount++;
        super._addWhitelisted(account);
    }

    function _removeWhitelisted(address account) internal {
        _usersAmount--;
        super._removeWhitelisted(account);
    }

    // -----------------------------------------
    // GETTERS
    // -----------------------------------------

    function getCurrentUsersAmount() external view returns (uint256) {
        return _usersAmount;
    }

    function getLastDepositDoneDate() external view returns (uint256) {
        return _lastDepositDone;
    }

    function getDepositDelay() external pure returns (uint256) {
        return _depositDelay;
    }

    function getDepositorAddress() external view returns (address) {
        return _depositor;
    }

    function getDepositsAmount() external view returns (uint256) {
        return _depositsAmount;
    }

    function getDepositData(uint256 depositId) external view returns (uint256 tokens, uint256 usersLength) {
        return (
            _depositedPerDelay[depositId].tokens,
            _depositedPerDelay[depositId].usersLength
        );
    }

    function getUserLastWithdraw(address user) external view returns (uint256) {
        return _userWithdraws[user];
    }
}
