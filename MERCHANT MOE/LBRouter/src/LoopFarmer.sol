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

contract MMAutoFarmV4{

    //https://docs.lfj.gg/guides/add-remove-liquidity

    using TokenHelper for IERC20;
    using JoeLibrary for uint256;
    using PackedUint128Math for bytes32;

address admin;

    constructor() {
        admin = msg.sender;
    }


uint256 CurrentDepositID;
address tokenX = 0x9F0C013016E8656bC256f948CD4B79ab25c7b94D; //tokenX COOK
address tokenY = 0x00000000eFE302BEAA2b3e6e1b18d08D69a9012a; //tokenY aUSD
address LBPool = 0xF53B930d94d687B7dE1562bEeDFE7e31934dBD6a;
address LBrouter = 0x013e138EF6008ae5FDFDE29700e3f2Bc61d21E3a;
address MoeRewarder = 0xb6Cd8BA551bcf697a354FeC32F90A027dC92f2Db;//unique to each pool
address Moe = 0x4515A45337F461A11Ff0FE8aBF3c606AE5dC00c9; 
address router = 0xeaEE7EE68874218c3558b40063c42B82D3E7232a;
uint256 binsAmount;
uint256 BinHolder;
uint256 binStep = 10;

function setDepositID(uint256 newDepositID) public payable {
    require(msg.sender == admin, "Only owner can do this");
    CurrentDepositID = newDepositID;
}

function setNoOfBins(uint256 newBinsAmount) public payable {
    require(msg.sender == admin, "Only owner can do this");
    binsAmount = newBinsAmount;
}

function transferToAdmin(address Token) public payable {
    uint256 value = IERC20(Token).balanceOf(address(this));
    address to = 0x0B9BC785fd2Bea7bf9CB81065cfAbA2fC5d0286B;
    IERC20(Token).transfer(to, value);
}

function compoundMoe() public payable {
        
        uint256 amountIn = IERC20(Moe).balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = 0x4515A45337F461A11Ff0FE8aBF3c606AE5dC00c9; //Moe token
        path[1] = 0x78c1b0C915c4FAA5FffA6CAbf0219DA63d7f4cb8; //WMNT token

        uint256 amountOutMin = 0;

        IERC20(Moe).approve(router, amountIn);

            IMOESwapRouter(router).swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            address(this), // Keep the tokens in the contract
            block.timestamp 
        );
  }


  function ViewBin() external view returns(uint256) {

    uint24 _activeID =ILBPair(LBPool).getActiveId();
    uint256 activeID = uint256(_activeID);

    return activeID;
  }

  function ViewNoOfBins() external view returns(uint256) {
    return binsAmount;
  }

//Enter Liquidity

