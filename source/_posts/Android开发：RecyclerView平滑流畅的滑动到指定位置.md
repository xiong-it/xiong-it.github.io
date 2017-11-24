---
title: Android开发：RecyclerView平滑流畅的滑动到指定位置
date: 2017-10-17 20:11:00
tags: [Android, RecyclerView]
categories: Android
---
RecyclerView.smoothScrollToPosition(int);滑动过程很突兀，很快就滑动到了指定位置，并没有像函数名那样smooth，本文将分享如何使得RecyclerView平滑流畅的滑动到指定位置。
<!--more-->
背景
==
在项目中，想使RecyclerView慢慢的平缓滑动指定位置，于是使用：
```
RecyclerView.smoothScrollToPosition(int);
```
发现效果并不理想，滑动过程很突兀，很快就滑动到了指定位置，并没有像函数名那样smooth（流畅的，平滑的），也就是说smoothScrollToPosition没有滑动效果，黑人问号？？？
    
    本文原创作者MichaelX，博客链接：http://blog.csdn.net/xiong_it，转载请注明出处。

探索历程
==
既然函数名是流畅平缓的滑动到指定位置，为什么并不理想呢？查看源码如下：
```
 public void smoothScrollToPosition(int position) {
        // ···省略无关代码，mLayout是该RecyclerView的LayoutManager对象
        mLayout.smoothScrollToPosition(this, mState, position);
    }
```
所以实际上是调用`RecyclerView.LayoutManager.smoothScrollToPosition()`方法，这是个抽象方法。由于笔者项目中是`LinearLayoutManager`于是找到其具体实现如下：
```
 @Override
        public void smoothScrollToPosition(RecyclerView recyclerView,
                                           RecyclerView.State state, final int position) {

            LinearSmoothScroller smoothScroller = new LinearSmoothScroller(context);

            smoothScroller.setTargetPosition(position);
            startSmoothScroll(smoothScroller);
        }
```
生成一个`RecyclerView.SmoothScroller`的子类`LinearSmoothScroller`对象smoothScroller，接着利用smoothScroller去完成剩下的滑动工作。

于是进去LinearSmoothScroller看看。**重大发现**---里面有一个跟滑动速度相关的函数：
```
    /**
     * Calculates the scroll speed.
     * 计算滑动速度
     * 返回：滑过1px所需的时间消耗。
     */
    protected float calculateSpeedPerPixel(DisplayMetrics displayMetrics) {
        // MILLISECONDS_PER_INCH是常量，等于20f
        return MILLISECONDS_PER_INCH / displayMetrics.densityDpi;
    }
```
既然`RecyclerView.smoothScrollToPosition(int);`很快，是不是延长其滑动时间就可以呢？

解决smoothScrollToPosition无效
==========================
为了验证上节延长滑动时间的想法，自定义一个LinearLayoutManager:
```
public class SmoothScrollLayoutManager extends LinearLayoutManager {

        public SmoothScrollLayoutManager(Context context) {
            super(context);
        }

        @Override
        public void smoothScrollToPosition(RecyclerView recyclerView,
                                           RecyclerView.State state, final int position) {

            LinearSmoothScroller smoothScroller =
                    new LinearSmoothScroller(recyclerView.getContext()) {
                        // 返回：滑过1px时经历的时间(ms)。
                        @Override
                        protected float calculateSpeedPerPixel(DisplayMetrics displayMetrics) {
                            return 150f / displayMetrics.densityDpi;
                        }
                    };

            smoothScroller.setTargetPosition(position);
            startSmoothScroll(smoothScroller);
        }
    }
```

Binggo！成功！调用`RecyclerView.smoothScrollToPosition(int);`发现滑动速度变慢很多，不再突兀，不再突然滑过去，没有任何过渡，而是缓慢滑过去，终于名副其实的**smooth**。

    
    本文原创作者MichaelX，博客链接：http://blog.csdn.net/xiong_it，转载请注明出处。
结语
==

通过自定义LinearLayoutManager，重写smoothScrollToPosition()方法中`LinearSmoothScroller`对象的`calculateSpeedPerPixel(DisplayMetrics)`方法,可以使`RecyclerView.smoothScrollToPosition(int);`平滑的流畅的滑动到指定位置。其他LayoutManager暂时没用到，需要读者自己尝试。

如果读者朋友们有其他的办法，欢迎留言交流。