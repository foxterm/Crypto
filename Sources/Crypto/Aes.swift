// FoxTerm | Aes.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import Extension
import Foundation
import libetos

public extension Crypto {
    /**
     生成指定长度的强随机字节数据(常用语生成密钥 Key 或初始向量 IV)

     - Parameter length: 需要生成的字节长度
     - Returns: 生成成功返回 Data，失败返回 nil
     */
    func generateRandomBytes(length: Int) -> Data? {
        guard length > 0 else { return nil }
        var data = Data(count: length)

        let status = data.withUnsafeMutableBytes { buffer -> Int32 in
            guard let ptr = buffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                return ETOS_ERR_INVALID_PARAM
            }
            return etos_crypto_rand_bytes(ptr, length)
        }

        return status == ETOS_OK ? data : nil
    }

    /**
     使用 AES-256-GCM 算法加密数据，并打包导出为单一 Data (格式为: IV + Tag + Ciphertext)

     - Parameters:
       - plaintext: 待加密的明文 Data
       - key: 32 字节密钥 (256-bit)
       - iv: 12 字节初始向量(若传 nil 则内部自动生成随机 IV)
     - Returns: 加密成功返回拼接好的数据包，失败返回 nil
     */
    func encryptAES256GCM(
        plaintext: Data,
        key: Data,
        iv: Data? = nil
    ) -> Data? {
        guard key.count == ETOS_AES_256_KEY_SIZE else { return nil }

        let actualIV: Data
        if let iv {
            guard iv.count == ETOS_AES_GCM_IV_SIZE else { return nil }
            actualIV = iv
        } else {
            guard let randomIV = generateRandomBytes(length: Int(ETOS_AES_GCM_IV_SIZE)) else {
                return nil
            }
            actualIV = randomIV
        }

        var ciphertext = Data(count: plaintext.count)
        var ciphertextLen = 0
        var tag = Data(count: Int(ETOS_AES_GCM_TAG_SIZE))
        var outLen = ciphertext.count

        let status = plaintext.withUnsafeBytes { rawPlaintext in
            ciphertext.withUnsafeMutableBytes { rawCiphertext in
                tag.withUnsafeMutableBytes { rawTag in
                    key.withUnsafeBytes { rawKey in
                        actualIV.withUnsafeBytes { rawIV in
                            let res = etos_aes_256_gcm_encrypt(
                                rawPlaintext.bindMemory(to: UInt8.self).baseAddress,
                                plaintext.count,
                                rawKey.bindMemory(to: UInt8.self).baseAddress,
                                rawIV.bindMemory(to: UInt8.self).baseAddress,
                                rawCiphertext.bindMemory(to: UInt8.self).baseAddress,
                                &outLen,
                                rawTag.bindMemory(to: UInt8.self).baseAddress
                            )
                            ciphertextLen = outLen
                            return res
                        }
                    }
                }
            }
        }

        guard status == ETOS_OK else { return nil }

        ciphertext.count = ciphertextLen

        var combined = Data()
        combined.append(actualIV)
        combined.append(tag)
        combined.append(ciphertext)
        return combined
    }

    /**
     使用 AES-256-GCM 算法解密包含头部信息的数据包 (格式为: IV + Tag + Ciphertext)

     - Parameters:
       - encryptedData: 包含 IV(12B) + Tag(16B) + 密文 的组合 Data
       - key: 32 字节密钥 (256-bit)
     - Returns: 解密且校验成功返回明文 Data，校验失败或参数错误返回 nil
     */
    func decryptAES256GCM(
        encryptedData: Data,
        key: Data
    ) -> Data? {
        let ivSize = Int(ETOS_AES_GCM_IV_SIZE)
        let tagSize = Int(ETOS_AES_GCM_TAG_SIZE)
        let headerSize = ivSize + tagSize

        guard key.count == ETOS_AES_256_KEY_SIZE,
              encryptedData.count >= headerSize
        else {
            return nil
        }

        let iv = encryptedData.prefix(ivSize)
        let tag = encryptedData.dropFirst(ivSize).prefix(tagSize)
        let ciphertext = encryptedData.dropFirst(headerSize)

        var outPlaintext = Data(count: ciphertext.count)
        var plaintextLen = 0
        var outLen = outPlaintext.count

        let status = ciphertext.withUnsafeBytes { rawCiphertext in
            tag.withUnsafeBytes { rawTag in
                key.withUnsafeBytes { rawKey in
                    iv.withUnsafeBytes { rawIV in
                        outPlaintext.withUnsafeMutableBytes { rawPlaintext in
                            let res = etos_aes_256_gcm_decrypt(
                                rawCiphertext.bindMemory(to: UInt8.self).baseAddress,
                                ciphertext.count,
                                rawTag.bindMemory(to: UInt8.self).baseAddress,
                                rawKey.bindMemory(to: UInt8.self).baseAddress,
                                rawIV.bindMemory(to: UInt8.self).baseAddress,
                                rawPlaintext.bindMemory(to: UInt8.self).baseAddress,
                                &outLen
                            )
                            plaintextLen = outLen
                            return res
                        }
                    }
                }
            }
        }

        guard status == ETOS_OK else { return nil }

        outPlaintext.count = plaintextLen
        return outPlaintext
    }
}
