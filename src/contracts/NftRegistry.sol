// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./NftFactory.sol";

contract NftRegistry {
    using SafeMath for uint256;
    // mapping to save the symbol to Registry Address
    mapping(string => address) symbolToRegeistryAddress;
    // mapping to save the Uri to Registry Address
    mapping(string => address) uriToRegeistryAddress;
    //mapping to save all the registry addresses of an owner
    mapping(address => address[]) userToRegistries;

    address lastaddress;
    string lastUri;
    address feeAccount = 0x0000000000000000000000000000000000000000;
    address private _owner;

    constructor(address _feeAccount) public {
        feeAccount = _feeAccount;
        _owner = msg.sender;
    }

    /*
     * when you deploy Cifi_Token to Local testNet (Ganache) or to testnet like binance test net take the address of the
     * deployed Cifi_Token and add it below
     * the address below is just a dummy one that we need to change once we deploy the Cifi_Token Contract to the
     * binance main net and take the address of the contract and add it below
     * but for testing purposes just deploy the scifiToken to Ganache and take the address and use it.
     */

    ERC20 cifiTokenContract = ERC20(0xe56aB536c90E5A8f06524EA639bE9cB3589B8146);
    uint256 FEE = 10;
    uint8 cifiDecimals = cifiTokenContract.decimals();
    uint256 public feeAmount = FEE.mul(10**cifiDecimals).div(100);

    event RegistryCreated(
        string name,
        string symbol,
        string description,
        string uri,
        address caller,
        address registryAddress
    );

    function createRegistry(
        string memory name,
        string memory symbol,
        string memory description,
        string memory uri,
        bool isPrivate
    ) public returns (address) {
        require(msg.sender != address(0), "Invalid address");
        require(bytes(name).length != 0, "name can't be empty");
        require(bytes(symbol).length != 0, "symbol can't be empty");
        uniqueSymbol(symbol);
        cifiTokenContract.transferFrom(msg.sender, feeAccount, feeAmount);
        NftFactory registry =
            new NftFactory(
                name,
                symbol,
                description,
                uri,
                msg.sender,
                isPrivate
            );

        // adding the registry address to the symbolToRegeistryAddress
        symbolToRegeistryAddress[symbol] = address(registry);

        // saving the last registry address
        lastaddress = address(registry);

        // adding the registry address to the uriToRegeistryAddress
        uriToRegeistryAddress[uri] = address(registry);

        // adding the address to address array for userToRegisteries
        userToRegistries[msg.sender].push(address(registry));

        emit RegistryCreated(name, symbol, description, uri, msg.sender,address(registry));

        return address(registry);
    }

    function uniqueSymbol(string memory symbol) public view returns (bool) {
        require(
            symbolToRegeistryAddress[symbol] == address(0),
            "symbol already used"
        );
        return true;
    }

    function getlastAddress() public view returns (address) {
        return lastaddress;
    }

    function getRegistryAddressFromUri(string memory uri)
        public
        view
        returns (address)
    {
        return uriToRegeistryAddress[uri];
    }

    function getRegistries(address _user)
        public
        view
        returns (address[] memory)
    {
        return userToRegistries[_user];
    }

    function getRegistry(string memory _symbol) public view returns (address) {
        return symbolToRegeistryAddress[_symbol];
    }

    /**
     * this function allows you to change the address that is going to receive the fee amount
     */
    function ChangeFeeAccount(address newFeeAccount) public returns (bool) {
        require(msg.sender == _owner);
        feeAccount = newFeeAccount;
        return true;
    }

    function ChangeFeeAmount(uint256 newFeeAmount) public returns (bool) {
        require(msg.sender == _owner);
        FEE = newFeeAmount;
        return true;
    }
}
