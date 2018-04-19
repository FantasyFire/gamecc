pragma solidity ^0.4.0;

import "./BetBase.sol";
import "../token/ERC20/BasicToken.sol";

contract Bet is BetBase {
    /// @dev 
    /// @param _erc20Address - address of a deployed contract implementing
    ///  the ERC20 token interface
    /// @param _cut - percent cut the owner takes on each bet, must be 0-10,000.
    function Bet(address _erc20Address, uint256 _cut) public {
        require(_cut <= 10000);
        StandardToken candidateContract = StandardToken(_erc20Address);
        erc20Contract = candidateContract;
    }
}
