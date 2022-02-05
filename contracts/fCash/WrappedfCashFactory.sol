// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/Create2.sol";
import "./nBeaconProxy.sol";

contract WrappedfCashFactory {

    address public immutable beacon;
    bytes32 public constant SALT = 0;

    event WrapperDeployed(uint16 currencyId, uint40 maturity, address wrapper);

    constructor(address _beacon) {
        beacon = _beacon;
    }

    function _getByteCode(uint16 currencyId, uint40 maturity) internal view returns (bytes memory) {
        bytes memory initCallData = abi.encodeWithSignature("initialize(uint16,uint40)", currencyId, maturity);
        return abi.encodePacked(type(nBeaconProxy).creationCode, abi.encode(beacon, initCallData));
    }

    function deployWrapper(uint16 currencyId, uint40 maturity) external returns (address) {
        address wrapper = Create2.deploy(0, SALT, _getByteCode(currencyId, maturity));
        emit WrapperDeployed(currencyId, maturity, wrapper);
        return wrapper;
    }

    function computeAddress(uint16 currencyId, uint40 maturity) external view returns (address) {
        return Create2.computeAddress(SALT, keccak256(_getByteCode(currencyId, maturity)));
    }
}