---
title: Ubuntu 14.04编译AOSP for Nexus/Pixel
date: 2017-03-14 11:29:09
tags: [Ubuntu, AOSP, Nexus, Pixel]
categories: Android
---
为你手中的Nexus,Pixel手机刷入自己的专属Rom
<!--more-->
前言
==
虽说几年前博主在一家公司做机顶盒的时候总是需要编译Android源码，但是那时还没有手中的爱机：Nexus 6，又名shamu。今天我要为它刷入一个自己编译的Rom。拿起键盘就是干。
> 笔者注：AOSP:Android Open Source Project，安卓开源项目


准备
==

 - Ubuntu 14.04+
 - OpenJDK/JDK
 - Nexus/Pixel手机一部

假设你已经有了一个较新的Ubuntu系统和一部谷歌亲儿子手机，下文将从安装jdk开始。

> 本文作者MichaelX，博客地址：http://blog.csdn.net/xiong_it ，转载请注明出处。


----------


AOSP编译环境搭建
==========

安装OpenJDK
--
> **警告**：不要使用oracle jdk来编译较新（API 21+/Android 5.0及以上）的AOSP，会在准备编译工作**make** **clobber**时出现错误提示.
    
    Checking build tools versions...
    *************************************************************
    You asked for an OpenJDK based build but your version is java version "1.8.0_121" Java(TM) SE Runtime Environment(build 1.8.0_121-b13)Java HotSpot (TM)64 bit Server VM(build 25.121-b13), mixed mode).
    *************************************************************
    build/core/main.mk:230: *** stop.
    

关于**JDK版本**的选择：**根据你想编译的Android版本来决定**

 - AOSP最新源码: OpenJDK 8
 - Android 5.x (Lollipop) - Android 6.0 (Marshmallow):OpenJDK 7
 - Android 2.3.x (Gingerbread) - Android 4.4.x(KitKat):Java JDK 6
 - Android 1.5 (Cupcake) - Android 2.2.x (Froyo): Java JDK 5

博主想要编译的是Android 7.0，所以需要使用是OpenJDK 8。

