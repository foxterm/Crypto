// FoxTerm | Sign.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import Extension
import Foundation
import libetos

public extension Crypto {
    /// 使用 Ed25519 私钥对数据进行数字签名
    /// - Parameters:
    ///   - message: 待签名的原始数据
    ///   - privateKey: 32 字节 Ed25519 私钥原始字节
    /// - Returns: 签名成功返回 64 字节的签名数据，失败或参数错误返回 `nil`
    func signEd25519(message: Data, privateKey: Data) -> Data? {
        guard privateKey.count == ETOS_ED25519_PRIVATE_KEY_LEN else {
            return nil
        }
        let signature: Buffer<UInt8> = .init(ETOS_ED25519_SIGNATURE_LEN.int)
        let result = message.withCPointer { msgBuffer, msgCount -> Int32 in
            privateKey.withCPointer { keyBuffer, _ -> Int32 in
                etos_ed25519_sign(
                    msgBuffer,
                    msgCount,
                    keyBuffer,
                    signature.buffer
                )
            }
        }

        return result == 0 ? signature.data(signature.count) : nil
    }

    /// 使用 Ed25519 公钥验证数字签名
    /// - Parameters:
    ///   - message: 原始数据
    ///   - publicKey: 32 字节 Ed25519 公钥原始字节
    ///   - signature: 64 字节待验证的签名
    /// - Returns: 验证通过返回 `true`，验证失败或参数错误返回 `false`
    func verifyEd25519(message: Data, publicKey: Data, signature: Data) -> Bool {
        guard publicKey.count == ETOS_ED25519_PUBLIC_KEY_LEN,
              signature.count == ETOS_ED25519_SIGNATURE_LEN
        else {
            return false
        }

        let result = message.withCPointer { msgBuffer, masCount in
            publicKey.withCPointer { keyBuffer, _ in
                signature.withCPointer { sigBuffer, _ in
                    etos_ed25519_verify(
                        msgBuffer,
                        masCount,
                        keyBuffer,
                        sigBuffer
                    )
                }
            }
        }

        return result == 0
    }
}
