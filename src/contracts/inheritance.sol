// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

abstract contract BaseContract {
    int256 public x;
    address public owner;

    constructor() {
        x = 5;
        owner = msg.sender;
    }

    function setX(int256 _x) public virtual;
}

interface baseInterface {
    function setX(int256 _x) external;
}

contract A is BaseContract {
    int256 public y = 3;

    function setX(int256 _x) public override {
        x = _x;
    }
}
