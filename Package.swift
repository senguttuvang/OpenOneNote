// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "OpenOneNote",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "NotebookCore", targets: ["NotebookCore"]),
        .library(name: "NotebookPersistence", targets: ["NotebookPersistence"]),
        .executable(name: "onenote-research", targets: ["OneNoteResearch"]),
        .executable(name: "openonenote", targets: ["OpenOneNoteCLI"])
    ],
    targets: [
        .target(name: "NotebookCore"),
        .target(name: "NotebookPersistence", dependencies: ["NotebookCore"]),
        .executableTarget(name: "OneNoteResearch"),
        .executableTarget(name: "OpenOneNoteCLI", dependencies: ["NotebookCore", "NotebookPersistence"]),
        .testTarget(name: "NotebookCoreTests", dependencies: ["NotebookCore", "NotebookPersistence"])
    ]
)
