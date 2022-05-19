// SPDX-License-Identifier: MIT
pragma solidity >=0.8.00 <=0.8.14;

contract CheckAccreditation {
    address owner;
    mapping (uint256=>bool) usedChecks;

    constructor() payable
    {
        require(msg.sender == owner);
    }

    modifier onlyOwner
    {
        require(msg.sender == owner);
        _;
    }

    function changeOwner(address _newOwner) public onlyOwner
    {
        owner = _newOwner;
    }

    function addBalance() public payable onlyOwner
    {

    }
    
    function getBalance() view public returns(uint256)
    {
        return address(this).balance;
    }

    function getOwner() view public returns(address)
    {
        return owner;
    }

    function withdrawBalance() public onlyOwner
    {
        payable(msg.sender).transfer(address(this).balance);
    }

    function accreditCheck(uint256 _amount,uint256 _checkNumber, bytes memory _signature) public
    {
        require(usedChecks[_checkNumber] == false, "El pago ya fue utilizado");
        usedChecks[_checkNumber] = false;

        bytes32 hash = keccak256(abi.encodePacked(msg.sender,_amount, _checkNumber, address(this)));
        hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));

        require(recoverSigner(hash,_signature)== owner);

        payable(msg.sender).transfer(_amount);
    }

    function recoverSigner(bytes32 _hash, bytes memory _signature) internal pure returns(address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v,r,s) = splitSignature(_signature);

        return ecrecover(_hash, v, r, s);
    }

    function splitSignature(bytes memory _signature) internal pure returns(uint8, bytes32,bytes32)
    {
        require(_signature.length == 65);

        uint8 v;
        bytes32 r;
        bytes32 s;

        assembly
        {
            r := mload(add(_signature,32))
            s := mload(add(_signature,64))
            v := byte(0,mload(add(_signature,96)))
        }

        return (v,r,s);
    }
}