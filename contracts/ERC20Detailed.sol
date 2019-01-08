pragma solidity ^0.5.0;

import "./IERC20.sol";

/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is IERC20 {
    string private constant _name = "ZOM";
    string private constant _symbol = "ZOM";
    uint8 private constant _decimals = 18;
    uint256 private constant _initialSupply = 50000000 * 1 ether; // 50,000,000.00 ZOM

    /**
     * @return the name of the token.
     */
    function name() public pure returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    /**
     * @return the number of initial supply tokens.
     */
    function initialSupply() public pure returns (uint256) {
        return _initialSupply;
    }
}