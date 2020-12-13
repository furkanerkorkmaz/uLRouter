// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "uLRouter",
    platforms: [.iOS(.v8)],
    products: [
        .library(
            name: "uLRouter",
            targets: ["uLRouter"]),
    ],
    targets: [
        .target(
            name: "uLRouter",
            dependencies: [])
    ]
)
