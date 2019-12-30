#!/usr/bin/env sh

is_debug=false
is_bitcode=false
is_copy_header=false
is_fat=false

options=${@:3}

while getopts ":dbhf" option ${options}; do
    case "$option" in
    d)
        is_debug=true
        ;;
    b)
        is_bitcode=true
        ;;
    h)
        is_copy_header=true
        ;;
    f)
        is_fat=true
        ;;
    ?)
        echo "Usage:[-d isDebug] [-b enableBitcode] [-h copyHeaders] [-f buildFat]"
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

arm_build_path="./out/iOS_32"
arm64_build_path="./out/iOS_64"
simulator_build_path="./out/iOS_simulator"

mkdir -p ${arm_build_path}
mkdir -p ${arm64_build_path}
mkdir -p ${simulator_build_path}

# 分别编译模拟器和真机模块
gn gen "$arm_build_path" --args="target_os=\"ios\" target_cpu=\"arm\" enable_ios_bitcode=${is_bitcode} is_debug=${is_debug} use_xcode_clang=true"
gn gen "$arm64_build_path" --args="target_os=\"ios\" target_cpu=\"arm64\" enable_ios_bitcode=${is_bitcode} is_debug=${is_debug} use_xcode_clang=true"
gn gen "$simulator_build_path" --args="target_os=\"ios\" target_cpu=\"x64\" enable_ios_bitcode=${is_bitcode} is_debug=${is_debug} use_xcode_clang=true"

ninja -C ${arm_build_path} ${lib_name}
ninja -C ${arm64_build_path} ${lib_name}
ninja -C ${simulator_build_path} ${lib_name}

output_lib_path="${output_root_path}/lib"

mkdir -p ${output_lib_path}

output_lib_arm_path="${output_root_path}/lib/${lib_name}-arm.a"
output_lib_arm64_path="${output_root_path}/lib/${lib_name}-arm64.a"
output_lib_simulator_path="${output_root_path}/lib/${lib_name}-simulator.a"

# 拷贝编译产物
cp "${arm_build_path}/obj/${lib_path:1}/lib${lib_name}.a" ${output_lib_arm_path}
cp "${arm64_build_path}/obj/${lib_path:1}/lib${lib_name}.a" ${output_lib_arm64_path}
cp "${simulator_build_path}/obj/${lib_path:1}/lib${lib_name}.a" ${output_lib_simulator_path}

# 合并架构
if [[ ${is_fat} == true ]]; then
    echo "create fat lib"
    lipo -create ${output_lib_arm_path} ${output_lib_arm64_path} ${output_lib_simulator_path} -output "${output_root_path}/lib/${lib_name}-fat.a"
fi

# 抽取头文件
if [[ ${is_copy_header} == true ]]; then
	echo "copy webrtc headers"
	output_header_path="${output_root_path}/include"
	mkdir -p ${output_header_path}
	headers=`find . -name '*.h'`
	for header in $headers
	do
		echo "copy header path: ${header}"
		ditto ${header} "${output_header_path}/${header:1}"
	done
fi

open ${output_root_path}


