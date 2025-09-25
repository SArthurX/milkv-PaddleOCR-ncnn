# milkv-PaddleOCR-ncnn

This repository provides a C++ implementation of PaddleOCR optimized for RISC-V architecture, using the ncnn inference framework for efficient OCR processing on Milk-V platforms.


## System Requirements

### Dependencies
- **OpenCV** x
- **ncnn** inference framework

## Installation Guide

### 1. Download Dependencies

#### 1.1 Download and Build OpenCV

**For x86 platform:**
```bash
# Run OpenCV build script
./tools/build_opencv.sh
```

**For RISC-V platform:**
```bash
# Run RISC-V OpenCV build script
./tools/build_opencv_risc.sh
```

After compilation, OpenCV will be installed in:
- x86: `lib/opencv/opencv4/`
- RISC-V: `lib/opencv/opencv4_riscv/`

#### 1.2 Download and Build ncnn

**For x86 platform:**
```bash
# Enter ncnn directory
cd lib/ncnn

# Run build script
./build.sh

# After completion, lib/cmake/ncnn directory will be generated
```

**For RISC-V platform:**
```bash
# Run RISC-V ncnn build script
cd tools
./build_ncnn_risc.sh
```

After compilation, ncnn will be installed in:
- x86: `lib/ncnn/lib/cmake/ncnn/`
- RISC-V: `lib/ncnn/ncnn_riscv/lib/cmake/ncnn/`

### 2. Download Model Files

Model files should be placed in the `models/` directory, including:

```
models/
├── det.bin                    # Detection model binary file
├── det.param                  # Detection model parameter file
├── cls.bin                    # Classification model binary file
├── cls.param                  # Classification model parameter file
├── rec.bin                    # Recognition model binary file
├── rec.param                  # Recognition model parameter file
└── keys.txt                   # Character dictionary file
```

**Recommended Models:**
- PP-OCRv3 series models
- PP-OCRv5 series models (mobile/server versions)

### 3. Build Project

#### 3.1 x86 Platform Build

```bash
# Create build directory
mkdir -p build
cd build

# Configure CMake
cmake ..

# Build
make -j$(nproc)
```

#### 3.2 RISC-V Platform Build

```bash
# Use provided build script
./tools/build.sh
```

Or manual build:

```bash
# Create build directory
mkdir -p build
cd build

# Configure CMake (enable RISC-V cross-compilation)
cmake .. -DBUILD_FOR_RISCV=ON

# Build
make -j$(nproc)
```

## Usage

### Basic Usage

```bash
# Syntax
./build/main <config_file> <image_path>

# Example
./build/main config.json images/test.jpg
```

### Configuration File

Edit `config.json` to adjust OCR parameters:

```json
{
    "save": true,
    "det": {
        "infer_threads": -1,          // Inference thread count (-1 for auto)
        "model_path": "../models/det", // Detection model path
        "padding": 0,                 // Padding size
        "max_side_len": 768,          // Maximum side length
        "box_thres": 0.5,             // Box threshold
        "bitmap_thres": 0.3,          // Binarization threshold
        "unclip_ratio": 2.0,          // Expansion ratio
        "fp16": false                 // Whether to use FP16
    },
    "cls": {
        "infer_threads": 1,           // Inference thread count
        "reco_threads": -1,           // Recognition thread count
        "model_path": "../models/cls", // Classification model path
        "enable": true,               // Whether to enable classification
        "most_angle": true,           // Whether to use most common angle
        "fp16": false                 // Whether to use FP16
    },
    "rec": {
        "infer_threads": 1,           // Inference thread count
        "reco_threads": -1,           // Recognition thread count
        "model_path": "../models/rec", // Recognition model path
        "keys_path": "../models/keys.txt", // Dictionary file path
        "fp16": false                 // Whether to use FP16
    }
}
```

### Output Results

The program will output recognized text content, including:
- Text region coordinates
- Confidence scores
- Recognized text content

## Directory Structure

```
PaddleOCR-ncnn-CPP/
├── src/                      # Source code
│   ├── main.cpp             # Main program entry
│   ├── ocr_engine.cpp       # OCR engine implementation
│   ├── db_net.cpp           # DB detection network
│   ├── angle_net.cpp        # Angle classification network
│   ├── crnn_net.cpp         # CRNN recognition network
│   ├── utils.cpp            # Utility functions
│   └── 3rdparty/           # Third-party libraries
├── models/                  # Model files directory
├── images/                  # Test images
├── lib/                     # Dependencies
│   ├── opencv/             # OpenCV library
│   └── ncnn/               # ncnn library
├── tools/                   # Build tools
│   ├── build.sh            # RISC-V build script
│   ├── build_opencv.sh     # OpenCV build script
│   ├── build_opencv_risc.sh # RISC-V OpenCV build script
│   └── build_ncnn_risc.sh  # RISC-V ncnn build script
├── config.json             # Configuration file
└── CMakeLists.txt          # CMake configuration
```

## Performance Optimization

### Thread Configuration
- `infer_threads`: Inference thread count, -1 means using all available cores
- `reco_threads`: Recognition thread count for parallel processing of multiple text regions

### Model Selection
- **Mobile Models**: Smaller and faster, suitable for resource-constrained devices
- **Server Models**: Larger and more accurate, suitable for high-performance requirements

### FP16 Acceleration
- Enable `"fp16": true` on supported hardware to improve inference speed

## Troubleshooting

### Common Issues

1. **OpenCV not found**
   ```
   Solution: Ensure OpenCV is correctly compiled and installed, check path settings in CMakeLists.txt
   ```

2. **ncnn not found**
   ```
   Solution: Ensure ncnn is correctly compiled, check ncnn_DIR path settings
   ```

3. **Model loading failed**
   ```
   Solution: Check model file paths, ensure both .bin and .param files exist
   ```

4. **RISC-V cross-compilation failed**
   ```
   Solution: Ensure RISC-V toolchain is correctly installed, check tools/toolchain/ directory
   ```

### Debug Mode

Modify log level in `src/main.cpp`:
```cpp
// Detailed output
plog::init(plog::debug, &console_appender);

// Basic output
plog::init(plog::info, &console_appender);
```

## License

This project follows the license terms in the [LICENSE](LICENSE) file.

## Acknowledgments

- [PaddleOCR](https://github.com/PaddlePaddle/PaddleOCR) 
- [ncnn](https://github.com/Tencent/ncnn) 
- [OpenCV](https://opencv.org/)
- [Avafly](https://github.com/Avafly/PaddleOCR-ncnn-CPP)

## Contributing

Issues and Pull Requests are welcome to improve this project!