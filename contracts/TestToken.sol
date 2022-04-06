pragma solidity ^0.8.0;
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Context.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import './IBEP20.sol';

contract TestToken is Context, IBEP20, Ownable
{
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    address public wsfBankContract;


    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    constructor() public {
        _name = "xWSF";
        _symbol = "xWSF";
        _decimals = 18;
        _totalSupply = 0;
        wsfBankContract = msg.sender;
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function setWSFBankContractAddress(address _contract) external onlyOwner {
        require(wsfBankContract != _contract, 'This address was already used');
        wsfBankContract = _contract;
    }

    function transferXWSFToHolder(uint256 amount, address recipient) {
        require(msg.sender == wsfBankContract);
        _balances[msg.sender] = amount;
        _totalSupply += amount;
    }

    function increaseBalance(uint256 amount, address recipient) {
        require(msg.sender == wsfBankContract);
        _balances[recipient] += amount;
        _totalSupply += amount;
    }

    function resetBalance(address recipient) {
        require(msg.sender == wsfBankContract);
        _totalSupply -= _balances[recipient];
        _balances[recipient] = 0;

    }

    /**
     * @dev Returns the bep token owner.
   */
    function getOwner() override external view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token decimals.
   */
    function decimals() override external view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
   */
    function symbol() override external view returns (string memory) {
        return _symbol;
    }

    /**
    * @dev Returns the token name.
  */
    function name() override external view returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
   */
    function totalSupply() override external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
   */
    function balanceOf(address account) override external view returns (uint256) {
        return _balances[account];
    }




}
