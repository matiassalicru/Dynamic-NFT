//Begin
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";

contract audiA4Models is ERC721, ERC721URIStorage, KeeperCompatibleInterface {
    using Counters for Counters.Counter;

    Counters.Counter public tokenIdCounter;
 
   // Metadata information for each stage of the NFT on IPFS.
    string[] IpfsUri = [
        "https://gateway.pinata.cloud/ipfs/QmWDLNNbAuoda9cTYny8EZvS7VM7VSeLq9eLEhhcM4pbZ8",
        "https://gateway.pinata.cloud/ipfs/QmcNqSLgX1otzRsMKQRxBaafKyZ9Bcd59mfsTFZs7iUdxd",
        "https://gateway.pinata.cloud/ipfs/QmW8uD8xLhyJq5ehbMpyu7B3QAHJRXL3SBfsiKSxYx8HMR",
        "https://gateway.pinata.cloud/ipfs/QmbFdN47s29JJKGxoazCa2vyF963TZYRCfaQjr4YZnayg4",
        "https://gateway.pinata.cloud/ipfs/QmNyiyigMyQUdHVcKd3oihc9cW4Q6PnV7ZDHwghk7y8PNZ"
    ]; 

    uint256 lastTimeStamp;
    uint256 interval;

    constructor(uint _interval) ERC721("Audi A4 Models", "AUDIA4") {
        interval = _interval;
        lastTimeStamp = block.timestamp;
    }

    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /* performData */) {
        uint256 tokenId = tokenIdCounter.current() - 1;
        bool done;
        if (carModelStage(tokenId) >= 4) {
            done = true;
        }
        upkeepNeeded = !done && ((block.timestamp - lastTimeStamp) > interval);        
        // We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        //We highly recommend revalidating the upkeep in the performUpkeep function
        if ((block.timestamp - lastTimeStamp) > interval ) {
            lastTimeStamp = block.timestamp;            
            uint256 tokenId = tokenIdCounter.current() - 1;
            getNewCarModel(tokenId);
        }
        // We don't use the performData in this example. The performData is generated by the Keeper's call to your checkUpkeep function
    }

    function safeMint(address to) public {
        uint256 tokenId = tokenIdCounter.current();
        tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, IpfsUri[0]);
    }

    function getNewCarModel(uint256 _tokenId) public {
        // Since we have 5 stages now, we change the 2 for a 4
        if(carModelStage(_tokenId) >= 4){return;}
        // Get the current stage of the car models and add 1
        uint256 newVal = carModelStage(_tokenId) + 1;
        // store the new URI
        string memory newUri = IpfsUri[newVal];
        // Update the URI
        _setTokenURI(_tokenId, newUri);
    }

    // determine the stage of the car models
    function carModelStage(uint256 _tokenId) public view returns (uint256) {
        string memory _uri = tokenURI(_tokenId);
        // Model from 2006 to 2008
        if (compareStrings(_uri, IpfsUri[0])) {
            return 0;
        }
        // Model from 2009 to 2012
        if (
            compareStrings(_uri, IpfsUri[1]) 
        ) {
            return 1;
        }
        // Model from 2013 to 2016
        if (
            compareStrings(_uri, IpfsUri[2]) 
        ) {
            return 2;
        }
        // Model from 2017 to 2019
        if (
            compareStrings(_uri, IpfsUri[3]) 
        ) {
            return 3;
        }
        // Must be a 2020-Present model
        return 4;
    }

    // helper function to compare strings
    function compareStrings(string memory a, string memory b)
        public
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    // The following functions is an override required by Solidity.
    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    // The following functions is an override required by Solidity.
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}