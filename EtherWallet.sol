contract EtherWallet { 
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    receive() external payable {}

    function withdraw(uint _amount) external { 
        require(msg.sender == owner, "caller is not owner");
        
        (bool ok, ) =  msg.sender.call{value: _amount}("");
        require(ok, "failed to send ether");
    }

    function getBalance() external view returns(uint) {
        return address(this).balance;
    }
}