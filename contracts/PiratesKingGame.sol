// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/utils/Context.sol";
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import './IBEP20.sol';
import "./IPiratesKingChest.sol";


contract PiratesKingGame is Context, Ownable, IPiratesKingBase
{

    struct IsLandChoseStruct {
        string  date;
        string  isLandName;
        uint256 amount;
    }


    struct TransactionInfo {
        uint256 amount;
        uint256 timestamp;
        string t_type;
        address wallet;
    }

    using SafeMath for uint256;
    address public pktContract;
    address payable public findTreasureIslandPool;
    address payable public rewardPool;
    address payable public devPool;
    address public chestContract;
    uint256 private baseCost;
    uint256 private baseCostChestVip;
    uint256 private baseCostItemChest;

    // Contract status
    bool public active;
    mapping (address => IsLandChoseStruct[]) public islandsChose;
    mapping (string => TransactionInfo) private _transInfo;

    uint256 public buyChestRewardPercent = 70;
    uint256 public treasureIslandRewardPercent = 2;
    uint256 public treasureIslandDevPercent = 8;

    /*
    *	@dev Check if contract is active
	*/
    modifier isContractActive {
        require( active, "Contract is inactive" );
        _;
    }


    /*
    * @dev Log contract status update
  */
    event ContractStatusUpdate(bool newStatus);
    event LibContractAddressUpdate(address newAddress, bytes32 contractName);
    event NewIsLandChose(address indexed player, string name, uint256 amount, string date);
    event NewLevelUpgrade(address indexed player, string id_level, uint256 amount, string id_pirate);
    event NewChestPurchased(address indexed player, uint256 chest_id, uint256 amount);
    event GiveChestToContestWinner(address indexed player, uint256 chest_id);

    /*
    * @dev Set default admin role to owner
  */

    constructor(
    ) {
        findTreasureIslandPool = payable(0x6D5527D0c4494Dd9D8a2Fad80FF7872558eD9FdC);
        rewardPool = payable(0x6D5527D0c4494Dd9D8a2Fad80FF7872558eD9FdC);
        devPool = payable(0x9B5b98D20042c29293289Fea8324ef1584e9c78E);
        pktContract = payable(0x4cbd8ADCD7eCa7D1B71ADbBF484F1e8014681a9D);
        chestContract = payable(0x4b9E79936be974Ca4bEeffe160cceDa11f5c4400);
        baseCost = 1500*10**18;
        baseCostChestVip = 2000*10**18;
        baseCostItemChest = 1000*10**18;
        active = true;
    }

    /*
    *  @Update weapon contract address
  */
    function setFindTreasureIslandPoolAddress(address _address)
    external
    onlyOwner
    {
        require(findTreasureIslandPool != _address, 'This address was already used');
        findTreasureIslandPool = payable(_address);
        emit LibContractAddressUpdate(_address, 'findTreasureIsland');
    }

    function setRewardPoolAddress(address _address)
    external
    onlyOwner
    {
        require(rewardPool != _address, 'This address was already used');
        rewardPool = payable(_address);
        emit LibContractAddressUpdate(_address, 'rewardPool');
    }

    function setDevPoolAddress(address _address)
    external
    onlyOwner
    {
        require(devPool != _address, 'This address was already used');
        devPool = payable(_address);
        emit LibContractAddressUpdate(_address, 'devPool');
    }

    /*
    *  @Update token contract address
  */
    function setPKTContractAddress(address _contract)
    external
    onlyOwner
    {
        require(pktContract != _contract, 'This contract was already used');
        pktContract = _contract;
        emit LibContractAddressUpdate(_contract, 'pkt');
    }

    function setChestContractAddress(address _contract)
    external
    onlyOwner
    {
        require(chestContract != _contract, 'This contract was already used');
        chestContract = _contract;
        emit LibContractAddressUpdate(_contract, 'chest');
    }

    function setBuyChestRewardPercent(uint256 percent) external onlyOwner {
        require(buyChestRewardPercent != percent);
        buyChestRewardPercent = percent;
    }

    function setTreasureIslandRewardPercent(uint256 percent) external onlyOwner {
        require(treasureIslandRewardPercent != percent);
        treasureIslandRewardPercent = percent;
    }

    function setTreasureIslandDevPercent(uint256 percent) external onlyOwner {
        require(treasureIslandDevPercent != percent);
        treasureIslandDevPercent = percent;
    }


    function setBaseCost(uint256 _cost) external onlyOwner {
        require(_cost > 0, "cost must be > 0");
        baseCost = _cost;
    }

    function getBaseCost() public view onlyOwner returns (uint256) {
        return baseCost;
    }

    function setBaseCostChestVip(uint256 _cost) external onlyOwner {
        require(_cost > 0, "cost must be > 0");
        baseCostChestVip = _cost;
    }

    function getBaseCostChestVip() public view onlyOwner returns (uint256) {
        return baseCostChestVip;
    }

    function setBaseCostItemChest(uint256 _cost) external onlyOwner {
        require(_cost > 0, "cost must be > 0");
        baseCostItemChest = _cost;
    }

    function getBaseCostItemChest() public view onlyOwner returns (uint256) {
        return baseCostItemChest;
    }


    function activateDeactivateContract(bool _active)
    external
    onlyOwner
    {
        active = _active;
        emit ContractStatusUpdate(_active);
    }

    function playerChooseIsland(string memory  _islandName, uint256 _amount, string memory _date, string memory trans_id)
    external
    payable
    {
        uint256 devAmount = treasureIslandDevPercent.mul(_amount).div(100);
        uint256 rwAmount = treasureIslandRewardPercent.mul(_amount).div(100);
        uint256 treasureIslandAmount = _amount.sub(devAmount).sub(rwAmount);
        require(IBEP20(pktContract).transferFrom(
                _msgSender(),
                rewardPool, rwAmount
            ), "Deposit failed");

        require(IBEP20(pktContract).transferFrom(
                _msgSender(),
                devPool, devAmount
            ), "Deposit failed");

        require(IBEP20(pktContract).transferFrom(
            _msgSender(),
            findTreasureIslandPool, treasureIslandAmount
        ), "Deposit failed");


        TransactionInfo memory trans ;
        trans.amount = _amount;
        trans.timestamp = block.timestamp;
        trans.t_type = "Treasure_Island";
        trans.wallet = _msgSender();
        _transInfo[trans_id] = trans;


        emit NewIsLandChose(_msgSender(), _islandName, _amount, _date);
    }

    function playerUpgradeLevel(string memory  _idPirate, uint256 _amount, string memory _idLevel, string memory trans_id)
    external
    payable
    {
        require(IBEP20(pktContract).transferFrom(
                _msgSender(),
                devPool,
                _amount
            ), "Deposit failed");

        TransactionInfo memory trans ;
        trans.amount = _amount;
        trans.timestamp = block.timestamp;
        trans.t_type = "Upgrade_Level";
        trans.wallet = _msgSender();
        _transInfo[trans_id] = trans;

        emit NewLevelUpgrade(_msgSender(), _idLevel, _amount, _idPirate);
    }

    function buyChest(
        string memory _tokenURI,
        uint256 _price,
        string memory _data,
        uint8 _cType,
        string memory trans_id
    ) external payable returns (uint256) {
        if (_cType == 1) {
            require(_price >= baseCost, "_price must be > baseCost");
        } else if (_cType == 2) {
            require(_price >= baseCostChestVip, "_price must be > baseCost");
        } else if (_cType == 3) {
            require(_price >= baseCostItemChest, "_price must be > baseCost");
        }
        uint256 rwAmount = buyChestRewardPercent.mul(_price).div(100);
        uint256 devAmount = _price.sub(rwAmount);
        if (IBEP20(pktContract).transferFrom(_msgSender(), rewardPool, rwAmount) && IBEP20(pktContract).transferFrom(_msgSender(), devPool, devAmount))
        {
            IPiratesKingChest ChestContract = IPiratesKingChest(chestContract);
            uint256 chest_id = ChestContract.buyChest(_msgSender(),_tokenURI, _data, _cType);
            TransactionInfo memory trans ;
            trans.amount = _price;
            trans.timestamp = block.timestamp;

            if (_cType == 1) {
                trans.t_type = "Buy_Chest";
            } else if (_cType == 2) {
                trans.t_type = "Buy_Chest_Vip";
            }else if (_cType == 3) {
                trans.t_type = "Buy_Chest_Item";
            }
            trans.wallet = _msgSender();
            _transInfo[trans_id] = trans;
            emit NewChestPurchased(_msgSender(), chest_id, _price);
            return chest_id;
        } else {
            revert("Error transferring tokens");
        }

    }

    function giveChestToContestWinner(
        address winner,
        string memory _tokenURI,
        string memory _data,
        uint8 _cType
    ) external onlyOwner returns (uint256)
    {
        IPiratesKingChest ChestContract = IPiratesKingChest(chestContract);
        uint256 chest_id = ChestContract.buyChest(winner,_tokenURI, _data, _cType);
        emit GiveChestToContestWinner(winner, chest_id);
        return chest_id;
    }

    function transactionInfoOf(string memory trans_id) public view  returns (TransactionInfo memory) {
        return _transInfo[trans_id];
    }

}
