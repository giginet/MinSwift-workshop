// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MinSwift",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "MinSwiftKit",
            targets: ["MinSwiftKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", .exact("0.40200.0")),
        .package(url: "https://github.com/llvm-swift/LLVMSwift.git", .upToNextMinor(from: "0.4.0")),
        .package(url: "https://github.com/llvm-swift/FileCheck.git", .upToNextMinor(from: "0.0.3"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "minswift", dependencies: ["MinSwiftKit"]),
        .target(
            name: "MinSwiftKit",
            dependencies: ["SwiftSyntax", "LLVM"]),
        .testTarget(
            name: "MinSwiftKitTests",
            dependencies: ["MinSwiftKit", "FileCheck"])
    ]
)
