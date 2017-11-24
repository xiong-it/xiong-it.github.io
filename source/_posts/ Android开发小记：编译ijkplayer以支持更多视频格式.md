---
title: Android开发小记：编译ijkplayer以支持更多视频格式
date: 2017-09-22 21:11:02
tags: [Android, ijkplayer]
categories: Android
---
ijkplayer默认是不支持播放av的，呵呵，台词错了，是avi，今天分享下自己编译ijkplayer以支持avi，mpeg/mpg等更多格式视频。
<!--more-->
前言
==
ijkplayer大法好，感谢B站大佬。ijkplayer基于FFmpeg开发，适配Android/iOS平台。FFmpeg在开发界简直是神一般存在的项目，全平台全格式音视频编解码支持。像前段时间“杀程序员祭天”的暴风，受众颇广的QQ影音都是FFmpeg的受益者，因为不遵循GNU LGPL协议，也是FFmpeg项目耻辱柱上的成员。
但是ijkplayer默认是不支持播放av的，呵呵，台词错了，是avi，今天分享下自己编译ijkplayer以支持avi，mpeg/mpg等更多格式视频。

前提条件
==
生产环境是MacOS或者Linux系统，笔者是MacOS，Android 6.0，这里以Mac为例记下自己编译ijkplayer for Android的过程。`build ijkplayer for Android.`

编译准备
====
1. 安装homebrew：`ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`
2. 安装git：`brew install git`
3. 安装yasm：`brew install yasm`

下载ijkplayer项目：
`git clone https://github.com/Bilibili/ijkplayer.git`

替换支持格式编译脚本：
```
cd ijkplayer/config
rm module.sh # 这是一个软链接，默认指向module-lite.sh
ln -s module-default.sh module.sh
```

设置编译环境变量：
在终端执行以下命令（**具体请指向自己的路径**）
```
export ANDROID_NDK=/Users/michaelx/Library/Android/sdk/ndk-bundle
export ANDROID_SDK=/Users/michaelx/Library/Android/sdk
```
官方建议NDK版本为r10e，笔者为r13.1，MacOS 10.12.6 ，实测通过编译。

开始编译
====
cd进入项目根目录
```
bash init-android.sh
cd android/contrib
# 执行以下两条命令
./compile-ffmpeg.sh clean
# 如果默认shell不是bash，建议执行以下命令
bash compile-ffmpeg.sh clean

./compile-ffmpeg.sh all
# 如果默认shell不是bash，建议执行以下命令
bash compile-ffmpeg.sh all
```

执行过程中出现的以下类似提示可忽略：
```
WARNING: aarch64-linux-android-pkg-config not found, library detection may fail.

--------------------
[*] compile ffmpeg
--------------------
libavfilter/avfiltergraph.c: In function 'avfilter_graph_free':
libavfilter/avfiltergraph.c:132:5: warning: 'resample_lavr_opts' is deprecated (declared at libavfilter/avfilter.h:847) [-Wdeprecated-declarations]
     av_freep(&(*graph)->resample_lavr_opts);
     ^
```

出现以下提示时FFmpeg编译完了:
```
--------------------
[*] Finished
--------------------
# to continue to build ijkplayer, run script below,
sh compile-ijk.sh
```

那我们就可以编译ijkplayer拿到so动态库文件。按照提示执行:
```
bash compile-ijk.sh
# or
sh compile-ijk.sh
```

出现以下提示表示ijkplayer编译完毕:
```
[armeabi-v7a] Compile++ thumb: ijksoundtouch <= BPMDetect.cpp
[armeabi-v7a] Compile++ thumb: ijksoundtouch <= PeakFinder.cpp
[armeabi-v7a] Compile++ thumb: ijksoundtouch <= SoundTouch.cpp
[armeabi-v7a] Compile++ thumb: ijksoundtouch <= mmx_optimized.cpp
[armeabi-v7a] Compile++ thumb: ijksoundtouch <= ijksoundtouch_wrap.cpp
[armeabi-v7a] Install        : libijkffmpeg.so => libs/armeabi-v7a/libijkffmpeg.so
[armeabi-v7a] StaticLibrary  : libcpufeatures.a
[armeabi-v7a] StaticLibrary  : libijkj4a.a
[armeabi-v7a] StaticLibrary  : libandroid-ndk-profiler.a
[armeabi-v7a] StaticLibrary  : libijksoundtouch.a
[armeabi-v7a] StaticLibrary  : libyuv_static.a
[armeabi-v7a] SharedLibrary  : libijksdl.so
[armeabi-v7a] SharedLibrary  : libijkplayer.so
[armeabi-v7a] Install        : libijksdl.so => libs/armeabi-v7a/libijksdl.so
[armeabi-v7a] Install        : libijkplayer.so => libs/armeabi-v7a/libijkplayer.so
/Users/michealx/Documents/ijkplayer/android
```
进入`ijkplayer/android/ijkplayer/armeabi-v7a/` 就可以拿到编出来的ijkplayer so了，那么编出来的ijkplayer so怎么用到项目当中呢？接着看。

使用编译的ijkplayer so库
===============
ijkplayer的默认用法如下：
```
compile 'tv.danmaku.ijk.media:ijkplayer-java:0.8.3'
compile 'tv.danmaku.ijk.media:ijkplayer-armv7a:0.8.3'
```
第二个依赖没有任何代码，实际只是so库，既然要使用自己编译出来的so，那么第二个依赖可以去掉：
```
compile 'tv.danmaku.ijk.media:ijkplayer-java:0.8.3'
// compile 'tv.danmaku.ijk.media:ijkplayer-armv7a:0.8.3'
```
将自己编译出来的3个so文件放入项目的`main/jniLibs/armeabi-v7a/`下即可。播放代码无需做任何改变，现在ijkplayer就可以播放avi，mpeg/mpg多更多格式视频了。

至于ijkplayer更多玩法，笔者也还在探索，如果后续有空笔者会陆续更新。

传送门
===
基于ijkplayer 0.8.3编译的Android so库（比默认依赖支持更多格式）:
github:[compiled_ijkplayer4android][1](后续会根据ijkplayer版本持续更新)

致谢
==
[Bilibili/ijkplayer][2]


  [1]: https://github.com/xiong-it/compiled_ijkplayer4android
  [2]: https://github.com/Bilibili/ijkplayer