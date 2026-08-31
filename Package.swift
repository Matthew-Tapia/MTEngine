// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "MTEngine",
    platforms: [.macOS(.v15), .iOS(.v18)], // RealityViewCameraContent requires macOS 15 / iOS 18
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
        )
    ],
    swiftLanguageModes: [.v6]
)
