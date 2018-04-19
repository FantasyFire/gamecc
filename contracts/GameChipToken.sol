pragma solidity ^0.4.21;


import "./token/ERC20/StandardToken.sol";
import "./ownership/Ownable.sol";


/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 */
contract GameChipToken is StandardToken, Ownable {

    string public constant name = "Game Chip Coin";
    string public constant symbol = "GCC";
    //没有小数位，1 ETH = 10**6 GCT
    uint8 public constant decimals = 0;

    uint256 public constant INITIAL_SUPPLY = 100000000000000000000 * (10 ** uint256(decimals));

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    function GameChipToken() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }

    /**
    * @dev transfer to payees in batch. When player charge ETH, system will call this function to exchange GCC to player instead.
    */
    function batchTransfer(address[] _payees, uint256[] _values)  public onlyOwner returns(bool){
        require(_payees.length == _values.length);
        uint256 _sum = _summary(_values);
        require(balances[msg.sender] > _sum);

        address _from = msg.sender;
        for(uint256 i=0; i<_payees.length; i++){
            //wrong address will pass away.
            address _to = _payees[i];
            if(_to == address(0)){
                continue;
            }

            //wrong value will pass away.
            uint256 _value = _values[i];
            if(_value == 0){
                continue;
            }

            balances[_from] = balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_value);
            emit Transfer(_from, _to, _value);
        }

        return true;
    }

    /**
    * @dev Withdraw GCC from payers when player want to exchage to ETH. System will call this function before transfer ETH to player address.
    */
    function batchReclaim(address[] _payers, uint256[] _values) public onlyOwner returns(bool){
        require(_payers.length == _values.length);

        uint256 _sum = _summary(_values);
        require(_sum > 0);
        require(balances[msg.sender] + _sum < INITIAL_SUPPLY);

        for(uint256 i=0; i<_payers.length; i++){
            address _from = _payers[i];
            if(_from == address(0)){
                continue;
            }

            uint256 _value = _values[i];
            if(_value == 0 || balances[_from] < _value){
                continue;
            }

            balances[_from] = balances[_from].sub(_value);
            balances[msg.sender] = balances[msg.sender].add(_value);
            emit Transfer(_from, msg.sender, _value);
        }

        return true;
    }

    /**
    * @dev calc sum of value array.
    */
    function _summary(uint256[] _values) internal view returns(uint256){
        require(_values.length>0);
        uint256 _sum = 0;
        for(uint256 i=0; i<_values.length; i++){
            uint256 __sum = _sum;
            _sum += _values[i];
            require(_sum >= __sum);
        }

        return _sum;
    }
}
