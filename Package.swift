// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "GRDBExt",
  platforms: [
    .iOS(.v11),
    .macOS(.v10_13),
    .tvOS(.v11),
    .watchOS(.v4),
  ],
  products: [
    .library(name: "GRDBExt", targets: ["GRDBExt"]),
  ],
  dependencies: [
    .package(url: "https://github.com/groue/GRDB.swift", from: "6.2.0"),
  ],
  targets: [
    .target(
      name: "GRDBExt",
      dependencies: [
        .product(name: "GRDB", package: "GRDB.swift"),
      ],
      path: "Sources"
    ),
    .testTarget(
      name: "GRDBExtTests",
      dependencies: [
        "GRDBExt",
      ],
      path: "Tests"
    ),
  ],
  swiftLanguageVersions: [.v5]
)
