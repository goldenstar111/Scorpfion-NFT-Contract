//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; // security against transactions for multiple requests
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./NFT.sol";

contract Marketplace is Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;

    Counters.Counter public itemIds;
    Counters.Counter public Count_Minted;
    Counters.Counter public Count_Listed;

    address public ScorpionNFTAddr;

    uint256 public cost1 = 0.005 ether;
    uint256 public cost2 = 0.0125 ether;
    uint256 public cost3 = 0.025 ether;
    uint256 public cost4 = 0.05 ether;

    uint256 public royalties = 10;

    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable author;
        address payable holder;
        uint256 price;
        bool listed;
        bool minted;
        uint256 level;
    }

    // tokenId return which MarketToken
    mapping(uint256 => MarketItem) public idToMarketItem;
    // Id List return by holder
    mapping(address => uint256[]) private holderToItems;

    // listen to events from front end applications
    event MarketItemMinted(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address author,
        address holder,
        uint256 price,
        uint256 timeStamp,
        bool listed
    );

    event MarketItemListed(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address author,
        address holder,
        uint256 price,
        uint256 timeStamp,
        bool listed
    );

    event MarketItemPurchased(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address from,
        address to,
        uint256 price,
        uint256 timeStamp
    );

    constructor() {

    }
    
    function setScorp(address addr) public onlyOwner {
        ScorpionNFTAddr = addr;
    }

    function check_minted(uint256 id) public view returns (bool) {
        return idToMarketItem[id].minted;
    }

    function initNFTLevels() public onlyOwner {
        uint256 i;

        //set super founder level to nfts
        for(i = 1;i<=25; i++) {
            makeMarketItem(4, i);
        }

        //set founder level to nfts
        for(i = 26;i<=115; i++) {
            makeMarketItem(3, i);
        }

        //set rare level to nfts
        for(i = 116;i<=167; i++) {
            makeMarketItem(2, i);
        }

        //set limited edition level to nfts
        for(i = 168;i<=307; i++) {
            makeMarketItem(1, i);
        }

        //set super founder level to nfts island
        for(i = 308;i<=311; i++) {
            makeMarketItem(4, i);
        }

        //set founder level to nfts island
        for(i = 312;i<=322; i++) {
            makeMarketItem(3, i);
        }

        //set rare level to nfts island
        for(i = 323;i<=347; i++) {
            makeMarketItem(2, i);
        }

        //set limited edition level to nfts island
        for(i = 348;i<=407; i++) {
            makeMarketItem(1, i);
        }
    }

    function makeMarketItem(uint256 level, uint256 id) public onlyOwner {
        require(idToMarketItem[id].minted == false, "This item is already minted.");
        uint256 price = 1;

        if(level == 4)
            price = cost4;
        else if(level == 3)
            price = cost3;
        else if(level == 2)
            price = cost2;
        else if(level == 1)
            price = cost1;

        idToMarketItem[id] = MarketItem(
            id,
            address(0),
            id,
            payable(address(0)),
            payable(address(0)),
            price,
            false,
            false,
            level
        );
    }
   
    function claim(address payable receiver) external onlyOwner {
        receiver.transfer(address(this).balance);
    }

    // @notice function to create a market to put it up for sale
    // @params _nftContract
    function mintMarketItem(
        uint256 _tokenId
    ) public payable nonReentrant {
        require(idToMarketItem[_tokenId].minted == false, "This NFT Id is already minted");

        uint256 _defaultprice = idToMarketItem[_tokenId].price;
        require(msg.value >= _defaultprice, "This NFT should be paid to mint");

        ScorpionNFT(ScorpionNFTAddr).mintToken(_tokenId);
        Count_Minted.increment();

        //putting it up for sale
        idToMarketItem[_tokenId].holder = payable(msg.sender);
        idToMarketItem[_tokenId].nftContract = ScorpionNFTAddr;
        idToMarketItem[_tokenId].author = payable(msg.sender);
        idToMarketItem[_tokenId].minted = true;
        idToMarketItem[_tokenId].listed = false;

        // NFT transaction
        IERC721(ScorpionNFTAddr).transferFrom(address(this), msg.sender, _tokenId);
        
        addItemsbyHolder(msg.sender, _tokenId);

        emit MarketItemMinted(
            _tokenId,
            ScorpionNFTAddr,
            _tokenId,
            msg.sender,
            msg.sender,
            _defaultprice,
            block.timestamp,
            false
        );
        
        ScorpionNFT(ScorpionNFTAddr).setApprovalForAll(ScorpionNFTAddr, true);
    }

