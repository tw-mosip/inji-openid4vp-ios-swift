// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "OpenID4VP",
    platforms: [
           .macOS(.v11),
           .iOS(.v13)
       ],
    products: [
        .library(
            name: "OpenID4VP",
            targets: ["OpenID4VP"]),
    ],
    targets: [
        .target(
            name: "OpenID4VP"),
        .testTarget(
            name: "OpenID4VP",
            dependencies: ["OpenID4VP"]),
    ]
)
