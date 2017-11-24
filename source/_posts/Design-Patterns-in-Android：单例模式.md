---
title: Design Patterns in Android：单例模式
date: 2017-01-17 16:11:02
tags: [设计模式, Design Pattern, 单例模式, Singleton, Android]
categories: Design Pattern
---
这是[《Design Patterns in Android》](http://blog.csdn.net/Xiong_IT/article/details/54574020)系列第一篇博文，那就从本开始和笔者一起领略Android开发中设计模式的魅力吧。
本系列《设计模式Android篇》博文将循序渐进的向读者讲解设计模式在Android开发的实践应用
<!--more-->
前言
==
这是[《Design Patterns in Android》](http://blog.csdn.net/Xiong_IT/article/details/54574020)系列第一篇博文，那就从本开始和笔者一起领略Android开发中设计模式的魅力吧。
本系列《设计模式Android篇》博文将遵循以下模式，循序渐进的向读者讲解设计模式在Android开发的实践应用：

 1. 给出设计模式的定义和使用场景
 2. 给出设计模式的UML类图
 3. 给出该设计模式的简单Java代码
 4. 给出该设计模式在Android源码中的应用分析
 5. 给出该设计模式在Android应用开发中的实践
    
    本文原创作者xiong_it，博客链接：[http://blog.csdn.net/xiong_it](http://blog.csdn.net/xiong_it)，转载请注明出处。

单例模式定义
==
> 单例模式(Singleton pattern):确保一个类只有一个实例，并提供对该实例的全局访问。

根据其定义，它的使用场景：当你需要创建一个对象，但是创建这个对象时需要消耗大量的系统资源，或者这个对象迫于某种原因只能在内存中存在一个实例的时候，单例模式也许是个不错的创建方案。

单例模式UML类图
==
![这里写图片描述](http://img.blog.csdn.net/20170116175312086?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvWGlvbmdfSVQ=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
Singleton类作为单例类，它耦合了自身成员变量，并对外提供了一个公开方法getInstance()对instance对象的全局访问。

单例模式代码示例
==
众所周知，单例模式有多个变种，但是最常见的还是“饿汉式”及“懒汉式”2种。本处示例代码以线程安全的饿汉式举例。

```java
public class Singleton {
	private static Singleton sInstance = new Singleton();
	
	private Singleton() {
		super();
	}

	public static Singleton getInstance() {
		if(sInstance == null) {
			sInstance = new Singleton();
		}
		return sInstance;
	}
}
```
单例模式注意事项主要有3点：

 - 如果处于多线程环境，注意保持线程安全，不然就无法保证单例了
 - 单例模式的默认构造方法的修饰符需改为private，只能类内部访问，确保外部不能直接new出该实例
 - 单例模式需要提供一个全局访问入口，这个入口通常以getInstance()的public静态方法形式呈现

Android源码中的单例模式
==
InputMethodManager是用来管理输入法和软键盘状态的关键类，它就是源码中一个单例模式应用的典型案例。

```
public final classs InputMethodManager {

	/*...
	省略代码，保留关键代码
	...*/
	static InputMethodManager sInstance;
	
	InputMethodManager(IInputMethodManager service, Looper looper) {
        mService = service;
        mMainLooper = looper;
        mH = new H(looper);
        mIInputContext = new ControlledInputConnectionWrapper(looper,
                mDummyInputConnection, this);
    }

	/**
     * Retrieve the global InputMethodManager instance, creating it if it
     * doesn't already exist.
     * @hide
     */
    public static InputMethodManager getInstance() {
        synchronized (InputMethodManager.class) {
            if (sInstance == null) {
                IBinder b = ServiceManager.getService(Context.INPUT_METHOD_SERVICE);
                IInputMethodManager service = IInputMethodManager.Stub.asInterface(b);
                sInstance = new InputMethodManager(service, Looper.getMainLooper());
            }
            return sInstance;
        }
    }
}
```
从代码中，我们可以看到，InputMethodManager中有一个非公开的静态成员变量sInstance,它的构造方法也是非公开的，但是它对外（framwork层）提供了一个public的静态方法getInstance(Context)来对外提供单例对象，当该对象不存在时，就通过进程间通讯创建一个对象。
我们试想一下，假如它不是单例的话，在不同的应用中大家都可以自由创建该对象，该对象又极容易造成内存泄漏，创建N个InputMethodManager实例的话，你的Android手机该卡成什么鬼样子？？
> 延伸阅读:[《Android InputMethodManager 导致的内存泄露及解决方案》](https://zhuanlan.zhihu.com/p/20828861)

所以说，InputMethodManager做成单例是一个明智的选择，实际上，除了InputMethodManager，直接操作系统资源的许多??Manager都是采用了单例模式来创建，比如AccessibilityManager，InputManager，LayoutInflater，BulutoothManager等。
不过他们的单例模式实现多种多样，其中LayoutInflater及许多其他Manager是采用集合缓存的形式的实现，第一次getSystemService(String)获取LayouInflater对象时，系统会通过ServiceFetcher创建一个对象并缓存到系统服务列表中，第二次获取时，直接从列表中得到该对象，并不再二次创建，确保单例。

Android开发中的单例实践
==
大家用过Universal-Image-Loader吗？没用过也没关系，使用[UIL](https://github.com/nostra13/Android-Universal-Image-Loader)加载一张图片非常简单：

```java
ImageLoader.getInstance().displayImage(imageUrl, imageView);
```
很眼熟，对不对？其实，这里ImageLoader对象的创建就是采用了单例模式的实现。
假如它不是单例实现呢？每次用都初始化一次吗？每次都创建一个新的对象吗？显然这是很浪费资源的一件事，所以ImageLoader是采用了单例模式来创建一个对象，以后用的时候还是复用那个对象，保证了UIL API的易用性，同时也兼顾了系统资源的合理利用。
ImageLoader的单例实现代码是
```
public class ImageLoader {
	/*
	...
	省略代码，保留关键代码
	...
	*/
	private volatile static ImageLoader instance;

	protected ImageLoader() {
	}

	/** Returns singleton class instance */
	public static ImageLoader getInstance() {
		if (instance == null) {
			synchronized (ImageLoader.class) {
				if (instance == null) {
					instance = new ImageLoader();
				}
			}
		}
		return instance;
	}
}
```
    volatile关键字修饰的变量，一次只能有一个线程操作该变量，保证线程安全。

总结
==
当你的某个类多次创建很耗资源，或者你的某个类对象你只希望它存在一个实例对象在内存中时，请考虑单例模式。

好了，今天的《设计模式Android篇：单例模式》就到这里，请继续关注[《Design Patterns in Android》](http://blog.csdn.net/xiong_it/article/details/54574020)（设计模式Android篇）系列博文，欢迎各位读者朋友评论区拍砖交流，共同进步。
