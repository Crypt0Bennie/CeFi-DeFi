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



interface IMOESwapRouter {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
    }

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

contract MMAutoFarm{

    //https://docs.lfj.gg/guides/add-remove-liquidity

    using TokenHelper for IERC20;
    using JoeLibrary for uint256;
    using PackedUint128Math for bytes32;

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


//Trasfer to and from contract

function transferToAdmin(address Token) external payable {
    uint256 value = IERC20(Token).balanceOf(address(this));
    address to = 0x0B9BC785fd2Bea7bf9CB81065cfAbA2fC5d0286B;
    IERC20(Token).transfer(to, value);
}


//Swap directly with MM
  function SwapWMNTforUSDT(uint256 amountIn) external payable {
        
        IERC20(WMNT).approve(router, amountIn); //Approve Spending

        address[] memory path = new address[](2);
        path[0] = 0x78c1b0C915c4FAA5FffA6CAbf0219DA63d7f4cb8; //WMNT token
        path[1] = 0x201EBa5CC46D216Ce6DC03F6a759e8E766e956aE; //USDT token

        uint256 amountOutMin = 0;
        
        IMOESwapRouter(router).swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            address(this), // Keep the tokens in the contract
            block.timestamp + 300 // deadline in 5 minutes
        );
  }

  function ViewBin() external view returns(uint256) {

    uint24 _activeID =ILBPair(LBPool).getActiveId();
    uint256 activeID = uint256(_activeID);

    return activeID;
  }
//Enter Liquidity


function AddLiquidity() external payable {

    uint256 amountX = IERC20(WMNT).balanceOf(address(this));
    uint256 amountY = IERC20(USDT).balanceOf(address(this));
    uint256 binStep = 15;
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
        IERC20(WMNT).approve(0x013e138EF6008ae5FDFDE29700e3f2Bc61d21E3a, amountX);
        IERC20(USDT).approve(0x013e138EF6008ae5FDFDE29700e3f2Bc61d21E3a, amountY);


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


//(
 //   uint256 amountXAdded,
 //   uint256 amountYAdded,
//    uint256 amountXLeft,
 //   uint256 amountYLeft,
 //   uint256[] memory depositIds,
  ////  uint256[] memory liquidityMinted
//) = 
ILBRouter(LBrouter).addLiquidity(liquidityParameters);

CurrentDepositID = activeIdDesired;


}

function currentID() external view returns(uint256) {

    return CurrentDepositID;}

//Exit Liquidity

function removeFarm() external payable {

uint16 binStep = 15;
uint256 binsAmount = 1;

uint256[] memory amounts = new uint256[](binsAmount);
uint256[] memory claimid = new uint256[](binsAmount);
claimid[0] = CurrentDepositID;


// To figure out amountXMin and amountYMin, we calculate how much X and Y underlying we have as liquidity
    uint256 LBTokenAmount = ILBTokenNFT(0xf6C9020c9E915808481757779EDB53DACEaE2415).balanceOf(address(this), CurrentDepositID);
    amounts[0] = LBTokenAmount;


ILBRouter(0x013e138EF6008ae5FDFDE29700e3f2Bc61d21E3a).removeLiquidity(
    IERC20(0x78c1b0C915c4FAA5FffA6CAbf0219DA63d7f4cb8), // Replace with actual token X address
    IERC20(0x201EBa5CC46D216Ce6DC03F6a759e8E766e956aE), // Replace with actual token Y address
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

ILBTokenNFT(0xf6C9020c9E915808481757779EDB53DACEaE2415).approveForAll(0x013e138EF6008ae5FDFDE29700e3f2Bc61d21E3a, true);
ILBTokenNFT(0xf6C9020c9E915808481757779EDB53DACEaE2415).approveForAll(0x08A62Eb0ef6DbE762774ABF5e18F49671559285b, true);

}

//Collect Rewards

function collectRewards() public payable {
    uint256 binsAmount = 1;

    uint256[] memory claimid = new uint256[](binsAmount);
    claimid[0] = CurrentDepositID;
    IRewarder(0x08A62Eb0ef6DbE762774ABF5e18F49671559285b).claim(address(this), claimid);
}

//Get Bin

    // Function to receive MNT
    receive() external payable {}

}




