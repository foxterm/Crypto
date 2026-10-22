# Crypto

[English](README.md) | [中文文档](README_CN.md)

FoxTerm APP 专用加密库，基于 OpenSSL 和 libetos 的 Swift 封装，提供 AES-256-GCM 加密、SHA 哈希、HMAC 计算、Ed25519 签名及安全随机数生成。

> 本库为 [FoxTerm](https://foxterm.app/) APP 专用核心组件，欢迎下载使用：[https://foxterm.app/](https://foxterm.app/)

## 功能

- **AES-256-GCM** — 认证加密，输出格式为 IV + Tag + Ciphertext 组合包
- **SHA 哈希** — 完整算法覆盖：MD5、SHA-1、SHA-224/256/384/512、SHA-512/224、SHA-512/256、SHA3-224/256/384/512
- **文件哈希** — 流式文件摘要计算，64KB 分块读取
- **HMAC** — 基于哈希的消息认证码，支持可配置哈希算法
- **Ed25519 签名** — 数字签名生成与验证
- **随机字节** — 基于 libetos 的密码学安全随机数据生成
- **算法枚举** — `ShaAlgorithm` 枚举，提供 EVP 指针、摘要长度、名称与描述

## 环境要求

| 平台  | 最低版本 |
|-------|---------|
| iOS   | 17.0    |
| macOS | 14.0    |
| Swift | 5.10    |

## 安装

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

### 依赖

- [libetos](https://github.com/foxterm/libetos) — 底层 Socket 与密码学原语
- [Extension](https://github.com/foxterm/Extension) — Foundation 扩展
- [OpenSSL](https://github.com/foxterm/OpenSSL) — OpenSSL 加密工具库

## 使用

### AES-256-GCM 加密

```swift
let crypto = Crypto.shared

// 生成 256 位密钥
guard let key = crypto.generateRandomBytes(length: 32) else { return }

// 加密（未提供 IV 时自动生成）
let plaintext = "Hello, FoxTerm!".data(using: .utf8)!
guard let encrypted = crypto.encryptAES256GCM(plaintext: plaintext, key: key) else { return }
// 加密输出格式：IV (12B) + Tag (16B) + 密文

// 解密
guard let decrypted = crypto.decryptAES256GCM(encryptedData: encrypted, key: key) else { return }
let message = String(data: decrypted, encoding: .utf8)  // "Hello, FoxTerm!"
```

### SHA 哈希

```swift
let crypto = Crypto.shared

// 字符串哈希
let digest = crypto.sha("Hello, World!", algorithm: .sha256)
print(digest.hexString)

// 二进制数据哈希
let data = "binary data".data(using: .utf8)!
let hash = crypto.sha(data, algorithm: .sha512)

// 文件哈希（流式读取）
guard let fileHash = crypto.sha(file: "/path/to/largefile.zip", algorithm: .sha256) else { return }
```

### HMAC

```swift
let crypto = Crypto.shared

// 字符串方式
let mac = crypto.hmac("message", key: "secret", algorithm: .sha256)

// Data 方式
let hmac = crypto.hmac(messageData, key: keyData, algorithm: .sha512)
```

### Ed25519 签名

```swift
let crypto = Crypto.shared

// 签名
guard let signature = crypto.signEd25519(message: messageData, privateKey: privateKeyData) else { return }
// 签名为 64 字节

// 验证
let isValid = crypto.verifyEd25519(message: messageData, publicKey: publicKeyData, signature: signature)
```

### 随机字节

```swift
let crypto = Crypto.shared

// 生成 16 字节随机数据
guard let randomData = crypto.generateRandomBytes(length: 16) else { return }
```

### 算法枚举

```swift
// 遍历所有支持的算法
for algo in ShaAlgorithm.allCases {
    print("\(algo.rawValue): \(algo.name) — \(algo.digest) 字节")
}

// 输出：
// md5: MD5 — 16 字节
// sha1: SHA1 — 20 字节
// sha256: SHA2-256 — 32 字节
// sha512: SHA2-512 — 64 字节
// ...
```

## 项目结构

```
Sources/
└── Crypto/
    ├── Crypto.swift        # 核心单例类
    ├── Aes.swift           # AES-256-GCM 加解密、随机字节
    ├── Sha.swift           # SHA 哈希（字符串、数据、文件）
    ├── HMAC.swift          # HMAC 计算
    ├── Sign.swift          # Ed25519 签名/验证
    └── Algorithm.swift     # ShaAlgorithm 枚举
```

## 许可证

MIT
