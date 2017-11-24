---
title: 设计模式系列：OOP设计6大原则
date: 2017-01-13 10:39:20
tags: [设计模式, Design Pattern, 6大原则, OOP]
categories: Design Pattern
description: 相信有过开发经验的人都有过这种体验：让你接手一个的项目，2种情况。A.这个项目已经被好几个人，甚至好几代程序员开发维护过；B.这个项目等待你的全新开发。不给你设时间期限,你更愿意选择哪一个？我相信99.9%的人都会选择B这种开发模式。有木有？？Why？因为不想改一个bug引起n个bug。说到底，就是因为已有的项目架构没有做好，或者没有适时的做架构调整，假如你接手的是旧代码，可能为了添加一个功能，因为架构不具备扩展性，你也许只能在原有的基础上修改几行代码，甚至修改几百上千行代码来达到目的，以此来埋下诸多隐患待下一个接盘侠搞定。那么就引出了今天的话题？什么样的代码才具备可扩展性呢？
---
前言
--
相信有过开发经验的人都有过这种体验：让你接手一个的项目，2种情况。A.这个项目已经被好几个人，甚至好几代程序员开发维护过；B.这个项目等待你的全新开发。不给你设时间期限，你更愿意选择哪一个？我相信99.9%的人都会选择B这种开发模式。有木有？？
Why？因为不想改一个bug引起n个bug。说到底，就是因为已有的项目架构没有做好，或者没有适时的做架构调整，假如你接手的是旧代码，可能为了添加一个功能，因为架构不具备扩展性，你也许只能在原有的基础上修改几行代码，甚至修改几百上千行代码来达到目的，以此来埋下诸多隐患待下一个接盘侠搞定。那么就引出了今天的话题？什么样的代码才具备可扩展性呢？

    本文作者xiong_it，博客链接：http://blog.csdn.net/xiong_it。转载请注明出处。

Open Close Principle
----------
> OCP原则（开闭原则）：一个软件实体如类、模块和函数应该对扩展开放，对修改关闭。

wtf???太抽象了！！！在笔者的理解中，OCP是6大原则的最高纲领，所以才如此抽象，晦涩难懂。用面向对象的语言来讲，OCP是一个最抽象的接口，而其余的5大原则只是OCP的子类接口，他们一起定义了OOP世界的开发标准，常用的23中设计模式更是只能算作这6大原则的实现抽象类，咱们开发的代码实践才是真正的具体子类。
```
public interface OCP {
	void openExtention();
	void closeModifiability();
}
```
Q:What is OCP？
A:OCP是啥咧？它告诉我们，咱们编写的代码应该面向扩展开放，而尽量不要通过修改现有代码来拥抱需求变更。这里，代码可以指的是一个功能模块，类，或者方法。
Q:Why do we need to follow this principle？
A:我们为什么要遵循OCP原则呢？地球人都知道代码后期需求变更的痛苦，如果不利用扩展来适应变更，那迎来的将是代码被修改的千疮百孔。
Q:How do we practice this principle？
A:我们如何实践这条原则？能用抽象类的别用具体类，能用接口的别用抽象类。总之一句：尽量面向接口编程。这里之所以说“尽量”是因为凡事都有度，别让你来个hello world你还给整个接口再实现。

**talk is cheap，show your the code.**
     
     需求：老王开车去东北。
    
简单，开撸。

老王来了，大家藏好自己媳妇儿。
```
public class Laowang {
	private Car car;
	private DongBei dongbei;

	...
	getter() & setter()
	...

	public void drive() {
		car.goto(dongbei);
	}
}
```
要车就给你一辆咯

```
public class Car {
	public void goto(DongBei dongbei) {
		System.out.println(“要去东北咯，啦啦啦”);
		// 模拟开车旅途消耗时间。10s就到东北了，开的可够快的啊！司机之前是开飞机的吗？
		Thread.getCurrentThread().sleep(10 * 1000);
		System.out.println(“目的地东北到了”);
	}
}
```
东北到了

```
public class DongBei {
	private String address = "东北那旮沓儿";
}
```
老司机要发车了，赶紧打卡上车。滴，学生卡，咳咳咳，拿错卡了。

```
public static void main(String[] args) {
	Car car = new Car();
	Laowang wang = new Laowang();
	wang.setCar(car);
	DongBei dongbei = new DongBei();
	wang.setDongbei(dongbei);
	wang.drive();
}
```
Perfect，完美！
现在需求变了，老王实现了2017年定下的小目标，挣了1个亿，买了架私人飞机，他不想开车去东北了，太low，他要开飞机去东北。
    
    需求2：老王开飞机去东北
