// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "MTEngine",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PhysicsEngine", targets: ["PhysicsEngine"])
    ],
    targets: [
        .target(
            name: "PhysicsEngine",
            path: "Sources/PhysicsEngine"
        ),
        .testTarget(
            name: "PhysicsEngineTests",
            dependencies: ["PhysicsEngine"],
            path: "Tests/PhysicsEngineTests"
        ),
        .executableTarget(
            name: "NBodyDemo",
            dependencies: ["PhysicsEngine"],
            path: "Samples",
            sources: ["NPendulumDemo", "PhysicsDebugView"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
