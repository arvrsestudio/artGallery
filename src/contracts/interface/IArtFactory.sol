pragma solidity >=0.4.22 <0.8.4;

interface IArtFactory {
    function getRoyaltyFee(uint256 tokenID) external view returns (uint256);

    function getOriginalCreator(uint256 tokenID)
        external
        view
        returns (address);
}
