cmake_minimum_required(VERSION 3.20)
project(OCREngine)

option(BUILD_FOR_RISCV "Build for RISC-V architecture" OFF)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "-O3")

# OpenCV
if(BUILD_FOR_RISCV)
    message(STATUS "Configuring for RISC-V cross-compilation")
    
    set(CMAKE_SYSTEM_NAME Linux)
    set(CMAKE_SYSTEM_PROCESSOR riscv64)
    set(CMAKE_C_COMPILER ${CMAKE_SOURCE_DIR}/tools/toolchain/gcc/riscv64-linux-musl-x86_64/bin/riscv64-unknown-linux-musl-gcc)
    set(CMAKE_CXX_COMPILER ${CMAKE_SOURCE_DIR}/tools/toolchain/gcc/riscv64-linux-musl-x86_64/bin/riscv64-unknown-linux-musl-g++)
    
    set(CMAKE_SYSROOT ${CMAKE_SOURCE_DIR}/tools/toolchain/gcc/riscv64-linux-musl-x86_64/sysroot)
    set(CMAKE_FIND_ROOT_PATH ${CMAKE_SOURCE_DIR}/tools/toolchain/gcc/riscv64-linux-musl-x86_64/sysroot)
    set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
    set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
    set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
    
    
    set(OpenCV_DIR "${CMAKE_SOURCE_DIR}/lib/opencv/opencv4_riscv/lib/cmake/opencv4" CACHE PATH "OpenCV config path for RISC-V")
else()
    set(OpenCV_DIR "${CMAKE_SOURCE_DIR}/lib/opencv/opencv4/lib/cmake/opencv4" CACHE PATH "OpenCV config path")
endif()

find_package(OpenCV REQUIRED)
find_package(Iconv QUIET)
find_package(OpenEXR QUIET)
find_package(OpenMP QUIET)

if(NOT OpenMP_CXX_FOUND)
    add_library(OpenMP::OpenMP_CXX INTERFACE IMPORTED)
    set_target_properties(OpenMP::OpenMP_CXX PROPERTIES
        INTERFACE_COMPILE_OPTIONS "-fopenmp"
        INTERFACE_LINK_LIBRARIES "-fopenmp"
    )
endif()

#ncnn
if(BUILD_FOR_RISCV)
    set(ncnn_DIR "${CMAKE_SOURCE_DIR}/lib/ncnn/ncnn_riscv/lib/cmake/ncnn" CACHE PATH "ncnn cmake config path for RISC-V")
else()
    set(ncnn_DIR "${CMAKE_SOURCE_DIR}/lib/ncnn/lib/cmake/ncnn" CACHE PATH "ncnn cmake config path")
endif()
find_package(ncnn REQUIRED)

# main
set(SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/db_net.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/angle_net.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/crnn_net.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/ocr_engine.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/utils.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/3rdparty/clipper2/clipper.engine.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/3rdparty/clipper2/clipper.offset.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/3rdparty/clipper2/clipper.rectclip.cpp
)
add_executable(main ${SOURCES})
target_include_directories(main PRIVATE
    ${OpenCV_INCLUDE_DIRS}
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/src/3rdparty
)
target_link_libraries(main PRIVATE
    ${OpenCV_LIBS}
    ncnn
    OpenMP::OpenMP_CXX
    
)

target_compile_options(main PRIVATE
    -Wall
    -Wextra
    -Wno-unused-function
    -Wno-psabi
)