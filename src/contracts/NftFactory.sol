// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NftFactory is ERC721 {
    using SafeMath for uint256;

    string public Nftname;
    string public Nftsymbol;
    string public Nftdescription;
    string public Nfturi;
    bool public isPrivate;

    // Total tokens starts at 0 because each new token must be minted and the
    // _mint() call adds 1 to totalTokens
    uint256 public totalTokens = 0;

    address public Nftcreator;

    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) ownedTokens;

    // Metadata is a URL that points to a json dictionary
    mapping(uint256 => string) tokenIdToMetadata;

    event MetadataAssigned(
        address indexed _owner,
        uint256 _tokenId,
        string _url
    );
    event Mint(string url,uint256 tokenId );

    /**
     * a registry function that iis been called by the NFT registry smart contract
     */

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _description,
        string memory _uri,
        address _caller,
        bool _isPrivate
    ) ERC721(_name, _symbol) {
        Nftname = _name;
        Nftsymbol = _symbol;
        Nftdescription = _description;
        Nfturi = _uri;
        Nftcreator = _caller;
        isPrivate = _isPrivate;
        totalTokens = 0;
    }

    /**
     * this function helps with queries to Fetch the metadata for a givine token id
     */
    function getMetadataAtID(uint256 _tokenId)
        public
        view
        returns (string memory)
    {
        return tokenIdToMetadata[_tokenId];
    }

    /**
     * this function helps with queries to Fetch all the tokens that the address owns by givine address
     */
    function tokensOf(address _owner) public view returns (uint256[] memory) {
        require(_owner != address(0), "invalid owner");
        return ownedTokens[_owner];
    }

    /**
     * this function allows to approve more than one token id at once
     */
    function approveMany(address _to, uint256[] memory _tokenIds) public {
        /* Allows bulk-approval of many tokens. This function is useful for
      exchanges where users can make a single tx to enable the call of
      transferFrom for those tokens by an exchange contract. */
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            // approve handles the check for if one who is approving is the owner.
            approve(_to, _tokenIds[i]);
        }
    }

    /**
     * this function allows to approve all the tokens the address owns at once
     */
    function approveAll(address _to) public {
        uint256[] memory tokens = tokensOf(msg.sender);
        for (uint256 t = 0; t < tokens.length; t++) {
            approve(_to, tokens[t]);
        }
    }

    /**
     * this overload function allows to transfer tokens and updates all the mapping queries(without filling the URI)
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        require(from != address(0), "invalid address");
        require(to != address(0), "invalid address");
        _safeTransfer(from, to, tokenId, "");
        uint256[] memory fromIds = ownedTokens[from];
        uint256[] memory newFromIds = new uint256[](fromIds.length - 1);
        uint256[] storage toIds = ownedTokens[to];
        toIds.push(tokenId);
        ownedTokens[to] = toIds;
        uint256 j = 0;
        for (uint256 i = 0; i < fromIds.length; i++) {
            if (fromIds[i] != tokenId) newFromIds[j++] = (fromIds[i]);
        }
        ownedTokens[from] = newFromIds;
    }

    /**
     * this function allows to mint more of your NFT
     */
    function mint(string memory url) public {
        require(msg.sender == Nftcreator);
        totalTokens = totalSupply().add(1);
        // The index of the newest token is at the # totalTokens.
        _mint(msg.sender, totalTokens);
        // assign address to array of owned tokens aned you can qury what ids the address owns
        uint256[] storage ids = ownedTokens[msg.sender];
        ids.push(totalTokens);
        ownedTokens[msg.sender] = ids;
        // _mint() call adds 1 to total tokens, but we want the token at index - 1
        tokenIdToMetadata[totalTokens] = url;
        emit Mint(url,totalTokens);
    }

    /**
     * this function allows you to change the Registry privacy if its false it will change to true, if its true it will change to false
     */

    function changeRegisterPrivacy() public {
        require(msg.sender == Nftcreator);
        if (isPrivate == true) {
            isPrivate = false;
        } else if (isPrivate == false) {
            isPrivate = true;
        }
    }

    /**
     * this function allows you burn your NFT
     */
    function burn(uint256 _id) public returns (bool) {
        _burn(_id);
        return true;
    }

    function getTotalTokens() public view returns (uint256) {
        return totalTokens;
    }
}
