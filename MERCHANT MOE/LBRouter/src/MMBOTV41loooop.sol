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
address LBPool = 0xf6C9020c9E915808481757779EDB53DACEaE2415;
address LBrouter = 0x013e138EF6008ae5FDFDE29700e3f2Bc61d21E3a;
address MoeRewarder = 0x08A62Eb0ef6DbE762774ABF5e18F49671559285b;//Only rewarder for the tokenX/USDT 1 Pool
address Moe = 0x4515A45337F461A11Ff0FE8aBF3c606AE5dC00c9; 
address router = 0xeaEE7EE68874218c3558b40063c42B82D3E7232a;
uint256 binsAmount = 10;
uint256 BinHolder;

function setDpositID(uint256 newDepositID) public payable {
    require(msg.sender == admin, "Only owner can do this");
    CurrentDepositID = newDepositID;
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


  function ViewBin() external view returns(uint256) {

    uint24 _activeID =ILBPair(LBPool).getActiveId();
    uint256 activeID = uint256(_activeID);

    return activeID;
  }
//Enter Liquidity

function AddLiquiditytokenY() public payable {
       
    uint256 amountX = IERC20(tokenX).balanceOf(address(this));
    uint256 amountY = IERC20(tokenY).balanceOf(address(this));
    uint256 binStep = 10;
    uint256 amountXMin = 0;
    uint256 amountYMin = 0;
    uint24 _activeID =ILBPair(LBPool).getActiveId();
    uint256 activeIdDesired = uint256(_activeID);

    int256[] memory deltaIds = new int256[](binsAmount);
    deltaIds[0] = 0;
    deltaIds[1] = -1;
    deltaIds[2] = -2;
    deltaIds[3] = -3;
    deltaIds[4] = -4;
    deltaIds[5] = -5;
    deltaIds[6] = -6;
    deltaIds[7] = -7;
    deltaIds[8] = -8;
    deltaIds[9] = -9;

    uint256[] memory distributionX = new uint256[](binsAmount);
    distributionX[0] = 1e18;
    distributionX[1] = 0;
    distributionX[2] = 0;
    distributionX[3] = 0;
    distributionX[4] = 0;
    distributionX[5] = 0;
    distributionX[6] = 0;
    distributionX[7] = 0;
    distributionX[8] = 0;
    distributionX[9] = 0;

    uint256[] memory distributionY = new uint256[](binsAmount);
    distributionY[0] = 1e17;
    distributionY[1] = 1e17;
    distributionY[2] = 1e17;
    distributionY[3] = 1e17;
    distributionY[4] = 1e17;
    distributionY[5] = 1e17;
    distributionY[6] = 1e17;
    distributionY[7] = 1e17;
    distributionY[8] = 1e17;
    distributionY[9] = 1e17;
    
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
    uint256 binStep = 10;
    uint256 amountXMin = 0;
    uint256 amountYMin = 0;
    uint24 _activeID =ILBPair(LBPool).getActiveId();
    uint256 activeIdDesired = uint256(_activeID);

    int256[] memory deltaIds = new int256[](binsAmount);
    deltaIds[0] = 0;
    deltaIds[1] = 1;
    deltaIds[2] = 2;
    deltaIds[3] = 3;
    deltaIds[4] = 4;
    deltaIds[5] = 5;
    deltaIds[6] = 6;
    deltaIds[7] = 7;
    deltaIds[8] = 8;
    deltaIds[9] = 9;


    uint256[] memory distributionX = new uint256[](binsAmount);
    distributionX[0] = 1e17;
    distributionX[1] = 1e17;
    distributionX[2] = 1e17;
    distributionX[3] = 1e17;
    distributionX[4] = 1e17;
    distributionX[5] = 1e17;
    distributionX[6] = 1e17;
    distributionX[7] = 1e17;
    distributionX[8] = 1e17;
    distributionX[9] = 1e17;


    uint256[] memory distributionY = new uint256[](binsAmount);
    distributionY[0] = 1e18;
    distributionY[1] = 0;
    distributionY[2] = 0;
    distributionY[3] = 0;
    distributionY[4] = 0;
    distributionY[5] = 0;
    distributionY[6] = 0;
    distributionY[7] = 0;
    distributionY[8] = 0;
    distributionY[9] = 0;
    
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
claimid[0] = CurrentDepositID;
claimid[1] = CurrentDepositID - 1;
claimid[2] = CurrentDepositID - 2;
claimid[3] = CurrentDepositID - 3;
claimid[4] = CurrentDepositID - 4;
claimid[5] = CurrentDepositID - 5;
claimid[6] = CurrentDepositID - 6;
claimid[7] = CurrentDepositID - 7;
claimid[8] = CurrentDepositID - 8;
claimid[9] = CurrentDepositID - 9;

// To figure out amountXMin and amountYMin, we calculate how much X and Y underlying we have as liquidity
    amounts[0] = ILBTokenNFT(LBPool).balanceOf(address(this), CurrentDepositID);
    amounts[1] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID - 1));
    amounts[2] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID - 2));
    amounts[3] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID - 3));
    amounts[4] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID - 4));
    amounts[5] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID - 5));
    amounts[6] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID - 6));
    amounts[7] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID - 7));
    amounts[8] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID - 8));
    amounts[9] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID - 9));

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

claimid[0] = CurrentDepositID;
claimid[1] = CurrentDepositID + 1;
claimid[2] = CurrentDepositID + 2;
claimid[3] = CurrentDepositID + 3;
claimid[4] = CurrentDepositID + 4;
claimid[5] = CurrentDepositID + 5;
claimid[6] = CurrentDepositID + 6;
claimid[7] = CurrentDepositID + 7;
claimid[8] = CurrentDepositID + 8;
claimid[9] = CurrentDepositID + 9;


amounts[0] = ILBTokenNFT(LBPool).balanceOf(address(this), CurrentDepositID);
amounts[1] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID + 1));
amounts[2] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID + 2));
amounts[3] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID + 3));
amounts[4] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID + 4));
amounts[5] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID + 5));
amounts[6] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID + 6));
amounts[7] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID + 7));
amounts[8] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID + 8));
amounts[9] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID + 9));

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
    uint256 rewardbinsAmount = 10;
    uint256[] memory claimid = new uint256[](rewardbinsAmount);
    claimid[0] = CurrentDepositID;
    claimid[1] = CurrentDepositID - 1;
    claimid[2] = CurrentDepositID - 2;
    claimid[3] = CurrentDepositID - 3;
    claimid[4] = CurrentDepositID - 4;
    claimid[5] = CurrentDepositID - 5;
    claimid[6] = CurrentDepositID - 6;
    claimid[7] = CurrentDepositID - 7;
    claimid[8] = CurrentDepositID - 8;
    claimid[9] = CurrentDepositID - 9;

    IRewarder(MoeRewarder).claim(address(this), claimid);

}

function collectRewardstokenX() public payable {
    uint256 rewardbinsAmount = 10;
    uint256[] memory claimid = new uint256[](rewardbinsAmount);
    claimid[0] = CurrentDepositID;
    claimid[1] = CurrentDepositID + 1;
    claimid[2] = CurrentDepositID + 2;
    claimid[3] = CurrentDepositID + 3;
    claimid[4] = CurrentDepositID + 4;
    claimid[5] = CurrentDepositID + 5;
    claimid[6] = CurrentDepositID + 6;
    claimid[7] = CurrentDepositID + 7;
    claimid[8] = CurrentDepositID + 8;
    claimid[9] = CurrentDepositID + 9;
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




