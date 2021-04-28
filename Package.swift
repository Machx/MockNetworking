// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MockNetworking",
	platforms: [
		.macOS(.v11),
		.iOS(.v14),
	],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MockNetworking",
            targets: ["MockNetworking"]),
    ],
    dependencies: [
		.package(url: "https://github.com/Machx/Konkyo.git", .branch("main")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MockNetworking",
            dependencies: ["Konkyo"]),
        .testTarget(
            name: "MockNetworkingTests",
            dependencies: ["MockNetworking"]),
    ]
)
