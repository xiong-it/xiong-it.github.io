---
title: 'Android笔记：Bitmap.Config与内存占用的关系'
date: 2017-12-4 17:12:18
tags: [Bitmap.Config, Android]
categories: Android
---
Bitmap内存占用与Config关系笔记
<!--more-->
关于内存占用
==
Q:请问Bitmap的内存占用如何计算？
A:int momery = higthPixel \* widthPixel \* config因子;

什么是config因子？接着看。

Config因子
========
```
enum Bitmap.Config {
    ALPHA_8,
    RGB_565,
    RGB_444, // 3.0及以上已废弃，使用RGB_8888代替
    ARGB_8888
}
```

 - ALPHA_8（**基本不用**）:每个像素使用一个独立的alpha通道存储，该通道占用8bit，即：每个像素占用`1byte = 8bit / 8`内存，如果bitmap使用这种config编码，以上config因子为1；
 - RGB_565:只编码RGB通道信息，没有透明alpha通道信息，Red红色通道信息占用5位内存，Green绿色通道信息占用6位内存，Blue蓝色通道信息占用5位内存。每个像素占用`2 byte= (5bit + 6bit + 5bit) / 8` 内存，支持2^16 = 65535种颜色。每个像素占用2byte内存，质量较好，此时config因子为2；
 - ARGB_8888:每个通道（Alpha+RGB）都各占用8位内存，支持2^32 = 1600w种颜色，质量最好，每个像素占用`4 byte = 8bit * 4 / 8`内存，此时config因子为4。

RGB_565比ARGB_8888节省内存相信很多同学都知道，但是为什么RGB_565更节省内存？Bitmap每个像素的内存占用是怎么来的？
希望本文能解决一些同学的疑惑。因为RGB_565牺牲了alpha通道，不支持透明度，并且RGB每个通道信息较ARGB_888更少。

> 本文作者MichaelX，个人博客：http://blog.michaelx.tech 本文遵从[CC协议](http://creativecommons.org/licenses/by-nc-sa/4.0/)，转载请注明出处。

结论
==
当加载一张1080 * 1920px的图片时，使用以上config加载的内存占用情况分别为：

 - ALPHA_8（**基本不用**）:1080 * 1920 byte = 2025Kb = 2Mb
 - RGB_565:1080 \* 1920 \* 2 byte = 4050Kb = 4Mb
 - ARGB_8888:1080 \* 1920 \* 4 byte = 8100Kb = 8Mb

可以酌情选择合适的config进行加载，但是最好全局只使用一个config，否则易导致个别图片信息丢失或者加载错误。