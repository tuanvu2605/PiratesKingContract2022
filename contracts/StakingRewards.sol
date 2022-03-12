// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/utils/Counters.sol";
import "./IBEP20.sol";



contract StakingRewards is ReentrancyGuard, Ownable {
    using SafeMath for uint256;

    struct StakingInfo {
        uint256 balance;
        uint256 timestamp;
        uint256 reward;
    }

    /* ========== STATE VARIABLES ========== */
    using Counters for Counters.Counter;
    Counters.Counter private stakingCounter;
    IBEP20 public rewardsToken;
    IBEP20 public stakingToken;
    uint256 public APY = 365;
    uint256 public lockDuration = 5 * 86400;
    uint256 private _maxTokenStake = 1 * 10**6 * 10**18;
    uint256 private _minTokenStake = 5 * 10**3 * 10**18;

    uint256 private _totalSupply;
    mapping(uint256 => uint256) private _balances;
    mapping(address => uint256) private _totalBalances;
    mapping(uint256 => uint256) private _userStakingTime;
    mapping(uint256 => address) private _stakingIdMapping;
    mapping(address => uint256[]) private _totalStakingOfUser;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _rewardsToken,
        address _stakingToken
    ) public  {
        rewardsToken = IBEP20(_rewardsToken);
        stakingToken = IBEP20(_stakingToken);
    }

    /* ========== VIEWS ========== */

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(uint256 stakingId) external view returns (uint256) {
        return _balances[stakingId];
    }

    function totalBalanceOf(address account) external view returns (uint256) {
        return _totalBalances[account];
    }

    function userStakingTime(uint256 stakingId) external view returns (uint256) {
        return _userStakingTime[stakingId];
    }

    function totalStakingOfUser(address account) public view returns (uint256[] memory) {
        return _totalStakingOfUser[account];
    }

    function setMinTokenStake(uint256 value) external onlyOwner {
        require(_minTokenStake != value, 'This value was already used');
        _minTokenStake = value;
        emit MinTokenStakeUpdated(value);
    }

    function setMaxTokenStake(uint256 value) external onlyOwner {
        require(_maxTokenStake != value, 'This value was already used');
        _maxTokenStake = value;
        emit MaxTokenStakeUpdated(value);
    }

    function setAPY(uint256 value) external onlyOwner {
        require(APY != value, 'This value was already used');
        APY = value;
        emit APYUpdated(value);
    }

    function setLockDuration(uint256 value) external onlyOwner {
        require(lockDuration != value, 'This value was already used');
        lockDuration = value;
        emit LockDurationUpdated(value);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stake(uint256 amount) external nonReentrant returns (uint256){
        require(amount >= _minTokenStake, "Cannot stake < min");
        require(_totalBalances[msg.sender].add(amount) <= _maxTokenStake, "Cannot stake > max");
        stakingCounter.increment();
        require(_stakingIdMapping[stakingCounter.current()] == address(0), "An error occurred");
        _stakingIdMapping[stakingCounter.current()] = msg.sender;
        _totalStakingOfUser[msg.sender].push(stakingCounter.current());
        _totalSupply = _totalSupply.add(amount);
        _balances[stakingCounter.current()] = amount;
        _totalBalances[msg.sender] = _totalBalances[msg.sender].add(amount);
        stakingToken.transferFrom(msg.sender, address(this), amount);
        _userStakingTime[stakingCounter.current()] = block.timestamp;
        emit Staked(msg.sender, amount);
        return stakingCounter.current();
    }

    function withdraw(uint256 stakingId) private nonReentrant {
        require(_stakingIdMapping[stakingId] == msg.sender,"you must owner of staking id");
        require(_balances[stakingId] > 0 , "balance must > 0");
        uint256 amount = _balances[stakingId];
        _totalSupply = _totalSupply.sub(amount);
        _totalBalances[msg.sender] = _totalBalances[msg.sender].sub(amount);
        _balances[stakingId] = 0;
        stakingToken.transfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function getReward(uint256 stakingId) private nonReentrant  {
        require(_stakingIdMapping[stakingId] == msg.sender,"you must owner of staking id");
        require(_balances[stakingId] > 0 , "balance must > 0");
        uint256 secs = block.timestamp - _userStakingTime[stakingId];
        uint256 reward = _balances[stakingId].mul(APY).div(36500).mul(secs).div(86400);
        if (reward > 0) {
            rewardsToken.transfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function exit(uint256 stakingId) external {
        require(_stakingIdMapping[stakingId] == msg.sender,"you must owner of staking id");
        require((block.timestamp - _userStakingTime[stakingId]) >= lockDuration, "you cannot withdraw now!");
        withdraw(stakingId);
        getReward(stakingId);
    }


    // Added to support recovering LP Rewards from other systems such as BAL to be distributed to holders
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        require(tokenAddress != address(stakingToken), "Cannot withdraw the staking token");
        IBEP20(tokenAddress).transfer(owner(), tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function rewardOf(uint256 stakingId) external view returns (uint256) {
        uint256 secs = block.timestamp - _userStakingTime[stakingId];
        uint256 rw = _balances[stakingId].mul(APY).div(36500).mul(secs).div(86400);
        return rw;
    }
    function infoOf(uint256 stakingId) external view returns (StakingInfo memory) {
        StakingInfo memory info;
        info.balance = _balances[stakingId];
        info.timestamp = _userStakingTime[stakingId];
        uint256 secs = block.timestamp - _userStakingTime[stakingId];
        uint256 rw = _balances[stakingId].mul(APY).div(36500).mul(secs).div(86400);
        info.reward = rw;


        return info;
    }


    /* ========== EVENTS ========== */

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event Recovered(address token, uint256 amount);
    event MinTokenStakeUpdated(uint256 amount);
    event MaxTokenStakeUpdated(uint256 amount);
    event APYUpdated(uint256 value);
    event LockDurationUpdated(uint256 value);
}
