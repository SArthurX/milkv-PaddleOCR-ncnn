project_root=$(pwd)
ncnn_path="lib/ncnn"
install_path=${project_root}/${ncnn_path}/ncnn_riscv
build_dir=${project_root}/${ncnn_path}/build_riscv

# 設置 RISCV_ROOT_PATH 環境變量
export RISCV_ROOT_PATH="${project_root}/tools/toolchain/gcc/riscv64-linux-musl-x86_64"

rm -rf ${build_dir}
mkdir -p ${build_dir}
cd ${build_dir}

cmake .. \
  -DCMAKE_TOOLCHAIN_FILE=../toolchains/riscv64-unknown-linux-gnu.toolchain.cmake \
  -DCMAKE_INSTALL_PREFIX=${install_path} \
  -DCMAKE_BUILD_TYPE=Release \
  -DNCNN_VULKAN=OFF \
  -DNCNN_OPENMP=OFF \
  -DNCNN_RUNTIME_CPU=OFF \
  -DNCNN_AVX2=OFF \
  -DNCNN_AVX=OFF \
  -DNCNN_F16C=OFF \
  -DNCNN_FMA=OFF \
  -DNCNN_XOP=OFF

make -j$(nproc)
make install