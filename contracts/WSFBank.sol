pragma solidity ^0.8.0;


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)
// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.
/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b <= a, errorMessage);
        return a - b;
    }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a / b;
    }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a % b;
    }
    }
}

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)
/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)
/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
    unchecked {
        counter._value += 1;
    }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
    unchecked {
        counter._value = value - 1;
    }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: UNLICENSED
interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract DSMath {
    function add(uint x, uint y)  internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    //rounds to zero if x*y < WAD / 2
    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    //rounds to zero if x*y < WAD / 2
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    //rounds to zero if x*y < WAD / 2
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    //rounds to zero if x*y < RAY / 2
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

interface xWSFInterface {

    function transferXWSFToHolder(uint256 amount, address recipient) external ;

    function increaseBalance(uint256 amount, address recipient) external ;

    function decreaseBalance(uint256 amount, address recipient) external ;

    function resetBalance(address recipient) external ;

    function getPercentOf(address recipient) external view returns (uint256) ;

    function updateNewBalance(uint256 amount, address recipient) external ;

    function xWSFBalanceOf(address account) external view returns (uint256) ;

}

contract WSFBank is ReentrancyGuard, Ownable, DSMath {
    using SafeMath for uint256;

    struct StakingInfo {
        uint256 balance;
        uint256 startLockTime;
        uint256 totalLockTime;
        uint256 xWSF;
        uint256 busdReward;
        uint256 wsfReward;
        bool lockStatus;
    }

    struct DividendInfo {
        uint256 xWSF;
        uint256 bUSD;
    }

    /* ========== STATE VARIABLES ========== */
    using Counters for Counters.Counter;
    Counters.Counter private stakingCounter;
    IBEP20 public stakingToken;
    IBEP20 public wsfToken;
    IBEP20 public busdToken;
    xWSFInterface public xWSFToken;
    uint256 public maxTimeLock = 4*365*86400;
    uint256 public timeToCompoundWSF = 86400;
    uint256 private _minTokenStake = 10 * 10**5;
    uint256 private _ratio = 1011600000000000000000000000;
    uint256 private _totalSupply;
    uint256 private _indexDividendPay = 1;
    uint256 private _totalLockTime = 0;
    uint256 private _earlyUnlockRate = 20;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _userStakingTime;
    mapping(address => uint256) private _userTotalLockTime;
    mapping(address => uint256) private _userLastTimeLock;
    mapping(address => uint256) private _wsfRewards;
    mapping(address => uint256) private _busdRewards;
    mapping(address => uint256) private _userDividendIndex;
    mapping(address => bool) private _userLockStatus;
    mapping(uint256 => DividendInfo) private _dividendsInfo;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _stakingToken,
        address _xWSFToken,
        address _wsfToken,
        address _busdToken
    ) public  {
        stakingToken = IBEP20(_stakingToken);
        xWSFToken = xWSFInterface(_xWSFToken);
        busdToken = IBEP20(_busdToken);
        wsfToken = IBEP20(_wsfToken);
    }

    function updateAddress(
        address _stakingToken,
        address _xWSFToken,
        address _wsfToken,
        address _busdToken
    ) external onlyOwner {
        stakingToken = IBEP20(_stakingToken);
        xWSFToken = xWSFInterface(_xWSFToken);
        busdToken = IBEP20(_busdToken);
        wsfToken = IBEP20(_wsfToken);
    }


    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function totalLockTime() external view returns (uint256) {
        return _totalLockTime;
    }

    function balanceOf(address who) external view returns (uint256) {
        return _balances[who];
    }

    function userStakingTime(address who) external view returns (uint256) {
        return _userStakingTime[who];
    }

    function accrueInterest(uint _principal, uint _rate, uint _age) public pure returns (uint) {
        return rmul(_principal, rpow(_rate, _age));
    }

    function wsfRewardOf(address who) private view returns (uint256) {
        uint256 secs = block.timestamp - _userLastTimeLock[who];
        uint256 t = secs.div(timeToCompoundWSF);

        uint256 balance = _balances[who];
        uint256 b  = accrueInterest(balance, _ratio, t);
        uint256 total_rw = _wsfRewards[who] + b.sub(balance);
        return total_rw;
    }

    function busdRewardOf(address who) private view returns (uint256) {

        uint256 userDividendIndex = _userDividendIndex[who];
        uint256 currentDividendIndex = 0;
        if (_indexDividendPay > 0) {
            currentDividendIndex = _indexDividendPay - 1;
        }
        uint256 xWSFBalance = xWSFToken.xWSFBalanceOf(who);
        uint256 newBalance = 0;
        if (xWSFBalance > 0 &&  userDividendIndex < _indexDividendPay) {
            for (uint i = userDividendIndex; i < currentDividendIndex; i++) {
                DividendInfo memory info = _dividendsInfo[i];
                newBalance += xWSFBalance.mul(info.bUSD).div(info.xWSF);
            }
        }

        uint256 b = _busdRewards[who] + newBalance;
        return b;
    }

    function setRatio(uint256 r) external onlyOwner() {
        require(_ratio != r ,'This value was already used');
        _ratio = r;
        emit RatioUpdated(r);
    }

    function setMinTokenStake(uint256 value) external onlyOwner {
        require(_minTokenStake != value, 'This value was already used');
        _minTokenStake = value;
        emit MinTokenStakeUpdated(value);
    }

    function setMaxTimeLock(uint256 value) external onlyOwner {
        require(maxTimeLock != value, 'This value was already used');
        maxTimeLock = value;
        emit MaxTimeLockUpdated(value);
    }

    function setTimeToCompoundWSF(uint256 value) external onlyOwner {
        require(timeToCompoundWSF != value, 'This value was already used');
        timeToCompoundWSF = value;
        emit TimeToCompoundWSFUpdated(value);
    }

    function updateDividend(uint256 totalXWSF, uint256 totalBUSD) external onlyOwner {
        DividendInfo memory info ;
        info.xWSF = totalXWSF;
        info.bUSD = totalBUSD;

        _dividendsInfo[_indexDividendPay] = info;
        _indexDividendPay += 1;

    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stake(uint256 amount, uint256 time) external nonReentrant returns (uint256){
        require(amount >= _minTokenStake, "Cannot stake < min");
        require(_userLockStatus[msg.sender] != true, "Please unlock before continue lock");
        require(stakingToken.transferFrom(msg.sender, address(this), amount));

        stakingCounter.increment();
        _totalSupply = _totalSupply.add(amount);
        _userTotalLockTime[msg.sender] = time;
        _balances[msg.sender] = amount;

        _userStakingTime[msg.sender] = block.timestamp;
        _userLastTimeLock[msg.sender] = block.timestamp;

        // cal xWSF and send to user
        uint256 xWSFAmount = calculateXWSF(amount, time);
        xWSFToken.transferXWSFToHolder(xWSFAmount, msg.sender);
        _userDividendIndex[msg.sender] = _indexDividendPay;
        _busdRewards[msg.sender] = busdRewardOf(msg.sender);

        _userLockStatus[msg.sender] = true;

        // update busd reward

        emit Staked(msg.sender, amount);
        return stakingCounter.current();
    }

    function calculateXWSF(uint256 amount, uint256 time ) private view returns (uint256) {
        uint256 deno = maxTimeLock;
        uint256 xWSF = time.mul(amount).div(deno);
        return xWSF;
    }

    function stakeMoreWSF(uint256 amount) external nonReentrant {
        require(stakingToken.transferFrom(msg.sender, address(this), amount));
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        _totalSupply = _totalSupply.add(amount);
        _wsfRewards[msg.sender] = wsfRewardOf(msg.sender);
        _userLastTimeLock[msg.sender] = block.timestamp;

        uint256 xWSFAmount = calculateXWSF(_balances[msg.sender], _userTotalLockTime[msg.sender]);
        xWSFToken.updateNewBalance(xWSFAmount,msg.sender);
        _busdRewards[msg.sender] = busdRewardOf(msg.sender);
        _userDividendIndex[msg.sender] = _indexDividendPay;
    }

    function extendLockTime(uint256 moreTime) external {
        require(_userTotalLockTime[msg.sender] + moreTime <=  maxTimeLock, "cannot lock over max_time");
        _userTotalLockTime[msg.sender] += moreTime;
        uint256 xWSFAmount = calculateXWSF(_balances[msg.sender], _userTotalLockTime[msg.sender]);
        xWSFToken.updateNewBalance(xWSFAmount,msg.sender);
        _busdRewards[msg.sender] = busdRewardOf(msg.sender);
        _userDividendIndex[msg.sender] = _indexDividendPay;

    }

    function unlock() external {
        require(_balances[msg.sender] > 0 , "balance must > 0");
        if(_userStakingTime[msg.sender] + _userTotalLockTime[msg.sender] < block.timestamp) {
            if (stakingToken.transfer(msg.sender, _balances[msg.sender])) {
                _totalSupply = _totalSupply.sub(_balances[msg.sender]);
                _balances[msg.sender] = 0;
                xWSFToken.resetBalance(msg.sender);
                _userLockStatus[msg.sender] = false;
            }
        } else {
            uint256 availableBalance = _balances[msg.sender].mul(_earlyUnlockRate).div(100);
            if (stakingToken.transfer(msg.sender, availableBalance)) {
                _totalSupply = _totalSupply.sub(_balances[msg.sender]);
                _balances[msg.sender] = 0;
                xWSFToken.resetBalance(msg.sender);
                _userLockStatus[msg.sender] = false;
            }
        }
    }

    function claimWSFReward() external {
        uint256 reward = wsfRewardOf(msg.sender);
        require(reward > 0, 'reward must > 0');
        if(wsfToken.transfer(msg.sender, reward)) {
            _wsfRewards[msg.sender] = 0;
            _userLastTimeLock[msg.sender] = 0;
        }
    }

    function claimBUSDReward() external {

        uint256 rewardBUSD = busdRewardOf(msg.sender);
        require(rewardBUSD > 0, 'reward must > 0');
        if (busdToken.transfer(msg.sender, rewardBUSD)) {
            _busdRewards[msg.sender] = 0;
            _userDividendIndex[msg.sender] = _indexDividendPay;
        }
    }


    // Added to support recovering LP Rewards from other systems such as BAL to be distributed to holders
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        IBEP20(tokenAddress).transfer(owner(), tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }


    function infoOf(address who) external view returns (StakingInfo memory) {
        StakingInfo memory info;
        info.balance = _balances[who];
        info.startLockTime = _userStakingTime[who];
        info.totalLockTime = _userTotalLockTime[who];

        uint256 rw = wsfRewardOf(who);
        uint256 busdReward = busdRewardOf(who);
        uint256 xWSFBalance = xWSFToken.xWSFBalanceOf(who);

        info.wsfReward = rw;
        info.busdReward = busdReward;
        info.xWSF = xWSFBalance;
        info.lockStatus = _userLockStatus[who];

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
    event LockDurationUpdated(uint256 value);
    event RatioUpdated(uint256 r);
    event TimeToCompoundWSFUpdated(uint256 value);
    event MaxTimeLockUpdated(uint256 value);
}
