// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract GameToken {
    uint256 _totalSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Exchange(address indexed _buyer, uint256 _value);

    constructor(uint256 startingAmount) {
        _totalSupply = startingAmount;
        balances[msg.sender] = _totalSupply;
    }
    
    function name() public pure returns (string memory) {
        return "Game Token";
    }

    function symbol() public pure returns (string memory) {
        return "GAME";
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] > _value, "Insufficient balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(allowance(_from, _to) >= _value, "Allowance insufficient");
        require(balanceOf(_from) >= _value, "Insufficient balance");

        // First we reduce the allowance
        allowances[_from][_to] -= _value;

        // Then we make the changes
        balances[_from] -= _value;
        balances[_to] += _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }

    function exchange() public payable {
        // For every 1 ether, you get 1 token
        require(msg.value >= 0.1 ether, "1 token costs 0.1 ether");

        // Count the tokens exchanged
        uint256 tokens = msg.value / 0.1 ether;

        // Set state
        _totalSupply += tokens;
        balances[msg.sender] += tokens;

        emit Exchange(msg.sender, tokens);
    }
}