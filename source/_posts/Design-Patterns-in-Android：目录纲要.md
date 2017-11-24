---
title: Design Patterns in Android：目录纲要
date: 2017-01-17 15:14:34
tags: [设计模式, Design Pattern, Android]
categories: Design Pattern
---
前言
==
继[《设计模式系列：OOP设计6大原则》](http://blog.csdn.net/xiong_it/article/details/53467684)之后，博主自此将“间歇性”更新《Design Patterns in Android》（设计模式Android篇），旨在总结自己作为一名Android开发者，在摸索设计模式的过程中爬过的坑，因为很多设计模式的博文，书籍都是针对Java场景的，为了帮助一些Android开发者更贴切的理解和应用设计模式，博文将描述在Android源码中存在的设计模式，以及Android项目如何实践设计模式，将笔者在Android项目实践这些设计模式的心得体会，所得所想以文字的形式展现在读者朋友的眼前，也希望能够和广大的读者有更多的交流，促使自身进步。
> 间歇性：
1、笔者对于23种设计模式也不是全部了解,并没有全部实践过，只能根据自己一些经验来描述一些实践过或者接触过的模式
2、笔者中途也会更新其他博文，与读者分享

	本文作者xiong_it，博客链接：http://blog.csdn.net/xiong_it。转载请注明出处。

什么是设计模式
==
在分享设计模式in Android之前，我们先来看下“设计模式”的定义
> 在软件工程中，设计模式（design pattern）是对软件设计中普遍存在（反复出现）的各种问题，所提出的解决方案。-[维基百科《设计模式 (计算机)》](https://zh.wikipedia.org/wiki/%E8%AE%BE%E8%AE%A1%E6%A8%A1%E5%BC%8F_%28%E8%AE%A1%E7%AE%97%E6%9C%BA%29)

设计模式这个术语是由埃里希·伽玛（Erich Gamma）等人在1990年代从建筑设计领域引入到计算机科学的。并在1994年，埃里希·伽玛（Erich Gamma）, Richard Helm, Ralph Johnson，John Vlissides“四人帮”（Gang of Four，GoF）著成《设计模式：可复用面向对象软件的基础》为人所熟知并开始广泛流传。

也就是说，设计模式是一种软件编写过程中，解决编程问题的一种可复用的，有规矩可遵循的方案。

快速了解常用23中设计模式，[《设计模式教你追MM》](http://blog.csdn.net/xiong_it/article/details/43445799)

23种设计模式分类
==
根据设计模式的使用场景，大概可分为3类：

创建型
--
处理如何创建实例、对象。

 - [单例模式(Singleton pattern)](http://blog.csdn.net/xiong_it/article/details/54575474)
 - 原型模式(Prototype pattern)
 - 建造者/构造器模式(Builder Pattern)
 - 工厂方法模式(Factory Method pattern)
 - 抽象工厂模式(Abstact Factory)

结构型
--
处理类及对象的复合关系。

 - 适配器模式(Adapter pattern)
 - 桥接模式(Bridge pattern)
 - 组合模式(Composite pattern)
 - 装饰模式(Decorator pattern)
 - 享元模式(Flyweight pattern)
 - 代理模式(Proxy pattern)

行为型
--
 处理类/对象之间的转换，通讯。

 - [策略模式(Strategy pattern)](http://blog.csdn.net/xiong_it/article/details/54574746)
 - [模板方法模式(Template method pattern)](http://blog.csdn.net/xiong_it/article/details/54575479)
 - 职责链模式(Chain-of-responsibility pattern)
 - 命令模式(Command pattern)
 - 解释器模式(Interpreter pattern)
 - 迭代器模式(Iterator pattern)
 - 仲裁器/中介者模式(Mediator pattern)
 - 备忘录模式(Memento pattern)
 - 观察者(模式Observer pattern)
 - 状态模式(State pattern)
 - 参观者/访问者模式(Visitor)
	
结语
==
如上，23种设计模式，各有各的使用场景，应用适当，可以使得代码扩展性大大提高，有利于后期需求变更和功能扩展及代码维护，带有链接的模式表示笔者已有介绍该模式在Android开发中的相关博文。

参考
==
维基百科：[《设计模式（计算机）》](https://zh.wikipedia.org/wiki/%E8%AE%BE%E8%AE%A1%E6%A8%A1%E5%BC%8F_%28%E8%AE%A1%E7%AE%97%E6%9C%BA%29)，[《设计模式：可复用面向对象软件的基础》](https://zh.wikipedia.org/wiki/%E8%AE%BE%E8%AE%A1%E6%A8%A1%E5%BC%8F%EF%BC%9A%E5%8F%AF%E5%A4%8D%E7%94%A8%E9%9D%A2%E5%90%91%E5%AF%B9%E8%B1%A1%E8%BD%AF%E4%BB%B6%E7%9A%84%E5%9F%BA%E7%A1%80)
