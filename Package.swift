// swift-tools-version:5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RSCore",
    defaultLocalization: "en",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .library(name: "RSCore", type: .dynamic, targets: ["RSCore"]),
		.library(name: "RSCoreResources", type: .static, targets: ["RSCoreResources"])
    ],
    targets: [
        .target(
            name: "RSCore",
            dependencies: [], resources: [.process("Resources")]),
		.target(
            name: "RSCoreResources",
            resources: [
                .process("Resources/WebViewWindow.xib"),
                .process("Resources/IndeterminateProgressWindow.xib")
            ]),
        .testTarget(
            name: "RSCoreTests",
            dependencies: ["RSCore"]),
    ]
)
