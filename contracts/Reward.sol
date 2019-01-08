pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./IERC20.sol";
import "./ReentrancyGuard.sol";
import "./ZOMToken.sol";

/**
 * @title Reward
 * @author Ararat Tonoyan <tonoyandeveloper@gmail.com>
 * @dev The contract store the owner addresses, who can receive an reward
 * tokens from ZOMToken smart contract once in 30 days 1 and 3 percent annually.
 */
contract Reward is ReentrancyGuard {
    using SafeMath for uint256;

    uint8 private constant _smallProcent = 1;
    uint8 private constant _bigProcent = 3;
    uint256 private constant _rewardDelay = 30 days;
    uint256 private constant _firstGroupTokensLimit = 50000 * 1 ether; // 50,000.00 ZOM
    uint256 private _contractCreationDate;

    struct Holder {
        uint256 lastWithdrawDate;
        uint256 amountOfWithdraws;
    }

    IERC20 private _token;

    mapping(address => Holder) private _rewardTimeStamp;

    event NewTokensMinted(address indexed receiver, uint256 amount);

    modifier onlyHolder {
        uint256 balanceOfHolder = _getTokenBalance(msg.sender);
        require(balanceOfHolder > 0, "onlyHolder: the sender has no ZOM tokens");
        _;
    }

    // -----------------------------------------
    // CONSTRUCTOR
    // -----------------------------------------

    constructor() public {
        address zom = address(new ZOMToken());
        _token = IERC20(zom);
        _contractCreationDate = block.timestamp;
        _token.transfer(msg.sender, _token.totalSupply());
    }

    // -----------------------------------------
    // EXTERNAL
    // -----------------------------------------

    function withdrawRewardTokens() external onlyHolder nonReentrant {
        address holder = msg.sender;
        uint256 lastWithdrawDate = _getLastWithdrawDate(holder);
        uint256 howDelaysAvailable = (block.timestamp.sub(lastWithdrawDate)).div(_rewardDelay);

        require(howDelaysAvailable > 0, "withdrawRewardTokens: the holder can not withdraw tokens yet!");

        uint256 tokensAmount = _calculateRewardTokens(holder);

        // updating the last withdraw timestamp
        uint256 timeAfterLastDelay = block.timestamp.sub(lastWithdrawDate) % _rewardDelay;
        _rewardTimeStamp[holder].lastWithdrawDate = block.timestamp.sub(timeAfterLastDelay);

        // transfering the tokens
        _mint(holder, tokensAmount);

        emit NewTokensMinted(holder, tokensAmount);
    }


    // -----------------------------------------
    // GETTERS
    // -----------------------------------------

    function getHolderData(address holder) external view returns (uint256, uint256, uint256) {
        return (
            _getTokenBalance(holder),
            _rewardTimeStamp[holder].lastWithdrawDate,
            _rewardTimeStamp[holder].amountOfWithdraws
        );
    }

    function getAvailableRewardTokens(address holder) external view returns (uint256) {
        return _calculateRewardTokens(holder);
    }

    function token() external view returns (address) {
        return address(_token);
    }

    function creationDate() external view returns (uint256) {
        return _contractCreationDate;
    }

    // -----------------------------------------
    // INTERNAL
    // -----------------------------------------

    function _mint(address holder, uint256 amount) private {
        require(_token.mint(holder, amount),"_mint: the issue happens during tokens minting");
        _rewardTimeStamp[holder].amountOfWithdraws = _rewardTimeStamp[holder].amountOfWithdraws.add(1);
    }

    function _calculateRewardTokens(address holder) private view returns (uint256) {
        uint256 lastWithdrawDate = _getLastWithdrawDate(holder);
        uint256 howDelaysAvailable = (block.timestamp.sub(lastWithdrawDate)).div(_rewardDelay);
        uint256 currentBalance = _getTokenBalance(holder);
        uint8 procent = currentBalance >= _firstGroupTokensLimit ? _bigProcent : _smallProcent;
        uint256 amount = currentBalance * howDelaysAvailable * procent / 100;

        return amount / 12;
    }

    function _getTokenBalance(address holder) private view returns (uint256) {
        return _token.balanceOf(holder);
    }

    function _getLastWithdrawDate(address holder) private view returns (uint256) {
        uint256 lastWithdrawDate = _rewardTimeStamp[holder].lastWithdrawDate;
        if (lastWithdrawDate == 0) {
            lastWithdrawDate = _contractCreationDate;
        }

        return lastWithdrawDate;
    }
}