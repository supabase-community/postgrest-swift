// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "PostgREST",
  platforms: [
    .iOS(.v13),
    .macCatalyst(.v13),
    .macOS(.v10_15),
    .watchOS(.v6),
    .tvOS(.v13),
  ],
  products: [
    .library(
      name: "PostgREST",
      targets: ["PostgREST"]
    ),
  ],
  dependencies: [
    .package(
      name: "SnapshotTesting",
      url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.8.1"
    ),
    .package(name: "AnyCodable", url: "https://github.com/Flight-School/AnyCodable", from: "0.6.2"),
  ],
  targets: [
    .target(
      name: "PostgREST",
      dependencies: [
        "AnyCodable",
      ]
    ),
    .testTarget(
      name: "PostgRESTTests",
      dependencies: [
        "PostgREST",
        .product(
          name: "SnapshotTesting",
          package: "SnapshotTesting",
          condition: .when(platforms: [.iOS, .macOS, .tvOS])
        ),
      ],
      exclude: [
        "__Snapshots__",
      ]
    ),
    .testTarget(name: "PostgRESTIntegrationTests", dependencies: ["PostgREST"]),
  ]
)
