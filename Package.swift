// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PostgREST",
    platforms: [.iOS(.v11), .macOS(.v10_10)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PostgREST",
            targets: ["PostgREST"]
        ),
        .executable(name: "example", targets: ["example"]),
    ],
    dependencies: [
        .package(
            name: "SnapshotTesting",
            url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.8.1"
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PostgREST",
            dependencies: []
        ),
        .target(
            name: "example",
            dependencies: ["PostgREST"]
        ),
        .testTarget(
            name: "PostgRESTTests",
            dependencies: ["PostgREST", "SnapshotTesting"]
        ),
    ]
)
