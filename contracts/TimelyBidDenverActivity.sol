// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./Timely.sol";

contract TimelyBidDenverActivity is Ownable,IERC721Receiver{
    Timely timely;

    constructor(address timelyAddr){
        timely = Timely(timelyAddr);
    }

    function setTimelyAddr(address _addr) public{
        timely = Timely(_addr);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function getERC20TokenBalance(address tokenContractAddress)
        public
        view
        returns (uint256)
    {
        ERC20 erc20 = ERC20(tokenContractAddress);
        return erc20.balanceOf(address(this));
    }

    function withdraw(address to) public onlyOwner {
        payable(to).transfer(address(this).balance);
    }

    function withdrawERC20Tokens(address tokenAddress,address to) public onlyOwner{
        ERC20 erc20 = ERC20(tokenAddress);
        erc20.transfer(to,erc20.balanceOf(address(this)));
    }

    function payERC20AndMint(
        address tokenContractAddress,
        uint256 payAmout,
        uint256 tokenId,
        address userAddress
    ) public onlyOwner {
        //1.transfer token to this contract
        ERC20 erc20 = ERC20(tokenContractAddress);
        erc20.transferFrom(userAddress, address(this), payAmout);

        //2.mint nft
        timely.freeMint(tokenId);

        //3.transfer nft to user address
        timely.safeTransferFrom(address(this),userAddress,tokenId);
    }
}