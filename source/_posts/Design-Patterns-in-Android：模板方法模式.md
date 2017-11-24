---
title: Design Patterns in Android：模板方法模式
date: 2017-02-11 01:16:27
tags: [设计模式, Design Pattern, 模板方法模式, Template Method, Android]
categories: Design Pattern
---
今天给大家分享的是《设计模式Android篇：模板方法模式》。  
其实有一定开发经验的小伙伴已经不自觉的使用了模板方法了，今天将通过Android源码和Android开发案例跟大家讲解什么是模板方法模式。
<!--more-->
前言
==

今天给大家分享的是《设计模式Android篇：模板方法模式》。 
其实有一定开发经验的小伙伴已经不自觉的使用了模板方法了，今天将通过Android源码和Android开发案例跟大家讲解什么是模板方法模式。
点击此处查看[《Design Patterns in Android》][1]系列其他文章。
    
    本文原创作者MichaelX（xiong_it），博客链接：http://blog.csdn.net/xiong_it，转载请注明出处。

模板方式模式定义
========
> 模板方法模式(Template method pattern):定义一个操作中的算法框架，而将一些步骤延迟到子类中实现，使得子类可以不改变算法结构即可重新定义该算法的某些特定步骤

以上定义有两个关键词

 1. 算法框架：其本质是一个方法，也就是模板方法，它的调用会依次执行一些特定的步骤
 2. 特定步骤：其本质一系列抽象的方法，交由子类实现，以重新定义该算法细节

模板方法的UML类图
==========
![模板方法的UML类图](http://img.blog.csdn.net/20170209003325599?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvWGlvbmdfSVQ=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

templateMethod：模板方法
methodA,methodB：特定步骤

模板方法示例代码
========

基类
```
public abstract class AbstractClass {

	public void templateMethod() {
		methodA();

		methodB();
	}

	protected void abstract methodA();

	protected void abstract methodB();
}

```
子类
```

public class ConcreteClassA extends AbstractClass {


	@Override
	protected void abstract methodA() {
		System.out.println("ConcreteClassA.do something.");
	}

	@Override
	protected void abstract methodB() {
		System.out.println("ConcreteClassA.do other thing.");
	}
}


public class ConcreteClassB extends AbstractClass {


	@Override
	protected void abstract methodA() {
		System.out.println("ConcreteClassB.do something.");
	}

	@Override
	protected void abstract methodB() {
		System.out.println("ConcreteClassB.do other thing.");
	}
}
```
 
 

Android源码中模板方法模式
================
在Android的api源码中，给我们提供了一个执行异步任务的类AsyncTask，其用法d大致如下

 1. 写一个自己的异步任务类（比如叫DownloadTask）继承自AsyncTask，主要复写onPreExecute(),doInBackground(),onPostExecute()等。
 2. 执行downloadTask
 
代码如下

```
new DownloadTask().execute(url);
```
我们发现只要调用了execute（Params...）后，AsyncTask自动调用了各个回调方法了，onPreExecute(),doInBackground(),onPostExecute()等，其实这就是**模板方法模式**！下面我们通过一个android开发案例来弄懂模板方法。

Android开发中的模板方式模式实践
=================
Activity作为四大组件之首，是我们经常要使用到的，除非你的app不用和用户进行UI交互。
那在多个Activity中，我们通常在onCreate()做一些程序化的事情

 - 初始化控件
 - 获取网络/数据库数据
 - 注册事件监听
 - 注册广播
 - 等等

在onDestroy()中

 - 反注册广播
 - 资源释放等

这时我们通常可以使用模板方法模式来抽象出一个BaseActityBaseFragment类似，不展开分析。实例代码如下

先写一个基类BaseActity
```
public abstract class BaseActivity extends Activity {
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		initView();

		initData();

		initEvent();

		registerBroadcast();
	}

	/**
     * 初始化视图控件
     */
	protected abstract void initView();

	/**
     * 初始化数据
     */
	protected abstract void initData();

	/**
     * 初始化点击长按等事件
     */
	protected abstract void initEvent();

	/**
     * 注册广播接收者
     */
	protected void registerBroadcast() {
		// 子类可以选择性复写
	}

	@Override
	public void onDestroy() {
		super.onDestroy();

		unRegisterBroadcast();

		releaseMemory();
	}
	/**
     * 注销广播接收者
     */
	protected void unRegisterBroadcast() {
		// 子类可以选择性复写
	}

	/**
     * 做些释放对象引用等其他操作以释放内存
     */
	protected abstract void releaseMemory();
}
```

随手写一个实现类MyActivity

```
public class MyActivity extends BaseActivity {

	@Override
	protected void initView() {
		setContentView(resId);
		// TODO findViewById();
	}

	@Override
	protected void initData() {
		// TODO 访问数据库/网络获取数据
	}

	@Override
	protected void initEvent() {
		// TODO setOnClickListener
	}

	@Override
	protected void releaseMemory() {
		// TODO 把一些手动释放的对象值设为null
		someObj = null;// and so on.
	}
}
```

如果再有一个其他Activity代码也是如此编写，以BaseActivity的onCreate(),onDestroy()为模板方法（算法框架），initView(),initData(),initEvent()等方法为特定步骤，利用模板方法构建了一个较好的基类，子类无需修改BaseActivity的算法框架，不同的Activity只需复写这些特定步骤即重新定义这些特定的细节步骤。

总结
==
看完这篇《Design Patterns in Android：策略模式》，是不是很多人恍然大悟，原来模板方法就是这样啊！
当编写一个方法时，其中包含了某些特定的步骤时，就可以考虑使用模板方法模式了。

好了，今天的《设计模式Android篇：策略模式》就到这里，请继续关注[《Design Patterns in Android》（设计模式Android篇）][2]系列博文，欢迎各位读者朋友评论区拍砖交流，共同进步。



  [1]: http://blog.csdn.net/xiong_it/article/details/54574020
  [2]: http://blog.csdn.net/xiong_it/article/details/54574020