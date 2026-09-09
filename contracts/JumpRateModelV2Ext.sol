pragma solidity ^0.5.12;

import "./InterestRateModel.sol";
import "./BaseJumpRateModelV2Ext.sol";


/**
  * @title Compound's JumpRateModel Contract V2 for V2 cTokens
  * @author Arr00
  * @notice Supports only for V2 cTokens
  */
contract JumpRateModelV2Ext is InterestRateModel, BaseJumpRateModelV2Ext {

    /**
     * @notice Calculates the current borrow rate per block
     * @param cash The amount of cash in the market
     * @param borrows The amount of borrows in the market
     * @param reserves The amount of reserves in the market
     * @return The borrow rate percentage per block as a mantissa (scaled by 1e18)
     */
    function getBorrowRate(uint cash, uint borrows, uint reserves) external view returns (uint) {
        return getBorrowRateInternal(cash, borrows, reserves);
    }

    constructor(uint baseRatePerYear, uint multiplierPerYear, uint jumpMultiplierPerYear, uint kink_, address owner_, address operator_)
    BaseJumpRateModelV2Ext(baseRatePerYear, multiplierPerYear, jumpMultiplierPerYear, kink_, owner_, operator_) public {}
}