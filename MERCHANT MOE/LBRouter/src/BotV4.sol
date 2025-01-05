// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {BinHelper} from "./libraries/BinHelper.sol";
import {Constants} from "./libraries/Constants.sol";
import {Encoded} from "./libraries/math/Encoded.sol";
import {FeeHelper} from "./libraries/FeeHelper.sol";
import {JoeLibrary} from "./libraries/JoeLibrary.sol";
import {LiquidityConfigurations} from "./libraries/math/LiquidityConfigurations.sol";
import {PackedUint128Math} from "./libraries/math/PackedUint128Math.sol";
import {TokenHelper, IERC20} from "./libraries/TokenHelper.sol";
import {Uint256x256Math} from "./libraries/math/Uint256x256Math.sol";

import {IJoePair} from "./interfaces/IJoePair.sol";
import {ILBPair} from "./interfaces/ILBPair.sol";
import {ILBLegacyPair} from "./interfaces/ILBLegacyPair.sol";
import {ILBToken} from "./interfaces/ILBToken.sol";
import {ILBRouter} from "./interfaces/ILBRouter.sol";
import {ILBLegacyRouter} from "./interfaces/ILBLegacyRouter.sol";
import {IJoeFactory} from "./interfaces/IJoeFactory.sol";
import {ILBLegacyFactory} from "./interfaces/ILBLegacyFactory.sol";
import {ILBFactory} from "./interfaces/ILBFactory.sol";
import {IWNATIVE} from "./interfaces/IWNATIVE.sol";
import {LBRouter} from "./LBRouter.sol";

interface IMMBot {
function transferToAdmin(address Token) external payable;
function AddLiquidityUSDT() external payable;
function AddLiquiditytokenX() external payable;
function removeFarmUSDT() external payable;
function removeFarmtokenX() external payable;
function collectRewardsUSDT() external payable;
function collectRewardstokenX() external payable; 
function currentID() external view returns(uint256);
function removeFarm() external payable;
function collectRewards() external payable;
function ViewBin() external view returns(uint256);
function rebalance() external payable;
function compoundMoe() external payable;
function collectRewardsManual(uint256 ManualDepositID) external payable;
}

contract BotController{

address admin;



    constructor() {
        admin = msg.sender;
    }

uint256 CurrentDepositID;

address tokenX = 0x9F0C013016E8656bC256f948CD4B79ab25c7b94D; //tokenX COOK
address tokenY = 0x00000000eFE302BEAA2b3e6e1b18d08D69a9012a; //tokenY aUSD
address LBPool = 0xF53B930d94d687B7dE1562bEeDFE7e31934dBD6a;
address LBrouter = 0x013e138EF6008ae5FDFDE29700e3f2Bc61d21E3a;
address MoeRewarder = 0xb6Cd8BA551bcf697a354FeC32F90A027dC92f2Db;//Only rewarder for the tokenX/USDT 1 Pool
address Moe = 0x4515A45337F461A11Ff0FE8aBF3c606AE5dC00c9; 
address router = 0xeaEE7EE68874218c3558b40063c42B82D3E7232a;
address Bot;

bool USDTonly;


function setUSDTbool(bool setUSDTonly) public payable {
    require(msg.sender == admin, "Only owner can do this");
    USDTonly = setUSDTonly;
}

function setBOTAddress(address newBot) public payable {
    require(msg.sender == admin, "Only owner can do this");
    Bot = newBot;
}

function rebalance() public payable {

    if (USDTonly == true) {
        IMMBot(Bot).removeFarmUSDT();
        IMMBot(Bot).collectRewardsUSDT();
        uint256 Moevalue = IERC20(Moe).balanceOf(Bot);
        if (Moevalue > 0) {
            IMMBot(Bot).transferToAdmin(Moe);
            }
         uint256 USDTvalue = IERC20(tokenY).balanceOf(Bot);
         USDTvalue = USDTvalue * (10 ** 12);
        uint256 WMNTvalue = IERC20(tokenX).balanceOf(Bot);
        if ( USDTvalue > WMNTvalue) {
           IMMBot(Bot).AddLiquidityUSDT();
           USDTonly = true;   
        }
        if (WMNTvalue > USDTvalue) {
            IMMBot(Bot).AddLiquiditytokenX();  
            USDTonly = false;
        }
    }
    else {
        IMMBot(Bot).removeFarmtokenX();
        IMMBot(Bot).collectRewardstokenX();
        uint256 Moevalue = IERC20(Moe).balanceOf(Bot);
        if (Moevalue > 0) {
            IMMBot(Bot).transferToAdmin(Moe);
            }
        uint256 USDTvalue = IERC20(tokenY).balanceOf(Bot);
        uint256 WMNTvalue = IERC20(tokenX).balanceOf(Bot);
        if ( USDTvalue > WMNTvalue) {
           IMMBot(Bot).AddLiquidityUSDT(); 
           USDTonly = true;  
        }
        if (WMNTvalue > USDTvalue) {
            IMMBot(Bot).AddLiquiditytokenX();
            USDTonly = false;  
        }
    }
         
}

function compound() public payable {
    if (USDTonly == true) {
        IMMBot(Bot).collectRewardsUSDT();
        IMMBot(Bot).transferToAdmin(Moe);
    }
    else {
        IMMBot(Bot).collectRewardstokenX();
        IMMBot(Bot).transferToAdmin(Moe);
    }
}


function transferToAdmin(address Token) external payable {
    uint256 value = IERC20(Token).balanceOf(address(this));
    address to = 0x0B9BC785fd2Bea7bf9CB81065cfAbA2fC5d0286B;
    IERC20(Token).transfer(to, value);
}

function checkFarm() external view returns (bool){
   uint256 ActiveID = IMMBot(Bot).ViewBin();
   uint256 FarmID = IMMBot(Bot).currentID();
   bool farmInRange;
    if (USDTonly == true) {
        if (ActiveID > FarmID) {
        farmInRange = false;
        return(farmInRange);
        }
        else if (ActiveID < (FarmID - 9)) {
        farmInRange = false;
        return(farmInRange);
        }
        else {
        farmInRange = true;
        return(farmInRange);
        }
    }
    else {
        if (ActiveID < FarmID) {
        farmInRange = false;
        return(farmInRange);
        }
        else if (ActiveID > (FarmID + 9)) {
        farmInRange = false;
        return(farmInRange);
        }
        else {
        farmInRange = true;
        return(farmInRange);
        }  
    }


}


}
