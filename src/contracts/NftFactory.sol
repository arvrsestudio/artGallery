// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.4;

import "./ERC721_FORKED.sol";

contract NftFactory is ERC721_FORKED {
  string internal _name;
  string internal _symbol;
  string internal _description;
  string internal _uri;
  // Total tokens starts at 0 because each new token must be minted and the
  // _mint() call adds 1 to totalTokens
  uint256 totalTokens = 0;

  address internal _creator;

  address internal feeAccount; // the account that receives exchange
  uint256 internal feePercent; // the fee percentage

  // Mapping from token ID to owner
  mapping(uint256 => address) tokenOwner;

  // Mapping from owner to list of owned token IDs
  mapping(address => uint256[]) public ownedTokens;

  // Mapping from token ID to index of the owner tokens list
  mapping(uint256 => uint256) ownedTokensIndex;

  // Metadata is a URL that points to a json dictionary
  mapping(uint256 => string) tokenIdToMetadata;

  // mapping from symbol to full registration info
  mapping(string => REGISTRY) public registries;

  event MetadataAssigned(address indexed _owner, uint256 _tokenId, string _url);

  /**
   * its a struct to save every registry been made and store it to fetch any registry by chosing the symbol only
   * also good for making sure that symbols should be unique
   */
  struct REGISTRY {
    string name;
    string symbol;
    string description;
    string uri;
    address creator;
  }

  /**
   * a registry function that iis been called by the NFT registry smart contract
   */

  function Registry(
    string memory name,
    string memory symbol,
    string memory uri,
    string memory description,
    address caller
  ) public {
    symbol = _upperCase(symbol);

    _name = name;
    _symbol = symbol;
    _description = description;
    _creator = caller;
    _uri = uri;
    totalTokens = 0;

    registries[symbol] = REGISTRY(name, symbol, uri, description, msg.sender);
  }

  /**
   * a modifier to make sure that the address exists
   */
  modifier isOwnedToken(uint256 _tokenId) {
    require(ownerOf(_tokenId) != address(0));
    _;
  }

  /**
   * this function assignes the URI to automatically add the id number at the end of the URI
   */
  function assignDataToToken(uint256 id, string memory uri) public {
    require(msg.sender == _creator);
    bytes memory _url = bytes(uri);

    _url = abi.encodePacked(_url, bytes("/"));
    _url = abi.encodePacked(_url, _uintToBytes(id));
    _url = abi.encodePacked(_url, bytes(".json"));

    tokenIdToMetadata[id] = string(_url);
    MetadataAssigned(ownerOf(id), id, string(_url));
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
   * this function helps with queries to Fetch the owner address of the token by givine token id
   */
  function getTokenOwner(uint256 id) public view returns (address) {
    return tokenOwner[id];
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
    require(from != address(0), "invalid address");
    require(to != address(0), "invalid address");
    // add require to make sure that the tokenid exsistes
    safeTransferFrom(from, to, tokenId, "");
  }

  /**
   * this overload function allows to transfer tokens and updates all the mapping queries(with filling the URI)  
   */
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data
  ) public virtual override {
    require(
      _isApprovedOrOwner(_msgSender(), tokenId),
      "ERC721: transfer caller is not owner nor approved"
    );
    require(from != address(0), "invalid address");
    require(to != address(0), "invalid address");
    _safeTransfer(from, to, tokenId, _data);
    tokenOwner[tokenId] = to;
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
  function Mint(string memory url) public {
    require(msg.sender == _creator);
    uint256 currentTokenCount = totalSupply();
    // The index of the newest token is at the # totalTokens.
    _mint(msg.sender, currentTokenCount);
    // assign id to owner
    tokenOwner[currentTokenCount] = msg.sender;
    // assign address to array of owned tokens aned you can qury what ids the address owns
    uint256[] storage ids = ownedTokens[msg.sender];
    ids.push(currentTokenCount);
    ownedTokens[msg.sender] = ids;
    // _mint() call adds 1 to total tokens, but we want the token at index - 1
    tokenIdToMetadata[currentTokenCount] = url;
  }


  /**
   * this function allows you burn your NFT  
   */
  function burn(string memory symbol, uint256 _id) public returns (bool) {
    require(registries[symbol].creator == msg.sender);
    _burn(_id);
    delete tokenOwner[_id];
    return true;
  }

  /**
   * this function is been created just to convert uint variable to bytes
   *(private function only used in the "assignDataToToken" function in order to convert the uint variable to bytes
   * in order to concatenate it )  
   */
  function _uintToBytes(uint256 _int) internal pure returns (bytes memory) {
    uint256 maxlength = 100;
    bytes memory reversed = new bytes(maxlength);
    uint256 i = 0;
    if (_int == 0) return bytes("0");
    while (_int != 0) {
      uint256 remainder = _int % 10;
      _int = _int / 10;
      reversed[i++] = bytes1(uint8(48 + remainder));
    }
    bytes memory s = new bytes(i + 1);
    for (uint256 j = 0; j <= i; j++) {
      s[j] = reversed[i - j];
    }
    return s;
  }

  /**
   * this function is been created just to convert small strings to capital 
   *(private function only used in functions that we want to make the symbol auto capital 
   * in order to concatenate it )  
   */

  function _upperCase(string memory enter)
    internal
    pure
    returns (string memory)
  {
    bytes memory strbyte = bytes(enter);
    for (uint256 i = 0; i < strbyte.length; i++) {
      if (
        uint8(strbyte[i]) >= uint8(bytes1("a")) &&
        uint8(strbyte[i]) <= uint8(bytes1("z"))
      ) strbyte[i] = bytes1(uint8(strbyte[i]) - 32);
    }
    enter = string(strbyte);
    return enter;
  }
}
