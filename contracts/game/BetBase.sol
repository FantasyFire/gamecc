pragma solidity ^0.4.0;

import "../token/ERC20/StandardToken.sol";

contract BetBase {

    // structure for single bet
    struct Gambling {
        uint8[] betAreas;
        mapping(address => uint256) stakes;
        mapping(address => uint8) playerBetAreas;
        uint256 totalStake;
        uint64 startedAt;
        uint64 duration;
    }

    mapping(uint256 => Gambling) public gamblings;

    StandardToken public erc20Contract;

    // todo: 
    event GamblingCreated();

    // todo:
    function _addGambling(uint256 _betId, Gambling _gambling) internal {
        require(_gambling.duration >= 10 minutes);
        gamblings[_betId] = _gambling;

        GamblingCreated();
    }

    // todo:
    function _closeGambling(uint256 _betId) internal {

    }

    // todo:
    function _chipIn(uint256 _betId, uint8 _betArea) internal {

    }

    // todo:
    function _isOnBet(Gambling storage _gambling) internal returns(bool) {
        return false;
    }
}
