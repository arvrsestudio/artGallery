// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./NftFactory.sol";

contract NftRegistry is NftFactory,AccessControl {
  using SafeMath for uint256;
  address feeAccount = 0x0000000000000000000000000000000000000000;
  
  constructor(address _feeAccount) public {
    feeAccount = _feeAccount;
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    createRegistry("CifiPowa", "CIFI","testDescription", "testURI");
  }

  /*
   * when you deploy Cifi_Token to Local testNet (Ganache) or to testnet like binance test net take the address of the
   * deployed Cifi_Token and add it below
   * the address below is just a dummy one that we need to change once we deploy the Cifi_Token Contract to the
   * binance main net and take the address of the contract and add it below
   * but for testing purposes just deploy the scifiToken to Ganache and take the address and use it.
   */

   ERC20 cifiTokenContract = ERC20(0xCb880DC85b329158216681BdfF750c8Eb8C06055);
   uint256 constant FEE = 10;
   uint8 cifiDecimals = cifiTokenContract.decimals();
   uint256 public feeAmount = FEE.mul(10**cifiDecimals).div(100);

  event RegistryCreated(
    string name,
    string symbol,
    string description,
    string uri,
    address caller
  );
  
  modifier uniqueSymbol(string memory symbol){
      require(
      keccak256(bytes(registries[symbol].symbol)) != keccak256(bytes(symbol)),
      "symbol is already taken"
    );
    _;
  }

  function createRegistry(
    string memory name,
    string memory symbol,
    string memory description,
    string memory uri
  ) public uniqueSymbol (symbol)returns (bool) {
    require(msg.sender != address(0), "Invalid address");
    require(bytes(name).length != 0, "name can't be empty");
    require(bytes(symbol).length != 0, "symbol can't be empty");

       cifiTokenContract.transferFrom(0x4AB3a9Fc7abC71197FaD169FfEe41210b21F6CAa, feeAccount, feeAmount);
    Registry(name, symbol, description, uri, msg.sender);
    emit RegistryCreated(name, symbol, description, uri, msg.sender);

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

  /**
   * this function allows you to change the address that is going to receive the fee amount  
   */
   function ChangeFeeAccount(address newFeeAccount) public returns (bool) {
     require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
    feeAccount = newFeeAccount;
    return true;
  }  
}
