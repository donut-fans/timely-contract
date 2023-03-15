// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

abstract contract Timely{
    function freeMint(uint256 tokenId) public virtual;
      
    function safeTransferFrom(address _from,address _to,uint256 _tokenId) external virtual;
}

contract TimelyErc20Extends is Ownable,IERC721Receiver{

    address timelyContractAddress;
    address signatureAddress;

    constructor(address _timelyContractAddress){
        timelyContractAddress = _timelyContractAddress;
        signatureAddress = msg.sender;
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function setTimelyContractAddress(address _addr) public onlyOwner{
        timelyContractAddress = _addr;
    }

    function setSignatureAddress(address _addr) public onlyOwner{
        signatureAddress = _addr;
    }

    function payErc20TokenAndMint(address erc20Address,uint256 payAmout,uint256[] memory _tokenIds,bytes memory _signature) public{
        // bytes32 _msgHash = getMessageHash(msg.sender, _tokenId,payAmout); 
        bytes32 _msgHash = getMessageHash(msg.sender, _tokenIds,payAmout); 
        bytes32 _ethSignedMessageHash = ECDSA.toEthSignedMessageHash(_msgHash);
        require(verify(_ethSignedMessageHash, _signature) == signatureAddress, "Invalid signature");

        //Pay
        ERC20 erc20 = ERC20(erc20Address);
        erc20.transferFrom(msg.sender, address(this), payAmout);

        //mint nft
        Timely timely = Timely(timelyContractAddress);

        for(uint i = 0;i < _tokenIds.length;i++){
            timely.freeMint(_tokenIds[i]);
            //transfer nft to user
            timely.safeTransferFrom(address(this),msg.sender,_tokenIds[i]);
        }
    }

    function getMessageHash(address _account, uint256[] memory _tokenIds,uint256 amount) public pure returns(bytes32){
        return keccak256(abi.encodePacked(_account, _tokenIds,amount));
    }

    function toEthSignedMessageHash(bytes32 _messageHash) public pure returns(bytes32){
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function verify(bytes32 _ethSignHash, bytes memory _signature) public pure returns (address){
        return ECDSA.recover(_ethSignHash, _signature);
    }

    function withdrawToken(address tokenAddress,address to) public onlyOwner{
        ERC20 erc20 = ERC20(tokenAddress);
        erc20.transfer(to,erc20.balanceOf(address(this)));
    }

    function withdraw(address to) public onlyOwner{
        payable(to).transfer(address(this).balance);
    }
}