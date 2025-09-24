project_root=$(pwd)
ncnn_path="lib/ncnn"
install_path=${project_root}/${ncnn_path}/ncnn_riscv
build_dir=${project_root}/${ncnn_path}/build_riscv

# 完全清理之前的構建
rm -rf ${build_dir}
mkdir -p ${build_dir}
cd ${build_dir}

cmake .. \
  -DCMAKE_TOOLCHAIN_FILE=../toolchains/riscv64-linux-gnu.toolchain.cmake \
  -DCMAKE_INSTALL_PREFIX=${install_path} \
  -DCMAKE_BUILD_TYPE=Release \
  -DNCNN_VULKAN=OFF \
  -DNCNN_OPENMP=ON \
  -DNCNN_RUNTIME_CPU=OFF \
  -DNCNN_AVX2=OFF \
  -DNCNN_AVX=OFF \
  -DNCNN_F16C=OFF \
  -DNCNN_FMA=OFF \
  -DNCNN_XOP=OFF

make -j$(nproc)
make install