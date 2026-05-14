// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "F1Core",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "F1Core", targets: ["F1Core"]),
    ],
    targets: [
        .target(
            name: "F1Core",
            path: "Sources"
        ),
    ]
)
