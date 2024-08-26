// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "OpenId4VP",
    platforms: [
           .macOS(.v11),
           .iOS(.v13)
       ],
    products: [
        .library(
            name: "OpenId4VP",
            targets: ["OpenId4VP"]),
    ],
    targets: [
        .target(
            name: "OpenId4VP"),
        .testTarget(
            name: "OpenId4VPTests",
            dependencies: ["OpenId4VP"]),
    ]
)
