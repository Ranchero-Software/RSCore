// swift-tools-version:5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RSCore",
    platforms: [.macOS(SupportedPlatform.MacOSVersion.v13), .iOS(SupportedPlatform.IOSVersion.v16)],
    products: [
        .library(name: "RSCore", type: .dynamic, targets: ["RSCore"]),
		.library(name: "RSCoreResources", type: .static, targets: ["RSCoreResources"])
    ],
    targets: [
        .target(
            name: "RSCore",
            dependencies: []),
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
