// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "Crypto",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "Crypto", targets: ["Crypto"]),
    ],
    dependencies: [
        .package(url: "https://github.com/foxterm/libetos.git", branch: "main"),
        .package(url: "https://github.com/foxterm/Extension.git", branch: "main"),
        .package(url: "https://github.com/foxterm/OpenSSL.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Crypto",
            dependencies: [
                .product(name: "Extension", package: "Extension"),
                .product(name: "OpenSSL", package: "OpenSSL"),
                .product(name: "libetos", package: "libetos"),
            ]
        ),
    ]
)
