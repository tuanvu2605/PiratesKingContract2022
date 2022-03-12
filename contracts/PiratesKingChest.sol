// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IBEP20.sol";
import "./IPiratesKingBase.sol";

contract PiratesKingChest is
    ERC721,
    ERC721URIStorage,
    ERC721Enumerable,
    Ownable,
    IPiratesKingBase
{
    using SafeMath for uint256;
    string public collectionName;
    string public collectionNameSymbol;
    uint256 public chestCounter;
    address public pktContract;
    address public pktGameContract;
    mapping(uint256 => PKChest) public allChests;
    mapping(string => bool) public tokenURIExists;
    mapping(uint256 => bool) public chestOpens;
    event LibContractAddressUpdate(address newAddress, bytes32 contractName);

    constructor()
        ERC721("Chest Collection", "PKC")
    {
        collectionName = name();
        collectionNameSymbol = symbol();
        pktContract = payable(0x29bc99648bA29461A2B00aB860280B4309578827);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }

    function setPKTContractAddress(address _contract) external onlyOwner {
        require(pktContract != _contract, 'This address was already used');
        pktContract = _contract;
        emit LibContractAddressUpdate(_contract, "pkt");
    }

    function setPKTGameContractAddress(address _contract) external onlyOwner {
        require(pktGameContract != _contract, 'This address was already used');
        pktGameContract = _contract;
        emit LibContractAddressUpdate(_contract, "game");
    }

    function getTokenOwner(uint256 _tokenId) public view returns (address) {
        address _tokenOwner = ownerOf(_tokenId);
        return _tokenOwner;
    }

    function getTokenMetaData(uint256 _tokenId)
        public
        view
        returns (string memory)
    {
        string memory tokenMetaData = tokenURI(_tokenId);
        return tokenMetaData;
    }

    function isChestOpen(uint256 _tokenId) public view returns (bool) {
        return chestOpens[_tokenId];
    }

    function getNumberOfTokensMinted() public view returns (uint256) {
        uint256 totalNumberOfTokensMinted = totalSupply();
        return totalNumberOfTokensMinted;
    }

    function getTotalNumberOfTokensOwnedByAnAddress(address _owner)
        public
        view
        returns (uint256)
    {
        uint256 totalNumberOfTokensOwned = balanceOf(_owner);
        return totalNumberOfTokensOwned;
    }

    function getTokenExists(uint256 _tokenId) public view returns (bool) {
        bool tokenExists = _exists(_tokenId);
        return tokenExists;
    }


    function openChest(address _owner, uint256 _tokenId)
        external
        returns (PKChest memory)
    {
        require(msg.sender != address(0));
        require(_exists(_tokenId));
        address tokenOwner = ownerOf(_tokenId);
        require(tokenOwner == _owner);
        require(!chestOpens[_tokenId], "Chest has been opened");
        PKChest memory chest = allChests[_tokenId];
        chestOpens[_tokenId] = true;
        chest.isOpened = true;
        return chest;
    }

    function buyChest(
        address buyer,
        string memory _tokenURI,
        string memory _data,
        uint8 _cType
    ) external returns (uint256) {

        require(msg.sender == pktGameContract);
        chestCounter++;
        require(!_exists(chestCounter));
        require(!tokenURIExists[_tokenURI]);
        _mint(buyer, chestCounter);
        _setTokenURI(chestCounter, _tokenURI);
        tokenURIExists[_tokenURI] = true;
        PKChest memory newChest = PKChest(
                chestCounter,
                _tokenURI,
                payable(buyer),
                payable(buyer),
                payable(address(0)),
                0,
                0,
                false,
                false,
                _data,
                _cType
            );
            allChests[chestCounter] = newChest;
            return chestCounter;
    }
}
