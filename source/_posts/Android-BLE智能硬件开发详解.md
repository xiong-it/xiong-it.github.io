---
title: 'Android:BLE智能硬件开发详解'
date: 2017-03-14 11:23:18
tags: [BLE, 智能硬件, Android]
categories: Android
---
前些年，智能硬件炒的挺火的，那今天，咱就来说说**智能硬件那些事**
<!--more-->
目录
==

 - **前言**
 - **BLE是个什么鬼**
 - **BLE中的角色分工**
 - **主要的关键词和概念**
    - GATT(Generic Attribute Profile )
    - Characteristic
    - Service
 - **Android如何使用BLE**
    - 蓝牙权限
    - APP和BLE外设交互流程
 - **后记**
<br/>
        
> 本文作者MichaelX，博客地址：http://blog.csdn.net/xiong_it 转载请注明来源

----------


前言
==
前些年，智能硬件炒的挺火的，那今天，咱就来说说**智能硬件那些事**。BLE是智能硬件的一种通讯方式，通过BLE连接，iOS & Android手机和智能硬件就可以进行自定义的交互了。交互的体验如何，很大程度上取决于智能硬件的驱动工程师驱动写的好不好，以及App的代码质量如何。

笔者曾参与过多款BLE智能硬件的开发，许久不用，怕忘了，把自己的整理的一些知识记录与此，同时也希望能够给一些同学带来帮助。本文将尽力向读者讲清楚BLE是什么，以及在实际Android开发中该如何使用BLE。

