//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Mr is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;
    // keep track of tokenIds
    Counters.Counter private _tokenIds;

    // address of marketplace for NFTs to interact
    address public marketplaceAddress;

    constructor(address _marketplaceAddress) ERC721("MonProfile", "MP") {
        marketplaceAddress = _marketplaceAddress;
        _tokenIds.increment(); // tokenId start form 1

        for(uint i=0; i<5; i++) mintToken();
    }

    function mintToken() public onlyOwner returns (uint256) {
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);

        // set the token URI: id and uri
        _setTokenURI(
            newItemId,
            string(
                abi.encodePacked(
                    "https://test-mr-monmeta.s3.ap-southeast-1.amazonaws.com/json/",
                    newItemId.toString(),
                    ".json"
                )
            )
        );
        // give the marketplace the approval to transact between users
        // setApprovalForAll allows marketplace to do that with contract address
        setApprovalForAll(marketplaceAddress, true);
        // increase tokenId for next NFT
        _tokenIds.increment();

        // mint the token - return the id
        return newItemId;
    }
}
