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
    Counters.Counter public tokensSold;
    Counters.Counter public Count_Minted;
    Counters.Counter public Count_Listed;

    address public ScorpionNFTAddr;

    uint256 public cost1 = 0.005 ether;
    uint256 public cost2 = 0.0125 ether;
    uint256 public cost3 = 0.025 ether;
    uint256 public cost4 = 0.05 ether;

    uint256 public royalties = 10;
    uint256 public minMspc = 0;
    uint256 public maxGiveAway = 1;

    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable author;
        address payable holder;
        uint256 price;
        bool sold;
        bool minted;
        uint256 level;
    }

    // tokenId return which MarketToken
    mapping(uint256 => MarketItem) public idToMarketItem;

    // listen to events from front end applications
    event MarketItemMinted(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address author,
        address holder,
        uint256 price,
        uint256 timeStamp,
        bool sold
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
        uint256 i = uint256(1);

        //set super founder level to nfts
        for(i = 1;i<=25; i++) {
            makeMarketItem(uint256(4), i);
        }

        //set founder level to nfts
        for(i = 26;i<=115; i++) {
            makeMarketItem(uint256(3), i);
        }

        //set rare level to nfts
        for(i = 116;i<=167; i++) {
            makeMarketItem(uint256(2), i);
        }

        //set limited edition level to nfts
        for(i = 168;i<=307; i++) {
            makeMarketItem(uint256(1), i);
        }
    }

    function makeMarketItem(uint256 level, uint256 id) private {
        uint256 price = 1;

        if(level == uint256(4))
            price = cost4;
        else if(level == uint256(3))
            price = cost3;
        else if(level == uint256(2))
            price = cost2;
        else if(level == uint256(1))
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

        // itemIds.increment(); // start from 1
        Count_Minted.increment(); // start from 1

        // uint256 itemId = itemIds.current();

        //putting it up for sale
        // MarketItem memory tmp_item = idToMarketItem[itemId];
        idToMarketItem[_tokenId].holder = payable(msg.sender);
        idToMarketItem[_tokenId].nftContract = ScorpionNFTAddr;
        idToMarketItem[_tokenId].author = payable(msg.sender);
        idToMarketItem[_tokenId].minted = true;
        idToMarketItem[_tokenId].sold = false;

        // NFT transaction
        // IERC721(ScorpionNFTAddr).transferFrom(msg.sender, address(this), _tokenId);
        // IERC721(ScorpionNFTAddr).transferFrom(address(this), msg.sender, _tokenId);
        // ScorpionNFT(ScorpionNFTAddr).mintToken(_tokenId);
        payable(msg.sender).transfer(_tokenId);

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
    }

    //@notice function to conduct transactions and market sales
    //@params _nftContract Address of nft contract
    //@params  _itemId Id of nft token on marketplace
    function purchaseMarketItemByUsdt(
        address _nftContract,
        uint256 _itemId,
        uint256 _amountOfUsdt
    ) public nonReentrant {
        require(
            IERC721(_nftContract).balanceOf(msg.sender) < maxGiveAway,
            "No more available.!"
        );
        // uint256 price = idToMarketItem[_itemId].usdtPrice;
        // require(_amountOfUsdt == price, "Not enough USDT");

        uint256 tokenId = idToMarketItem[_itemId].tokenId;
        address preHolder = idToMarketItem[_itemId].holder;

        idToMarketItem[_itemId].holder = payable(msg.sender);
        idToMarketItem[_itemId].sold = true;

        // transfer the amount to the author
        // idToMarketItem[itemId].author.transfer(msg.value);
        // if (preHolder != address(0)) {
        //     uint256 amountToShareAuthor = (((price) * (royalties))) / 100;
        //     uint256 amountToHolder = price - amountToShareAuthor;
        //     usdt.transferFrom(
        //         msg.sender,
        //         idToMarketItem[_itemId].author,
        //         amountToShareAuthor
        //     );

        //     usdt.transferFrom(
        //         msg.sender,
        //         idToMarketItem[_itemId].holder,
        //         amountToHolder
        //     );
        // } else {
        //     usdt.transferFrom(
        //         msg.sender,
        //         idToMarketItem[_itemId].author,
        //         price
        //     );
        // }

        tokensSold.increment();

        // transfer the token from contract address to the buyer
        IERC721(_nftContract).transferFrom(address(this), msg.sender, tokenId);

        emit MarketItemPurchased(
            _itemId,
            _nftContract,
            tokenId,
            preHolder,
            msg.sender,
            0,
            block.timestamp
        );
    }

    function purchaseMarketItemByMspc(
        address _nftContract,
        uint256 _itemId,
        uint256 _amountOfMspc
    ) public nonReentrant {
        require(
            IERC721(_nftContract).balanceOf(msg.sender) < maxGiveAway,
            "No more available.!"
        );

        require(_amountOfMspc >= minMspc, "Not enough MSPC");

        uint256 tokenId = idToMarketItem[_itemId].tokenId;
        address preHolder = idToMarketItem[_itemId].holder;

        idToMarketItem[_itemId].holder = payable(msg.sender);
        idToMarketItem[_itemId].sold = true;

        // transfer the amount to the author
        // if (preHolder != address(0)) {
        //     uint256 amountToShareAuthor = (((_amountOfMspc) * (royalties))) /
        //         100;

        //     uint256 amountToHolder = _amountOfMspc - amountToShareAuthor;
        //     mspc.transferFrom(
        //         msg.sender,
        //         idToMarketItem[_itemId].author,
        //         amountToShareAuthor
        //     );

        //     mspc.transferFrom(
        //         msg.sender,
        //         idToMarketItem[_itemId].holder,
        //         amountToHolder
        //     );
        // } else {
        //     mspc.transferFrom(
        //         msg.sender,
        //         idToMarketItem[_itemId].holder,
        //         _amountOfMspc
        //     );
        // }

        tokensSold.increment();

        // transfer the token from contract address to the buyer
        IERC721(_nftContract).transferFrom(address(this), msg.sender, tokenId);

        emit MarketItemPurchased(
            _itemId,
            _nftContract,
            tokenId,
            preHolder,
            msg.sender,
            // _amountOfMspc,
            0,
            block.timestamp
        );
    }

    // @notice function to fetchMarketItems - minting, buying ans selling
    // @return the number of unsold items
    function fetchMarketItemByAddress(address _nftContract)
        external
        view
        returns (MarketItem[] memory)
    {
        uint256 itemCount = itemIds.current();
        uint256 unsoldItemCount = itemIds.current() - tokensSold.current();
        uint256 currentIndex = 0;

        // looping over the number of items created (if number has not been sold populate the array)
        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].holder == address(0)) {
                if (idToMarketItem[i + 1].nftContract == _nftContract) {
                    uint256 currentId = i + 1;
                    MarketItem memory currentItem = idToMarketItem[currentId];
                    items[currentIndex] = currentItem;
                    currentIndex += 1;
                }
            }
        }
        return items;
    }

    function fetchMarketItemsWithCursor(uint256 cursor, uint256 howMany)
        external
        view
        returns (MarketItem[] memory, uint256 newCursor)
    {
        uint256 itemCount = itemIds.current();
        uint256 currentIndex = 0;
        uint k = 0;
        /*
        if (length > itemCount - cursor) {
            length = itemCount - cursor;
        }
        */

        MarketItem[] memory items = new MarketItem[](howMany);

        for (uint256 i = 1; i <= itemCount; i++) {
            if (idToMarketItem[i].holder == address(0)) {
                if (k >= cursor) {
                    items[currentIndex++] = idToMarketItem[i];
                    if (currentIndex==howMany) break;
                }
                k++;
            }
        }

        return (items, cursor + k);
    }

    function getMarketItemCount() external view returns (uint256) {
        uint256 marketItemCount = itemIds.current() - tokensSold.current();
        return marketItemCount;
    }

    // return nfts that the user has purchased
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = itemIds.current();
        // a second counter for each individual user
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].holder == msg.sender) {
                itemCount += 1;
            }
        }

        // second loop to loop through the amount you have purchased with itemcount
        // check to see if the holder address is equal to msg.sender
        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].holder == msg.sender) {
                uint256 currentId = idToMarketItem[i + 1].itemId;
                // current array
                MarketItem memory currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    // function for returning an array of minted nfts
    function fetchItemsCreated() public view returns (MarketItem[] memory) {
        // instead of .holder it will be the .author
        uint256 totalItemCount = itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].author == msg.sender) {
                itemCount += 1;
            }
        }

        // second loop to loop through the amount you have purchased with itemcount
        // check to see if the holder address is equal to msg.sender
        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].author == msg.sender) {
                uint256 currentId = idToMarketItem[i + 1].itemId;
                MarketItem memory currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function setMinMspc(uint256 _minMspc) external onlyOwner {
        minMspc = _minMspc;
    }

    function setRoyalties(uint256 _royalties) external onlyOwner {
        royalties = _royalties;
    }

    function setMaxGiveAway(uint256 _msxGiveAway) external onlyOwner {
        maxGiveAway = _msxGiveAway;
    }

    function updateMspcPriceById(uint256 _nftId, uint256 _newPrice)
        external
        onlyHolder(_nftId)
    {
        // idToMarketItem[_nftId].mspcPrice = _newPrice;
    }

    function updateUsdtPriceById(uint256 _nftId, uint256 _newPrice)
        external
        onlyHolder(_nftId)
    {
        // idToMarketItem[_nftId].usdtPrice = _newPrice;
    }

    function changeMspcPriceById(uint256 _nftId, uint256 _newPrice)
        external
        onlyOwner
    {
        // idToMarketItem[_nftId].mspcPrice = _newPrice;
    }

    function changeUsdtPriceById(uint256 _nftId, uint256 _newPrice)
        external
        onlyOwner
    {
        // idToMarketItem[_nftId].usdtPrice = _newPrice;
    }

    modifier onlyHolder(uint256 _nftId) {
        require(
            msg.sender == idToMarketItem[_nftId].holder,
            "Authorization denied"
        );
        _;
    }
}
