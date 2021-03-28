// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.4;

import "./NftFactory.sol";

contract RegistryFactory is NftFactory {
  

  constructor(address _feeAccount, uint256 _feePercent) public {
    feeAccount = _feeAccount;
    feePercent = _feePercent;
  }

  event RegistryCreated(
    string name,
    string symbol,
    string description,
    address caller
  );

  function createRegistry(
    string memory name,
    string memory symbol,
    string memory description
  ) public  returns (bool) {
    require(msg.sender != address(0), "Invalid address");
    require(bytes(name).length != 0, "name can't be empty");
    require(bytes(symbol).length != 0, "symbol can't be empty");
    require(
      keccak256(bytes(registries[symbol].symbol)) != keccak256(bytes(symbol)),
      "symbol is already taken"
    );

    Registry(name, symbol, description, msg.sender);

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
