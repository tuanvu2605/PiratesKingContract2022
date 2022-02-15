// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import "./IBEP20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./IPancakeswapV2Factory.sol";
import "./IPancakeswapV2Router02.sol";

contract PiratesKingToken is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;

    address payable public bnbPoolAddress;
    address payable public prPoolAddress;


    uint256 private _tTotal = 100 * 10**6 * 10**18;
    uint256 private constant MAX = ~uint256(0);
    string private _name = "PiratesKing";
    string private _symbol = "PKT";
    uint8 private _decimals = 18;

    uint256 public _BNBFee = 0;
    uint256 private _previousBNBFee = _BNBFee;
    uint256 public  _PRFee = 0;
    uint256 private _previousPRFee = _PRFee;
    uint256 public _buyFee = 0;
    uint256 private _previousBuyFee = _buyFee;
    uint256 public _liquidityFee = 0;
    uint256 private _previousLiquidityFee = _liquidityFee;


    IPancakeswapV2Router02 public pancakeswapV2Router;
    address public pancakeswapV2Pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;
    // 00
    uint256 public _maxTxAmount =  100 * 10**6 * 10**18;
    uint256 private numTokensToSwap =  1 * 10**3 * 10**18;
    uint256 public swapCoolDownTime = 0;
    uint256 private lastSwapTime;
    mapping(address => uint256) private lastTxTimes;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );
    event ExcludedFromFee(address account);
    event IncludedToFee(address account);
    event UpdateFees(uint256 bnbFee, uint256 liquidityFee, uint256 prFee, uint256 buyFee);
    event UpdatedMaxTxAmount(uint256 maxTxAmount);
    event UpdateNumTokensToSwap(uint256 amount);
    event UpdateBNBPoolAddress(address account);
    event UpdatePRPoolAddress(address account);
    event SwapAndCharged(uint256 token, uint256 liquidAmount, uint256 bnbPool, uint256 prPool, uint256 bnbLiquidity);
    event UpdatedCoolDowntime(uint256 timeForContract);
    event SwapTokensForEth(bool status);
    event AddLiquidity (bool status);
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor () {
        //Test Net
//        IPancakeswapV2Router02 _pancakeswapV2Router = IPancakeswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        //Main Net
        IPancakeswapV2Router02 _pancakeswapV2Router = IPancakeswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        pancakeswapV2Pair = IPancakeswapV2Factory(_pancakeswapV2Router.factory())
        .createPair(address(this), _pancakeswapV2Router.WETH());

        // set the rest of the contract variables
        pancakeswapV2Router = _pancakeswapV2Router;

        //exclude owner and this contract from fee
        _isExcludedFromFee[_msgSender()] = true;
        _isExcludedFromFee[address(this)] = true;
        _balances[_msgSender()] = _tTotal;

        bnbPoolAddress = payable(0xBa71532C52E78d719Ef9233f9bA9E80Cd3c81727);
        prPoolAddress = payable(0x18d6444D46D07283c6b9982Ad75fd51d2A7cFeC1);
        _approve(address(this), address(pancakeswapV2Router), ~uint256(0));
        emit Transfer(address(0), owner(), _tTotal);
    }


    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function getOwner() external view override returns (address) {
        return owner();
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function setBNBPoolAddress(address account) external onlyOwner {
        require(account != bnbPoolAddress, 'This address was already used');
        bnbPoolAddress = payable(account);
        emit UpdateBNBPoolAddress(account);
    }

    function setPRPoolAddress(address account) external onlyOwner {
        require(account != prPoolAddress, 'This address was already used');
        prPoolAddress = payable(account);
        emit UpdatePRPoolAddress(account);
    }
    function setCoolDownTime(uint256 timeForContract) external onlyOwner {
        require(swapCoolDownTime != timeForContract);
        swapCoolDownTime = timeForContract;
        emit UpdatedCoolDowntime(timeForContract);
    }


    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
        emit ExcludedFromFee(account);
    }

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
        emit IncludedToFee(account);
    }

    function setFees(uint256 bnbFee, uint256 liquidityFee, uint256 prFee, uint256 buyFee) external onlyOwner() {
        require(bnbFee + liquidityFee + prFee <= 8  &&  buyFee <= 4);
        _BNBFee = bnbFee;
        _liquidityFee = liquidityFee;
        _PRFee = prFee;
        _buyFee = buyFee;
        emit UpdateFees(bnbFee, liquidityFee, prFee, buyFee);
    }

    function setMaxTxAmount(uint256 percent) external onlyOwner() {
        require(percent > 1 , 'percent must > 1');
        _maxTxAmount = _tTotal.mul(percent).div(10**2);
        emit UpdatedMaxTxAmount(_maxTxAmount);
    }

    function setNumTokensToSwap(uint256 amount) external onlyOwner() {
        require(numTokensToSwap != amount);
        numTokensToSwap = amount;
        emit UpdateNumTokensToSwap(amount);
    }


    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    //to receive ETH from pancakeswapV2Router when swapping
    receive() external payable {
        require(msg.sender == address(pancakeswapV2Router), "Only router is allowed");
    }

    function _getBuyFeeValues(uint256 tAmount) private view returns (uint256) {

        uint256 fee = tAmount.mul(_buyFee).div(10**2);
        uint256 tTransferAmount = tAmount.sub(fee);
        return tTransferAmount;
    }

    function _getSellFeeValues(uint256 tAmount) private view returns (uint256) {

        uint256 fee = tAmount.mul(_BNBFee + _PRFee + _liquidityFee).div(10**2);
        uint256 tTransferAmount = tAmount.sub(fee);
        return tTransferAmount;
    }

    function removeAllFee() private {
        if(_BNBFee == 0 && _liquidityFee == 0 && _PRFee == 0 && _buyFee == 0) return;

        _previousBNBFee = _BNBFee;
        _previousLiquidityFee = _liquidityFee;
        _previousPRFee = _PRFee;
        _previousBuyFee = _buyFee;

        _BNBFee = 0;
        _liquidityFee = 0;
        _PRFee = 0;
        _buyFee = 0;
    }

    function restoreAllFee() private {
        _BNBFee = _previousBNBFee;
        _liquidityFee = _previousLiquidityFee;
        _PRFee = _previousPRFee;
        _buyFee = _previousBuyFee;
    }

    function isExcludedFromFee(address account) external view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if(
            !_isExcludedFromFee[from] &&
        !_isExcludedFromFee[to] &&
        balanceOf(pancakeswapV2Pair) > 0 &&
        !inSwapAndLiquify &&
        from != address(pancakeswapV2Router) &&
        (from == pancakeswapV2Pair || to == pancakeswapV2Pair)
        ) {
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is pancakeswap pair.
        uint256 tokenBalance = balanceOf(address(this));
        if(tokenBalance >= _maxTxAmount)
        {
            tokenBalance = _maxTxAmount;
        }

        bool overMinTokenBalance = tokenBalance >= numTokensToSwap;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != pancakeswapV2Pair &&
            swapAndLiquifyEnabled &&
            block.timestamp >= lastSwapTime + swapCoolDownTime
        ) {
            tokenBalance = numTokensToSwap;
            swapAndCharge(tokenBalance);
            lastSwapTime = block.timestamp;
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = false;
        if (balanceOf(pancakeswapV2Pair) > 0 && (from == pancakeswapV2Pair || to == pancakeswapV2Pair)) {
            takeFee = true;
        }

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from,to,amount,takeFee);
    }

    function swapAndCharge(uint256 tokenBalance) private lockTheSwap {
        uint256 initialBalance = address(this).balance;

        uint256 liquidBalance = tokenBalance.mul(_liquidityFee).div(_liquidityFee + _BNBFee + _PRFee).div(2);
        tokenBalance = tokenBalance.sub(liquidBalance);
        swapTokensForEth(tokenBalance);

        uint256 newBalance = address(this).balance.sub(initialBalance);
        uint256 bnbForLiquid = newBalance.mul(liquidBalance).div(tokenBalance);
        addLiquidity(liquidBalance, bnbForLiquid);

        uint256 poolBalance = address(this).balance;
        uint256 prBalance = poolBalance.div(_BNBFee + _PRFee + _liquidityFee).mul(_PRFee);
        uint256 rewardBalance = poolBalance - prBalance;

        (bool r_success, ) = payable(bnbPoolAddress).call{value: rewardBalance}("");
        (bool p_success, ) = payable(prPoolAddress).call{value: prBalance}("");
        if(r_success && p_success) {
            emit SwapAndCharged(tokenBalance, liquidBalance, rewardBalance, prBalance, bnbForLiquid);
        }
    }


    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the pancakeswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeswapV2Router.WETH();

        if (allowance(address(this), address(pancakeswapV2Router)) <= tokenAmount) {
            _approve(address(this), address(pancakeswapV2Router), ~uint256(0));
        }


        // make the swap
        try pancakeswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        ) {
            emit SwapTokensForEth(true);
        } catch Error(string memory /*reason*/) {
            emit SwapTokensForEth(false);
        }
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios

        if (allowance(address(this), address(pancakeswapV2Router)) <= tokenAmount) {
            _approve(address(this), address(pancakeswapV2Router), ~uint256(0));
        }

        // add the liquidity
        try pancakeswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        ) {
            emit AddLiquidity(true);
        } catch Error(string memory /*reason*/) {
            emit AddLiquidity(false);
        }
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee)
            removeAllFee();
        uint256 tTransferAmount = amount;
        if (recipient == pancakeswapV2Pair) {
             tTransferAmount = _getSellFeeValues(amount);
        } else if (sender == pancakeswapV2Pair) {
            tTransferAmount = _getBuyFeeValues(amount);
        }

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(tTransferAmount);
        _balances[address(this)] = _balances[address(this)].add(amount.sub(tTransferAmount));
        emit Transfer(sender, recipient, tTransferAmount);
        emit Transfer(sender, address(this) , amount.sub(tTransferAmount));

        if(!takeFee)
            restoreAllFee();
    }
}
