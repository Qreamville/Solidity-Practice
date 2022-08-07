// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract MarksManagementSystem {
    // Student details
    struct Student {
        uint Id;
        string name;
        int mark;
    }

    address owner;
    uint studentCount = 0;
    mapping(uint => Student) public allStudent;

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Access denied");
        _;
    }

    function addStudent(uint _id, string memory _name, int _mark) external onlyOwner{
        studentCount += 1;
        allStudent[studentCount] = Student(_id, _name, _mark);
    }

    function increaseMark(int _bonusMark, uint _student) external onlyOwner{
        allStudent[_student].mark = allStudent[_student].mark + _bonusMark;
    }
}