简单，给老王加个属性，加几个方法就实现了嘛？代码就不撸了。
OK，又是一次完美变化！？
需求又变了，老张和老王是穿一条裤裆长大的发小，老张看老王这都开上飞机了，他的车是不是可以借来开一开？

    需求3：老张开车去东北
这，这，这，简单，重新撸一遍老王在需求1的代码就行了，不就改个名的事吗？
来来来，需求又变了，老张有急事去东北，老王就把飞机也借给老张用了。
    
    需求4：老张开飞机去东北
这，这，这，这，这，这，简单，把老王在需求2的代码重撸一遍就是了。
来来来，需求又变了，老王这回不去东北了，他想开飞机去广东那儿去探望下老丈人，顺便兜兜风。
	
	需求5：老王开飞机去广东
	需求6：老张开车去广东
	需求7：老王要开飞机去美国
	需求8：小王要开车去西藏
	需求...
这，这，这，这这这，R&D小哥一口老血喷在屏幕上，卒，享年25岁。

在这里，笔者建议，将人物，交通工具，目的地抽象化，接口化，就可以适应需求的频繁变更了。

上类图
![OCP demo类图](http://img.blog.csdn.net/20170111203335703?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvWGlvbmdfSVQ=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
客户端代码作如下调整：
```
public static void main(String[] args) {
	// 想用地上开的交通工具出行，好，那就new个车给你开
	ITransportation car = new Car();
	// 这次是老王要出门
	Person wang = new Laowang();
	// 老王选择开车出行
	wang.setTransportation(car);
	// 老王目的地是东北
	AbsDestination dongbei = new DongBei();
	dongbei.setAddressName("东北");
	wang.setDestination(dongbei);
	// 老司机开着车就出发了
	wang.startOff();
}
```
老王的代码如下
```
public class Laowang extends Person{
	...
	public void startOff() {
		this.transportation.transport();
		System.out.println("出发咯");
		//thread.sleep();
		System.out.println("目的地" + this.destination.getAddressName() +"到了.");
	}
}
```
运行结果是：
	
	出发咯
	目的地东北到了.
现在，假如要做如上一些需求变更，在需求的变更过程中，客户端的代码变化是不是小多了呢？
>  注意：开闭原则对扩展开放，对修改关闭，并不意味着不做任何修改，低层次模块的变化，必然要有高层模块进行耦合，否则就是一个孤立无意义的代码片段。
在业务规则改变的情况下高层模块必须有部分改变以适应新业务，改变要尽量地少，放置变化风险的扩散
---秦小波《设计模式之禅》


Single Responsibility Principle
------------------------------------
>  SRP原则（职责单一原则）:应该有且只有一个原因引起类的变更。
```
public interface SRP extends OCP {
	void onlyDoOneThing();
}
```
通俗点来讲，一个类，一个方法只应该做一件事情。
举2个栗子：
1.当一个类A有R1，R2两个职责时，当R1的职责发生变更时，你需要修改类A，当R2发生变更时，你又需要修改类A，这时，已经有2个原因可能会引起类的变化了，类A就已经职责不单一了，就需要职责拆分，比如拆分成类A1，A2：A1类负责R1职责，A2类负责R2职责了。
2.再比如有一个方法M，它即负责计算和打印两个职责
```
public void M(int a, int b) {
	int c = 0;
	c = a + b;
	
    System.out.println("打印的是 = " + c); 
}
```
有一天，你想要修改下计算规则，改为
```
c=a+b+1;
```
此时，你修改了方法M。
又一天，你想修改下打印规则，改为
```
System.out.println("打印的是 = " + （c+1）); 
```
你又修改了方法M，此时，超过了2个原因让你去修改它，所以这个方法应该拆分为待返回值得计算calc方法和打印print两个方法。
似的每个方法都只做一件事情。

那它是如何体现扩展性的呢？
拿一个Android中最常见的ImageLoader的设计来举例子，ImageLoader主要需要实现2个功能，下载图片，缓存图片。
假如，我们把所有的功能全部放在一个ImageLoader类中，假设下载要改方式呢？缓存要改策略呢？你通通要改ImageLoader，你如何保证修改某个功能的过程中另一个功能依旧完好，没被污染？拆分职责，使用ImageCache接口及其子类实现进行缓存，和ImageLoader建立关联，职责单一了，你再在每个单一的职责类里面去修改相关代码，这样其他功能代码被污染的概率大大降低。

当然，这里只是随意举的例子，划分单一职责这个度很难把握，每个人都需要根据自身情况和项目情况来进行判断。

Liskov Substitution Principle
----------------------------------

> OCP原则(里氏替换原则)：所有引用基类的地方必须能透明地使用其子类的对象
```
public interface LSP extends OCP {
	void liskovSubstitutionPrinciple();
}
```
通俗点讲：只要父类能出现的地方子类就可以出现，而且替换为子类也不产生任何异常错误，反之则不然。这主要体现在，我们经常使用抽象类/基类做为方法参数，具体使用哪个子类作为参数传入进去，由调用者决定。

这条原则包含以下几个方面：

 - 子类必须完全实现父类的方法
 - 子类可以有自己的个性外观（属性）和行为（方法）
 - 覆盖或者实现父类方法时，参数可以被放大。即父类的某个方法参数为HashMap时，子类参数可以是HashMap，也可以是Map或者更大
 - 覆盖或者实现父类的方法时，返回结果可以被缩小。即父类的某个方法返回类型是Map，子类可以是Map，也可以是HashMap或者更小。

Dependence Inversion Principle
-----------------------------------
> DIP原则（依赖倒置原则）：高层模块不要依赖低层模块，所以依赖都应该是抽象的，抽象不应该依赖于具体细节而，具体细节应该依赖于抽象

底层模块：不可分割的原子逻辑就是低层模块
高层模块：低层模块的组装合成后就是高层模块

抽象：Java中体现为基类，抽象类，接口，而不单指抽象类
细节：体现为子类，实现类

通俗点讲，该原则包含以下几点要素：

 - 模块间的依赖应该通过抽象发生，具体实现类之间不应该建立依赖关系
 - 接口或者抽象类不依赖于实现类，否则就失去了抽象的意义
 - 实现类依赖于接口或者抽象类

总结起来，一句话：”**面向接口编程**“。

Interface-Segregation Principle
-------------------------------------
> ISP原则（接口隔离原则）:客户端不应该依赖它不需要的接口；类间的依赖应该建立在最小的接口上

通俗点讲：使用接口时应该建立单一接口，不要建立臃肿庞大的接口，尽量给调用者提供专门的接口，而非多功能接口。

这里我想举个例子就是Android中的事件处理Listener设计，大家都知道，我们想给button添加点击事件时，可以使用如下代码

```
button.setOnClickListener(clickListener);
```
想给它添加长按事件时，可以使用如下代码

```
button.setOnLongClickListener(longClickListener);
```
还有其他比如OnTouchListener等等等事件接口，它为什么不直接提供一个通用的接口IListener呢？然后回调所有的事件给调用者处理，而要提供这么多独立的接口，这就是遵循了ISP原则的结果，每个接口最小化了，Activity/button作为调用者，我可以选择性的去处理我想处理的事件，不关心的事件Listener我就不去处理，依赖。

Low of Demeter
-------------------
> LoD法则（迪米特法则）：又称最少知识原则（Least Knowledge Principle， LKP），一个对象应该对其他对象有最少的了解。

通俗点讲：一个类应该对自己需要耦合或者调用的类知道越少越好，被耦合或者调用的类内部和我没有关系，我不需要的东西你就别public了吧。

迪米特法则包含以下几点要素：

 - 只和朋友类交流：只耦合该耦合的类
 - 朋友间也是有距离的：减少不该public的方法，向外提供一个简洁的访问
 - 自家的方法就自己创建：只要该方法不会增加内部的负担，也不会增加类间耦合

感谢和参考
--
秦小波：《设计模式之禅》
Mr.simple：《Android 源码设计模式解析与实战》
java-my-life:http://www.cnblogs.com/java-my-life/
...
...
后话
--
规则只是规则，大家不应该死守规则，应该持辩证的态度去看待这6大原则，才能更好地达到实践应用的目的。
感谢以上作者和博客的规范化引导以及诸多博主的博客才渐渐让我懂得实践设计模式与应用架构。笔者将会未来陆续更新《设计模式系列》in Android博客，后续博客中，均参考了以上书籍和博客。欢迎各位朋友评论区点赞拍砖交流。
