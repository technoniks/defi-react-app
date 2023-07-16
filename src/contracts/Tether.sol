// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.0;

contract Tether {
	string public name = "Mock Tether";
	string public symbol = "nUSDT";
	// 1 million tethers to 1st account
	uint256 public totalSupply = 1000000000000000000000000;
	uint8 public decimals = 18;

	mapping(address => uint256) public balanceOf;
	mapping(address => mapping(address => uint256)) allowance;

	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(
		address indexed _owner,
		address indexed _spender,
		uint256 _value
	);

	constructor() public {
		balanceOf[msg.sender] = totalSupply;
	}

	function transfer(address _to, uint256 _value) public returns (bool) {
		require(balanceOf[msg.sender] >= _value);

		balanceOf[msg.sender] -= _value;
		balanceOf[_to] += _value;

		emit Transfer(msg.sender, _to, _value);
		return true;
	}

	function approve(address _spender, uint256 _value) public returns (bool) {
		allowance[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
	}

	function transferFrom(
		address _from,
		address _to,
		uint256 _value
	) public returns (bool) {
		require(_value <= balanceOf[_from]);
		require(_value <= allowance[_from][msg.sender]);

		balanceOf[_from] -= _value;
		balanceOf[_to] += _value;
		allowance[msg.sender][_from] -= _value;

		emit Transfer(_from, _to, _value);
		return true;
	}
}
