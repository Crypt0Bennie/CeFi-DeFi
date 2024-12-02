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

contract MMAutoFarm{

    //https://docs.lfj.gg/guides/add-remove-liquidity

    using TokenHelper for IERC20;
    using JoeLibrary for uint256;
    using PackedUint128Math for bytes32;

address admin;

    constructor() {
        admin = msg.sender;
    }


address WMNT = 0x78c1b0C915c4FAA5FffA6CAbf0219DA63d7f4cb8; //tokenY
address JOE = 0x371c7ec6D8039ff7933a2AA28EB827Ffe1F52f07; //tokenX
address router = 0xeaEE7EE68874218c3558b40063c42B82D3E7232a;
address joeWMNTpool = 0xeBCf4786cd1A47FE6A8ca75Af674aDd06c84f4b4;
address LBrouter = 0x013e138EF6008ae5FDFDE29700e3f2Bc61d21E3a;


//Trasfer to and from contract

function transferToAdmin(address Token) external payable {
    uint256 value = IERC20(Token).balanceOf(address(this));
    address to = 0x0B9BC785fd2Bea7bf9CB81065cfAbA2fC5d0286B;
    IERC20(Token).transfer(to, value);
}


  function ViewBin() external view returns(uint256) {

    uint24 _activeID =ILBPair(joeWMNTpool).getActiveId();
    uint256 activeID = uint256(_activeID);

    return activeID;
  }

    function ViewNFTs() external view returns(uint256) {

    uint24 _activeID =ILBPair(joeWMNTpool).getActiveId();
    uint256 activeID = uint256(_activeID);

    return activeID;
  }


//Enter Liquidity



//Exit Liquidity



//Collect Rewards

//Get Bin

    // Function to receive MNT
    receive() external payable {}

}




