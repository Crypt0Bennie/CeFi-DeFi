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
address tokenX = 0x78c1b0C915c4FAA5FffA6CAbf0219DA63d7f4cb8; //tokenX WMNT
address tokenY = 0x201EBa5CC46D216Ce6DC03F6a759e8E766e956aE; //tokenY USDT
address LBPool = 0xf6C9020c9E915808481757779EDB53DACEaE2415;
address LBrouter = 0x013e138EF6008ae5FDFDE29700e3f2Bc61d21E3a;
address MoeRewarder = 0x08A62Eb0ef6DbE762774ABF5e18F49671559285b;//Only rewarder for the tokenX/USDT 1 Pool
address Moe = 0x4515A45337F461A11Ff0FE8aBF3c606AE5dC00c9; 
address router = 0xeaEE7EE68874218c3558b40063c42B82D3E7232a;
address public botController;
uint256 public binsAmount;
uint16 binStep = 15;
bool public tokenXDeposit;

function setDpositID(uint256 newDepositID) public payable {
    require(msg.sender == admin, "Only owner can do this");
    CurrentDepositID = newDepositID;
}

function setNumberOfBins(uint256 setNumberBins) public payable {
    require(msg.sender == admin, "Only owner can do this");
    binsAmount = setNumberBins;
}

function transferToAdmin(address Token) public payable {
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

function AddLiquiditytokenY() public payable {    
    uint256 amountX = IERC20(tokenX).balanceOf(address(this));
    uint256 amountY = IERC20(tokenY).balanceOf(address(this));
    uint256 amountXMin = 0;
    uint256 amountYMin = 0;
    uint24 _activeID =ILBPair(LBPool).getActiveId();
    uint256 activeIdDesired = uint256(_activeID);
    int256 deltaIdStart = int256(activeIdDesired);

    deltaIdStart = deltaIdStart - int256(binsAmount);

    int256[] memory deltaIds = new int256[](binsAmount);
    for (uint256 i = 0; i < (binsAmount - 1); i++) {
    deltaIds[i] = deltaIdStart + int256(i);
    }

    uint256 distribution = (10 ** 18) / binsAmount;


    uint256[] memory distributionX = new uint256[](binsAmount);

    for (uint256 i = 0; i < (binsAmount - 1); i++) {
    distributionX[i] = 0;
        if (i == 0) {
            distributionX[0] = 1e18;
        }
    }

    uint256[] memory distributionY = new uint256[](binsAmount);

    for (uint256 i = 0; i < (binsAmount - 1); i++) {
    distributionY[i] = distribution;
    }
    
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
tokenXDeposit = false;
}

function AddLiquiditytokenX() external payable {
       
    uint256 amountX = IERC20(tokenX).balanceOf(address(this));
    uint256 amountY = IERC20(tokenY).balanceOf(address(this));
    uint256 amountXMin = 0;
    uint256 amountYMin = 0;
    uint24 _activeID =ILBPair(LBPool).getActiveId();
    uint256 activeIdDesired = uint256(_activeID);
    int256 deltaIdStart = int256(activeIdDesired);

    int256[] memory deltaIds = new int256[](binsAmount);
    for (uint256 i = 0; i < (binsAmount - 1); i++) {
    uint256 did = i;
    deltaIds[i] = deltaIdStart + int256(did);
    }

    uint256 distribution = 1e18 / binsAmount;

    uint256[] memory distributionX = new uint256[](binsAmount);

    for (uint256 i = 0; i < (binsAmount - 1); i++) {
    distributionX[i] = distribution;
    }

    uint256[] memory distributionY = new uint256[](binsAmount);

    for (uint256 i = 0; i < (binsAmount - 1); i++) {
    distributionY[i] = 0;
    }
    distributionY[0] = 1e18;
    
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
tokenXDeposit = true;
}

function currentID() external view returns(uint256) {

    return CurrentDepositID;}

//Exit Liquidity

function removeFarmtokenY() external payable {
     
uint256 LBTokenAmount;

uint256[] memory amounts = new uint256[](binsAmount);

    for (uint256 i = 0; i < (binsAmount - 1); i++) {
    LBTokenAmount = ILBTokenNFT(LBPool).balanceOf(address(this), CurrentDepositID - i);
    amounts[i] = LBTokenAmount;
    }

uint256[] memory claimid = new uint256[](binsAmount);

    for (uint256 i = 0; i < (binsAmount - 1); i++) {
    claimid[i] = (CurrentDepositID - i);
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
     
uint256 LBTokenAmount;

uint256[] memory amounts = new uint256[](binsAmount);
uint256[] memory claimid = new uint256[](binsAmount);

    for (uint256 i = 0; i < (binsAmount - 1); i++) {
    LBTokenAmount = ILBTokenNFT(LBPool).balanceOf(address(this), (CurrentDepositID + i));
    amounts[i] = LBTokenAmount;
    claimid[i] = (CurrentDepositID + i);
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
    block.timestamp
);

}



function approveTokenRewarder() public payable {

ILBTokenNFT(LBPool).approveForAll(LBrouter, true);
ILBTokenNFT(LBPool).approveForAll(MoeRewarder, true);

}

//Collect Rewards

function collectRewards() public payable {
    uint256 rewardbinsAmount = (binsAmount * 2) + 1;
    uint256 DepositID = CurrentDepositID - binsAmount;
    uint256[] memory claimid = new uint256[](rewardbinsAmount);

    for (uint256 i = 0; i < rewardbinsAmount; i++) {
    claimid[i] = (DepositID + i);
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

}




