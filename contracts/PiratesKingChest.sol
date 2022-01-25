// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

// import ERC721 iterface
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import './IBEP20.sol';
import './IPiratesKingBase.sol';


// PiratesKingChest smart contract inherits ERC721 interface
contract PiratesKingChest is ERC721, ERC721URIStorage, ERC721Enumerable, Ownable, IPiratesKingBase {

    using SafeMath for uint256;
    // this contract's token collection name
    string public collectionName;
    // this contract's token symbol
    string public collectionNameSymbol;
    uint256 public chestCounter;
    uint256 private baseCost;
    address public pktContract;
    address public poolRewardAddress;




    mapping(uint256 => PKChest) public allChests;
    // check if token URI exists
    mapping(string => bool) public tokenURIExists;
    mapping(uint256 => bool) public chestOpens;

    event LibContractAddressUpdate(address newAddress, bytes32 contractName);

    // initialize contract while deployment with contract's collection name and token
    constructor(address _pktContract, address _poolRewardAddress) ERC721("Chest Collection", "PKC") {
        collectionName = name();
        collectionNameSymbol = symbol();
        _setPKTContractAddress(_pktContract);
        _setPoolContractAddress(_poolRewardAddress);
    }


    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
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

    /*
*  @Update pkt contract address
  */
    function _setPKTContractAddress(address _contract)
    private
    {
        pktContract = _contract;
        emit LibContractAddressUpdate(_contract, 'pkt');
    }

    /*
*  @Update pool contract address
  */
    function _setPoolContractAddress(address _contract)
    private
    {
        poolRewardAddress = _contract;
        emit LibContractAddressUpdate(_contract, 'pool');
    }

    // mint a new crypto boy
    function mintChest(string memory _tokenURI, string memory _data, uint8 _cType) external onlyOwner returns(uint256)
    {
        // check if this function caller is not an zero address account
        require(msg.sender != address(0));
        // increment counter
        chestCounter ++;
        // check if a token exists with the above token id => incremented counter
        require(!_exists(chestCounter));

        // check if the token URI already exists or not
        require(!tokenURIExists[_tokenURI]);
        // check if the token name already exists or not

        // mint the token
        _mint(msg.sender, chestCounter);
        // set token URI (bind token id with the passed in token URI)
        _setTokenURI(chestCounter, _tokenURI);

        // make passed token URI as exists
        tokenURIExists[_tokenURI] = true;

        // creat a new crypto boy (struct) and pass in new values
        PKChest memory newChest = PKChest(
            chestCounter,
            _tokenURI,
            payable(_msgSender()),
            payable(_msgSender()),
            payable(address(0)),
            0,
            0,
            false,
            false,
            _data,
            _cType);
        // add the token id and it's crypto boy to all crypto boys mapping
        allChests[chestCounter] = newChest;
        return chestCounter;
    }

    function setBaseCost(uint256 _cost) external onlyOwner
    {
        require (_cost > 0, "cost must be > 0");
        baseCost = _cost;
    }

    // You can read from a state variable without sending a transaction.
    function getBaseCost() public view onlyOwner returns (uint256)
    {
        return baseCost;
    }


    // get owner of the token
    function getTokenOwner(uint256 _tokenId)
    public
    view
    returns(address)
    {
        address _tokenOwner = ownerOf(_tokenId);
        return _tokenOwner;
    }

    // get metadata of the token
    function getTokenMetaData(uint _tokenId)
    public
    view
    returns(string memory)
    {
        string memory tokenMetaData = tokenURI(_tokenId);
        return tokenMetaData;
    }

    function isChestOpen(uint _tokenId)
    public
    view
    returns(bool)
    {
        return chestOpens[_tokenId];
    }

    // get total number of tokens minted so far
    function getNumberOfTokensMinted()
    public
    view
    returns(uint256) {
        uint256 totalNumberOfTokensMinted = totalSupply();
        return totalNumberOfTokensMinted;
    }

    // get total number of tokens owned by an address
    function getTotalNumberOfTokensOwnedByAnAddress(address _owner)
    public
    view
    returns(uint256)
    {
        uint256 totalNumberOfTokensOwned = balanceOf(_owner);
        return totalNumberOfTokensOwned;
    }

    // check if the token already exists
    function getTokenExists(uint256 _tokenId)
    public
    view
    returns(bool)
    {
        bool tokenExists = _exists(_tokenId);
        return tokenExists;
    }

    // by a token by passing in the token's id
    function buyToken(uint256 _tokenId)
    public
    payable
    {
        // check if the function caller is not an zero account address
        require(msg.sender != address(0));
        // check if the token id of the token being bought exists or not
        require(_exists(_tokenId));
        // get the token's owner
        address tokenOwner = ownerOf(_tokenId);
        // token's owner should not be an zero address account
        require(tokenOwner != address(0));
        // the one who wants to buy the token should not be the token's owner
        require(tokenOwner !=_msgSender());
        // get that token from all crypto boys mapping and create a memory of it defined as (struct => CryptoBoy)
        PKChest memory chest = allChests[_tokenId];
        // price sent in to buy should be equal to or more than the token's price
        require(msg.value >= chest.price);
        // token should be for sale
        require(chest.forSale);
        address payable sendTo = chest.currentOwner;
        if (!IBEP20(pktContract).transferFrom(
                _msgSender(),
                sendTo,
                chest.price
        )) {
            revert("Error transferring tokens");
        }
        // transfer the token from owner to the caller of the function (buyer)
        _transfer(tokenOwner,_msgSender(), _tokenId);

        // sendTo.transfer(msg.value);
        // update the token's previous owner
        chest.previousOwner = payable(chest.currentOwner);
        // update the token's current owner
        chest.currentOwner = payable(_msgSender());
        // update the how many times this token was transfered
        chest.numberOfTransfers += 1;
        // set and update that token in the mapping
        allChests[_tokenId] = chest;
    }

    function changeTokenPrice(uint256 _tokenId, uint256 _newPrice)
    public
    {
        // require caller of the function is not an empty address
        require(msg.sender != address(0));
        // require that token should exist
        require(_exists(_tokenId));
        // get the token's owner
        address tokenOwner = ownerOf(_tokenId);
        // check that token's owner should be equal to the caller of the function
        require(tokenOwner ==_msgSender());
        // get that token from all crypto boys mapping and create a memory of it defined as (struct => CryptoBoy)
        PKChest memory chest = allChests[_tokenId];
        // update token's price with new price
        chest.price = _newPrice;
        // set and update that token in the mapping
        allChests[_tokenId] = chest;
    }

    // switch between set for sale and set not for sale
    function toggleForSale(uint256 _tokenId)
    public
    {
        // require caller of the function is not an empty address
        require(msg.sender != address(0));
        // require that token should exist
        require(_exists(_tokenId));
        // get the token's owner
        address tokenOwner = ownerOf(_tokenId);
        // check that token's owner should be equal to the caller of the function
        require(tokenOwner ==_msgSender());
        // get that token from all crypto boys mapping and create a memory of it defined as (struct => CryptoBoy)
        PKChest memory chest = allChests[_tokenId];
        // if token's forSale is false make it true and vice versa
        if(chest.forSale) {
            chest.forSale = false;
        } else {
            chest.forSale = true;
        }
        // set and update that token in the mapping
        allChests[_tokenId] = chest;
    }

    function openChest(
        address _owner,
        uint256 _tokenId
    )
    external
    returns (PKChest memory)
    {
        // require caller of the function is not an empty address
        require(msg.sender != address(0));
        // require that token should exist
        require(_exists(_tokenId));
        // get the token's owner
        address tokenOwner = ownerOf(_tokenId);
        // check that token's owner should be equal to the caller of the function
        require(tokenOwner == _owner);
        // get that token from all crypto boys mapping and create a memory of it defined as (struct => CryptoBoy)
        require(!chestOpens[_tokenId], "Chest has been opened");
        PKChest memory chest = allChests[_tokenId];
        chestOpens[_tokenId] = true;
        chest.isOpened = true;
        return chest;
    }

    function buyChest(
        string memory _tokenURI,
        uint256 _price,
        string memory _data,
        uint8 _cType
    )
    external
    payable
    returns(uint256)
    {

        require(_price >= baseCost, "_price must be > baseCost");

        if (IBEP20(pktContract).transferFrom(
            _msgSender(),
            poolRewardAddress,
            _price
        )) {
            // check if this function caller is not an zero address account
            require(msg.sender != address(0));
            // increment counter
            chestCounter ++;
            // check if a token exists with the above token id => incremented counter
            require(!_exists(chestCounter));

            // check if the token URI already exists or not
            require(!tokenURIExists[_tokenURI]);
            // check if the token name already exists or not

            // mint the token
            _mint(msg.sender, chestCounter);
            // set token URI (bind token id with the passed in token URI)
            _setTokenURI(chestCounter, _tokenURI);

            // make passed token URI as exists
            tokenURIExists[_tokenURI] = true;

            // creat a new crypto boy (struct) and pass in new values
            PKChest memory newChest = PKChest(
                chestCounter,
                _tokenURI,
                payable(_msgSender()),
                payable(_msgSender()),
                payable(address(0)),
                0,
                0,
                false,
                false,
                _data,
                _cType);
            // add the token id and it's crypto boy to all crypto boys mapping
            allChests[chestCounter] = newChest;
            return chestCounter;
        } else {
            revert("Error transferring tokens");
        }

    }

}


