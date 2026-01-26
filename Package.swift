// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "sqlite-data",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
    .tvOS(.v16),
    .watchOS(.v9),
    .macCatalyst(.v16),
  ],
  products: [
    .library(
      name: "SQLiteData",
      targets: ["SQLiteData"]
    ),
    .library(
      name: "SQLiteDataTestSupport",
      targets: ["SQLiteDataTestSupport"]
    ),
  ],
  traits: [
    .trait(
      name: "SQLiteDataTagged",
      description: "Introduce SQLiteData conformances to the swift-tagged package."
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-collections", from: "1.0.0"),
    // GRDB fork with Android support (removes CSQLite dependency that doesn't compile on Android)
    .package(url: "https://github.com/svobodamarek/GRDB.swift", branch: "master"),
    .package(url: "https://github.com/pointfreeco/swift-concurrency-extras", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.3.3"),
    // Dependencies fork with Android support (uses OpenCombine via combine-schedulers fork)
    .package(url: "https://github.com/svobodamarek/swift-dependencies", branch: "main"),
    .package(url: "https://github.com/pointfreeco/swift-perception", from: "2.0.0"),
    // Sharing fork with Android support (uses forked dependencies)
    .package(url: "https://github.com/svobodamarek/swift-sharing", branch: "main"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.4"),
    // Structured queries fork with Android support (uses OpenCombine)
    .package(
      url: "https://github.com/svobodamarek/swift-structured-queries",
      branch: "main",
      traits: [
        .trait(name: "StructuredQueriesTagged", condition: .when(traits: ["SQLiteDataTagged"]))
      ]
    ),
    .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.5.0"),
    // JNI support for Skip native Android builds.
    .package(url: "https://source.skip.tools/swift-jni.git", from: "0.3.1"),
    // Android native support modules (provides AndroidNDK).
    .package(url: "https://source.skip.tools/swift-android-native.git", from: "1.4.3"),
  ],
  targets: [
    .target(
      name: "SQLiteData",
      dependencies: [
        .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "GRDB", package: "GRDB.swift"),
        .product(name: "IssueReporting", package: "xctest-dynamic-overlay"),
        .product(name: "OrderedCollections", package: "swift-collections"),
        .product(name: "Perception", package: "swift-perception"),
        .product(name: "Sharing", package: "swift-sharing"),
        .product(name: "StructuredQueriesSQLite", package: "swift-structured-queries"),
        .product(name: "SwiftJNI", package: "swift-jni"),
        .product(name: "AndroidNative", package: "swift-android-native", condition: .when(platforms: [.android])),
        .product(
          name: "Tagged",
          package: "swift-tagged",
          condition: .when(traits: ["SQLiteDataTagged"])
        ),
      ]
    ),
    .target(
      name: "SQLiteDataTestSupport",
      dependencies: [
        "SQLiteData",
        .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
        .product(name: "CustomDump", package: "swift-custom-dump"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing"),
        .product(name: "StructuredQueriesTestSupport", package: "swift-structured-queries"),
      ]
    ),
    .testTarget(
      name: "SQLiteDataTests",
      dependencies: [
        "SQLiteData",
        "SQLiteDataTestSupport",
        .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
        .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing"),
        .product(name: "SnapshotTestingCustomDump", package: "swift-snapshot-testing"),
        .product(name: "StructuredQueries", package: "swift-structured-queries"),
      ]
    ),
  ],
  swiftLanguageModes: [.v6]
)

let swiftSettings: [SwiftSetting] = [
  .enableUpcomingFeature("MemberImportVisibility")
  // .unsafeFlags([
  //   "-Xfrontend",
  //   "-warn-long-function-bodies=50",
  //   "-Xfrontend",
  //   "-warn-long-expression-type-checking=50",
  // ])
]

for index in package.targets.indices {
  package.targets[index].swiftSettings = swiftSettings
}

#if !os(Windows)
  // Add the documentation compiler plugin if possible
  package.dependencies.append(
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
  )
#endif
