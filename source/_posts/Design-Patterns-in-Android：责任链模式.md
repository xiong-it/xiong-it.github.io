---
title: Design Patterns in Android：责任链模式
date: 2018-05-14 17:55:55
tags: [设计模式, Design Pattern, 责任链模式, Chain-of-responsibility, Android]
categories: Design Pattern
---
今天给大家分享的是《设计模式Android篇:责任链模式》。  
今天将通过Android源码和Android开发案例跟大家讲解什么是责任链模式。
<!--more-->
## 前言
非常抱歉，本系列博客长达半年没更新了，今日偶得灵感，更新一波《设计模式Android篇:责任链模式》。点击此处查看[《Design Patterns in Android》][1]系列其他文章。

> 本文原创作者MichaelX。
CSDN博客：http://blog.csdn.net/xiong_it
掘金主页：https://juejin.im/user/56efe6461ea493005565dafd
知乎专栏：https://zhuanlan.zhihu.com/c_144117654
个人博客：http://blog.michaelx.tech
转载请注明出处。

## 模板方式模式定义
> 职责链(Chain-of-responsibility pattern):它是一种对象的行为模式。在责任链模式里，很多对象由每一个对象对其下家的引用而连接起来形成一条链。请求在这个链上传递，直到链上的某一个对象决定处理此请求。发出这个请求的客户端并不知道链上的哪一个对象最终处理这个请求，这使得系统可以在不影响客户端的情况下动态地重新组织和分配责任。

## 模板方法的UML类图
![责任链模式类图][2]
**责任链模式各角色分工：**

 - Client:发出请求的高层代码。
 - Handler:定义一个处理请求的接口。一般会定义一个处理请求的抽象方法（handleRequest()），以及一个set方法(setSuccessor)来指定下后续处理者。
 - ConcreteHandler:具体的请求处理者，收到请求后可以自己处理，也可以将请求传递给后续处理者。

## 责任链示例代码
这里举个栗子：**老王**在中介所要买个**二手房**，他提出价格过高，希望得到更多的优惠，比如88折，中介经纪人小明收到请求。以下是处理流程。

Client发起购房请求
```java
public class Client {
	public static void main(String[] args) {
		HouseBuyer laowang = new HouseBuyer("老王");
		laowang.buyHouse("88折卖不卖？");
	}
}

public class HouseBuyer {
	public void buyHouse(int accountOff) {
		AbsAgency xiaoming = new Staff("底层员工小明");
		xiaoming.handle(accountOff);
	}
}
```
抽象处理者Handler
```java
public abstract class AbsAgency {
	protected AbsAgency mAgency;

	public void setNextHandler(AbsAgency agency) {
		this.mAgency = agency;
	}

	// 处理折扣
	public abstract void handle(int accountOff);

	public AbsAgency geNextHandler() {
		return mAgency;
	}
}
```
具体处理者：处理购房请求
```java
public class Staff extends AbsAgency {

	public abstract void handle(int accountOff) {
		// 如果折扣低于80折，不出售；
		// 如果90折以上，一线员工自行处理;
		// 低于90折，需要汇报经理处理
		if (accountOff <= 80) {
			System.out.println("价格太低，要吃土咯。。。");
		} else if (accountOff > 90 && accountOff <= 100) {
			System.out.println("价格合适，卖给你了。");
		} else {
			setNextHandler(new Manager("上级经理"));
			getNextHandler().handle(accountOff);
		}
	}
}

public class Manager extends AbsAgency {

	public abstract void handle(int accountOff) {
		// 如果折扣低于80折，不出售；
		// 根据人品决定是否接受购房请求
		if (accountOff <= 80) {
			System.out.println("价格太低，要吃土咯。。。");
		} else {
			System.out.println("老王人品还行，成交。");
		}
	}
```
最终老王的购房请求在经理这个级别得到了处理，但是老王才不关心谁解决的，只要能低价买到这个房子就行了。

## Android源码中责任链模式
责任链模式思想在Android源码中的体现莫过于：触摸事件的处理和分发了。每当用户接触屏幕时，Android都会将其打包成一个MotionEvent对象从ViewTree自顶而下的分发处理。
代码过多，这里只用一张图表示其思路：
![此处输入图片的描述][3]
其方向为：`Activity--->ViewGroup--->View`
具体源码可参考郭神的[《Android事件分发机制完全解析，带你从源码的角度彻底理解(上)》][4]，阅读源码，我们可以发现dispatchTouchEvent有点类似上面责任链实例代码中的handle()方法，自己能处理就处理，处理不了就向下一级分发处理。

## Android开发中的责任链模式实践
举个例子，我们的图片需要设计三级缓存，那么它是怎么取缓存的呢？
```java
AbsCacheManager bmpCache = new MemoryCache();
Bitmap bmp = bmpCache.getCache(cacheKey);
```
先定义一个缓存抽象类
```
public abstract class AbsCacheManager {
	protected AbsCacheManager mCache;
    // 获取Bitmap
	public abstract Bitmap getCache(String cacheKey); 

	public void setNextHandler(AbsCacheManager manager) {
		mCache = manager;
	}

	public AbsCacheManager getNextHandler() {
		return mCache;
	}
}

```
下面是具体实施者：内存缓存，磁盘缓存，网络获取
```java
public class MemoryCache extends AbsCacheManager {

	public Bitmap getCache(String cacheKey) {
		Bitmap bmp = getCacheFromMemory(cacheKey);
		// 如果内存缓存为空，则将请求传递给下一位：磁盘缓存来处理
		if (bmp == null) {
			setNextHandler(new DiskCache());
			bmp = getNextHandler().getCache(cacheKey);
		}
		return bmp;
	}

}

public class DiskCache extends AbsCacheManager {

	public Bitmap getCache(String cacheKey) {
		Bitmap bmp = getCacheFromDisk(cacheKey);
				// 如果磁盘缓存为空，则将请求传递给下一位：网络图片下载来处理
		if (bmp == null) {
			setNextHandler(new NetworkFetchManager());
			bmp = getNextHandler().getCache(cacheKey);
		}
		return bmp;
	}
}

public class NetworkFetchManager extends AbsCacheManager {
	public Bitmap getCache(String cacheKey) {
		Bitmap bmp = getCacheFromNetWork(cacheKey);
		return bmp;
	}
}
```
一条责任链跃然纸上：内存—>磁盘->网络。

当然，以上没有考虑线程切换问题，实际操作是需要考虑耗时操作在子线程执行的。

## 总结
其实责任链模式就是在某种场景下：有一个请求需要处理，但是最终处理者又不确定的时候采用的一种模式。
但是其处理者对于客户端是透明的，无需知道谁将处理这个请求，只需要抛出请求，拿到结果即可。


  [1]: http://blog.csdn.net/xiong_it/article/details/54574020
  [2]: http://oler3nq5z.bkt.clouddn.com/%E8%B4%A3%E4%BB%BB%E9%93%BE%E6%A8%A1%E5%BC%8F.png-80style
  [3]: http://oler3nq5z.bkt.clouddn.com/%E4%BA%8B%E4%BB%B6%E5%88%86%E5%8F%91%E5%B1%82%E7%BA%A7.png
  [4]: https://blog.csdn.net/guolin_blog/article/details/9097463