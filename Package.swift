// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "OpenOneNote",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "NotebookCore", targets: ["NotebookCore"]),
        .library(name: "NotebookPersistence", targets: ["NotebookPersistence"]),
        .library(name: "NotebookEditor", targets: ["NotebookEditor"]),
        .executable(name: "openonenote-dev", targets: ["OpenOneNoteDev"]),
        .executable(name: "OpenOneNoteMac", targets: ["OpenOneNoteMac"]),
        .executable(name: "onenote-research", targets: ["OneNoteResearch"]),
        .executable(name: "openonenote", targets: ["OpenOneNoteCLI"])
    ],
    targets: [
        .target(name: "NotebookCore"),
        .target(name: "NotebookPersistence", dependencies: ["NotebookCore"]),
        .target(name: "NotebookEditor", dependencies: ["NotebookCore", "NotebookPersistence"]),
        .target(name: "DevelopmentKit"),
        .executableTarget(name: "OpenOneNoteDev", dependencies: ["DevelopmentKit"]),
        .executableTarget(name: "OpenOneNoteMac", dependencies: ["NotebookEditor"]),
        .executableTarget(name: "OneNoteResearch"),
        .executableTarget(name: "OpenOneNoteCLI", dependencies: ["NotebookCore", "NotebookPersistence"]),
        .testTarget(name: "NotebookCoreTests", dependencies: ["NotebookCore", "NotebookPersistence"]),
        .testTarget(name: "NotebookEditorTests", dependencies: ["NotebookEditor", "NotebookCore", "NotebookPersistence"]),
        .testTarget(name: "DevelopmentKitTests", dependencies: ["DevelopmentKit"])
    ]
)
