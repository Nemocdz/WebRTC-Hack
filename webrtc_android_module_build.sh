#!/usr/bin/env sh

is_debug=false
is_copy_header=false

options=${@:3}

while getopts ":dh" option ${options}; do
    case "$option" in
    d)
        is_debug=true
        ;;
    h)
        is_copy_header=true
        ;;
    ?)
        echo "Usage:[-d isDebug] [-h copyHeaders]"
        exit -1
        ;;
    esac
done

# 检查输入的模块路径
 if [ ! -n ${1} ]; then
    echo "unknown lib path"
    exit 1
fi

# 检查输入的输出路径
 if [ ! -n ${2} ]; then
    echo "unknown output path"
    exit 1
# 不允许输出在源码内
 elif [[ ${2} == ./* ]]; then
    echo "can't use current path"
    exit 1
fi

lib_path=${1}
output_root_path=${2}

# 获取模块名字，为路径最后一部分
lib_name=$(echo "$lib_path" | awk -F "/" '{print $(NF)}')

arm_build_path="./out/android_32"
arm64_build_path="./out/android_64"

mkdir -p ${arm_build_path}
mkdir -p ${arm64_build_path}

# 编译真机模块
gn gen "$arm_build_path" --args="target_os=\"android\" target_cpu=\"arm\" is_debug=${is_debug} use_custom_libcxx=false"
gn gen "$arm64_build_path" --args="target_os=\"android\" target_cpu=\"arm64\" is_debug=${is_debug} use_custom_libcxx=false"

ninja -C ${arm_build_path} ${lib_name}
ninja -C ${arm64_build_path} ${lib_name}

output_lib_path="${output_root_path}/lib"

mkdir -p ${output_lib_path}

output_lib_arm_path="${output_root_path}/lib/${lib_name}-arm.a"
output_lib_arm64_path="${output_root_path}/lib/${lib_name}-arm64.a"

# 拷贝编译产物
cp "${arm_build_path}/obj/${lib_path:1}/lib${lib_name}.a" ${output_lib_arm_path}
cp "${arm64_build_path}/obj/${lib_path:1}/lib${lib_name}.a" ${output_lib_arm64_path}

# 抽取头文件
if [[ ${is_copy_header} == true ]]; then
    echo "copy webrtc headers"
    output_header_path="${output_root_path}/include"
    mkdir -p ${output_header_path}
    find . -name "*.h" -type | xargs -I {} cp --parents {} ${output_header_path}
fi
