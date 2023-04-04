// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.18 <0.9.0;

contract exercise1 {

    struct Student {
        string name;
        uint age;
        bool exist;
    }

    mapping (address => Student) students;
    uint32 numStudents;
    Student [] allStudents;
    address [] studentAddress;

    function addMeToList(string memory _name, uint _age) public {
        require(students[msg.sender].exist == false);
        students[msg.sender] = Student(_name, _age, true);
        allStudents.push(students[msg.sender]);
        studentAddress.push(msg.sender);
        numStudents++;
    }

    function getMe() public view returns(Student memory) {
        return students[msg.sender];
    }

    function getAll() public view returns(Student [] memory) {
        return allStudents;
    }

    function getStudentById(uint8 id) public view returns(Student memory) {
        return (students[studentAddress[id]]);
    }
}