function mintMarketItemToList(
        uint256 _tokenId,
        uint256 _price
    ) public payable nonReentrant {
        require(idToMarketItem[_tokenId].minted == false, "This NFT Id is already minted");

        uint256 _defaultprice = idToMarketItem[_tokenId].price;
        require(msg.value >= _defaultprice, "This NFT should be paid to mint");

        ScorpionNFT(ScorpionNFTAddr).mintToken(_tokenId);

        Count_Minted.increment();
        Count_Listed.increment();

        //putting it up for sale
        idToMarketItem[_tokenId].holder = payable(msg.sender);
        idToMarketItem[_tokenId].nftContract = ScorpionNFTAddr;
        idToMarketItem[_tokenId].author = payable(msg.sender);
        idToMarketItem[_tokenId].minted = true;
        
        idToMarketItem[_tokenId].listed = true;
        idToMarketItem[_tokenId].price = _price;

        // NFT transaction
        IERC721(ScorpionNFTAddr).transferFrom(address(this), msg.sender, _tokenId);

        addItemsbyHolder(msg.sender, _tokenId);

        emit MarketItemMinted(
            _tokenId,
            ScorpionNFTAddr,
            _tokenId,
            msg.sender,
            msg.sender,
            _defaultprice,
            block.timestamp,
            true
        );
        
        ScorpionNFT(ScorpionNFTAddr).setApprovalForAll(ScorpionNFTAddr, true);
    }

    function gettokenURI(uint256 _id) public view returns(string memory) {
        string memory result_str = idToMarketItem[_id].minted ? ScorpionNFT(ScorpionNFTAddr).tokenURI(_id) : "";
        return result_str;
    }

    function ownerOf(uint256 _id) public view returns(address){
        address addr = idToMarketItem[_id].minted ? ScorpionNFT(ScorpionNFTAddr).ownerOf(_id) : address(0);
        return addr;
    }

    function balanceOf(address _addr) public view returns(uint256){
        return ScorpionNFT(ScorpionNFTAddr).balanceOf(_addr);
    }

    function dropNFTById(uint256 _id) public onlyHolder(_id){
        idToMarketItem[_id].listed = false;
        Count_Listed.decrement();
    }

    function updatePriceById(uint256 _id, uint256 _price) public onlyHolder(_id) {
        require(msg.sender == ownerOf(_id), "2.You are not owner of Token.");

        if(idToMarketItem[_id].listed == false)
            Count_Listed.increment();

        idToMarketItem[_id].listed = true;
        idToMarketItem[_id].price = _price;
        
        emit MarketItemListed(
            _id,
            ScorpionNFTAddr,
            _id,
            idToMarketItem[_id].author,
            msg.sender,
            _price,
            block.timestamp,
            true
        );
    }

    function getPriceById(uint256 _id) public view returns (uint256) {
        return idToMarketItem[_id].price;
    }

    function purchaseItem(uint256 _id) public payable {
        require(idToMarketItem[_id].minted == true, "Not Minted.");
        require(idToMarketItem[_id].listed == true, "Not Listed.");
        require(idToMarketItem[_id].price <= msg.value, "Not enough BNB to purchase item.");

        IERC721(ScorpionNFTAddr).transferFrom(idToMarketItem[_id].holder, msg.sender, _id);

        addItemsbyHolder(msg.sender, _id);
        removeItemsbyHolder(idToMarketItem[_id].holder, _id);

        payable(idToMarketItem[_id].holder).transfer(idToMarketItem[_id].price);

        emit MarketItemPurchased(
            _id,
            ScorpionNFTAddr,
            _id,
            idToMarketItem[_id].holder,
            msg.sender,
            idToMarketItem[_id].price,
            block.timestamp
        );

        idToMarketItem[_id].holder = payable(msg.sender);
        idToMarketItem[_id].listed = false;
        Count_Listed.decrement();
        
        ScorpionNFT(ScorpionNFTAddr).setApprovalForAll(ScorpionNFTAddr, true);
    }

    function addItemsbyHolder(address _holder, uint256 _id) private {
        holderToItems[_holder].push(_id);
    }

    function itemsbyholder(address _holder) public view returns (uint256[] memory) {
        return holderToItems[_holder];
    }

    function removeItemsbyHolder(address _holder, uint256 _id) private {
        uint256 _len = holderToItems[_holder].length;
        for (uint256 index = 0; index < _len; index++) {
            if(holderToItems[_holder][index] == _id){
                holderToItems[_holder][index] = holderToItems[_holder][_len-1];
                holderToItems[_holder].pop();
                break;
            }
        }
    }

    // return nfts that the user has purchased
    function fetchMyNFTs(address _holder) public view returns (MarketItem[] memory) {
        uint256[] memory tmp_items = itemsbyholder(_holder);
        MarketItem[] memory items = new MarketItem[](tmp_items.length);
        
        for (uint256 index = 0; index < tmp_items.length; index++) {
            items[index] = idToMarketItem[tmp_items[index]];
        }

        return items;
    }

    function setRoyalties(uint256 _royalties) external onlyOwner {
        royalties = _royalties;
    }

    modifier onlyHolder(uint256 _nftId) {
        require(
            msg.sender == idToMarketItem[_nftId].holder,
            "Authorization denied"
        );
        _;
    }
}
