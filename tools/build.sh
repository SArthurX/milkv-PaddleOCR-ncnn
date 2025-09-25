project_root=$(pwd)

rm -rf ${project_root}/build
mkdir -p ${project_root}/build
cd ${project_root}/build

cmake ..  -DBUILD_FOR_RISCV=ON
make -j$(nproc)