// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./IPiratesKingBase.sol";
import "./IPiratesKingChest.sol";
import "./IBEP20.sol";

// PiratesKing Characters smart contract inherits ERC721 interface
contract PiratesKingCharacter is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Ownable,
    IPiratesKingBase
{
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    // this contract's token collection name
    string public collectionName;
    // this contract's token symbol
    string public collectionNameSymbol;
    // total number of pirates king characters minted
    Counters.Counter private characterCounter;
    address public chestContract;
    address public pktContract;

    event LibContractAddressUpdate(address newAddress, bytes32 contractName);

    // define pirates king character struct
    struct PKCharacter {
        uint256 tokenId;
        string tokenURI;
        address payable mintedBy;
        address payable currentOwner;
        address payable previousOwner;
        uint256 price;
        uint256 numberOfTransfers;
        bool forSale;
    }

    mapping(uint256 => PKCharacter) public allCharacters;
    mapping(string => bool) public tokenURIExists;

    // initialize contract while deployment with contract's collection name and token
    constructor()
        ERC721("Pirates King Character Collection", "PKCH")
    {
        collectionName = name();
        collectionNameSymbol = symbol();
        chestContract = payable(0x4b9E79936be974Ca4bEeffe160cceDa11f5c4400);
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

    function setChestContractAddress(address _contract) external onlyOwner {
        require(chestContract != _contract, 'This address was already used');
        chestContract = _contract;
        emit LibContractAddressUpdate(_contract, "chest");
    }

    function openChest(uint256 _tokenId) external {
        IPiratesKingChest ChestContract = IPiratesKingChest(chestContract);
        PKChest memory chest = ChestContract.openChest(_msgSender(), _tokenId);
        require(msg.sender != address(0));
        // increment counter
        characterCounter.increment();
        // check if a token exists with the above token id => incremented counter
        require(!_exists(characterCounter.current()));

        string memory _tokenURI = chest.data;
        // check if the token URI already exists or not
        require(!tokenURIExists[_tokenURI]);
        // check if the token name already exists or not

        // mint the token
        _mint(msg.sender, characterCounter.current());
        // set token URI (bind token id with the passed in token URI)
        _setTokenURI(characterCounter.current(), _tokenURI);
        // make passed token URI as exists
        tokenURIExists[_tokenURI] = true;
        // make token name passed as exists

        // creat a new pirates king character (struct) and pass in new values
        PKCharacter memory newCharacter = PKCharacter(
            characterCounter.current(),
            chest.data,
            payable(msg.sender),
            payable(msg.sender),
            payable(address(0)),
            0,
            0,
            false
        );
        // add the token id and it's pirates king character to all pirates king characters mapping
        allCharacters[characterCounter.current()] = newCharacter;
    }

    // get owner of the token
    function getTokenOwner(uint256 _tokenId) public view returns (address) {
        address _tokenOwner = ownerOf(_tokenId);
        return _tokenOwner;
    }

    // get metadata of the token
    function getTokenMetaData(uint256 _tokenId)
        public
        view
        returns (string memory)
    {
        string memory tokenMetaData = tokenURI(_tokenId);
        return tokenMetaData;
    }

    // get total number of tokens minted so far
    function getNumberOfTokensMinted() public view returns (uint256) {
        uint256 totalNumberOfTokensMinted = totalSupply();
        return totalNumberOfTokensMinted;
    }

    // get total number of tokens owned by an address
    function getTotalNumberOfTokensOwnedByAnAddress(address _owner)
        public
        view
        returns (uint256)
    {
        uint256 totalNumberOfTokensOwned = balanceOf(_owner);
        return totalNumberOfTokensOwned;
    }

    // check if the token already exists
    function getTokenExists(uint256 _tokenId) public view returns (bool) {
        bool tokenExists = _exists(_tokenId);
        return tokenExists;
    }

    // by a token by passing in the token's id
    function buyToken(uint256 _tokenId) public payable {
        // check if the function caller is not an zero account address
        require(msg.sender != address(0));
        // check if the token id of the token being bought exists or not
        require(_exists(_tokenId));
        // get the token's owner
        address tokenOwner = ownerOf(_tokenId);
        // token's owner should not be an zero address account
        require(tokenOwner != address(0));
        // the one who wants to buy the token should not be the token's owner
        require(tokenOwner != msg.sender);
        // get that token from all pirates king characters mapping and create a memory of it defined as (struct => PKCharacter)
        PKCharacter memory character = allCharacters[_tokenId];
        // price sent in to buy should be equal to or more than the token's price
        require(msg.value >= character.price);
        // token should be for sale
        require(character.forSale);
        // get owner of the token
        address payable sendTo = character.currentOwner;
        // send token's worth of ethers to the owner
        if (
            !IBEP20(pktContract).transferFrom(
                _msgSender(),
                sendTo,
                character.price
            )
        ) {
            revert("Error transferring tokens");
        }
        // transfer the token from owner to the caller of the function (buyer)
        _transfer(tokenOwner, msg.sender, _tokenId);
        // update the token's previous owner
        character.previousOwner = character.currentOwner;
        // update the token's current owner
        character.currentOwner = payable(msg.sender);
        // update the how many times this token was transfered
        character.numberOfTransfers += 1;
        // set and update that token in the mapping
        allCharacters[_tokenId] = character;
    }

    function changeTokenPrice(uint256 _tokenId, uint256 _newPrice) public {
        // require caller of the function is not an empty address
        require(msg.sender != address(0));
        // require that token should exist
        require(_exists(_tokenId));
        // get the token's owner
        address tokenOwner = ownerOf(_tokenId);
        // check that token's owner should be equal to the caller of the function
        require(tokenOwner == msg.sender);
        // get that token from all pirates king characters mapping and create a memory of it defined as (struct => PKCharacter)
        PKCharacter memory character = allCharacters[_tokenId];
        // update token's price with new price
        character.price = _newPrice;
        // set and update that token in the mapping
        allCharacters[_tokenId] = character;
    }

    // switch between set for sale and set not for sale
    function toggleForSale(uint256 _tokenId) public {
        // require caller of the function is not an empty address
        require(msg.sender != address(0));
        // require that token should exist
        require(_exists(_tokenId));
        // get the token's owner
        address tokenOwner = ownerOf(_tokenId);
        // check that token's owner should be equal to the caller of the function
        require(tokenOwner == msg.sender);
        // get that token from all pirates king characters mapping and create a memory of it defined as (struct => PKCharacter)
        PKCharacter memory character = allCharacters[_tokenId];
        // if token's forSale is false make it true and vice versa
        if (character.forSale) {
            character.forSale = false;
        } else {
            character.forSale = true;
        }
        // set and update that token in the mapping
        allCharacters[_tokenId] = character;
    }
}