**前方高能：**文章有点长，笔者经历了好几次改版，也花费了好几个月的业余时间，读者可能需要点耐心。着急的读者可直接跳转至**[Android如何使用BLE](http://blog.csdn.net/Xiong_IT/article/details/60966458#t8)**

BLE是个什么鬼
========

BLE：Bluetooth Low Energy,低功耗蓝牙。Android官方介绍如下：

> Android 4.3 (API Level 18) introduces built-in platform support for Bluetooth Low Energy in the central role and provides APIs that apps can use to discover devices, query for services, and read/write characteristics. In contrast to Classic Bluetooth, Bluetooth Low Energy (BLE) is designed to provide significantly lower power consumption. This allows Android apps to communicate with BLE devices that have low power requirements, such as proximity sensors, heart rate monitors, fitness devices, and so on.

什么意思呢？自从API18/Android4.3开始，Android开始支持低功耗蓝牙并给APP提供了一套api调用。相比传统蓝牙来说，BLE技术旨在降低蓝牙功耗。至于我们Android开发者来说，要做的就是调用这套api，和具备蓝牙的智能硬件沟通，通过蓝牙读写操控智能硬件。

BLE技术允许APP和那些有着**低功耗**需求的BLE设备进行通讯，这些设备包括但不限于：距离传感器设备，心跳率检测仪，健身器材，智能穿戴等。

> **约定:文中提到的"外设","BLE外设"和"智能硬件"是等价的.请读者知悉.**


----------


角色分工
====

> Once the phone and the activity tracker have established a connection, they start transferring GATT metadata to one another. Depending on the kind of data they transfer, one or the other might act as the server. For example, if the activity tracker wants to report sensor data to the phone, it might make sense for the activity tracker to act as the server. If the activity tracker wants to receive updates from the phone, then it might make sense for the phone to act as the server.

在Android APP和BLE外设进行交互时,他们分别扮演两个角色.这两个角色是不固定的.
GATT server:发送数据的一方.
GATT client:接收数据的一方.
当APP向外设写入数据时,APP就是server,外设就是client;当APP读取外设数据时,APP就是client.外设就是server.


----------


主要的关键词和概念
=========


GATT(Generic Attribute Profile )
--------------------------------
> The GATT profile is a general specification for sending and receiving short pieces of data known as "attributes" over a BLE link. All current Low Energy APPlication profiles are based on GATT.

这个是BLE通讯的基本协议,这个协议定义了BLE发送和接收一小段数据的规范,这些被传输的小段数据被称为"attributes".

Characteristic
--------------
> A characteristic contains a single value and 0-n descriptors that describe the characteristic's value. A characteristic can be thought of as a type, analogous to a class. 

博主的理解中,"Characteristic"是BLE通讯之间的沟通"搬运工",因为这是我们从智能硬件直接读写的东西,它依附于下文的Service存在，有自己的标志码：uuid。它『**分为读取BLE外设数据的Characteristic & 向BLE外设写入数据的Characteristic**』。
下面章节中将用代码说话.

Service
-------

> A service is a collection of characteristics. For example, you could have a service called "Heart Rate Monitor" that includes characteristics such as "heart rate measurement." 

此Service非彼Android四大组件中的彼Service,而是BluetoothGattService.这个Service是一个characteristics的集合,它可以理解为针对某个信号的通讯线路。


----------


Android如何使用BLE
==============

蓝牙权限
----

使用BLE需要两个权限

```xml
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
```
如果你想要APP只适配具备BLE的手机,那个可以再添加一个硬件权限特性
```xml
<uses-feature android:name="android.hardware.bluetooth_le" android:required="true"/>
```


----------


APP和BLE外设交互流程
-------------

APP和BLE外设交互的一个大概流程就是:

 1. BLE外设打开电源
 2. APP初始化蓝牙
 3. APP扫描周边BLE外设
 4. APP连接到周边BLE外设
 4. APP读写BLE外设
 5. 交互完成,APP向BLE外设写入关机/待机指令(可选)
 6. BLE外设关机
 7. APP关闭本地蓝牙连接

以下将逐步利用代码进行讲解APP和BLE外设交互.

初始化BLE
----
Java代码判断当前手机是否支持BLE低功耗蓝牙
```java
// 判断手机是否支持BLE
if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)) {
    Toast.makeText(this, R.string.ble_not_supported, Toast.LENGTH_SHORT).show();
    finish();// 如果手机不支持BLE就关闭程序,仅供参考
}
```

初始化蓝牙管理者和适配器,这2个对象是ble通讯的基石.
```java
// 初始化蓝牙管理者和适配器,这2个对象是ble通讯的基石.
private BluetoothAdapter mBluetoothAdapter;
...
final BluetoothManager bluetoothManager =
        (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
mBluetoothAdapter = bluetoothManager.getAdapter();
```

跳转到系统蓝牙设置界面
```java
private BluetoothAdapter mBluetoothAdapter;
...
// 验证蓝牙是否已打开,如果没打开就提示用户跳转打开.
if (mBluetoothAdapter == null || !mBluetoothAdapter.isEnabled()) {
    Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
    startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
    }
```
<br/>
APP扫描周边BLE外设
------------
需要实现一个BluetoothAdapter.LeScanCallback回调接口，得到扫描结果。该接口只有一个回调方法：
```
/**
 * @param device 被手机蓝牙扫描到的BLE外设实体对象
 * @param rssi 大概就是表示BLE外设的信号强度，如果为0，则表示BLE外设不可连接。
 * @param scanRecord 被扫描到的BLE外围设备提供的扫描记录，一般没什么用
 */
public void onLeScan(final BluetoothDevice device, int rssi, byte[] scanRecord) 
```
由于扫描BLE设备比较消耗资源，官方推荐间歇性扫描，示例代码如下
```
    private BluetoothAdapter mBluetoothAdapter;
    private boolean mScanning;
    private Handler mHandler;

    // 每扫描10s休息一下
    private static final long SCAN_PERIOD = 10000;
    
    private BluetoothAdapter.LeScanCallback mLeScanCallback =
        new BluetoothAdapter.LeScanCallback() {
    @Override
    public void onLeScan(final BluetoothDevice device, int rssi, byte[] scanRecord) {
            // TODO 这里可以进行连接操作，连接操作见下一小节
            if (device != null && device.getName() != null && device.getName().contain("你的产品名称")){
                // 连接设备
                connectDevice(device);
                // 停止扫描
                scanLeDevice(false);
            }
           }
       });
   }
};
    
    ...
    /**
     * @param enable 是否进行扫描，false则停止扫描
     */
    private void scanLeDevice(final boolean enable) {
        if (enable) {
            // 利用Handler进行间歇性扫描，每次扫描时间：10s
            mHandler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    mScanning = false;
                    mBluetoothAdapter.stopLeScan(mLeScanCallback);
                }
            }, SCAN_PERIOD);

            mScanning = true;
            mBluetoothAdapter.startLeScan(mLeScanCallback);
        } else {
            // 停止扫描
            mScanning = false;
            mBluetoothAdapter.stopLeScan(mLeScanCallback);
        }
        ...
    }
```
<br/>
APP连接周边BLE外设
------------
连接操作是进行手机和BLE外设交互的基础，请看下面connectDevice(BluetoothDevice)方法实现。

分两步走：
 1. 判断该设备是否连接过，连接过则首先尝试直接连接：BluetoothGatt.connect()
 2. 首次连接或者直连失败使用：BluetoothDevice.connectGatt(Context context, boolean autoConnect, BluetoothGattCallback callback)
```java
public boolean connectDevice(final BluetoothDevice device) {
		if (mBluetoothAdapter == null || device == null) {
			Log.w(TAG,
					"BluetoothAdapter not initialized or unspecified address.");
			return false;
		}
        
        String address = device.getAddress();
		// 之前连接过的设备，尝试直接连接。mBluetoothDeviceAddress表示刚才连接过的设备地址
		if (mBluetoothDeviceAddress != null
				&& address.equals(mBluetoothDeviceAddress)
				&& mBluetoothGatt != null) {
			Log.d(TAG,
					"Trying to use an existing mBluetoothGatt for connection.");
			if (mBluetoothGatt.connect()) {// 连接成功
			    // 修改连接状态变量
				mConnectionState = STATE_CONNECTING;
				return true;
			} else {
				return false;
			}
		}

		final BluetoothDevice remoteDevice = mBluetoothAdapter.getRemoteDevice(address);
		if (remoteDevice == null) {
			Log.w(TAG, "Device not found.  Unable to connect.");
			return false;
		}
		mBluetoothGatt = remoteDevice.connectGatt(context, false, mGattCallback);
		Log.d(TAG, "Trying to create a new connection.");
		// 将当前连接上的设备地址赋值给连接过的设备地址变量
		mBluetoothDeviceAddress = address;
		// 改变连接状态变量
		mConnectionState = STATE_CONNECTING;
		return true;
	}
```
连接BEL外设时，需要一个实现回调接口以得到连接状态，BluetoothGattCallback大概实现如下：
```
private final BluetoothGattCallback mGattCallback =
            new BluetoothGattCallback() {
        @Override
        public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
            // 该方法在连接状态改变时回调，newState即代表当前连接状态
            String intentAction;
            // 连接上了
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                intentAction = ACTION_GATT_CONNECTED;
                // 改变蓝牙连接状态变量
                mConnectionState = STATE_CONNECTED;
                // 发送自定义广播：连接上了
                broadcastUpdate(intentAction);
                // 当前外设相当于前面章节提到的Server角色：提供数据被手机读取
                Log.i(TAG, "Connected to GATT server.");
                // 获取读/写服务：Service。该方法会触发下面的onServicesDiscovered()回调
                mBluetoothGatt.discoverServices();

            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {// 断开连接了
                intentAction = ACTION_GATT_DISCONNECTED;
                mConnectionState = STATE_DISCONNECTED;
                Log.i(TAG, "Disconnected from GATT server.");
                // 发送自定义广播：断开了连接
                broadcastUpdate(intentAction);
            }
        }

        @Override
        // 该方法在蓝牙服务被发现时回调。由上述的mBluetoothGatt.discoverServices()触发结果。
        public void onServicesDiscovered(BluetoothGatt gatt, int status) {
            // 发现服务。status表示发现服务的结果码
            if (status == BluetoothGatt.GATT_SUCCESS) {
                broadcastUpdate(ACTION_GATT_SERVICES_DISCOVERED);
                // TODO 从发现的Service来找出读数据用的BluetoothGattCharacteristic和写数据用的BluetoothGattCharacteristic。
                initReadAndWriteCharacteristic(gatt.getServices());
                
            } else {// 未发现服务
                Log.w(TAG, "onServicesDiscovered received: " + status);
            }
        }

        @Override
        // 读取操作的回调结果
        public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                broadcastUpdate(ACTION_DATA_AVAILABLE, characteristic);
            }
        }
        
        @Override
        // 写入操作的回调结果
        public void onCharacteristicWrite(BluetoothGatt gatt,
				BluetoothGattCharacteristic characteristic, int status) {
		};
     ...
    };
...
```

<br/>
**找出读写"数据包"的"搬运工"**

下面是找出读写"搬运工"BluetoothGattCharacteristic的initReadAndWriteCharacteristic()代码实现

```
BluetoothGattCharacteristic mReadCharacteristic;
BluetoothGattCharacteristic mWriteCharacteristic;

public void initReadAndWriteCharacteristic(
			List<BluetoothGattService> gattServices) {
		if (gattServices == null)
			return;
		// 遍历所有的 GATT Services.
		for (BluetoothGattService gattService : gattServices) {
			if (!gattService.getUuid().toString().trim().equalsIgnoreCase("这里是你期望的Service的uuid，由你司智能外色的驱动工程师决定"))
			    continue;
			List<BluetoothGattCharacteristic> gattCharacteristics = gattService.getCharacteristics();
			// 遍历当前Service中所有的Characteristics.
			for (BluetoothGattCharacteristic gattCharacteristic : gattCharacteristics) {

				if (gattCharacteristic.getUuid().toString().trim().equalsIgnoreCase(""这里是你期望的写数据的uuid，由你司驱动工程师决定"")) {
					mWriteCharacteristic = gattCharacteristic;
				} else if (gattCharacteristic.getUuid().toString().trim().equalsIgnoreCase("这里是你期望的读数据的uuid，由你司驱动工程师决定")) {
					mReadCharacteristic = gattCharacteristic;
				}
			}
		}
	}
```
至此，我们就拿到了可携带读写数据的“搬运工”-『**mReadCharacteristic  & mWriteCharacteristic**』，下面就可以和智能硬件进行交互了。
<br/>
APP读取BLE外设蓝牙数据
--------------
想要读取BLE外设的数据时，比如：心跳速率，电量等等。可通过下面方式。
```
// 告诉”搬运工“我想知道BLE外设当前数据,将回调BluetoothGattCallback接口的onCharacteristicRead()方法
mBluetoothGatt.readCharacteristic(mReadCharacteristic);

// 读取BLE蓝牙数据操作的回调方法
 @Override
public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                broadcastUpdate(ACTION_DATA_AVAILABLE, characteristic);
                // ”搬运工“把”数据包“搬出来了
                byte[] data = characteristic.getValue();
		        // 根据驱动工程师给的协议文档，解析该数组，该处假设数组0位上表示心跳速率
		        int heartRateR = data[0];// 得到心跳速率，做相应UI更新和操作
		}
            }
        }
```
<br/>
APP向BLE外设写入数据
-------------
比如说你想告诉BLE外设让他锁屏，或者进行某个动作，APP向操纵BLE外设时可通过以下方式
```
// 根据驱动工程师给的协议文档，组织一个数组命令
byte[] data = getData();
// 将该条命令“数据包”给“搬运工"
mWriteCharacteristic.setValue(data);

// ”搬运工“将数据搬到BLE外设里面了，将回调BluetoothGattCallback接口的onCharacteristicWrite()方法
mBluetoothGatt.writeCharacteristic(characteristic);

// 向BLE蓝牙外设写入数据操作的回调方法
@Override
public void onCharacteristicWrite(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {
			if(status == BluetoothGatt.GATT_SUCCESS) {
			    // 命令写入成功，数据包成功写入BLE外设中
			}	
		};
```
> 多说一句，其实，手机关闭外设也是一条写入命令，外设得到该命令后即进入省电待机状态，一般外设也可以通过开/关机键彻底关机。

<br/>
APP关闭蓝牙连接
-----
交互完了，不需要了，还是把APP蓝牙连接给断掉吧
```
public void close() {
    if (mBluetoothGatt == null) {
        return;
    }
    mBluetoothGatt.close();
    mBluetoothGatt = null;
}
```

----------

后记
==

Android官方在SDK中提供了许多demo供开发者参考（1年前左右），其实关于BLE api调用也是有的,不过只涉及了蓝牙外设的连接,未涉及蓝牙数据读写.BLE官方demo路径:`User/AndroidSDK/samples/android-19/connectivity/BluetoothLeGatt`
以上路径是笔者举例的路径,如果你的SDK目录下没有samples目录，现在（20170308）SDK Manager已经不开放sample下载了,请点击下载：[android-sample-api19][1] 文件提取密码: y87g


> 本文原创作者:[MichaelX](http://blog.csdn.net/xiong_it),博客地址:http://blog.csdn.net/xiong_it.转载请注明来源

欢迎光临：[MichaelX's Blog](https://xiong-it.github.io)

参考链接
====
https://developer.android.com/guide/topics/connectivity/bluetooth-le.html#terms


  [1]: https://pan.baidu.com/s/1o87ASJK