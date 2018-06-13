---
title: Design Patterns in Android：装饰模式
date: 2018-06-13 17:12:00
tags: [设计模式, Design Pattern, 装饰模式, Decorator, Android]
categories: Design Pattern
---
装饰模式是干嘛的呢？它在项目中有哪些用途呢？装饰模式在Android源码中有哪些应用呢？本文将和读者朋友一起分享探讨装饰者模式在Android中的应用和实践。
<!--more-->
前言
==
装饰模式是干嘛的呢？它在项目中有哪些用途呢？装饰模式在Android源码中有哪些应用呢？本文将和读者朋友一起分享探讨装饰者模式在Android中的应用和实践。

    本文原创作者MichaelX。 
    CSDN博客：https://blog.csdn.net/xiong_it 
    掘金主页：https://juejin.im/user/56efe6461ea493005565dafd 
    知乎专栏：https://zhuanlan.zhihu.com/c_144117654 
    个人博客：http://blog.michaelx.tech 

转载请注明出处。

装饰模式定义
======
> 装饰者模式：也叫wrapper模式。动态地给一个对象添加一些额外的职责，就增加功能来说，装饰者模式相比生成子类更加灵活，提供了有别于继承的另一种选择。

装饰模式的UML类图
==========
![这里写图片描述](http://oler3nq5z.bkt.clouddn.com/%E8%A3%85%E9%A5%B0%E8%80%85%E6%A8%A1%E5%BC%8Fuml.png-80style)
有四个角色需要说明：

 - Component抽象构件
Component是一个接口或者是抽象类，就是定义我们最核心的对象，也就是最原始的对象，如上面的成绩单。

**注意：**在装饰模式中，必然有一个最基本、最核心、最原始的接口或抽象类充当Component抽象构件。

 - ConcreteComponent 具体构件
ConcreteComponent是最核心、最原始、最基本的接口或抽象类的实现，你要装饰的就是它。

 - Decorator装饰角色
一般是一个抽象类，做什么用呢？实现接口或者抽象方法，它里面可不一定有抽象的方法呀，在它的属性里必然有一个private变量指向Component抽象构件。

 - 具体装饰角色
ConcreteDecoratorA和ConcreteDecoratorB是两个具体的装饰类，你要把你最核心的、最原始的、最基本的东西装饰成其他东西。

装饰模式示例代码
========
```java
public abstract class Component {
     //抽象的方法
     public abstract void operate();
}
```
```java
public class ConcreteComponent extends Component {
     //具体实现
     @Override
     public void operate() {
             System.out.println("do Something");
     }
}
```
```java
public abstract class Decorator extends Component {
     private Component component = null;        
     //通过构造函数传递被修饰者
     public Decorator(Component _component){
             this.component = _component;
     }
     //委托给被修饰者执行
     @Override
     public void operate() {
             this.component.operate();
     }
}
```
```java
public class ConcreteDecorator1 extends Decorator {
     //定义被修饰者
     public ConcreteDecorator1(Component _component){
             super(_component);
     }
     //定义自己的修饰方法
     private void method1(){
             System.out.println("method1 修饰");
     }
     //重写父类的Operation方法
     public void operate(){
             this.method1();
             super.operate();
     }
}
```
```java
public class ConcreteDecorator2 extends Decorator {
     //定义被修饰者
     public ConcreteDecorator2(Component _component){
             super(_component);
     }
     //定义自己的修饰方法
     private void method2(){
             System.out.println("method2修饰");
     }
     //重写父类的Operation方法
     public void operate(){
             super.operate();
             this.method2();
     }
}
```
使用场景类
```java
public class Client {
     public static void main(String[] args) {
             Component component = new ConcreteComponent();
             //第一次修饰
             component = new ConcreteDecorator1(component);
             //第二次修饰
             component = new ConcreteDecorator2(component);
             //修饰后运行
             component.operate();
     }
}
```

Android源码中的装饰模式
==============

案例一
---

Context是Android中一个几乎无处不在的角色，ContextWrapper/ContextThemeWrapper就在继承过程中承担了ContextImpl的装饰者角色。
![这里写图片描述](http://oler3nq5z.bkt.clouddn.com/Context%E8%A3%85%E9%A5%B0%E8%80%85%E6%A8%A1%E5%BC%8Fuml%E7%B1%BB%E5%9B%BE.png-80style)
ContextThemeWrapper部分代码为例：
```java
public class ContextThemeWrapper extends ContextWrapper {
    private int mThemeResource;
    private Resources.Theme mTheme;
    private LayoutInflater mInflater;
    private Configuration mOverrideConfiguration;
    private Resources mResources;

    @Override
    public AssetManager getAssets() {
        // Ensure we're returning assets with the correct configuration.
        return getResourcesInternal().getAssets();
    }

    @Override
    public Resources getResources() {
        return getResourcesInternal();
    }

    private Resources getResourcesInternal() {
        if (mResources == null) {
            if (mOverrideConfiguration == null) {
                mResources = super.getResources();
            } else {
                final Context resContext = createConfigurationContext(mOverrideConfiguration);
                mResources = resContext.getResources();
            }
        }
        return mResources;
    }

    @Override
    public Resources.Theme getTheme() {
        if (mTheme != null) {
            return mTheme;
        }

        mThemeResource = Resources.selectDefaultTheme(mThemeResource,
                getApplicationInfo().targetSdkVersion);
        initializeTheme();

        return mTheme;
    }

    @Override
    public Object getSystemService(String name) {
        if (LAYOUT_INFLATER_SERVICE.equals(name)) {
            if (mInflater == null) {
                mInflater = LayoutInflater.from(getBaseContext()).cloneInContext(this);
            }
            return mInflater;
        }
        return getBaseContext().getSystemService(name);
    }

    protected void onApplyThemeResource(Resources.Theme theme, int resId, boolean first) {
        theme.applyStyle(resId, true);
    }

    private void initializeTheme() {
        final boolean first = mTheme == null;
        if (first) {
            mTheme = getResources().newTheme();
            final Resources.Theme theme = getBaseContext().getTheme();
            if (theme != null) {
                mTheme.setTo(theme);
            }
        }
        onApplyThemeResource(mTheme, mThemeResource, first);
    }
}
```

案例二
---

还有一个比较典型的例子是RecyclerView通过RecyclerView.ItemDecorator来扩展样式。
不过这个是一个变种的装饰者，这个实践比较另类的地方在于：我们通常是在装饰者的的执行方法中扩展被代理对象的行为，而RecyclerView+ItemDecorator的实践则恰恰相反，ItemDecorator反倒成了被代理对象，RecyclerView成了装饰者。

Android开发中的装饰模式实践
=================
说实话，笔者自己也没有实践过装饰模式，但是有一个场景需求应该是可以应用装饰模式的。比如一个直播场景，点击礼物时需要礼物飞出来，双击有一个爱心❤️飘出来，那么礼物和爱心就可以看成是直播画面的装饰者，类关系如下：
![这里写图片描述](http://oler3nq5z.bkt.clouddn.com/%E7%9B%B4%E6%92%AD%E8%A3%85%E9%A5%B0%E8%80%85uml.jpg-80style)
GirlView：主播画面
GirlDecorator：主播画面装饰者
GiftView：礼物效果
LoveView：爱心效果

总结
==
**特点：**装饰模式其实就是在代理某个对象过程中，给特定的代理行为前后加上不同的装饰行为，比如文中的`ContextThemeWrapper`就在代理`ContextImpl`的`getSystemService`这个行为过程中，加上了返回LayoutInflater这个装饰行为。因此，我们也可以认为**装饰模式其实是一种特殊的代理模式**

装饰模式的优缺点
优点：

 - 装饰类和被装饰类可以独立发展，而不会相互耦合。换句话说，Component类无须知道Decorator类，Decorator类是从外部来扩展Component类的功能，而Decorator也不用知道具体的构件。

 - 装饰模式是继承关系的一个替代方案。我们看装饰类Decorator，不管装饰多少层，返回的对象还是Component，实现的还是is-a的关系。
 - 装饰模式可以动态地扩展一个实现类的功能，这不需要多说，装饰模式的定义就是如此。

缺点：

 - 装饰太多层时会增加系统复杂度，有时出现问题可能无法快速定位。

当某个对象的行为需要加强，并且可能有多种加强的需求时，那么装饰模式有可能就能排上用场了。

好了，今天的《设计模式Android篇：装饰模式》就到这里，请继续关注[《Design Patterns in Android》（设计模式Android篇）](http://blog.csdn.net/xiong_it/article/details/54574020)系列博文，欢迎各位读者朋友评论区拍砖交流，共同进步。
