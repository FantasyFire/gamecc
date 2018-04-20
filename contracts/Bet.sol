pragma solidity ^0.4.0;

import "./BetBase.sol";
import "./StandardToken.sol";

contract Bet is BetBase {

    address public ceoAddress;

    bool public isBetContract = true;
    
    /// @dev Access modifier for CEO-only functionality
    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    /// @dev 
    /// @param _erc20Address - address of a deployed contract implementing
    ///  the ERC20 token interface
    /// @param _cut - percent cut the owner takes on each bet, must be 0-10,000.
    function Bet(address _erc20Address, uint256 _cut) public {
        require(_cut <= 10000);

        ceoAddress = msg.sender;

        StandardToken candidateContract = StandardToken(_erc20Address);
        erc20Contract = candidateContract;
    }

    // 创建一局赌局
    function createGambling(uint256 _betId, uint8[] betAreas, uint64 duration) public onlyCEO {
        // @notice 暂定每个赌局必须持续10分钟以上
        require(duration >= 10 minutes);
        require(!_gamblingExist(_betId));
        address[] storage players;
        Gambling memory _gambling = Gambling(
            betAreas,
            players,
            uint256(0),
            uint64(now),
            duration
        );
        _addGambling(_betId, _gambling);
    }

    // 下注，仅允许绑定的erc20合约调用
    function chipIn(uint256 _betId, address _player, uint8 _betArea, uint256 _value) public {
        require(msg.sender == address(erc20Contract));
        require(_gamblingExist(_betId));
        Gambling storage _gambling = gamblings[_betId];
        require(!_hasChippedIn(_gambling, _player));
        require(_betAreaExist(_gambling, _betArea));
        _chipIn(_gambling, _player, _betArea, _value);
    }

    // 结束一局赌局
    function closeGambling(uint256 _betId) public onlyCEO {
        require(_gamblingExist(_betId));
        Gambling storage _gambling = gamblings[_betId];
        require(_isReadyToClose(_gambling));
        _closeGambling(_gambling);
    }

    function withdrawERC20() public onlyCEO {
        // todo: 这里应该检测erc20Contract是否为0
        erc20Contract.transfer(ceoAddress, erc20Contract.balanceOf(this));
    }

    // 返回能否下注
    function canChipIn(uint256 _betId, address _player, uint8 _betArea) public view returns(bool res) {
        res = _gamblingExist(_betId);
        if (res) {
            Gambling storage _gambling = gamblings[_betId];
            res = !_hasChippedIn(_gambling, _player) && _betAreaExist(_gambling, _betArea);
        }
    }
}
