pragma solidity ^0.4.0;

import "./SafeMath.sol";
import "./StandardToken.sol";

contract BetBase {
    using SafeMath for uint256;

    // 记录一次下注的信息
    struct Stake {
        uint8 betArea;
        uint256 value;
    }

    // 记录一场赌局的信息
    struct Gambling {
        uint8[] betAreas;
        address[] players;
        mapping(address => Stake) stakes;
        uint256 totalStake;
        uint64 startedAt;
        uint64 duration;
    }

    // 赌局id 到 赌局信息的映射
    mapping(uint256 => Gambling) public gamblings;

    // 赌局使用的代币合约
    StandardToken public erc20Contract;

    // events
    // todo: 赌局创建事件
    event GamblingCreated();
    // todo: 下注事件
    event ChipIn();
    // todo: 赌局结束事件
    event GamblingClosed();

    /// @dev DON'T give me your money.
    function() external {}

    // 增加一个赌局
    function _addGambling(uint256 _betId, Gambling _gambling) internal {
        gamblings[_betId] = _gambling;
        emit GamblingCreated();
    }

    // 结束赌局，分配赌金 考虑换个方法名close感觉不太合适
    function _closeGambling(Gambling storage _gambling) internal {
        // todo: 这个赢区将由一个接口获取
        // 假设已获得这局赢的下注区
        uint8 winBetArea = 1;
        // @notice 因为memory只能声明静态数组，这里以所有玩家数为数组长度，保证足够位置
        address[] memory winners = new address[](_gambling.players.length);
        uint256 totalWinStake = 0; // 赢的下注区的总赌注，用于计算赢区每人所得
        for (uint8 i = 0; i < _gambling.players.length; i++) {
            address player = _gambling.players[i];
            if (_gambling.stakes[player].betArea == winBetArea) {
                totalWinStake = totalWinStake.add(_gambling.stakes[player].value); // 累积赢区总赌注
                winners[i] = player;// 记录赢家
            }
        }
        // 分别发放奖金
        for (uint8 j = 0; j < winners.length; j++) {
            address winner = winners[j];
            if (winner != 0) {
                // todo: 这里应该检测erc20Contract是否为0
                // @notice 由于这里用的是uint256，尾数会被截去
                erc20Contract.transfer(winner, _gambling.totalStake * _gambling.stakes[winner].value / totalWinStake);
            }
        }
        emit GamblingClosed();
    }

    // 下注
    function _chipIn(Gambling storage _gambling, address _player, uint8 _betArea, uint256 _value) internal {
        // 一个玩家在一个赌局中只能下一次注
        _gambling.players.push(_player);
        _gambling.stakes[_player] = Stake(_betArea, _value);
        _gambling.totalStake = _gambling.totalStake.add(_value);
        emit ChipIn();
    }

    // 返回赌局是否正在进行
    function _isOnBet(Gambling storage _gambling) internal view returns(bool) {
        return _gambling.startedAt <= now && now <= _gambling.startedAt + _gambling.duration;
    }

    // 返回赌局是否存在
    function _gamblingExist(uint256 _betId) internal view returns(bool) {
        // @notice 暂认为startedAt不为0赌局就是存在的
        return gamblings[_betId].startedAt > 0;
    }
    // 返回玩家是否已经参与该赌局
    function _hasChippedIn(Gambling storage _gambling, address _player) internal view returns(bool) {
        return _gambling.stakes[_player].betArea != 0;
    }

    // 返回赌局中是否存在该下注区
    function _betAreaExist(Gambling storage _gambling, uint8 _betArea) internal view returns(bool res) {
        res = false;
        for (uint8 i = 0; i <= _gambling.betAreas.length; i++) {
            if (_gambling.betAreas[i] == _betArea) {
                res = true;
                break;
            }
        }
    }

    // 返回赌局是否可结束
    function _isReadyToClose(Gambling storage _gambling) internal view returns(bool res) {
        return _gambling.startedAt + _gambling.duration <= now;
    }
}
