pragma solidity ^0.5.0;

import "./SafeMath.sol"; 
import "./Ownable.sol";
import "./ERC20.sol";
import "./MedicalPass.sol";


contract UpgradePass is Ownable   {
    
    MedicalPass public medicalContract;
    ERC20 public ZOM;
    
    
    uint256 public bronzeToSilver = 600 * 10 ** 18;
    uint256 public bronzeToGold = 1700 * 10 ** 18;
    uint256 public silverToGold = 1200* 10 ** 18;

    uint256 thirtyDaysToUnix=2592000;

     
    constructor (ERC20 _token) public {
        require(address(_token) != address(0), "token is the zero address");
        ZOM = _token;
        
    }

 
     function upgradeMedicalPass(string memory _upgradeTo) public{
        uint256 index = medicalContract.getIndexByAddress(msg.sender);
        uint256 deductToken = 0 ;
        require(index !=0);
        if(compareStrings(_upgradeTo , "silver")){
            uint tokenAllowance = ZOM.allowance(msg.sender, address(this));
             require(tokenAllowance >= bronzeToSilver);
             ZOM.transferFrom(msg.sender, address(this), tokenAllowance);
             medicalContract.renewOrUpgrade(index , "silver" , block.timestamp , block.timestamp+thirtyDaysToUnix);


        }else if(compareStrings(_upgradeTo , "gold")){
            if(compareStrings(medicalContract.getPassTypeByIndex(index) , "bronze")){
                deductToken = bronzeToGold;
            }else if(compareStrings(medicalContract.getPassTypeByIndex(index) , "silver")){
                deductToken = silverToGold;
            }
             uint tokenAllowance = ZOM.allowance(msg.sender, address(this));
             require(tokenAllowance >= deductToken);
             ZOM.transferFrom(msg.sender, address(this), tokenAllowance);
             medicalContract.renewOrUpgrade(index , "gold" , block.timestamp , block.timestamp+thirtyDaysToUnix);
        }else{
            return;
        }
    }
    
       
    function compareStrings (string memory a, string memory b) public view returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))) );
     }
    
}
