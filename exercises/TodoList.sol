// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract TodoList { 
    struct Todo {
        string text;
        bool completed;
    }

    Todo[] public todos;

    function create(string calldata _text) public {
        todos.push(Todo({text: _text, completed: false}));
    }
    function update(uint index, string calldata _text) public {
        todos[index].text = _text;
        Todo storage todo = todos[index];
        todo.text = _text;
    }
    function get(uint index) public view returns (string memory, bool){
        Todo memory todo = todos[index];
        return(todo.text, todo.completed);
    }
    function toggle(uint index) public {
        todos[index].completed = !todos[index].completed;
    }
}