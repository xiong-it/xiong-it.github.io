---
title: Android开发：使用AutoInputAuthCode快速实现自动填写验证码
date: 2017-05-09 17:36:18
tags: [AutoInputAuthCode, 验证码]
categories: 开源
---
使用AutoInputAuthCode快速实现自动填写验证码
<!--more-->
前言
==
该类库的实现原理:[《Android开发:实现APP自动填写注册验证码功能》][1]。感兴趣的可以看下。  

项目地址：[https://github.com/xiong-it/AutoInputAuthCode][2]

> 本文原创作者:[MichaelX](http://blog.csdn.net/xiong_it),博客地址:http://blog.csdn.net/xiong_it.转载请注明来源


----------


AutoInputAuthCode使用介绍
=================
在Android Studio打开你的app module中的build.gradle,添加依赖：
```gradle
dependencies {
   ...
   compile 'tech.michaelx.authcode:authcode:1.0.0' // 添加依赖
   ...
}
```
如果无法下载上述依赖，可以打开你的项目根目录下的build.gradle，添加maven仓库地址
```gradle
allprojects {
    repositories {
        jcenter()
        maven { url 'https://dl.bintray.com/xiong-it/AndroidRepo'} // 添加这行
    }
}
```

示范代码
====

AutoInputAuthCode是一个帮助Android开发者快速实现自动填写验证码的类库，客户端示例代码如下：
```java
CodeConfig config = new CodeConfig.Builder()
                        .codeLength(4) // 设置验证码长度
                        .smsFromStart(133) // 设置验证码发送号码前几位数字
                        //.smsFrom(1690123456789) // 如果验证码发送号码固定，则可以设置验证码发送完整号码
                        .smsBodyStartWith("百度科技") // 设置验证码短信开头文字
                        .smsBodyContains("验证码") // 设置验证码短信内容包含文字
                        .build();
                        
AuthCode.getInstance().with(context).config(config).into(EditText);
```
1. 通过单例获取一个AuthCode对象;
2. 提供一个上下文对象给AuthCode，放心，我会妥善处理你的上下文;
3. 提供一个你的验证码特征描述;
4. 告诉AuthCode你想将验证码写入哪个EditText.
  
搞定，收工！  

效果图
===
![](http://oler3nq5z.bkt.clouddn.com/authcode2.gif)


注意事项
====
自动填写验证码需要读取短信权限，请在清单中添加权限：
```xml
<uses-permission android:name="android.permission.READ_SMS"/>
<uses-permission android:name="android.permission.READ_SMS"/>
```
  
由于读取短信在API 23（Android 6.0）上权限级别是**dangerous**。所以还需要动态申请权限，但是申请权限需要依赖于Activity或者Fragment中的onRequestPermissionsResult()回调，所以需要开发者自己实现。  

可参考[AutoInputAuthCode][2]中sample的代码。

该库实现原理请参考：[《Android开发:实现APP自动填写注册验证码功能》][1]

总结
==
该库实际上被完成有一段时间了，一直在试着上传jcenter，有空把上传代码到jcenter总结下发出来，虽然上传jcenter在网上教程挺多的，但是很多都不够细节，容易误解，我就是被坑的一个。  
  
祝大家撸码愉快！  
项目地址：[https://github.com/xiong-it/AutoInputAuthCode][2]

  [1]: http://blog.csdn.net/xiong_it/article/details/50997084
  [2]: https://github.com/xiong-it/AutoInputAuthCode