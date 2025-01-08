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
address tokenX = 0x78c1b0C915c4FAA5FffA6CAbf0219DA63d7f4cb8; //tokenX tokenX
address tokenY = 0x201EBa5CC46D216Ce6DC03F6a759e8E766e956aE; //tokenY USDT
address LBPool = 0xf6C9020c9E915808481757779EDB53DACEaE2415;
address LBrouter = 0x013e138EF6008ae5FDFDE29700e3f2Bc61d21E3a;
address MoeRewarder = 0x08A62Eb0ef6DbE762774ABF5e18F49671559285b;//Only rewarder for the tokenX/USDT 1 Pool
address Moe = 0x4515A45337F461A11Ff0FE8aBF3c606AE5dC00c9; 
address router = 0xeaEE7EE68874218c3558b40063c42B82D3E7232a;
address public botController;
uint256 binsAmount = 20;
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

function AddLiquidityUSDT() public payable {
       
    uint256 amountX = IERC20(tokenX).balanceOf(address(this));
    uint256 amountY = IERC20(tokenY).balanceOf(address(this));
    uint256 binStep = 15;
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
    deltaIds[10] = -10;
    deltaIds[11] = -11;
    deltaIds[12] = -12;
    deltaIds[13] = -13;
    deltaIds[14] = -14;
    deltaIds[15] = -15;
    deltaIds[16] = -16;
    deltaIds[17] = -17;
    deltaIds[18] = -18;
    deltaIds[19] = -19;

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
    distributionX[10] = 0;
    distributionX[12] = 0;
    distributionX[13] = 0;
    distributionX[14] = 0;
    distributionX[15] = 0;
    distributionX[16] = 0;
    distributionX[17] = 0;
    distributionX[18] = 0;
    distributionX[19] = 0;

    uint256[] memory distributionY = new uint256[](binsAmount);
    distributionY[0] = 5e16;
    distributionY[1] = 5e16;
    distributionY[2] = 5e16;
    distributionY[3] = 5e16;
    distributionY[4] = 5e16;
    distributionY[5] = 5e16;
    distributionY[6] = 5e16;
    distributionY[7] = 5e16;
    distributionY[8] = 5e16;
    distributionY[9] = 5e16;
    distributionY[10] = 5e16;
    distributionY[11] = 5e16;
    distributionY[12] = 5e16;
    distributionY[13] = 5e16;
    distributionY[14] = 5e16;
    distributionY[15] = 5e16;
    distributionY[16] = 5e16;
    distributionY[17] = 5e16;
    distributionY[18] = 5e16;
    distributionY[19] = 5e16;
    
    uint256 idSlippage = 0;

    //Approve Tokens
        IERC20(tokenX).approve(0x013e138EF6008ae5FDFDE29700e3f2Bc61d21E3a, amountX);
        IERC20(tokenY).approve(0x013e138EF6008ae5FDFDE29700e3f2Bc61d21E3a, amountY);


ILBRouter.LiquidityParameters memory liquidityParameters = ILBRouter.LiquidityParameters(
        IERC20(0x78c1b0C915c4FAA5FffA6CAbf0219DA63d7f4cb8), // Replace with actual token X address
        IERC20(0x201EBa5CC46D216Ce6DC03F6a759e8E766e956aE), // Replace with actual token Y address
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
    uint256 binsAmount = 10;
    uint256 amountX = IERC20(tokenX).balanceOf(address(this));
    uint256 amountY = IERC20(tokenY).balanceOf(address(this));
    uint256 binStep = 15;
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

uint16 binStep = 15;

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
claimid[10] = CurrentDepositID -10;
claimid[11] = CurrentDepositID - 11;
claimid[12] = CurrentDepositID - 12;
claimid[13] = CurrentDepositID - 13;
claimid[14] = CurrentDepositID - 14;
claimid[15] = CurrentDepositID - 15;
claimid[16] = CurrentDepositID - 16;
claimid[17] = CurrentDepositID - 17;
claimid[18] = CurrentDepositID - 18;
claimid[19] = CurrentDepositID - 19;

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
    amounts[10] = ILBTokenNFT(LBPool).balanceOf(address(this), CurrentDepositID - 10);
    amounts[11] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID - 11));
    amounts[12] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID - 12));
    amounts[13] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID - 13));
    amounts[14] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID - 14));
    amounts[15] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID - 15));
    amounts[16] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID - 16));
    amounts[17] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID - 17));
    amounts[18] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID - 18));
    amounts[19] = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID - 19));

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
    uint256 binsAmount = 10;
uint16 binStep = 15;


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
    uint256 rewardbinsAmount = 20;
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
claimid[10] = CurrentDepositID -10;
claimid[11] = CurrentDepositID - 11;
claimid[12] = CurrentDepositID - 12;
claimid[13] = CurrentDepositID - 13;
claimid[14] = CurrentDepositID - 14;
claimid[15] = CurrentDepositID - 15;
claimid[16] = CurrentDepositID - 16;
claimid[17] = CurrentDepositID - 17;
claimid[18] = CurrentDepositID - 18;
claimid[19] = CurrentDepositID - 19;

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
uint16 binStep = 15;

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

  //Swap directly with MM
  function converttokenX() external payable {
        
        uint256 amountIn = IERC20(tokenX).balanceOf(address(this));
        IERC20[] memory tokenPath = new IERC20[](2);
        tokenPath[0] = IERC20(tokenX);
        tokenPath[1] = IERC20(tokenY);
        uint128 amountOut = 0;
        IERC20(tokenX).approve(LBrouter, amountIn);

        uint256[] memory pairBinSteps = new uint256[](1); // pairBinSteps[i] refers to the bin step for the market (x, y) where tokenPath[i] = x and tokenPath[i+1] = y
        pairBinSteps[0] = 15;

        ILBRouter.Version[] memory versions = new ILBRouter.Version[](1);
        versions[0] = ILBRouter.Version.V2_2; // add the version of the Dex to perform the swap on

        ILBRouter.Path memory path; // instanciate and populate the path to perform the swap.
        path.pairBinSteps = pairBinSteps;
        path.versions = versions;
        path.tokenPath = tokenPath;

    
        ILBRouter(LBrouter).swapExactTokensForTokens(amountIn, amountOut, path, address(this), block.timestamp + 1);
  }


}




