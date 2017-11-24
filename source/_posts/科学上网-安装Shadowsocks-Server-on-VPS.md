---
title: '科学上网:安装Shadowsocks Server on VPS'
date: 2017-05-03 16:46:37
tags: [科学上网, Shadowsocks]
categories: 科学上网
---
作为一名开发者，科学上网是一个很强的诉求，至今被|墙的google，偶尔抽风的github，当然你要想着看小片，全球最大的xx网站也在墙外
<!--more-->
前言
==
作为一名开发者，科学上网是一个很强的诉求，至今被|墙的google，偶尔抽风的github，当然你要想着看小片，全球最大的xx网站也在墙外。科学上网的方法大致如下几种：
1. 修改本机hosts，可访问的网站有限
2. vpn：容易被封
3. shadowsocks-俗称：影梭
4. etc...

简单介绍
====
其中修改hosts的方法成本最低，也最简单，网上找到需要访问网站的ip，写进本机hosts文件中即可。这样访问被|墙网站时，机器先访问hosts文件，发现已经有ip了，就不会访问dns服务器去要求解析域名了，而是直接根据指定ip去访问被|墙网站。  

vpn的方式由于其容易被探测的缘故，容易被封。  

根据socks5代理方式实现的shadowsocks项目，由于其隐蔽性存活至今。其需要一外国的服务器上装shadowsocks服务端实现流量中转，然后本地机器装shadowsocks客户端进行科学上网。当然网上也有很多的shadowsocks账号购买，服务器它给你搭好了，然后就售卖账号，但是也存在些骗子收完钱跑路的，拿着账号上不了网，当然也存在奸商超售账号的情况，许多人买完账号挤在一个服务器上爬蜗牛。那么为什么不自己搭一个shadowsocks服务端呢？更何况年付的价钱不比你购买账号贵！服务器还在自己手里，不怕隐私泄露。

什么是vps
======
笔者理解也不深，感觉就是虚拟主机的升级版，可拥有独立ip，但又不是独立服务器，是一台服务器上利用虚拟化技术独立出来的单独机器，购买这台vps后，你自己就可以对这台机器做任意操作：重装系统（Linux，Windows），装任意软件，拥有root权限，可远程操控都不在话下。总之和一台远程服务器差不多。但是价格却远低于服务器价格。搬瓦工VPS的介绍翻译如下：
>  隶属于美国IT7公司旗下的一款低价OpenVZ VPS主机方案、2017年新增KVM VPS架构，尤其是6款便宜年付VPS，无论从性价比还是稳定性都非常适合大众VPS用户需求，我们可以用来建站、搭建上网环境

官网：[性价比高*搬瓦工vps][1]

笔者购买的是最便宜的年付19刀（人民币130左右）的512M内存，10G ssd硬盘，100G宽带方案，难能可贵的是搬瓦工vps：可使用**支付宝**支付，据说是2016年推出的新功能，之前只能使用PayPal支付。


----------


购买搬瓦工VPS
========
1. 打开搬瓦工官网：[性价比高*搬瓦工vps][2]
2. 点击要购买的的套餐下方的 订购按钮“order Now”，
![][3]
3. 进入如下图示界面，选择付账周期Billing Cycle（月付，季付，半年付，年付），和
节点Location（洛杉矶，佛罗里达等），洛杉矶的节点还行，比较稳定。最后点击Add to Cart加入购物车，之后下一个界面点击check out结账。
![][4]
4. 注册账号
有几点：
 - 资料是否完全真实无所谓，姓名可以随意填
 - 邮箱必须自己的，以免以后找回密码需要
 - 国家、地区、省份必须真实
 - 街道等详细地址你随意填写，电话也可以随意。不能用V=P=N软件更换IP购买，用真实的IP购买就可以。
 - Pay Method中选择Alipay即支付宝，勾选下方的协议
 - 点击Complete Order结账
 - 手机支付宝扫二维码，完事
![][5]

搬瓦工VPS安装shadowsocks服务端
======================
 1. 点击图中的Client Area，登陆账号
![][6]
 2. 查看服务
 ![][7]
 3. 点击右边的KiviVM Control Panel进入vps控制面板
 ![][8]
 4. 安装shadowsocks Server
 ![此处输入图片的描述][9]

ss客户端使用
=======
[ss客户端下载][10]
[ss客户端使用][11]

参考博客
====
https://b.lhuac.com/2/


  [1]: https://bandwagonhost.com/aff.php?aff=14794
  [2]: https://bandwagonhost.com/aff.php?aff=14794
  [3]: http://oler3nq5z.bkt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202017-04-27%20%E4%B8%8B%E5%8D%888.06.23.png
  [4]: http://oler3nq5z.bkt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202017-04-27%20%E4%B8%8B%E5%8D%888.07.44.png
  [5]: http://oler3nq5z.bkt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202017-04-27%20%E4%B8%8B%E5%8D%888.20.39.png
  [6]: http://oler3nq5z.bkt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202017-04-27%20%E4%B8%8B%E5%8D%888.23.57.png
  [7]:http://oler3nq5z.bkt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202017-04-27%20%E4%B8%8B%E5%8D%888.25.16.png
  [8]: http://oler3nq5z.bkt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202017-04-27%20%E4%B8%8B%E5%8D%888.27.36.png
  [9]: http://oler3nq5z.bkt.clouddn.com/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202017-04-27%20%E4%B8%8B%E5%8D%888.29.14.png
  [10]: https://github.com/shadowsocks
  [11]: https://github.com/shadowsocks/shadowsocks-windows/wiki/Shadowsocks-Windows-%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E