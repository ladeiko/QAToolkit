// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "QAToolkit",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "QAToolkit",
            targets: ["QAToolkit"]),
    ],
    targets: [
        .target(
            name: "QAToolkit",
            path: "QAToolkit",
            publicHeadersPath: "Headers"),
    ]
)
