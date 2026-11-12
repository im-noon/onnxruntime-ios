# onnxruntime-ios

A size-reduced [ONNX Runtime](https://github.com/microsoft/onnxruntime) for iOS, packaged for Swift Package Manager.
It runs CNN models (fp32 and int8/uint8 quantized) in ORT format (`.ort`) on the CPU and XNNPACK execution
providers.

| | |
|---|---|
| ONNX Runtime version | 1.32.0 |
| Execution providers | CPU, XNNPACK |
| Model format | `.ort` only (ORT minimal build) |
| Platforms | iOS 15.1+ (device arm64, simulator arm64 and x86_64) |
| Size added to an app | 4.2 MB on iPhone arm64 (1.6 MB compressed) |
| APIs | Objective-C/Swift (`OnnxRuntimeBindings`), C and C++ |

## Installation

In Xcode, choose **File > Add Package Dependencies** and enter `https://github.com/im-noon/onnxruntime-ios`, or add it
to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/im-noon/onnxruntime-ios", exact: "1.32.0"),
],
targets: [
    .target(name: "MyTarget", dependencies: [.product(name: "onnxruntime", package: "onnxruntime-ios")]),
]
```

## Usage

```swift
import OnnxRuntimeBindings

let env = try ORTEnv(loggingLevel: .warning)
let options = try ORTSessionOptions()
try options.appendXnnpackExecutionProvider(with: ORTXnnpackExecutionProviderOptions())
let session = try ORTSession(env: env, modelPath: modelPath, sessionOptions: options)

let input = try ORTValue(tensorData: NSMutableData(data: pixels), elementType: .float, shape: [1, 3, 224, 224])
let outputs = try session.run(withInputs: ["input": input], outputNames: ["output"], runOptions: nil)
let scores = try outputs["output"]!.tensorData() as Data
```

The C and C++ APIs are available from the `onnxruntime` framework, e.g. `#include <onnxruntime/onnxruntime_cxx_api.h>`.

## Models

This build loads only ORT-format models. Convert an `.onnx` model with the `onnxruntime` Python package:

```bash
python -m onnxruntime.tools.convert_onnx_models_to_ort --target_platform arm --optimization_style Fixed model.onnx
```

Use `--optimization_style Fixed`. Runtime-style models fail to load when the XNNPACK provider is enabled in a minimal
build.

Only the operators a TensorFlow Lite-style CNN needs are included: convolution, pooling, normalization, activations,
quantization (QDQ and QOperator), resize, shape and post-processing ops such as NonMaxSuppression and TopK, for ONNX
opsets 12 to 23. A model that uses another operator fails to load with a "kernel not found" error.

## How it is built

- Source: [microsoft/onnxruntime](https://github.com/microsoft/onnxruntime) at `e19a9ae831`, plus a fix for
  undefined interop API symbols in minimal builds (`onnxruntime/core/session/interop_api.cc`).
- Flags: `--minimal_build=extended`, a reduced operator and type set (float, int8, uint8), `--disable_ml_ops`,
  `--use_xnnpack`, `--no_telemetry`, `MinSizeRel`, dynamic framework.
- No telemetry: the Microsoft 1DS telemetry client that ORT mobile builds include by default is not built in, so the
  runtime makes no network requests.

The `OnnxRuntimeBindings` target is compiled from ONNX Runtime's `objectivec/` sources, without the training API and
CoreML provider.

## License

ONNX Runtime is licensed under the MIT License (see `LICENSE`). Bundled third-party components are listed in
`ThirdPartyNotices.txt`.
