// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ArtFactory1155 is ERC1155 {
    using SafeMath for uint256;

    string public Artname;
    string public Artsymbol;
    string public Artdescription;

    address public Artcreater;
    // Total tokens starts at 0 because each new token must be minted and the
    // _mint() call adds 1 to totalTokens
    ERC20 cifiTokenContract = ERC20(0x89F2a5463eF4e4176E57EEf2b2fDD256Bf4bC2bD);

    address public feeAccount = address(0x0000000000000000000000);
    uint256 FEE = 100;
    uint8 cifiDecimals = cifiTokenContract.decimals();
    uint256 public feeAmount = FEE.mul(10**cifiDecimals).div(100);
    event Mint(string url, uint256 tokenId);

    /**
     * a gallery function that is been called by the ART gallery smart contract
     */

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _description,
        string memory _uri,
        address creater,
        address _feeAccount
    ) ERC1155(_uri) {
        Artname = _name;
        Artsymbol = _symbol;
        Artdescription = _description;
        Artcreater = creater;
        feeAccount = _feeAccount;
        _setURI(_uri);
    }

    function setURIPrefix(string memory baseURI) public {
        require(msg.sender == Artcreater);
        _setURI(baseURI);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) public {
        super.safeTransferFrom(from, to, id, amount, "");
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public {
        super.safeBatchTransferFrom(from, to, ids, amounts, "");
    }

    /**
     * this function allows to mint more of your Art
     */
    function mint(
        address account,
        uint256 id,
        uint256 amount
    ) external returns (bool) {
        require(msg.sender == Artcreater);
        cifiTokenContract.transferFrom(msg.sender, feeAccount, feeAmount);
        _mint(account, id, amount, "");
        return true;
    }

    function mintBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external returns (bool) {
        require(msg.sender == Artcreater);
        cifiTokenContract.transferFrom(msg.sender, feeAccount, feeAmount);
        _mintBatch(account, ids, amounts, "");
        return true;
    }

    /**
     * this function allows you burn your Art
     */
    function burn(
        address account,
        uint256 id,
        uint256 amount
    ) public returns (bool) {
        require(
            isApprovedForAll(account, _msgSender()),
            "ArtFactory: Invalid operator"
        );
        _burn(account, id, amount);
        return true;
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public returns (bool) {
        require(
            isApprovedForAll(account, _msgSender()),
            "ArtFactory: Invalid operator"
        );
        _burnBatch(account, ids, amounts);
        return true;
    }
}
