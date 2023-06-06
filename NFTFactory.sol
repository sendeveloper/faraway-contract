// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./NFTCollection.sol";

contract NFTFactory is Ownable {

    event CollectionCreated(address collection, string name, string symbol);

    constructor() {}

    function createCollection(string memory _name, string memory _symbol, string memory _baseURI) public onlyOwner {
        NFTCollection collection = new NFTCollection(_name, _symbol, _baseURI);
        emit CollectionCreated(address(collection), _name, _symbol);
    }
}