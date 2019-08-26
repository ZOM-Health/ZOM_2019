pragma solidity ^0.5.0;

contract Ownable {
   address payable public owner;

   event OwnershipTransferred(address indexed _from, address indexed _to);

   constructor() public {
       owner = msg.sender;
   }

   modifier onlyOwner {
       require(msg.sender == owner);
       _;
   }

   function transferOwnership(address payable _newOwner) public onlyOwner {
       owner = _newOwner;
   }
}


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract ERC20 {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

    
contract MedicalPass is Ownable   {
    
    using SafeMath for uint256;
    ERC20 public ZOM;

    
    struct Pass {
        string passType;
        address owner;
        uint256 issuedTimestamp;
        uint256 expiryTimestamp;
    }

    uint256 bronzePass = 500 * 10 * 18;
    uint256 silverPass = 1000* 10 * 18;
    uint256 goldPass = 2000* 10 * 18;
    
    uint256 thirtyDaysToUnix=2592000;
    
   
    Pass[] public issuedPasses;
    mapping(address => uint256) private addressToPass;

    
    constructor (ERC20 _token) public {
        require(address(_token) != address(0), "token is the zero address");
        ZOM = _token;
        
        Pass memory newPass = Pass("" , address(0) , 0 , 0);
        issuedPasses.push(newPass);
        addressToPass[msg.sender] = issuedPasses.length -1 ;
    }


    function buyBronzePass ()public {
        uint tokenAllowance = ZOM.allowance(msg.sender, address(this));
        require(tokenAllowance >= bronzePass);
        ZOM.transferFrom(msg.sender, address(this), tokenAllowance);
        
        Pass memory newPass = Pass("bronze" , msg.sender , block.timestamp , block.timestamp+thirtyDaysToUnix);
        issuedPasses.push(newPass);
        addressToPass[msg.sender] = issuedPasses.length -1 ;
    }
    
       function buySilverPass ()public {
        uint tokenAllowance = ZOM.allowance(msg.sender, address(this));
        require(tokenAllowance >= silverPass);
        ZOM.transferFrom(msg.sender, address(this), tokenAllowance);
        
        Pass memory newPass = Pass("silver" , msg.sender , block.timestamp , block.timestamp+thirtyDaysToUnix);
        issuedPasses.push(newPass);
        addressToPass[msg.sender] = issuedPasses.length -1 ;
    }
    
    
    function buyGoldPass ()public {
        uint tokenAllowance = ZOM.allowance(msg.sender, address(this));
        require(tokenAllowance >= goldPass);
        ZOM.transferFrom(msg.sender, address(this), tokenAllowance);
        
        Pass memory newPass = Pass("gold" , msg.sender , block.timestamp , block.timestamp+thirtyDaysToUnix);
        issuedPasses.push(newPass);
        addressToPass[msg.sender] = issuedPasses.length -1 ;
    }
    
    function compareStrings (string memory a, string memory b) public view returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))) );
       }
    
    function upgradePass(string memory _upgradeTo) public{
        uint256 index = getIndexByAddress(msg.sender);
        require(index !=0);
        if(compareStrings(_upgradeTo , "silver")){
            uint tokenAllowance = ZOM.allowance(msg.sender, address(this));
             require(tokenAllowance >= silverPass);
             ZOM.transferFrom(msg.sender, address(this), tokenAllowance);
             issuedPasses[index].passType = "silver";
             issuedPasses[index].issuedTimestamp = block.timestamp;
             issuedPasses[index].expiryTimestamp= block.timestamp + thirtyDaysToUnix;

        }else if(compareStrings(_upgradeTo , "gold")){
             uint tokenAllowance = ZOM.allowance(msg.sender, address(this));
             require(tokenAllowance >= goldPass);
             ZOM.transferFrom(msg.sender, address(this), tokenAllowance);
             issuedPasses[index].passType = "gold";
             issuedPasses[index].issuedTimestamp = block.timestamp;
             issuedPasses[index].expiryTimestamp= block.timestamp + thirtyDaysToUnix;
        }else{
            return;
        }
    }
    
    function renewPass() public {
        uint256 index = getIndexByAddress(msg.sender);
        require(index !=0);
        if(compareStrings(issuedPasses[index].passType, "bronze")){
            
             uint tokenAllowance = ZOM.allowance(msg.sender, address(this));
             require(tokenAllowance >= bronzePass);
             ZOM.transferFrom(msg.sender, address(this), tokenAllowance);
             issuedPasses[index].passType = "bronze";
             issuedPasses[index].issuedTimestamp = block.timestamp;
             issuedPasses[index].expiryTimestamp= block.timestamp + thirtyDaysToUnix;
             
        } else if(compareStrings(issuedPasses[index].passType, "silver")){
            
             uint tokenAllowance = ZOM.allowance(msg.sender, address(this));
             require(tokenAllowance >= silverPass);
             ZOM.transferFrom(msg.sender, address(this), tokenAllowance);
             issuedPasses[index].passType = "silver";
             issuedPasses[index].issuedTimestamp = block.timestamp;
             issuedPasses[index].expiryTimestamp= block.timestamp + thirtyDaysToUnix;
             
        } else if(compareStrings(issuedPasses[index].passType, "gold")){
            
             uint tokenAllowance = ZOM.allowance(msg.sender, address(this));
             require(tokenAllowance >= goldPass);
             ZOM.transferFrom(msg.sender, address(this), tokenAllowance);
             issuedPasses[index].passType = "goldPass";
             issuedPasses[index].issuedTimestamp = block.timestamp;
             issuedPasses[index].expiryTimestamp= block.timestamp + thirtyDaysToUnix;
        } 

    }
    
    function getIndexByAddress(address owner) public view returns(uint256){
        return addressToPass[owner];
    }
    
      
}
