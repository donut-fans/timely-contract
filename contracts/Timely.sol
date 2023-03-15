// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Timely is Ownable,ERC721Enumerable{
    using Strings for uint256;

    address public adminAddr;

    bool public canTransfer = true;

    bool public ethToAddress = false;

    mapping(address => bool) public freeMintAddrs;

    string preffix = "https://donut-prd01.oss-us-west-1.aliyuncs.com/metadata/timely/";

    string private suffix = ".json";

    string private signature;

    constructor(string memory _signature) ERC721("Timely", "timely.fans"){
        adminAddr = msg.sender;
        signature = _signature;
        freeMintAddrs[msg.sender] = true;
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

        return
            string(abi.encodePacked(preffix, tokenId.toString(), suffix));
    }

    function setFreeMintAddr(address _freeMintAddr,bool canFreeMint) public {
        require(msg.sender == adminAddr,"You do not have access!");
        freeMintAddrs[_freeMintAddr] = canFreeMint;
    }

    function setSignature(string memory _signature) public {
        require(msg.sender == adminAddr,"You do not have access!");
        signature = _signature;
    }

    function flipTransferFuncion() public {
        require(msg.sender == adminAddr,"You do not have access!");
        canTransfer = !canTransfer;
    }

    function setPreffix(string memory _preffix) public {
        require(msg.sender == adminAddr,"You do not have access!");
        preffix = _preffix;
    }

    function setSuffix(string memory _suffix) public {
        require(msg.sender == adminAddr,"You do not have access!");
        suffix = _suffix;
    }

    function burn(uint256 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender,"You do not have access!");
        _burn(_tokenId);
    }

    function mint(string memory _signature,uint256 amout,uint256 tokenId) public payable{
        require(keccak256(abi.encodePacked(signature)) == keccak256(abi.encodePacked(_signature)),"Error signature");

        require(msg.value == amout,"Error price");

        if(ethToAddress){
            payable(owner()).transfer(msg.value);
        }
        _safeMint(msg.sender, tokenId);
    }

    function freeMint(uint256 tokenId) public{
        require(freeMintAddrs[msg.sender] == true,"You do not have access!");
        _safeMint(msg.sender, tokenId);
    }

    function withdraw(address to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(to).transfer(balance);
    }

    function setAdmin(address _adminAddr) public onlyOwner {
        adminAddr = _adminAddr;
    }

    function flipEthToAddress(bool _ethToAddress) public {
        require(msg.sender == adminAddr,"You do not have access!");
        ethToAddress = _ethToAddress;
    }
}

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

contract TimelyBid is Ownable,IERC721Receiver{
    Timely timely;

    address private receiverAddress;

    constructor(address timelyAddr,address _receiverAddress){
        timely = Timely(timelyAddr);
        receiverAddress = _receiverAddress;
    }

    function setTimelyAddr(address _addr) public{
        timely = Timely(_addr);
    }

    function setReceiverAddr(address _receiverAddress) public onlyOwner{
        receiverAddress = _receiverAddress;
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
        erc20.transferFrom(userAddress, receiverAddress, payAmout);

        //2.mint nft
        timely.freeMint(tokenId);

        //3.transfer nft to user address
        timely.safeTransferFrom(address(this),userAddress,tokenId);
    }
}