// swift-tools-version:5.9
// Generated file. Do not edit.

import PackageDescription

let package = Package(
    name: "onnxruntime",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "onnxruntime", targets: ["OnnxRuntimeBindings"]),
    ],
    targets: [
        .target(
            name: "OnnxRuntimeBindings",
            dependencies: ["onnxruntime"],
            path: "objectivec",
            // No unsafeFlags: SPM rejects them in packages consumed by URL.
            cxxSettings: [
                .define("SPM_BUILD"),
            ],
            linkerSettings: [
                .linkedLibrary("c++"),
            ]
        ),
        .binaryTarget(name: "onnxruntime", url: "https://github.com/im-noon/onnxruntime-ios/releases/download/1.32.1/onnxruntime.xcframework.zip", checksum: "0305e64c2c32df665cd4e07e451e488e4aae50f1051500e24df6623e93490197"),
    ],
    cxxLanguageStandard: .cxx17
)
