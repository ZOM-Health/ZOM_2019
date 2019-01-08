pragma solidity ^0.5.0;

import "./Roles.sol";

/**
 * @title MinterRole
 * @dev Only some specific address can mint new tokens
 */
contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function _addMinter(address account) private {
        _minters.add(account);
        emit MinterAdded(account);
    }
}