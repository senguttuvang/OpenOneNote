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
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-markdown.git", exact: "0.9.0"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", exact: "2.14.3"),
        .package(url: "https://github.com/AzureAD/microsoft-authentication-library-for-objc.git", exact: "2.16.0")
    ],
    targets: [
        .target(name: "MarkdownNotes", dependencies: [.product(name: "Markdown", package: "swift-markdown"), .product(name: "SwiftSoup", package: "SwiftSoup")]),
        .target(name: "OneNoteGraph", dependencies: ["MarkdownNotes", .product(name: "MSAL", package: "microsoft-authentication-library-for-objc")]),
        .target(name: "MarkdownEditor", dependencies: ["MarkdownNotes", "OneNoteGraph"], resources: [.copy("Resources/Mermaid")]),
        .target(name: "NotebookCore"),
        .target(name: "NotebookPersistence", dependencies: ["NotebookCore"]),
        .target(name: "NotebookEditor", dependencies: ["NotebookCore", "NotebookPersistence"]),
        .target(name: "DevelopmentKit", dependencies: ["MarkdownNotes"]),
        .executableTarget(name: "OpenOneNoteDev", dependencies: ["DevelopmentKit"]),
        .executableTarget(name: "OpenOneNoteMac", dependencies: ["NotebookEditor", "MarkdownEditor"]),
        .executableTarget(name: "OneNoteResearch"),
        .executableTarget(name: "OpenOneNoteCLI", dependencies: ["NotebookCore", "NotebookPersistence"]),
        .testTarget(name: "NotebookCoreTests", dependencies: ["NotebookCore", "NotebookPersistence"]),
        .testTarget(name: "NotebookEditorTests", dependencies: ["NotebookEditor", "NotebookCore", "NotebookPersistence"]),
        .testTarget(name: "DevelopmentKitTests", dependencies: ["DevelopmentKit"]),
        .testTarget(name: "MarkdownNotesTests", dependencies: ["MarkdownNotes", "OneNoteGraph", "MarkdownEditor"])
    ]
)
