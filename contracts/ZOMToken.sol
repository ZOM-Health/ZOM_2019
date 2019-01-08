pragma solidity ^0.5.0;

import "./ERC20Detailed.sol";
import "./ERC20Mintable.sol";
import "./ERC20Burnable.sol";

/**
 * @title ZOM Token smart contract
 */
contract ZOMToken is ERC20Detailed, ERC20Mintable, ERC20Burnable {
    constructor() public {
        _mint(msg.sender, initialSupply());
    }
}