pragma solidity ^0.4.11;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }


}

contract TestToken is Ownable {
    using SafeMath for uint256;

    string public constant name = "TestToken";
    string public constant symbol = "TTT";
    uint32 public constant decimals = 18;

    uint256 public totalSupply;
uint256 public hardCap = 10 000 000 000 * 1 ether;
uint256 public minCap = 500 000 000 * 1 ether;

mapping(address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;

bool public mintingFinished = false;
bool public transferAllowed = false;

modifier canMint() {
require(!mintingFinished);
_;
}

modifier whenTransferAllowed() {
if(msg.sender != owner){
require(transferAllowed);
}
_;
}

/**
* @dev transfer token for a specified address
* @param _to The address to transfer to.
* @param _value The amount to be transferred.
*/
function transfer(address _to, uint256 _value) whenTransferAllowed public returns (bool) {
require(_to != address(0));

// SafeMath.sub will throw if there is not enough balance.
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}

/**
* @dev Gets the balance of the specified address.
* @param _owner The address to query the the balance of.
* @return An uint256 representing the amount owned by the passed address.
*/
function balanceOf(address _owner) public constant returns (uint256 balance) {
return balances[_owner];
}

/**
* @dev Transfer tokens from one address to another
* @param _from address The address which you want to send tokens from
* @param _to address The address which you want to transfer to
* @param _value uint256 the amount of tokens to be transferred
*/
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));

uint256 _allowance = allowed[_from][msg.sender];

// Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
// require (_value <= _allowance);

balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
return true;
}

/**
* @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
*
* Beware that changing an allowance with this method brings the risk that someone may use both the old
* and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
* race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
* https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
* @param _spender The address which will spend the funds.
* @param _value The amount of tokens to be spent.
*/
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}

/**
* @dev Function to check the amount of tokens that an owner allowed to a spender.
* @param _owner address The address which owns the funds.
* @param _spender address The address which will spend the funds.
* @return A uint256 specifying the amount of tokens still available for the spender.
*/
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}

/**
* @dev Function to mint tokens
* @param _to The address that will receive the minted tokens.
* @param _amount The amount of tokens to mint.
* @return A boolean that indicates if the operation was successful.
*/
function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
totalSupply = totalSupply.add(_amount);
balances[_to] = balances[_to].add(_amount);

Mint(_to, _amount);
Transfer(0x0, _to, _amount);
return true;
}

/**
* @dev Function to stop minting new tokens.
* @return True if the operation was successful.
*/
function finishMinting() onlyOwner public returns (bool) {
mintingFinished = true;
MintFinished();
return true;
}

/**
 * @dev Burns a specific amount of tokens.
 * @param _value The amount of token to be burned.
 */
function burn(uint256 _value) public {
require(_value > 0);

address burner = msg.sender;
balances[burner] = balances[burner].sub(_value);
totalSupply = totalSupply.sub(_value);
Burn(burner, _value);
}



event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
event Burn(address indexed burner, uint256 value);
event Mint(address indexed to, uint256 amount);
event MintFinished();
}

contract Crowdsale {
using SafeMath for uint256;

uint icoStartTime = ;   // 30.11.17
uint icoDays = 30;    // 30.12.17

uint preIcoStartTime = ;    // 20.11.17
uint preIcoDays = 5; // 25.11-17

// address where ETH funds are collected
address public wallet;

// addresses where Token funds are collected
address bonusForTeam;
address bonusForOwner;
address bonusForBounty;

uint bonusPercentTeam = 20;
uint bonusPercentOwner = 10;
uint bonusPercentBounty = 10;

TestToken public token;

modifier saleIsOn() {
require((now > preIcoStartTime && now < preIcoStartTime + preIcoDays * 1 days) || (now > icoStartTime && now < icoStartTime + icoDays * 1 days));
_;
}

modifier isUnderHardCap() {
require(totalSupply < = hardCap);
_;
}

function Crowdsale() {
require(icoStartTime >= now);
require(_endTime >= _startTime);


token = new TestToken();
}

function buyTokens(address beneficiary) saleIsOn isUnderHardCap public payable {
require(beneficiary != 0x0);

uint256 weiAmount = msg.value;

uint256 tokens;
tokens = weiAmount.mul();



token.mint(beneficiary, tokens);

// transferring incoming ETH
wallet.transfer(msg.value);
}

function() external payable {
buyTokens(msg.sender);
}
}



