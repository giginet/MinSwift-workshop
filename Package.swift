// swift-tools-version:5.1

import PackageDescription

let rpath = "/Applications/Xcode-beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx"

let package = Package(
    name: "MinSwift",
    platforms: [.macOS(.v10_14)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "MinSwiftKit",
            targets: ["MinSwiftKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git",
                 .revision("swift-DEVELOPMENT-SNAPSHOT-2019-07-10-m")),
        .package(url: "https://github.com/llvm-swift/LLVMSwift.git",
                 .revision("0.4.1")),
        .package(url: "https://github.com/llvm-swift/FileCheck.git",
                 from: "0.0.3")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "minswift", dependencies: ["MinSwiftKit"],
                linkerSettings: [
                    .unsafeFlags(["-rpath", rpath])
            ]
        ),
        .target(
            name: "MinSwiftKit",
            dependencies: ["SwiftSyntax", "LLVM"]),
        .testTarget(
            name: "MinSwiftKitTests",
            dependencies: ["MinSwiftKit", "FileCheck"])
    ]
)
