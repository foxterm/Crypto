# Crypto

[English](README.md) | [中文文档](README_CN.md)

A dedicated cryptographic library for the FoxTerm APP. Built as a Swift wrapper around OpenSSL and libetos, it provides AES-256-GCM encryption, SHA hashing, HMAC computation, Ed25519 signatures, and cryptographically secure random number generation.

> This library is a dedicated core component for the [FoxTerm](https://foxterm.app/) APP. Download it here: [https://foxterm.app/](https://foxterm.app/)

## Features

- **AES-256-GCM** — Authenticated encryption with IV + Tag + Ciphertext packed output format
- **SHA Hashing** — Full algorithm coverage: MD5, SHA-1, SHA-224/256/384/512, SHA-512/224, SHA-512/256, SHA3-224/256/384/512
- **File Hashing** — Streaming file digest computation with 64KB chunked reading
- **HMAC** — Keyed-hash message authentication code with configurable hash algorithm
- **Ed25519 Signatures** — Digital signature generation and verification
- **Random Bytes** — Cryptographically secure random data generation via libetos
- **Algorithm Enumeration** — `ShaAlgorithm` enum with EVP pointer, digest size, name, and description

## Requirements

| Platform | Minimum Version |
|----------|----------------|
| iOS      | 17.0           |
| macOS    | 14.0           |
| Swift    | 5.10           |

## Installation

### Swift Package Manager

```swift
.package(url: "https://github.com/foxterm/Crypto.git", branch: "main"),
```

```swift
.product(name: "Crypto", package: "Crypto"),
```

### CocoaPods

```ruby
pod 'Crypto', :git => 'https://github.com/foxterm/Crypto.git'
```

### Dependencies

- [libetos](https://github.com/foxterm/libetos) — Low-level socket and cryptographic primitives
- [Extension](https://github.com/foxterm/Extension) — Foundation extensions
- [OpenSSL](https://github.com/foxterm/OpenSSL) — OpenSSL cryptographic toolkit

## Usage

### AES-256-GCM Encryption

```swift
let crypto = Crypto.shared

// Generate a 256-bit key
guard let key = crypto.generateRandomBytes(length: 32) else { return }

// Encrypt (IV is auto-generated if not provided)
let plaintext = "Hello, FoxTerm!".data(using: .utf8)!
guard let encrypted = crypto.encryptAES256GCM(plaintext: plaintext, key: key) else { return }
// encrypted format: IV (12B) + Tag (16B) + Ciphertext

// Decrypt
guard let decrypted = crypto.decryptAES256GCM(encryptedData: encrypted, key: key) else { return }
let message = String(data: decrypted, encoding: .utf8)  // "Hello, FoxTerm!"
```

### SHA Hashing

```swift
let crypto = Crypto.shared

// Hash a string
let digest = crypto.sha("Hello, World!", algorithm: .sha256)
print(digest.hexString)

// Hash binary data
let data = "binary data".data(using: .utf8)!
let hash = crypto.sha(data, algorithm: .sha512)

// Hash a file (streaming, async-friendly)
guard let fileHash = crypto.sha(file: "/path/to/largefile.zip", algorithm: .sha256) else { return }
```

### HMAC

```swift
let crypto = Crypto.shared

// String-based
let mac = crypto.hmac("message", key: "secret", algorithm: .sha256)

// Data-based
let hmac = crypto.hmac(messageData, key: keyData, algorithm: .sha512)
```

### Ed25519 Signatures

```swift
let crypto = Crypto.shared

// Sign
guard let signature = crypto.signEd25519(message: messageData, privateKey: privateKeyData) else { return }
// signature is 64 bytes

// Verify
let isValid = crypto.verifyEd25519(message: messageData, publicKey: publicKeyData, signature: signature)
```

### Random Bytes

```swift
let crypto = Crypto.shared

// Generate 16 random bytes
guard let randomData = crypto.generateRandomBytes(length: 16) else { return }
```

### Algorithm Enumeration

```swift
// List all supported algorithms
for algo in ShaAlgorithm.allCases {
    print("\(algo.rawValue): \(algo.name) — \(algo.digest) bytes")
}

// Output:
// md5: MD5 — 16 bytes
// sha1: SHA1 — 20 bytes
// sha256: SHA2-256 — 32 bytes
// sha512: SHA2-512 — 64 bytes
// ...
```

## Project Structure

```
Sources/
└── Crypto/
    ├── Crypto.swift        # Core singleton class
    ├── Aes.swift           # AES-256-GCM encrypt/decrypt, random bytes
    ├── Sha.swift           # SHA hashing (string, data, file)
    ├── HMAC.swift          # HMAC computation
    ├── Sign.swift          # Ed25519 sign/verify
    └── Algorithm.swift     # ShaAlgorithm enum
```

## License

MIT