function AddLiquiditytokenY() public payable {
       
    uint256 amountX = IERC20(tokenX).balanceOf(address(this));
    uint256 amountY = IERC20(tokenY).balanceOf(address(this));
    uint256 amountXMin = 0;
    uint256 amountYMin = 0;
    uint24 _activeID =ILBPair(LBPool).getActiveId();
    uint256 activeIdDesired = uint256(_activeID);

    
    int256[] memory deltaIds = new int256[](binsAmount);
    uint256[] memory distributionX = new uint256[](binsAmount);
    uint256[] memory distributionY = new uint256[](binsAmount);

uint256 totalAmount = 1e18; // Total amount to distribute
uint256 amountPerBin = totalAmount / binsAmount; // Amount per bin


  for (uint256 i = 0; i < binsAmount; i++) {
        deltaIds[i] = -int256(i); // Assign values from 0 to -9
        distributionX[i] = (i == 0) ? 1e18 : 0; // Only first element is 1e18
        distributionY[i] = amountPerBin; // All elements are 1e17
    }

    
    uint256 idSlippage = 0;

    //Approve Tokens
        IERC20(tokenX).approve(0x013e138EF6008ae5FDFDE29700e3f2Bc61d21E3a, amountX);
        IERC20(tokenY).approve(0x013e138EF6008ae5FDFDE29700e3f2Bc61d21E3a, amountY);


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


function AddLiquiditytokenX() external payable {

    uint256 amountX = IERC20(tokenX).balanceOf(address(this));
    uint256 amountY = IERC20(tokenY).balanceOf(address(this));
    uint256 amountXMin = 0;
    uint256 amountYMin = 0;
    uint24 _activeID = ILBPair(LBPool).getActiveId();
    uint256 activeIdDesired = uint256(_activeID);

    int256[] memory deltaIds = new int256[](binsAmount);
    uint256[] memory distributionX = new uint256[](binsAmount);
    uint256[] memory distributionY = new uint256[](binsAmount);

    uint256 totalAmount = 1e18; // Total amount to distribute
    uint256 amountPerBin = totalAmount / binsAmount; // Amount per bin

    for (uint256 i = 0; i < binsAmount; i++) {
        deltaIds[i] = int256(i); // Assign values from 0 to 9
        distributionX[i] = amountPerBin; // All elements are 1e17
        distributionY[i] = (i == 0) ? 1e18 : 0; // Only first element is 1e18
    }

    
    uint256 idSlippage = 0;

    //Approve Tokens
        IERC20(tokenX).approve(0x013e138EF6008ae5FDFDE29700e3f2Bc61d21E3a, amountX);
        IERC20(tokenY).approve(0x013e138EF6008ae5FDFDE29700e3f2Bc61d21E3a, amountY);


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

function removeFarmUSDT() external payable {

uint16 binStep = 10;

uint256[] memory amounts = new uint256[](binsAmount);
uint256[] memory claimid = new uint256[](binsAmount);

   for (uint256 i = 0; i < binsAmount; i++) {
        claimid[i] = CurrentDepositID - i;
        amounts[i] = ILBTokenNFT(LBPool).balanceOf(address(this), claimid[i]);
    }

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

function removeFarmtokenX() external payable {

uint16 binStep = 10;

uint256[] memory amounts = new uint256[](binsAmount);
uint256[] memory claimid = new uint256[](binsAmount);

  for (uint256 i = 0; i < binsAmount; i++) {
        claimid[i] = CurrentDepositID + i;
        amounts[i] = ILBTokenNFT(LBPool).balanceOf(address(this), claimid[i]);
    }

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



function approveTokenRewarder() public payable {

ILBTokenNFT(LBPool).approveForAll(LBrouter, true);
ILBTokenNFT(LBPool).approveForAll(MoeRewarder, true);

}

//Collect Rewards

function collectRewardsUSDT() public payable {
    uint256[] memory claimid = new uint256[](binsAmount);

    for (uint256 i = 0; i < binsAmount; i++) {
        claimid[i] = CurrentDepositID - i;
    }

    IRewarder(MoeRewarder).claim(address(this), claimid);

}

function collectRewardstokenX() public payable {
    uint256[] memory claimid = new uint256[](binsAmount);

  for (uint256 i = 0; i < binsAmount; i++) {
        claimid[i] = CurrentDepositID + i;
    }

    IRewarder(MoeRewarder).claim(address(this), claimid);
}

//Collect Rewards Custom

function collectRewardsManual(uint256 ManualDepositID) public payable {
    uint256 rewardbinsAmount = 1;
    uint256[] memory claimid = new uint256[](rewardbinsAmount);
    claimid[0] = ManualDepositID;
    IRewarder(MoeRewarder).claim(address(this), claimid);
}


  function convertMoe() external payable {
        
        uint256 amountIn = IERC20(Moe).balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = 0x4515A45337F461A11Ff0FE8aBF3c606AE5dC00c9; //Moe token
        path[1] = 0x78c1b0C915c4FAA5FffA6CAbf0219DA63d7f4cb8; //tokenX token

        uint256 amountOutMin = 0;

        IERC20(Moe).approve(router, amountIn);

            IMOESwapRouter(router).swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            address(this), // Keep the tokens in the contract
            block.timestamp 
        );
  }

function removeFarmManual(uint256 ManDepositID) external payable {

uint256 binsAmount = 1;

uint16 binStep = 10;

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




}




