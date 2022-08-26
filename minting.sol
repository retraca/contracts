// SPDX-License-Identifier: GPL-3.0
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract MintBasic is ERC721Enumerable, Ownable {
  using Strings for uint256;

/* change address of contract*/
    address public tokenContract = 0x00;

    string public baseURI;
    string public orderBookURI;
    uint256 public cost = .0 ether;
    bool public paused = false;
    uint256 public maxSupply = 10000;
    uint256 public minted = 0;
    string public json = ".json";

/* change ERC721 constructor parameters*/
    constructor() ERC721('#mintingBasic', '#MiT') {}

  function order(uint256 minties) external {
    require(minties >= 0);
    require(minties <= 9999);
    require(!_exists(minties));
    uint256 wallet = orderWallet(msg.sender);
    require(wallet > 0);
    address target = IERC721(tokenContract).ownerOf(minties);
    require(target == msg.sender);
    _burn(wallet);
    _mint(msg.sender, minties);
  }

  function mint() external payable {
    require(!paused);
    uint256 supply = minted;
    require(supply + 1 <= maxSupply);
    require(msg.value >= cost);
    minted++;
    _mint(msg.sender, supply + 10000);
  }

  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setjson(string memory _newjson) public onlyOwner {
    json = _newjson;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }

  function withdraw() public payable onlyOwner {
    require(payable(msg.sender).send(address(this).balance));
  }

  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);}
    return tokenIds;
  }

    function orderWallet(address _owner)
    public
    view
    returns (uint256)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256 tokenId = 0;
    for (uint256 i; i < ownerTokenCount; i++) {
      if(tokenOfOwnerByIndex(_owner, i) > 9999){
      tokenId = tokenOfOwnerByIndex(_owner, i);}
    }
    return tokenId;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    if (tokenId >= 10000) {
    string memory currentBaseURI = orderBookURI;
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, '1', json))
        : "";}
    else {
    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), json))
        : "";}
  }

    function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

}