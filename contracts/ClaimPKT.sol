// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/utils/Context.sol";
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import './IBEP20.sol';


contract ClaimPKT is Context, Ownable
{
    using SafeMath for uint256;
    address public pktContract;
    uint256 private initialTokens = 8500 * 10**18;
    bool private isLimitedClaim = false;
    uint256 private numberOfClaim = 1;
    mapping (address => uint256) private _isClaimedPKT;
    event LibContractAddressUpdate(address newAddress, bytes32 contractName);

    constructor(
    ) {
        pktContract = payable(0x29bc99648bA29461A2B00aB860280B4309578827);
    }

    function setPKTContractAddress(address _contract)
    external
    onlyOwner
    {
        require(pktContract != _contract, 'This contract was already used');
        pktContract = _contract;
        emit LibContractAddressUpdate(_contract, 'pkt');
    }

    function setInitialTokens(uint256 _amount) external onlyOwner {
        require(initialTokens != _amount, 'This amount was already used');
        initialTokens = _amount;
    }

    function setNumberOfClaim(uint256 value) external onlyOwner {
        require(numberOfClaim != value, 'This amount was already used');
        numberOfClaim = value;
    }

    function setLimitedClaim(bool value) external onlyOwner {
        require(isLimitedClaim != value, 'This value was already used');
        isLimitedClaim = value;
    }

    function sendInitialTokensToPlayer(address _to)
    external
    {
        if (isLimitedClaim) {
            require(_isClaimedPKT[_to] <= numberOfClaim, "Only claim once");
        }
        IBEP20 PKTToken = IBEP20(pktContract);
        uint256 balance = PKTToken.balanceOf(address(this));
        // Check contract balance
        if (balance < initialTokens) {
            revert("Not enough balance on  contract!");
        }
        if (!PKTToken.transfer(_to, initialTokens)) {
            revert("Error transfering tokens");
        }

        _isClaimedPKT[_to] = _isClaimedPKT[_to]  +1;
    }

}
