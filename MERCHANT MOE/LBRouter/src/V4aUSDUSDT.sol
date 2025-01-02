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





interface ILBTokenNFT {
    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    function isApprovedForAll(address owner, address spender) external view returns (bool);

    function approveForAll(address spender, bool approved) external;
}

interface IRewarder {
    function claim(address user, uint256[] calldata ids) external;
    }

    interface IMOESwapRouter {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
    }

contract MMAutoFarmSTABLE{

    //https://docs.lfj.gg/guides/add-remove-liquidity

    using TokenHelper for IERC20;
    using JoeLibrary for uint256;
    using PackedUint128Math for bytes32;

address admin;
bool pause;

    constructor() {
        admin = msg.sender;
    }


uint256 CurrentDepositID;
address tokenX = 0xD2B4C9B0d70e3Da1fBDD98f469bD02E77E12FC79; //tokenX aUSD
address tokenY = 0x201EBa5CC46D216Ce6DC03F6a759e8E766e956aE; //tokenY USDT
uint16 binStep = 1; //Change based on pool
address LBPool = 0x2d7Bf73AA7A5806f56E785CCec2c9a60C53F9D10; //Unique to each pool
address LBrouter = 0x013e138EF6008ae5FDFDE29700e3f2Bc61d21E3a;
address MoeRewarder = 0x728eE7f032f8eA494b185138A3383598b573dA60;//Unique to each pool
address Moe = 0x4515A45337F461A11Ff0FE8aBF3c606AE5dC00c9; 
address WMNT = 0x78c1b0C915c4FAA5FffA6CAbf0219DA63d7f4cb8; 
address router = 0xeaEE7EE68874218c3558b40063c42B82D3E7232a;

function setDpositID(uint256 newDepositID) public payable {
    require(msg.sender == admin, "Only owner can do this");
    CurrentDepositID = newDepositID;
}


//Trasfer to and from contract

function transferToAdmin(address Token) external payable {
    uint256 value = IERC20(Token).balanceOf(address(this));
    address to = 0x0B9BC785fd2Bea7bf9CB81065cfAbA2fC5d0286B;
    IERC20(Token).transfer(to, value);
}


  function ViewBin() external view returns(uint256) {

    uint24 _activeID =ILBPair(LBPool).getActiveId();
    uint256 activeID = uint256(_activeID);

    return activeID;
  }
//Enter Liquidity


function AddLiquidity() external payable {
       
    uint256 amountX = IERC20(tokenX).balanceOf(address(this));
    uint256 amountY = IERC20(tokenY).balanceOf(address(this));
    uint256 amountXMin = 0;
    uint256 amountYMin = 0;
    uint24 _activeID =ILBPair(LBPool).getActiveId();
    uint256 activeIdDesired = uint256(_activeID);
    uint256 binsAmount = 1;
    int256[] memory deltaIds = new int256[](binsAmount);
    deltaIds[0] = 0;
    uint256[] memory distributionX = new uint256[](binsAmount);
    distributionX[0] = 1e18;
    uint256[] memory distributionY = new uint256[](binsAmount);
    distributionY[0] = 1e18;
    uint256 idSlippage = 0;

    //Approve Tokens
        IERC20(tokenX).approve(LBrouter, amountX);
        IERC20(tokenY).approve(LBrouter, amountY);


        ILBRouter.LiquidityParameters memory liquidityParameters = ILBRouter.LiquidityParameters(
        IERC20(tokenX), // Replace with actual token X address
        IERC20(tokenY), // Replace with actual token Y address
        binStep,           // Replace with appropriate bin step
        amountX,           // Replace with desired amount of token X
        amountY,           // Replace with desired amount of token Y
        amountXMin,
        amountYMin,
        activeIdDesired,
        idSlippage,
        deltaIds,
        distributionX,
        distributionY,
        address(this),
        address(this),
        block.timestamp + 300 // deadline in 5 minutes
        );

ILBRouter(LBrouter).addLiquidity(liquidityParameters);

CurrentDepositID = activeIdDesired;
}

function currentID() external view returns(uint256) {

    return CurrentDepositID;}

//Exit Liquidity

function removeFarm() external payable {

uint256 binsAmount = 1;

uint256[] memory amounts = new uint256[](binsAmount);
uint256[] memory claimid = new uint256[](binsAmount);
claimid[0] = CurrentDepositID;


// To figure out amountXMin and amountYMin, we calculate how much X and Y underlying we have as liquidity
    uint256 LBTokenAmount = ILBTokenNFT(LBPool).balanceOf(address(this), CurrentDepositID);
    amounts[0] = LBTokenAmount;


ILBRouter(LBrouter).removeLiquidity( 
    IERC20(tokenX), // Replace with actual token X address
    IERC20(tokenY), // Replace with actual token Y address
    binStep,
    0,
    0,
    claimid,
    amounts,
    address(this),
    block.timestamp + 300
);

}

function removeFarmManual(uint256 ManDepositID) external payable {

uint256 binsAmount = 1;

uint256[] memory amounts = new uint256[](binsAmount);
uint256[] memory Manclaimid = new uint256[](binsAmount);
Manclaimid[0] = ManDepositID;


// To figure out amountXMin and amountYMin, we calculate how much X and Y underlying we have as liquidity
    uint256 LBTokenAmount = ILBTokenNFT(LBPool).balanceOf(address(this), ManDepositID);
    amounts[0] = LBTokenAmount;


ILBRouter(LBrouter).removeLiquidity( 
    IERC20(tokenX), // Replace with actual token X address
    IERC20(tokenY), // Replace with actual token Y address
    binStep,
    0,
    0,
    Manclaimid,
    amounts,
    address(this),
    block.timestamp + 300
);

}

function approveTokenRewarder() public payable {

ILBTokenNFT(LBPool).approveForAll(LBrouter, true);
ILBTokenNFT(LBPool).approveForAll(MoeRewarder, true);

}

//Collect Rewards

function collectRewards() public payable {
    uint256 rewardbinsAmount = 1;
    uint256[] memory claimid = new uint256[](rewardbinsAmount);
    claimid[0] = CurrentDepositID;
    IRewarder(MoeRewarder).claim(address(this), claimid);
}

//Collect Rewards Custom

function collectRewardsManual(uint256 ManualDepositID) public payable {
    uint256 rewardbinsAmount = 1;
    uint256[] memory claimid = new uint256[](rewardbinsAmount);
    claimid[0] = ManualDepositID;
    IRewarder(MoeRewarder).claim(address(this), claimid);
}

    // Function to receive MNT
    receive() external payable {}

}




