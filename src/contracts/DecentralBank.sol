// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.0;

import "./RWD.sol";
import "./Tether.sol";

contract DecentralBank {
	string public name = "Decentral Bank";
	address public owner;
	Tether public tether;
	RWD public rwd;
	address[] public stakers;

	mapping(address => uint256) public stakingBalance;
	mapping(address => bool) public hasStaked;
	mapping(address => bool) public isStaking;

	constructor(Tether _tether, RWD _rwd) public {
		tether = _tether;
		rwd = _rwd;
		owner = msg.sender;
	}

	// Transfer tether tokens from caller(msg.sender) to contract address(bank) for staking
	function depositeTokens(uint _amount) public {
		require(_amount > 0, "amount cannot be less than 0");
		tether.transferFrom(msg.sender, address(this), _amount);
		stakingBalance[msg.sender] += _amount;

		if (!hasStaked[msg.sender]) {
			stakers.push(msg.sender);
		}
		isStaking[msg.sender] = true;
		hasStaked[msg.sender] = true;
	}

	function issueTokens() public {
		require(msg.sender == owner, "caller must be owner");
		for (uint i = 0; i < stakers.length; i++) {
			address recipient = stakers[i];
			uint balance = stakingBalance[recipient] / 9;
			if (balance > 0) {
				rwd.transfer(recipient, balance);
			}
		}
	}

	function unstakeTokens() public {
		uint balance = stakingBalance[msg.sender];
		require(balance > 0, "staking balance cannot be less than 0");

		tether.transfer(msg.sender, balance);
		stakingBalance[msg.sender] = 0;
		isStaking[msg.sender] = false;
	}
}
