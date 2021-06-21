// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./library/Governance.sol";

contract CifiPowa is ERC1155, Governance {
    using SafeMath for uint256;
    string public name;
    string public symbol;

    constructor() ERC1155("https://ipfs.io/ipfs/") {
        name = "Cifipowa1155";
        symbol = "POWA1";
    }

    function setURIPrefix(string memory baseURI) public onlyGovernance {
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
    ) external onlyGovernance returns (bool) {
        _mint(account, id, amount, "");
        return true;
    }

    function mintBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external onlyGovernance returns (bool) {
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
