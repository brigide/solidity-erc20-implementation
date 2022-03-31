// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

import "./feicoin.sol";

contract FEICoinICO is FEICoin {
    address public admin;
    address payable public deposit;
    uint256 tokenPrice = 0.001 ether;
    uint256 public hardcap = 300 ether;
    uint256 public raisedAmount;
    uint256 public saleStart = block.timestamp;
    uint256 public saleEnd = block.timestamp + 604800; //ends in one week
    uint256 public tokenTradeStart = saleEnd + 604800;

    uint256 public maxInvestment = 5 ether;
    uint256 public minInvestment = 0.1 ether;

    enum State {
        BeforeStart,
        Running,
        AfterEnd,
        Halted
    }
    State public icoState;

    constructor(address payable _deposit) {
        deposit = _deposit;
        admin = msg.sender;
        icoState = State.BeforeStart;
    }

    modifier authorizeAdmin() {
        require(msg.sender == admin);
        _;
    }

    function halt() public authorizeAdmin {
        icoState = State.Halted;
    }

    function resume() public authorizeAdmin {
        icoState = State.Running;
    }

    function changeDepositAccount(address payable _deposit)
        public
        authorizeAdmin
    {
        deposit = _deposit;
    }

    function getCurrentState() public view returns (State) {
        if (icoState == State.Halted) return icoState;

        if (block.timestamp < saleEnd) return State.BeforeStart;

        if (block.timestamp >= saleStart && block.timestamp <= saleEnd)
            return State.Running;

        return State.AfterEnd;
    }

    event Invest(address investor, uint256 value, uint256 tokens);

    function invest() public payable returns (bool) {
        icoState = getCurrentState();
        require(icoState == State.Running);

        require(msg.value >= minInvestment && msg.value <= maxInvestment);
        raisedAmount += msg.value;
        require(raisedAmount <= hardcap);

        uint256 tokens = msg.value / tokenPrice;

        balances[msg.sender] += tokens;
        balances[founder] -= tokens;
        deposit.transfer(msg.value);
        emit Invest(msg.sender, msg.value, tokens);

        return true;
    }

    receive() external payable {
        invest();
    }

    function transfer(address to, uint256 tokens)
        public
        override
        returns (bool success)
    {
        require(block.timestamp > tokenTradeStart);
        super.transfer(to, tokens); //same as FEICoin.transfer(to, tokens);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public override returns (bool success) {
        require(block.timestamp > tokenTradeStart);
        super.transferFrom(from, to, tokens);

        return true;
    }

    function burn() public returns (bool) {
        icoState = getCurrentState();
        require(icoState == State.AfterEnd);

        balances[founder] = 0;

        return true;
    }
}
