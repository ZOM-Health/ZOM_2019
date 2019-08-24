pragma solidity ^0.5.0;

/**
 * @dev Multiownable smart contract
 * which allows to many ETH wallets to manage main smart contract.
 */
contract Multiownable {
    // VARIABLES

    uint256 internal _ownersGeneration;
    uint256 internal _howManyOwnersDecide;
    address[] internal _owners;
    bytes32[] internal _allOperations;
    address internal _insideCallSender;
    uint256 internal _insideCallCount;

    // Reverse lookup tables for owners and allOperations
    mapping(address => uint256) public ownersIndices; // Starts from 1
    mapping(bytes32 => uint256) public allOperationsIndicies;

    // Owners voting mask per operations
    mapping(bytes32 => uint256) public votesMaskByOperation;
    mapping(bytes32 => uint256) public votesCountByOperation;

    // EVENTS

    event OwnershipTransferred(address[] previousOwners, uint256 howManyOwnersDecide, address[] newOwners, uint256 newHowManyOwnersDecide);
    event OperationCreated(bytes32 operation, uint256 howMany, uint256 ownersCount, address proposer);
    event OperationUpvoted(bytes32 operation, uint256 votes, uint256 howMany, uint256 ownersCount, address upvoter);
    event OperationPerformed(bytes32 operation, uint256 howMany, uint256 ownersCount, address performer);
    event OperationDownvoted(bytes32 operation, uint256 votes, uint256 ownersCount,  address downvoter);
    event OperationCancelled(bytes32 operation, address lastCanceller);

    // ACCESSORS

    function isOwner(address wallet) external view returns (bool) {
        return ownersIndices[wallet] > 0;
    }

    function ownersCount() external view returns (uint256) {
        return _owners.length;
    }

    function allOperationsCount() external view returns (uint256) {
        return _allOperations.length;
    }

    // MODIFIERS

    /**
     * @dev Allows to perform method by any of the owners
     */
    modifier onlyAnyOwner {
        if (checkHowManyOwners(1)) {
            bool update = (_insideCallSender == address(0));
            if (update) {
                _insideCallSender = msg.sender;
                _insideCallCount = 1;
            }
            _;
            if (update) {
                _insideCallSender = address(0);
                _insideCallCount = 0;
            }
        }
    }

    /**
     * @dev Allows to perform method only after many owners call it with the same arguments
     */
    modifier onlyManyOwners {
        if (checkHowManyOwners(_howManyOwnersDecide)) {
            bool update = (_insideCallSender == address(0));
            if (update) {
                _insideCallSender = msg.sender;
                _insideCallCount = _howManyOwnersDecide;
            }
            _;
            if (update) {
                _insideCallSender = address(0);
                _insideCallCount = 0;
            }
        }
    }

    /**
     * @dev Allows to perform method only after all owners call it with the same arguments
     */
    modifier onlyAllOwners {
        if (checkHowManyOwners(_owners.length)) {
            bool update = (_insideCallSender == address(0));
            if (update) {
                _insideCallSender = msg.sender;
                _insideCallCount = _owners.length;
            }
            _;
            if (update) {
                _insideCallSender = address(0);
                _insideCallCount = 0;
            }
        }
    }

    /**
     * @dev Allows to perform method only after some owners call it with the same arguments
     */
    modifier onlySomeOwners(uint256 howMany) {
        require(howMany > 0, "onlySomeOwners: howMany argument is zero");
        require(howMany <= _owners.length, "onlySomeOwners: howMany argument exceeds the number of owners");

        if (checkHowManyOwners(howMany)) {
            bool update = (_insideCallSender == address(0));
            if (update) {
                _insideCallSender = msg.sender;
                _insideCallCount = howMany;
            }
            _;
            if (update) {
                _insideCallSender = address(0);
                _insideCallCount = 0;
            }
        }
    }

    // CONSTRUCTOR

    constructor() public {
        _owners.push(msg.sender);
        ownersIndices[msg.sender] = 1;
        _howManyOwnersDecide = 1;
    }

    // INTERNAL METHODS

    /**
     * @dev onlyManyOwners modifier helper
     */
    function checkHowManyOwners(uint256 howMany) internal returns (bool) {
        if (_insideCallSender == msg.sender) {
            require(howMany <= _insideCallCount, "checkHowManyOwners: nested owners modifier check require more owners");
            return true;
        }

        uint256 ownerIndex = ownersIndices[msg.sender] - 1;
        require(ownerIndex < _owners.length, "checkHowManyOwners: msg.sender is not an owner");

        bytes32 operation = keccak256(abi.encodePacked(msg.data, _ownersGeneration));
        require((votesMaskByOperation[operation] & (2 ** ownerIndex)) == 0, "checkHowManyOwners: owner already voted for the operation");

        votesMaskByOperation[operation] |= (2 ** ownerIndex);
        uint256 operationVotesCount = votesCountByOperation[operation] + 1;
        votesCountByOperation[operation] = operationVotesCount;

        if (operationVotesCount == 1) {
            allOperationsIndicies[operation] = _allOperations.length;
            _allOperations.push(operation);
            emit OperationCreated(operation, howMany, _owners.length, msg.sender);
        }

        emit OperationUpvoted(operation, operationVotesCount, howMany, _owners.length, msg.sender);

        // If enough owners confirmed the same operation
        if (votesCountByOperation[operation] == howMany) {
            deleteOperation(operation);
            emit OperationPerformed(operation, howMany, _owners.length, msg.sender);
            return true;
        }

        return false;
    }

    /**
     * @dev Used to delete cancelled or performed operation
     * @param operation defines which operation to delete
     */
    function deleteOperation(bytes32 operation) internal {
        uint256 index = allOperationsIndicies[operation];

        if (index < _allOperations.length - 1) { // Not last
            _allOperations[index] = _allOperations[_allOperations.length - 1];
            allOperationsIndicies[_allOperations[index]] = index;
        }

        _allOperations.length--;

        delete votesMaskByOperation[operation];
        delete votesCountByOperation[operation];
        delete allOperationsIndicies[operation];
    }

    // PUBLIC METHODS

    /**
     * @dev Allows owners to change their mind by cacnelling votesMaskByOperation operations
     * @param operation defines which operation to delete
     */
    function cancelPending(bytes32 operation) external onlyAnyOwner {
        uint256 ownerIndex = ownersIndices[msg.sender] - 1;
        require((votesMaskByOperation[operation] & (2 ** ownerIndex)) != 0, "cancelPending: operation not found for this user");

        votesMaskByOperation[operation] &= ~(2 ** ownerIndex);
        uint256 operationVotesCount = votesCountByOperation[operation] - 1;
        votesCountByOperation[operation] = operationVotesCount;

        emit OperationDownvoted(operation, operationVotesCount, _owners.length, msg.sender);

        if (operationVotesCount == 0) {
            deleteOperation(operation);
            emit OperationCancelled(operation, msg.sender);
        }
    }

    /**
     * @dev Allows owners to change ownership
     * @param newOwners defines array of addresses of new owners
     */
    function transferOwnership(address[] calldata newOwners) external {
        transferOwnershipWithHowMany(newOwners, newOwners.length);
    }

    /**
     * @dev Allows owners to change ownership
     * @param newOwners defines array of addresses of new owners
     * @param newHowManyOwnersDecide defines how many owners can decide
     */
    function transferOwnershipWithHowMany(address[] memory newOwners, uint256 newHowManyOwnersDecide) public onlyManyOwners {
        require(newOwners.length > 0, "transferOwnershipWithHowMany: owners array is empty");
        require(newOwners.length <= 256, "transferOwnershipWithHowMany: owners count is greater then 256");
        require(newHowManyOwnersDecide > 0, "transferOwnershipWithHowMany: newHowManyOwnersDecide equal to 0");
        require(newHowManyOwnersDecide <= newOwners.length, "transferOwnershipWithHowMany: newHowManyOwnersDecide exceeds the number of owners");

        // Reset owners reverse lookup table
        for (uint256 j = 0; j < _owners.length; j++) {
            delete ownersIndices[_owners[j]];
        }

        for (uint256 i = 0; i < newOwners.length; i++) {
            require(newOwners[i] != address(0), "transferOwnershipWithHowMany: owners array contains zero");
            require(ownersIndices[newOwners[i]] == 0, "transferOwnershipWithHowMany: owners array contains duplicates");
            ownersIndices[newOwners[i]] = i + 1;
        }

        emit OwnershipTransferred(_owners, _howManyOwnersDecide, newOwners, newHowManyOwnersDecide);

        _owners = newOwners;
        _howManyOwnersDecide = newHowManyOwnersDecide;
        _allOperations.length = 0;
        _ownersGeneration++;
    }

    // GETTERS

    function getOwnersGeneration() external view returns (uint256) {
        return _ownersGeneration;
    }
    
    function getHowManyOwnersDecide() external view returns (uint256) {
        return _howManyOwnersDecide;
    }

    function getInsideCallSender() external view returns (address) {
        return _insideCallSender;
    }

    function getInsideCallCount() external view returns (uint256) {
        return _insideCallCount;
    }

    function getOwners() external view returns(address [] memory) {
        return _owners;
    }

    function getAllOperations() external view returns (bytes32 [] memory) {
        return _allOperations;
    }
}