PhotoDIY
==========
照片DIY

AppStore地址：https://itunes.apple.com/app/id1133036606

## 优化点
1. 预览模式时，添加可左右滑动选择预览图片；
2. 滤镜优化；
3. 选择不同尺寸图片预览时，大小位置加载不对；

##介绍方案
照片DIY是一款处理照片的App，除了可以对照片进入各种翻转、剪裁、缩放，添加文字等基本操作；
还可以添加各种可调节的滤镜操作以及在各种涂鸦和画笔操作等；

PhotoDIY is a photo processing App, in addition to the photo into a variety of flip, cut, zoom, add text and other basic operations;
You can also add a variety of adjustable filter operation and in a variety of graffiti and brush operations;

* [Facebook分享申请流程](http://bbs.mob.com/thread-19148-1-1.html)：`http://bbs.mob.com/thread-19148-1-1.html`


## Icon 与 Launch Image 的生成

[http://ticons.fokkezb.nl/](http://ticons.fokkezb.nl/)

安装：`brew install imagemagick && sudo npm i -g ticons`
命令行：
```
ticons icons ./PhotoDIY.png --output-dir ~/Pictures/icons --alloy --platforms iphone,ipad
ticons splashes ./Launch.png --output-dir ~/Pictures/launch --alloy --platforms iphone,ipad
```




##社会化分享
1.facebook：https://developers.facebook.com/docs/sharing/ios#message
2.twitter：https://apps.twitter.com/app/13101254/show
3.instagram：https://www.instagram.com/developer/clients/manage/
4.微信：https://open.weixin.qq.com/
5.微博：http://open.weibo.com/apps/3082351787
6.腾迅：http://op.open.qq.com/ios_appinfov2/detail?appid=1105751861

##Facebook User_post 审核备注
1. Open App and click the Share button in the top left corner;(打开App，点击左上角的分享按钮；)
2. Then,In the pop-up sharing menu, select Facebook Logo;(在弹出的分享菜单中选择Facebook;)
3. And Then ,In the pop-up page and log in to grant the appropriate permissions;(在弹出页面中登录并授予相应的权限；)


##创建模拟器版本
1.在模拟器中运行应用，这会在 Xcode 的 DerivedData 缓存中自动创建模拟器版本；
2.压缩模拟器版本，使用以下命令：ditto -ck --sequesterRsrc --keepParent `ls -1 -d -t ~/Library/Developer/Xcode/DerivedData/*/Build/Products/*-iphonesimulator/PhotoDIY.app | head -n 1` ~/Desktop/PhotoDIY.zip ；
3.验证版本,可以使用 ios-sim 实用程序模拟器命令行应用启动器来验证模拟器版本。
安装后，运行：ios-sim launch /path/to/your-app.app ；
完整命令：ios-sim --devicetypeid com.apple.CoreSimulator.SimDeviceType.iPhone-6s launch ~/Desktop/PhotoDIY.app
4.提交审核,通过[应用面板](https://developers.facebook.com/apps)提交压缩文件（例如：YourApp.zip）；

##第三方AppKey 及 Secrect
微信:`APPID:wxe9ee15bc76746188   APPSecret:fb4ca3b28e9110091fad90769279e789`
Facebook测试账号：`326136004438567   APPSecret:43eafc5c6dde0656e7031c40f414b8fc`
Facebook正式账号：`325600794492088   APPSecret:c8387c35222f95bfab9550ab182b94bd`


##本地化文案
1.内购产品说明

去掉所有限制和广告

购买之后可以解除所有App限制和广告。

欢迎使用

去掉所有限制和廣告

購買之後可以解除所有App限制和廣告。


Remove all restrictions and ads

After purchase, you can unblock all App restrictions and ads.


모든 제한 사항 및 광고 삭제

구매 후 모든 앱 제한 사항 및 광고 차단을 해제 할 수 있습니다.


すべての制限と広告を削除する

購入後、すべてのアプリの制限と広告のブロックを解除できます。

#### 支持网址
http://app.wodedata.com/myapp/photodiy.html

### v1.1版本

1. 自定义字体动态下载，减少了安装包体积；
2. 兼容了iPhoneX；
3. 修改了图标及背景；
4. 添加了消息推送；

PhotoDIY是一款可以加滤镜、各种涂鸭、打码塞克、裁剪等功能的图片照片处理的App。

1. Custom font dynamic download, reducing the volume of the installation package;
Compatible with iPhoneX
3. modified the icon and background;
4. Added message push;

PhotoDIY is a photo processing application that can add filters, all kinds of graffiti, playing code Seck, cropping and other functions.

