## TSSocial_Pay

### 功能
三方支付(wx,alipay,paypal)

### 配置
```
1. pod 'WechatOpenSDK'
2. 创建 XXX\_Bridging_Header.h 
3. 配置引用
   #import "WXApi.h"
   #import <AlipaySDK/AlipaySDK.h>
4. Link Binary With Libraries 
	添加 CoreMotion.framework

```


### 使用git submodule引入该模块
[git submodule子模块使用教程](https://www.jianshu.com/p/b49741cb1347)

cd proj_root

mkdir lib/ lib为自定义统一保存子工程目录

git submodule add [工程地址] [保存路径]

#### 引入TSSocialPay
<pre>
git submodule add git@gitlab.caiqr.com:ios_module/TSSocial_LoginShare.git lib/TSSocialPay
</pre>

#### 使用注意事项
1. 使用时需添加TSSocial_PaySrc文件中内容参与工程编译

2. 若仅使用微信和支付宝,工程不需要引入TSPayPal类参与工程编译

3. 若需要支持PayPal支付,需引入TSPayPal类参与编译
	
	Podfile文件中添加  pod 'PayPal-iOS-SDK'

### Usage
-
#### 微信

##### 注册微信支付ID
<pre>
TSPaymentHelper.registerWeChatAppID(wx_app_id: _)
</pre>

##### 调用微信支付
<pre>
TSPaymentHelper.default.sendWechatPayment(appid: _, partnerId: _, prepayId: _, package: _, nonceStr: _, timeStamp: _, sign: _)
</pre>

-
#### 支付宝

##### 注册支付宝urlScheme
<pre>
TSPaymentHelper.registerAlipayScheme(urlScheme: _)
</pre>

##### 调用支付宝
<pre>
TSPaymentHelper.default.sendAliPayment(alipayPayOrder: _)
</pre>

-
#### PayPal
##### 配置
<pre>
//配置环境id (生产&沙盒)
TSPayPal.registerPayPalProductId(environmentProduction: "xx", environmentSandbox: "xx")

//指定调用环境 (默认生产环境)
TSPayPal.default.paypalEnvironment = .product

//配置PayPal支付凭证验证逻辑
TSPayPal.default.checkPaypalPayment = {(recept) -> Bool in
	//operation
	//return state
}
</pre>

##### 调用PayPal
<pre>
TSPaymentHelper.default.sendPayPalPayment(orderID: _, money_type: _, amount: _, description: _, launchVC: _)
</pre>

-
#### 代理 TSPaymentThirdHelperDelegate
<pre>
TSPaymentHelper.default.delegate = self

设置代理,并实现代理方法
func paymentCallBack(result: TSPaymentThirdResult) {
	//success or fail
}
</pre>

-
#### 系统回调 -- Application OpenUrl Method

<pre>
TSPaymentHelper.handle(url: url)
</pre>
