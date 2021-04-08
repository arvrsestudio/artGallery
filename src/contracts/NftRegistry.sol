// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./NftFactory.sol";

contract NftRegistry is NftFactory {
  using SafeMath for uint256;

  constructor(address _feeAccount) public {
    feeAccount = _feeAccount;
  }

  /*
   * when you deploy Cifi_Token to Local testNet (Ganache) or to testnet like binance test net take the address of the
   * deployed Cifi_Token and add it below
   * the address below is just a dummy one that we need to change once we deploy the Cifi_Token Contract to the
   * binance main net and take the address of the contract and add it below
   * but for testing purposes just deploy the cifiToken to Ganache and take the address and use it.
   */

  ERC20 cifiTokenContract = ERC20(0x135a6636C8d1D5099C6a6A1D8D0762C4c9Ed9f09);
  uint256 constant FEE = 10;
  string constant DEFAULT_DESCRIPTION = "";

  event RegistryCreated(
    string name,
    string symbol,
    string description,
    string uri,
    address caller
  );


  
  function createRegistry(string memory name,
    string memory symbol,
    string memory uri,
    string memory description)public returns (bool){
        return _createRegistry(name, symbol, uri, description);
    }
    
    function createRegistry(string memory name,
    string memory symbol,
    string memory uri)public returns (bool){
        return _createRegistry(name, symbol, uri, DEFAULT_DESCRIPTION);
    }
    
    
    
  function _createRegistry(
    string memory name,
    string memory symbol,
    string memory uri,
    string memory description
  ) internal returns (bool) {
    require(msg.sender != address(0), "Invalid address");
    require(bytes(name).length != 0, "name can't be empty");
    require(bytes(symbol).length != 0, "symbol can't be empty");
    require(
      keccak256(bytes(registries[symbol].symbol)) != keccak256(bytes(symbol)),
      "symbol is already taken"
    );
    uint256 balaceOfUser = cifiTokenContract.balanceOf(msg.sender);
    uint8 cifiDecimals = cifiTokenContract.decimals();
    uint256 feeAmount = FEE.mul(10**cifiDecimals).div(100);
    require(
      balaceOfUser >= feeAmount,
      "insufficient  Balance, unable to pay the registration Fee"
    );

    cifiTokenContract.transferFrom(msg.sender, feeAccount, feeAmount);
    Registry(name, symbol, uri,description, msg.sender);

    return true;
  }


  function getRegistryAddress(string memory symbol)
    public
    view
    returns (address)
  {
    require(
      keccak256(bytes(registries[symbol].symbol)) == keccak256(bytes(symbol)),
      "symbol is already taken"
    );
    return registries[symbol].creator;
  }
}
