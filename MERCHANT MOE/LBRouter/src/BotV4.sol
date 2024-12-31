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
function AddLiquidity() external payable;
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

address WMNT = 0x78c1b0C915c4FAA5FffA6CAbf0219DA63d7f4cb8; //tokenX
address USDT = 	0x201EBa5CC46D216Ce6DC03F6a759e8E766e956aE; //tokenY
address router = 0xeaEE7EE68874218c3558b40063c42B82D3E7232a;
address LBPool = 0xf6C9020c9E915808481757779EDB53DACEaE2415;
address LBrouter = 0x013e138EF6008ae5FDFDE29700e3f2Bc61d21E3a;
address MoeRewarder = 0x08A62Eb0ef6DbE762774ABF5e18F49671559285b; //Only rewarder for the WMNT/JOE 25 Pool
address Moe = 0x4515A45337F461A11Ff0FE8aBF3c606AE5dC00c9;
address Bot = 0xe3c5Eca3cFb3D8Cfbf22cE97CD7bDdc06C4E9141;




function rebalance() public payable {
        uint256 Bin = IMMBot(Bot).currentID();
        IMMBot(Bot).removeFarm();
        IMMBot(Bot).collectRewardsManual(Bin);
        IMMBot(Bot).collectRewardsManual(Bin - 1);
        IMMBot(Bot).collectRewardsManual(Bin - 2);
        uint256 Moevalue = IERC20(Moe).balanceOf(Bot);
        if (Moevalue > 0) {
            IMMBot(Bot).compoundMoe();
            }
        uint256 WMNTvalue = IERC20(WMNT).balanceOf(Bot);
        if (WMNTvalue > 0) {
            IMMBot(Bot).rebalance();
            }
        IMMBot(Bot).AddLiquidity();     
}

function compound() public payable {
    IMMBot(Bot).collectRewards();
    uint256 Moevalue = IERC20(Moe).balanceOf(Bot);
    if (Moevalue > 0) {
        IMMBot(Bot).compoundMoe();
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

       if (ActiveID > FarmID) {
        farmInRange = false;
        return(farmInRange);
        }

        else if (ActiveID < (FarmID - 2)) {
        farmInRange = false;
        return(farmInRange);
        }
        else {
        farmInRange = true;
        return(farmInRange);
        }

}


}
