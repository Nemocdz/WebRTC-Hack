# WebRTC_Hack

WebRTC Native 的源码有 12G，完整编译很慢，直接使用也要解决繁琐的依赖。本项目用于单独编译 WebRTC 中的模块为静态库，方便后续升级和使用。

## 准备工作

参考 [WebRTC 官网教程](https://webrtc.org/native-code/development/)，先安装好 [Chromium depot tools](http://dev.chromium.org/developers/how-tos/install-depot-tools) 和下载好源码。

* iOS：MacOS + Xcode
* Android：Linux

## 编译单独模块

### iOS

1. 修改需要编译的模块文件夹下的 `BUILD.gn` 文件，例如 `modules/audio_processing/BUILD.gn`

   ```
   rtc_static_library("audio_processing") {
   	// 增加下面这一句，这样才会将依赖也编译进去
     complete_static_lib = true 
     // ...
    }
   ```

2. 拷贝 webrtc_iOS_module_build.sh 到 WebRTC 的源码目录中

3. `cd` 到源码目录下

4. `sh webrtc_iOS_module_build.sh <模块路径> <静态库输出路径> <可选项>` 选项如下：

   * -d：表示以 Debug 模式编译，默认为 Release
   * -b：表示开启 Bitcode，默认不开启
   * -h：表示拷贝完整头文件，默认不拷贝
   * -f：表示生成合并多个架构的静态库，默认不合成

#### Example

```shell
sh webrtc_iOS_module_build.sh ./common_audio ~/Desktop/output -b -f
```

#### 文章

[WebRTC Native 模块单独编译静态库（iOS）](https://nemocdz.github.io/post/webrtc-native-%E6%A8%A1%E5%9D%97%E5%8D%95%E7%8B%AC%E7%BC%96%E8%AF%91%E9%9D%99%E6%80%81%E5%BA%93ios/)

### Android

1. 修改需要编译的模块文件夹下的 `BUILD.gn` 文件，例如 `modules/audio_processing/BUILD.gn`

   ```
   rtc_static_library("audio_processing") {
   	// 增加下面这一句，这样才会将依赖也编译进去
     complete_static_lib = true 
     // ...
    }
   ```

2. 拷贝 webrtc_android_module_build.sh 到 WebRTC 的源码目录中

3. `cd` 到源码目录下

4. `sh webrtc_android_module_build.sh <模块路径> <静态库输出路径> <可选项>` 选项如下：

   * -d：表示以 Debug 模式编译，默认为 Release
   * -h：表示拷贝完整头文件，默认不拷贝

#### Example

```shell
sh webrtc_android_module_build.sh ./common_audio ~/Desktop/output -d -h
```

