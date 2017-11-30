---
title: 'Hexo遇上Travis-CI：可能是最通俗易懂的自动发布博客图文教程'
date: 2017-11-30 14:10:18
tags: [Hexo, travis]
categories: hexo
---
今天笔者就来介绍下利用[travis-ci][2]这个持续集成平台简化发布流程.
<!--more-->
相信很多同学都有自己的博客，如果没有，可以参看[《Hexo建站：部署到github》][1]，利用Hexo和github pages服务搭建一个美观便捷的博客，Hexo可以将你编写的md文档解析渲染成html网页，最后通过git推送到github即可形成一个网站。

Hexo发布博客流程
==========

 1. 搭建hexo环境（一系列软件安装，配置）
 2. hexo new post “文章名称”
 3. 编写md文档
 4. hexo clean
 5. hexo generate
 6. hexo deploy

以上第一步一般只在第一次搭建的时候需要进行，后续只要执行2~6步即可。但是存在一些情况，假如你需要在不同的电脑上发布博客呢？假如你重装了系统呢？是不是需要重新来一次？要知道最繁琐的步骤就是第一步，这里面可以分出很多步来做，看过上面那篇博客或者自己正在使用`hexo+gh`手动发布博客的同学都知道多痛苦。

今天笔者就来介绍下利用[travis-ci][2]这个持续集成平台简化发布流程，简化后流程:

 1. 编写md文档
 2. git push

利用travis大大提高了效率！是不是很诱人？

Travis-CI简介
===========

Travis CI 是开源持续集成构建项目，用来构建托管在GitHub上的代码。它提供了多种编程语言的支持，包括JavaScript，Java，Scala，Ruby，PHP，Haskell和Erlang在内的多种语言。

当我们每次进行`git push`等动作时，Travis CI 会自动检测我们的提交，然后根据配置文件`.travis.yml`帮我们自动生成、部署静态网页。

事先预备
====

推送hexo博客源码到github
-----------------

 1. cd进入自己的本地hexo博客文件夹，就是你要发布博客时进入的那个文件夹。
 2. 将自己本地所有hexo博客源码文件push到github。
推送教程：[《如何提交代码到Github》][3]

> 注意：不是`hexo deploy`更新博客repo！而是直接把本地博客托管到github。

笔者直接把本地hexo博客源码托管到了[xiong-it.github.io][4]的**hexo**分支，博客网站则在默认的**master**分支上。不想采取分支管理的话，你也可以把本地hexo博客托管到独立仓库，但是在配置travis同步时会有所不同。本文采取分支管理方式。

配置github token
--------------

那既然需要使用travis自动化更新你的博客，travis自然需要读写你的github上的repo。github提供了token机制来供外部访问你的仓库。

进入[https://github.com/settings/tokens][5]，生成一个供travis读写你的github用的token，至于token的权限，笔者直接全选了，但是不建议这样做，风险比较大，token注意保密，待会会用到。
![此处输入图片的描述][6]

配置Travis-CI
===========

使用github账号登陆[travis][7]，如果没有github账号的同学，可以参考[《如何提交代码到Github》][8]注册一个自己的github账号。

在travis进入仓库同步管理
---------------

进入[https://travis-ci.org/profile][9]，**打开刚才托管的hexo博客源码仓库同步开关，不一定是博客网站repo**。由于笔者直接把本地hexo博客源码托管到了[xiong-it.github.io][10]的**hexo**分支，所以也就是打开网站repo。如果你不是采取的分支管理，而是将hexo博客源码托管道独立repo，打开对应的github repo开关即可。
如图：
![此处输入图片的描述][11]

travis设置
--------

点击上图中红色圆圈，进入设置页，设置自动化编译时机，自动化编译过程中需要用到的变量。
 ![此处输入图片的描述][12]

 ![此处输入图片的描述][13]

以上设置的含义是：

 - 只在.travis.yml文件存在时编译，必选！
 - 当仓库/分支发生更新时编译，也就是push后进行编译的意思，一般会需要选择，方便自动化构建。
 - 加了GH_TOEKN等变量，value值为刚才预备工作中准备的token字符串

编写.travis.yml文件
---------------

`.travis.yml`是[travis][2]平台进行自动化构建的配置文件，travis会根据配置文件生成一个shell自动化脚本。

进入hexo博客源码本地repo
```
cd hexo
touch .travis.yml
vim .travis.yml
```
.travis.yml示例如下：
```yml
# 指定语言环境
language: node_js
# 指定需要sudo权限
sudo: required
# 指定node_js版本
node_js: 
  - 7.9.0
# 指定缓存模块，可选。缓存可加快编译速度。
cache:
  directories:
    - node_modules
    
# 指定博客源码分支，因人而异。hexo博客源码托管在独立repo则不用设置此项
branches:
  only:
    - hexo 

before_install:
  - npm install -g hexo-cli

# Start: Build Lifecycle
install:
  - npm install
  - npm install hexo-deployer-git --save
  
# 执行清缓存，生成网页操作
script:
  - hexo clean
  - hexo generate
  
# 设置git提交名，邮箱；替换真实token到_config.yml文件，最后depoy部署
after_script:
  - git config user.name "yourName"
  - git config user.email "yourEmail"
  # 替换同目录下的_config.yml文件中gh_token字符串为travis后台刚才配置的变量，注意此处sed命令用了双引号。单引号无效！
  - sed -i "s/gh_token/${GH_TOKEN}/g" ./_config.yml
  - hexo deploy
# End: Build LifeCycle
```
修改下_config.yml文件的deploy节点：
```yml
# 修改前
deploy:
  - type: git
    repo: git@github.com:xiong-it/xiong-it.github.io.git
    branch: master
```
```yml
# 修改后
deploy:
- type: git
  # 下方的gh_token会被.travis.yml中sed命令替换
  repo: https://gh_token@github.com/xiong-it/xiong-it.github.io.git
  branch: master
```
[yml示例传送门][14]

最后将两个yml文件push更新到hexo博客源码branch或者独立repo，就会在[travis后台][15]成功看到第一次构建了。

> 欢迎访问我的个人hexo博客：[http://xiong-it.github.io][4]

大功告成
====

以后每次更新博客，只需要编写md文件，放入hexo/source/_post/文件夹下，`git add，commit，push`后，push操作也可以直接使用刚才申请的token，而无需在不同电脑上配置ssh共密钥。
```
git push https://<your_token>@github.com/xiong-it/xiong-it.github.io.git hexo:hexo
```
travis就会读取hexo博客源码分支下的`.travis.yml`文件，自动帮我们生成并部署网站了。

  [1]: http://blog.csdn.net/xiong_it/article/details/55193816
  [2]: https://travis-ci.org/
  [3]: http://blog.csdn.net/xiong_it/article/details/68944728
  [4]: http://xiong-it.github.io
  [5]: https://github.com/settings/tokens
  [6]: http://oler3nq5z.bkt.clouddn.com/github_token.png
  [7]: https://travis-ci.org/
  [8]: http://blog.csdn.net/xiong_it/article/details/68944728
  [9]: https://travis-ci.org/profile/
  [10]: http://xiong-it.github.io
  [11]: http://oler3nq5z.bkt.clouddn.com/travis_sync.png
  [12]: http://oler3nq5z.bkt.clouddn.com/travis_setting1.png
  [13]: http://oler3nq5z.bkt.clouddn.com/travis_setting2.png
  [14]: https://github.com/xiong-it/xiong-it.github.io/tree/hexo
  [15]: https://travis-ci.org/ttp://oler3nq5z.bkt.clouddn.com/travis_setting2.png