// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AugramX",
    platforms: [.iOS(.v17)],
    products: [
        .application(
            name: "AugramX",
            targets: ["App"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "App",
            dependencies: ["Core", "Design", "Views", "ViewModels"],
            path: "Sources/App",
            resources: [.process("Resources")]
        ),
        .target(name: "Core", path: "Sources/Core"),
        .target(name: "Design", path: "Sources/Design"),
        .target(name: "Views", path: "Sources/Views"),
        .target(name: "ViewModels", path: "Sources/ViewModels")
    ]
)
