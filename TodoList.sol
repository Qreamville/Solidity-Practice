// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract TodoList {

    struct Todo{
        string text;
        bool isComplete;
    }

    Todo[] public todos;

    function creatTodo(string calldata _text) external{
        todos.push(Todo(_text, false));
    }

    function editTodo(uint _index, string calldata _newText) external{
        todos[_index].text = _newText;
    }

    function completed(uint _index) external{
        todos[_index].isComplete = !todos[_index].isComplete;
    }
}
