//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// contract ScorpionNFT is ERC721, Ownable {
contract ScorpionNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    // keep track of tokenIds
    // Counters.Counter private _tokenIds;

    // address of marketplace for NFTs to interact
    // address public marketplaceAddress;

    // event NewNFTMint(address minter, uint tokenId);

    constructor() ERC721("ScorpionNFT", "SCPN") {
    // constructor(address _marketplaceAddress) ERC721("ScorpionNFT", "SCPN") {
        // marketplaceAddress = _marketplaceAddress;
        // _tokenIds.increment(); // tokenId start form 1
    }

    function mintToken() public returns (uint256 id) {
    // function mintToken() public payable returns (uint256 id) {
        // require(msg.value >= cost1);
        // (bool sent, bytes memory data) = minterAddress.call{value: cost1}("");
        // (bool sent, bytes memory data) = minterAddress.call{value: msg.value}("");

        // uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, id);
        // _mint(msg.sender, newItemId);
        // emit NewNFTMint(minterAddress, newItemId);
        // set the token URI: id and uri
        _setTokenURI(
            id,
            string(
                abi.encodePacked(
                    "https://scorpion-finance.mypinata.cloud/ipfs/QmR1bLXTtCRu14SRAXoLuHfdv6PyYm1pv6yLxLUSBfR7my/",
                    id.toString(),
                    ".json"
                )
            )
        );
        // give the marketplace the approval to transact between users
        // setApprovalForAll allows marketplace to do that with contract address
        // setApprovalForAll(marketplaceAddress, true);
        // increase tokenId for next NFT
        // _tokenIds.increment();

        // mint the token - return the id
        // return newItemId;
    }

    // function claim(address payable receiver) external onlyOwner {
    //     receiver.transfer(address(this).balance);
    // }

}
