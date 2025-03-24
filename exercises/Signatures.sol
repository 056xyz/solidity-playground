// SPDX-License-Identifier: MITpragma solidity ^0.8.0;
pragma solidity 0.8.26;
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "forge-std/console.sol";
import "forge-std/Test.sol";

contract Verifier {
    using ECDSA for bytes32;

    address public verifyingAddress;

    constructor(address _verifyingAddress) {
        verifyingAddress = _verifyingAddress;
    }

    function verifyV1(
        string calldata message,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public view {
        bytes32 signedMessageHash = keccak256(abi.encode(message))
            .toEthSignedMessageHash();
        require(
            signedMessageHash.recover(v, r, s) == verifyingAddress,
            "signature not valid v1"
        );
    }

    function verifyV2(
        string calldata message,
        bytes calldata signature
    ) public view {
        bytes32 signedMessageHash = keccak256(abi.encode(message))
            .toEthSignedMessageHash();
        require(
            signedMessageHash.recover(signature) == verifyingAddress,
            "signature not valid v2"
        );
    }
}


contract TestSigs1 is Test {
    using ECDSA for bytes32;
    Verifier verifier;

    address owner;
    uint256 privateKey =
        0x1010101010101010101010101010101010101010101010101010101010101010;

    function setUp() public {
        owner = vm.addr(privateKey);
        verifier = new Verifier(owner);
    }

    function testVerifyV1andV2() public {
        string memory message = "attack at dawn";

        bytes32 msgHash = keccak256(abi.encode(message))
            .toEthSignedMessageHash();

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);

        bytes memory signature = abi.encodePacked(r, s, v);
        assertEq(signature.length, 65);

        console.logBytes(signature);
        verifier.verifyV1(message, r, s, v);
        verifier.verifyV2(message, signature);
    }
}


contract SignTest is Test {
// private key = 123
// public key = vm.addr(private key)
// message = "secret message"
// message hash = keccak256(message)
// vm.sign(private key, message hash)
function testSignature() public {
uint256 privateKey = 123;
// Computes the address for a given private key.
address alice = vm.addr(privateKey);
   
    // Test valid signature
    bytes32 messageHash = keccak256("Signed by Alice");

    (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, messageHash);
    address signer = ecrecover(messageHash, v, r, s);

    assertEq(signer, alice);

    // Test invalid message
    bytes32 invalidHash = keccak256("Not signed by Alice");
    signer = ecrecover(invalidHash, v, r, s);

    assertTrue(signer != alice);
}
}