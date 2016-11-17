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