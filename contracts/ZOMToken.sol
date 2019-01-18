pragma solidity ^0.5.0;

import "./ERC20Mintable.sol";
import "./ERC20Burnable.sol";

/**
 * @title ZOM Token smart contract
 */
contract ZOMToken is ERC20Mintable, ERC20Burnable {
    string private constant _name = "ZOM";
    string private constant _symbol = "ZOM";
    uint8 private constant _decimals = 18;
    uint256 private constant _initialSupply = 50000000 * 1 ether; // 50,000,000.00 ZOM

    constructor () public {
        _mint(msg.sender, initialSupply());
    }

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