cmake_minimum_required(VERSION 3.20)
project(OCREngine)

# 添加 RISC-V 编译选项
option(BUILD_FOR_RISCV "Build for RISC-V architecture" OFF)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "-O3")

# 靜態編譯配置
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(BUILD_SHARED_LIBS OFF)
set(CMAKE_EXE_LINKER_FLAGS "-static-libgcc -static-libstdc++")

# 如果是 RISC-V 交叉編譯，使用完全靜態鏈接
if(BUILD_FOR_RISCV)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static")
endif()

# libs path
set(LIB_ROOT "${CMAKE_SOURCE_DIR}")

# RISC-V 交叉编译配置
if(BUILD_FOR_RISCV)
    message(STATUS "Configuring for RISC-V cross-compilation")
    
    # 设置交叉编译工具链
    set(CMAKE_SYSTEM_NAME Linux)
    set(CMAKE_SYSTEM_PROCESSOR riscv64)
    set(CMAKE_C_COMPILER /usr/bin/riscv64-linux-gnu-gcc)
    set(CMAKE_CXX_COMPILER /usr/bin/riscv64-linux-gnu-g++)
    
    # 设置 sysroot
    set(CMAKE_SYSROOT /usr/riscv64-linux-gnu)
    set(CMAKE_FIND_ROOT_PATH /usr/riscv64-linux-gnu)
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

if(OpenMP_CXX_FOUND)
        message(STATUS "OpenMP found for RISC-V: ${OpenMP_CXX_VERSION}")
    else()
        message(WARNING "OpenMP not found for RISC-V, creating dummy OpenMP target")
        # 創建一個虛擬的 OpenMP 目標來滿足 ncnn 的依賴
        add_library(OpenMP::OpenMP_CXX INTERFACE IMPORTED)
        set_target_properties(OpenMP::OpenMP_CXX PROPERTIES
            INTERFACE_COMPILE_OPTIONS "-fopenmp"
            INTERFACE_LINK_LIBRARIES "-fopenmp"
        )
        set(OpenMP_CXX_FOUND TRUE)
        set(OpenMP_CXX_FLAGS "-fopenmp")
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
    
)

if(OpenMP_CXX_FOUND)
    target_link_libraries(main PRIVATE OpenMP::OpenMP_CXX)
endif()

target_compile_options(main PRIVATE
    -Wall
    -Wextra
    -Wno-unused-function
    -Wno-psabi
)