博主是用的Ubuntu 14.04 LTS，可采取安装deb包或者添加ppa两种方式安装OpenOJDK 8：
 1. OpenJDK deb包下载:[OpenJDK 8 on github](https://github.com/xiong-it/buildAOSP/tree/master/OpenJDK8)
 2. 添加ppa方式安装OpenJDK
```
$ sudo add-apt-repository ppa:openjdk-r/ppa
$ sudo apt-get update

$ sudo apt-get install openjdk-8-jdk

$ sudo update-alternatives --config java
$ sudo update-alternatives --config javac
```
假如你Ubuntu是15.04或者更新的系统，可直接运行下列命令进行OpenJDK 8安装

```
$ sudo apt-get update
$ sudo apt-get install openjdk-8-jdk
```

Linux使用下列命令查看机器中所有jdk版本
```
$ michaelx@michaelx-ThinkPad:~/AOSP_NBD91Z$ update-java-alternatives -l
// 打印出下面已安装的jdk版本
java-1.8.0-openjdk-amd64 1069 /usr/lib/jvm/java-1.8.0-openjdk-amd64
```

Linux设置默认JDK命令
```
// 设置默认为openjdk8，此处必须选用OpenJDK8
$ sudo update-java-alternatives -s java-1.8.0-openjdk-amd64
// 设置默认为oracle jdk8
$ sudo update-java-alternatives -s java-8-oracle
// 设置默认为oracle jdk7
$ sudo update-java-alternatives -s java-7-oracle
```
Ubuntu 14.04设置默认OpenJDK 8时出现一处警告提示：
    
    update-java-alternatives: plugin alternative does not exist: /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/IcedTeaPlugin.so
该提示无需理会，可直接忽略。

查看Java版本，出现以下提示，说明jdk环境已经ok。
```
$ java -version

openjdk version "1.8.0_111"
OpenJDK Runtime Environment (build 1.8.0_111-8u111-b14-3~14.04.1-b14)
OpenJDK 64-Bit Server VM (build 25.111-b14, mixed mode)
```
如果实在切换不了默认jdk，就像博主一样，卸了oracle jdk吧。

安装必要软件
------
在你的Ubuntu 14(x64)上执行以下命令
```
$ sudo apt-get install git-core gnupg flex bison gperf build-essential \
  zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
  lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache \
  libgl1-mesa-dev libxml2-utils xsltproc unzip
```
会有些已经安装，有些无法安装，或者安装失败，无需理会，继续往下。其他系统版本系统请直接参考：[Establishing a build environment][2]

配置USB访问权限
---------
ps：不知道这个干啥的，但是官方是这么建议的，为了让普通用户可访问usb设备。
```
$ wget -S -O - http://source.android.com/source/51-android.rules | sed "s/<username>/$USER/" | sudo tee >/dev/null /etc/udev/rules.d/51-android.rules; sudo udevadm control --reload-rules
```


----------


安装repo
======

安装repo以下载AOSP源码。repo是Google根据git开发来专门管理Android源码用的，具有断点续传的特性。其主要命令可参考：[git/repo常用命令一览][3]。依次执行下面命令。
```
$ cd ~
$ mkdir bin
$ PATH=~/bin:$PATH

$ curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
$ chmod a+x ~/bin/repo # 给repo添加执行权限
```


配置git
=====
由于需要下载Android源码，你需要事先准备好一个google的[gmail邮箱](https://www.google.com/gmail/)。执行以下命令配置git用户名和gmail邮箱。
```
$ git config --global user.name "Your Name"
$ git config --global user.email "you@gmail.com"
```

配置Google的git cookies访问权限，以便大量下载aosp源码站点资源。
[https://android.googlesource.com/new-password][4]
![configure git](http://img.blog.csdn.net/20170312103501761?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvWGlvbmdfSVQ=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
复制框中的命令,粘贴到终端,执行。


----------


下载AOSP源码
===========
**创建一个目录以存放Android源码**
```
$ mkdir ~/AOSP_NBD91Z # 目录名请自行定义，本文以AOSP_NBD91ZNBD91Z为例
$ cd AOSP_NBD91Z
```

根据手中的机器和以下两个连接进行**repo分支选择**：
https://source.android.com/source/build-numbers.html
https://developers.google.com/android/nexus/drivers

AOSP源码编译默认是不适配驱动的，只适合模拟器运行，由于博主想要为Nexus 6编译，所以需要考虑驱动问题，根据上文第二个链接找到shamu的最新驱动，目前（20170307）最新的驱动支持到build NBD91Z，将**驱动下载下来，留着备用**。
![这里写图片描述](http://img.blog.csdn.net/20170312115424282?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvWGlvbmdfSVQ=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
在第一个链接中找到对应的branch name（**android-7.0.0_r29**）。
![这里写图片描述](http://img.blog.csdn.net/20170312140527859?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvWGlvbmdfSVQ=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

**在AOSP本地目录初始化repo分支**
```
$ cd ~/AOSP_NBD91Z
$ repo init -u https://android.googlesource.com/platform/manifest -b android-7.0.0_r29
```

**下载/续传AOSP源码**
无论是第一次开始下载，还是中途断掉后接着续传下载，都是执行以下命令。
```
$ repo sync
```
之后就是漫长的等待了，该分支（android-7.0.0_r29）代码总共约80G（含版本管理文件.repo目录46G）。
这里提醒下各位，分区的时候一定记得至少至少至少给到120G啊，80G还不是最新分支的大小呢。编译后更加大得多：该分支编译出的out目录共30G左右。
![这里写图片描述](http://img.blog.csdn.net/20170312140830563?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvWGlvbmdfSVQ=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
不过下载完成后，如果没什么版本控制的需要 .repo目录倒是可以删除掉，节省点硬盘空间。


----------


编译AOSP预备工作
====
**设置编译缓存（可选操作）**
可加速后续第二次编译，如需要，可在源码目录执行以下命令
```
$ export USE_CCACHE=1
$ export CCACHE_DIR=~/AOSP_NBD91Z/.ccache # 目录自定义
$ prebuilts/misc/linux-x86/ccache/ccache -M 50G # 官方推荐50-100G
```
更新环境变量
```
$ vim ~/.bashrc
# 添加以下这行
export USE_CCACHE=1

$ source ~/.bashrc
```

**释放手机驱动**
将上述下载的几个驱动文件解压到`源码根目录`，解压后也就是几个脚本文件，依次执行，以释放驱动，画风大概如下
![释放shamu驱动](http://img.blog.csdn.net/20170312141135768?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvWGlvbmdfSVQ=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

![释放shamu驱动](http://img.blog.csdn.net/20170312213814287?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvWGlvbmdfSVQ=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

![释放shamu驱动](http://img.blog.csdn.net/20170312184550739?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvWGlvbmdfSVQ=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

共8大条款，几十个小条款，一行行回车按过去，心累啊。

> 划重点：在执行驱动脚本后，会让你看一大长串协议，最后你需要输入：**I ACCEPT** 来同意驱动的协议，方可释放驱动文件。按回车按快了则提示你没有同意，驱动未释放成功。成功之后会多出一个vendor目录。

**清理编译文件**
驱动释放完毕，先执行`make clobber`清理下编译后文件的目录，第一次编译其实博主觉得这个命令无所谓。
> 相似命令：`make clean` 它清理out/target/product/[product_name]目录。


----------


编译AOSP
========
**准备好编译平台**
```
$ cd AOSP_NBD91Z
$ source build/envsetup.sh
# or 或者，上面的命令和下面的命令等价
$ . build/envsetup.sh
```
**选择编译平台**
执行上述命令后方可执行这条命令`lunch`
![lunch](http://img.blog.csdn.net/20170312141046014?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvWGlvbmdfSVQ=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
由于笔者手中是Nexus 6（shamu），所以果断选择了21


**关于几种模式的区别**

 - user 正常模式，给普通用户用的
 - userdebug	具备root权限和更多调试功能，其他和user模式无异
 - eng	开发者的最佳选项，具有许多额外的调试工具

**正式编译AOSP源码**
运行`make`进行编译，也可以使用-j选项指定并行编译线程数量
```
# 利用6个线程进行编译。官方建议的最快并行线程数量为：j16-j32之间。
$ make -j6 

# 请各位根据自身CPU性能量力而行。博主曾经使用-j16导致GUI界面和终端统统卡死，只能强制关机，心疼我的ssd硬盘30s。
```

又是一次漫长的等待啊，如果不出什么问题，那么在`out/target/product/[product_name]/`目录下将会多出诸如system.img，recovery.img等等，就可以愉快的刷机了。
![build-aosp-successful](http://img.blog.csdn.net/20170312215601142?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvWGlvbmdfSVQ=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

下面是生成的各种镜像文件和其他。
![out-dir-files](http://img.blog.csdn.net/20170312215818926?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvWGlvbmdfSVQ=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)


----------


编译AOSP遇到的问题
=========
**权限遭拒**
由于博客使用了外部硬盘作为out编译输出，`make`时提示Permission is denied。这时换成`sudo make`即可。
> 使用外部磁盘做out输出：export OUT_DIR_COMMON_BASE=/media/username/外部磁盘路径/out

**内存不足**
由于笔者的内存只有4G，并且最开始没有分出swap分区，导致多次内存不足编译失败，有多种日志形式都表明内存不足：

第1种错误：
`[ 34% 12287/35393] Building with Jack: out/target/common/obj/JAVA_LIBRARIES/core-all_intermediates/with-local/classes.dex
FAILED: /bin/bash out/target/common/obj/JAVA_LIBRARIES/core-all_intermediates/with-local/classes.dex.rsp
Communication error with Jack server (52). Try 'jack-diagnose'
ninja: build stopped: subcommand failed.
make: *** [ninja_wrapper] Error 1`

第2种错误：
`[ 82% 30024/36285] Aligning zip: out/target/product/shamu/obj/SHARED_LIBRARIES/libdlext_test_runpath_zip_zipaligned_intermediates/libdlext_test_runpath_zip_zipaligned.zip
[ 82% 30025/36285] Import includes file: out/target/product/shamu/obj/STATIC_LIBRARIES/libverifier_intermediates/import_includes
[ 82% 30026/36285] target thumb C++: libverifier <= bootable/recovery/asn1_decoder.cpp
[ 82% 30027/36285] target thumb C++: libverifier <= bootable/recovery/verifier.cpp
[ 82% 30028/36285] Export includes file:  -- out/target/product/shamu/obj/STATIC_LIBRARIES/libverifier_intermediates/export_includes
[ 82% 30029/36285] target thumb C++: libverifier <= bootable/recovery/ui.cpp
ninja: fatal: fork: Cannot allocate memory
make: *** [ninja_wrapper] Error 1`

第3种错误：
`FAILED: /bin/bash out/target/common/obj/JAVA_LIBRARIES/core-all_intermediates/with-local/classes.dex.rsp
Out of memory error (version 1.2-rc4 'Carnac' (298900 f95d7bdecfceb327f9d201a1348397ed8a843843 by android-jack-team@google.com)).
GC overhead limit exceeded.
Try increasing heap size with java option '-Xmx<size>'.
Warning: This may have produced partial or corrupted output.
[ 31% 11494/36285] host C++: libartd-compiler <= art/compiler/optimizing/graph_visualizer.cc
[ 31% 11494/36285] Building with Jack: out/target/common/obj/JAVA_LIBRARIES/libprotobuf-java-nano_intermediates/classes.jack
[ 31% 11494/36285] build out/target/common/obj/JAVA_LIBRARIES/sdk_v21_intermediates/classes.jack
ninja: build stopped: subcommand failed.`

第4种错误：
`[  6% 2375/35393] target Java: icu4j (out/target/common/obj/JAVA_LIBRARIES/icu4j_intermediates/classes)
Note: Some input files use or override a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
Note: external/icu/icu4j/main/classes/core/src/com/ibm/icu/impl/Relation.java uses unchecked or unsafe operations.
Note: Recompile with -Xlint:unchecked for details.
[  6% 2394/35393] host C++: libLLVMMC_32 <= external/llvm/lib/MC/MCDwarf.cppninja: fatal: fork: Cannot allocate memory
make: *** [ninja_wrapper] Error 1`

第5种错误：
```
[  5% 1883/35393] Docs droiddoc: out/target/common/docs/api-stubs
FAILED: /bin/bash out/target/common/docs/api-stubs-timestamp.rsp
OpenJDK 64-Bit Server VM warning: INFO: os::commit_memory(0x00000000bdb80000, 72876032, 0) failed; error='Cannot allocate memory' (errno=12)
#
# There is insufficient memory for the Java Runtime Environment to continue.
# Native memory allocation (mmap) failed to map 72876032 bytes for committing reserved memory.
# An error report file with more information is saved as:
# /home/michaelx/AOSP_NBD91Z/hs_err_pid508.log
[  5% 1883/35393] Docs droiddoc: out/target/common/docs/system-api-stubs
DroidDoc took 27 sec. to write docs to out/target/common/docs/system-api-stubs
ninja: build stopped: subcommand failed.
make: *** [ninja_wrapper] Error 1
```

解决内存不足的3个办法：

 1. 增加机器内存
 2. 增加swap分区
 3. 修改prebuild/sdk/tools/jack-admin文件

第一种方式就不说了，给机器加根内存条，壕专享。
第二种方式：增加swap分区：[http://hancj.blog.51cto.com/89070/197915](http://hancj.blog.51cto.com/89070/197915)
第三种方式：
```
# 备份jack-admin
$ cp prebuild/sdk/tools/jack-admin ~/Docments/jack-admin.original

# 修改jack-admin文件
$ vim prebuild/sdk/tools/jack-admin

# start-server方法，笔者的jack-admin在443行，修改该方法中的一句话：
# JACK_SERVER_COMMAND="java -Djava.io.tmpdir=$TMPDIR $JACK_SERVER_VM_ARGUMENTS -cp $LAUNCHER_JAR $LAUNCHER_NAME"
# 改成下面这行,增加java堆大小。
JACK_SERVER_COMMAND="java -Djava.io.tmpdir=$TMPDIR $JACK_SERVER_VM_ARGUMENTS -Xmx8000M -cp $LAUNCHER_JAR $LAUNCHER_NAME"
```
> 以上增加的-Xmx8000M，表示允许java在运行时java堆使用最大不超过8000M内存，这个数值是笔者经历了多次测试得到的结果，2048M，4096M，依旧没通过编译，改成8000M后编译通过，可能跟笔者自身硬件限制有很大关系

	另一种修改方式：修改jack-admin第29行的变量：JACK_SERVER_VM_ARGUMENTS="${JACK_SERVER_VM_ARGUMENTS:=-Dfile.encoding-UTF-8 -XX:+TieredCompilation}"
	改成：
	JACK_SERVER_VM_ARGUMENTS="${JACK_SERVER_VM_ARGUMENTS:=-Dfile.encoding-UTF-8 -XX:+TieredCompilation -Xmx8000M}"
	但是这种修改方式仍然不好使，编译失败了。
笔者是尝试了第二，三种方式解决。

**jack-server无法运行**
错误日志如下：
`[ 37% 13421/35393] Ensure Jack server is installed and started
FAILED: /bin/bash -c "(prebuilts/sdk/tools/jack-admin install-server prebuilts/sdk/tools/jack-launcher.jar prebuilts/sdk/tools/jack-server-4.8.ALPHA.jar  2>&1 || (exit 0) ) && (JACK_SERVER_VM_ARGUMENTS=\"-Dfile.encoding=UTF-8 -XX:+TieredCompilation\" prebuilts/sdk/tools/jack-admin start-server 2>&1 || exit 0 ) && (prebuilts/sdk/tools/jack-admin update server prebuilts/sdk/tools/jack-server-4.8.ALPHA.jar 4.8.ALPHA 2>&1 || exit 0 ) && (prebuilts/sdk/tools/jack-admin update jack prebuilts/sdk/tools/jacks/jack-2.28.RELEASE.jar 2.28.RELEASE || exit 47; prebuilts/sdk/tools/jack-admin update jack prebuilts/sdk/tools/jacks/jack-3.36.CANDIDATE.jar 3.36.CANDIDATE || exit 47; prebuilts/sdk/tools/jack-admin update jack prebuilts/sdk/tools/jacks/jack-4.7.BETA.jar 4.7.BETA || exit 47 )"
Jack server already installed in "/home/michaelx/.jack-server"
Launching Jack server java -XX:MaxJavaStackTraceDepth=0 -Djava.io.tmpdir=/tmp -Dfile.encoding=UTF-8 -XX:+TieredCompilation -cp /home/michaelx/.jack-server/launcher.jar com.android.jack.launcher.ServerLauncher
Jack server failed to (re)start, try 'jack-diagnose' or see Jack server log
No Jack server running. Try 'jack-admin start-server'
No Jack server running. Try 'jack-admin start-server'
[ 37% 13421/35393] target thumb C++: libicui18n <= external/icu/icu4c/source/i18n/coptccal.cpp
[ 37% 13421/35393] target thumb C++: libicui18n <= external/icu/icu4c/source/i18n/compactdecimalformat.cpp
[ 37% 13421/35393] target thumb C++: libicui18n <= external/icu/icu4c/source/i18n/cpdtrans.cpp
ninja: build stopped: subcommand failed.`

解决Jack server failed to (re)start办法：

```
$ cd /prebuild/sdk/tools/

$ jack-admin stop-server
$ jack-admin start-server
```

和各路编译错误大战了7天7夜（真的是7天7夜呀，碰到的无数问题我都没写完呢），终于修成正果。

----------


总结
==
到了这里，相信大家都能轻松搞机了，如果有需要Nexus的刷机教程，请留言评论，下次出一篇Nexus的刷机过程。放2张Nexus 6刷机后的高清截图
![首屏截图](http://img.blog.csdn.net/20170313115421821?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvWGlvbmdfSVQ=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

![抽屉截图](http://img.blog.csdn.net/20170313115511697?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvWGlvbmdfSVQ=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
> 本文原创作者:[MichaelX](http://blog.csdn.net/xiong_it),博客地址:http://blog.csdn.net/xiong_it.转载请注明来源

欢迎光临：[MichaelX's Blog](https://xiong-it.github.io)

参考链接
====
感谢
AOSP官网：[https://source.android.com/source/initializing.html][5]
AskUbuntu：[http://askubuntu.com/questions/709904/ubuntu-openjdk-8-unable-to-locate-package][6]
CSDN:http://blog.csdn.net/brightming/article/details/49763515

etc....


  [1]: http://askubuntu.com/questions/599105/using-alternatives-with-java-7-and-java-8-on-14-04-2-lts
  [2]: https://source.android.com/source/initializing.html
  [3]: http://blog.csdn.net/xiong_it/article/details/45173987
  [4]: https://android.googlesource.com/new-password
  [5]: https://source.android.com/source/initializing.html
  [6]: http://askubuntu.com/questions/709904/ubuntu-openjdk-8-unable-to-locate-package