pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./IERC20.sol";
import "./ReentrancyGuard.sol";
import "./ZOMToken.sol";

/**
 * @title
 * Last - 1 March 2018
 * Now - 20 April 2018
 */
contract Inflation is ReentrancyGuard {
    using SafeMath for uint256;

    uint8 private constant _smallProcent = 1;
    uint8 private constant _bigProcent = 3;
    uint256 private constant _inflationDelay = 30 seconds; // need to change
    uint256 private constant _firstGroupTokensLimit = 50000 * 1 ether; // 50,000.00 ZOM

    struct Holder {
        uint256 lastWithdrawDate;
        uint256 amountOfWithdraws;
        bool isActive;
    }

    IERC20 private _token;

    mapping(address => Holder) private _inflationTimeStamp;

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
        _token.transfer(msg.sender, _token.totalSupply());
    }

    // -----------------------------------------
    // EXTERNAL
    // -----------------------------------------

    function withdrawInflationTokens() public onlyHolder nonReentrant {
        if (_inflationTimeStamp[msg.sender].isActive == false) {
            _inflationTimeStamp[msg.sender].isActive = true;
            _inflationTimeStamp[msg.sender].lastWithdrawDate = block.timestamp;
        } else {
            uint256 lastWithdrawDate = _inflationTimeStamp[msg.sender].lastWithdrawDate;
            uint256 howDelaysAvailable = (block.timestamp.sub(lastWithdrawDate)).div(_inflationDelay);

            require(howDelaysAvailable > 0, "withdrawInflationTokens: the holder can not withdraw tokens yet!");

            uint256 timeAfterMonthStart = block.timestamp.sub(lastWithdrawDate) % _inflationDelay;
            _inflationTimeStamp[msg.sender].lastWithdrawDate = block.timestamp.sub(timeAfterMonthStart);
        }

        uint256 procentTokens = _calculateInflationTokens(msg.sender);

        _token.mint(msg.sender, procentTokens);
        _inflationTimeStamp[msg.sender].amountOfWithdraws = _inflationTimeStamp[msg.sender].amountOfWithdraws.add(1);

        emit NewTokensMinted(msg.sender, procentTokens);
    }

    // -----------------------------------------
    // GETTERS
    // -----------------------------------------

    function getHolderData(address holder) public view returns (uint256, uint256, uint256, bool) {
        return (
            _getTokenBalance(holder),
            _inflationTimeStamp[holder].lastWithdrawDate,
            _inflationTimeStamp[holder].amountOfWithdraws,
            _inflationTimeStamp[holder].isActive
        );
    }

    function getAvailableInflationTokens(address holder) public view returns (uint256) {
        return _calculateInflationTokens(holder);
    }

    function token() public view returns (address) {
        return address(_token);
    }

    // -----------------------------------------
    // INTERNAL
    // -----------------------------------------

    function _calculateInflationTokens(address holder) internal view returns (uint256) {
        uint256 lastWithdrawDate = _inflationTimeStamp[holder].lastWithdrawDate;
        uint256 howDelaysAvailable = lastWithdrawDate == 0 ? 1 : (block.timestamp.sub(lastWithdrawDate)).div(_inflationDelay);
        uint256 currentBalance = _getTokenBalance(holder);
        uint8 procent = currentBalance >= _firstGroupTokensLimit ? _bigProcent : _smallProcent;
        uint256 amount = currentBalance * howDelaysAvailable * procent / 100;

        return amount;
    }

    function _getTokenBalance(address holder) internal view returns (uint256) {
        return _token.balanceOf(holder);
    }
}