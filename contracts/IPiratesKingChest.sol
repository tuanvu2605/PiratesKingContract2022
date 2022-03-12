// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;
import "./IPiratesKingBase.sol";

interface IPiratesKingChest is IPiratesKingBase {
    function openChest(address _owner, uint256 _tokenId)
        external
        returns (PKChest memory);

    function buyChest(
        address buyer,
        string memory _tokenURI,
        string memory _data,
        uint8 _cType
    ) external returns (uint256);
}
