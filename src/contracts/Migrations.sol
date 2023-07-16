// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.0;

contract Migrations {
	address public owner;
	uint last_completed_migration;

	constructor() public {
		owner = msg.sender;
	}

	modifier restricted() {
		if (msg.sender == owner) _;
	}

	function setCompleted(uint completed) public restricted {
		last_completed_migration = completed;
	}

	function upgrade(address new_address) public restricted {
		Migrations upgrade = Migrations(new_address);
		upgrade.setCompleted(last_completed_migration);
	}
}
