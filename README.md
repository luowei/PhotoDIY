# PhotoDIY - 图片编辑应用

PhotoDIY 是一款功能强大的 iOS 照片编辑应用，提供滤镜、裁剪、文字叠加、绘图和社交分享等多种图像编辑功能。本项目包含两个主要实现版本：

- **OC/** - Legacy Objective-C 实现（生产环境）
- **Swift/** - 新的 Swift 重写版本（开发中，位于 `swift` 分支）

## 📱 应用信息

- **App Store**: https://itunes.apple.com/app/id1133036606
- **支持网站**: http://app.wodedata.com/myapp/photodiy.html
- **当前版本**: 1.2 (Build 20180130)
- **Bundle ID**: com.wodedata.PhotoDIY

---

## 🏗️ OC 版本 (Legacy - Objective-C)

### 项目路径
```
OC/PhotoDIY.xcworkspace
```

### 技术栈

- **语言**: Objective-C
- **最低 iOS 版本**: 7.0+
- **项目结构**: `.xcworkspace` (CocoaPods)
- **UI 框架**: UIKit + Storyboard
- **版本**: 1.2 (Build 20180130)

### 核心依赖

#### 图像处理
- **GPUImage** (0.1.7) - 实时滤镜和效果处理
- **SDWebImage** (3.8.1) - 异步图像加载和缓存

#### UI 组件
- **MBProgressHUD** - 进度指示器
- **FCAlertView** (1.4.0) - 自定义弹窗
- **FDStackView** (1.0) - 堆栈视图
- **FXBlurView** (1.6.4) - 模糊效果

#### 社交分享
- **UMengUShare** (6.2.2) - 统一社交分享平台
  - 微信 (WeChat): `wxe9ee15bc76746188`
  - 新浪微博 (Sina Weibo): `wb3082351787`
  - QQ: `tencent1105751861` / `QQ41e86f35`
  - Twitter
  - Instagram
  - Facebook: `fb326136004438567`

#### 广告
- **Google-Mobile-Ads-SDK** (7.28.0)

### 项目结构

```
OC/PhotoDIY/
├── AppDelegate.h/m          # 应用入口
├── PhotoTools/              # 核心照片处理和相机功能
├── ContentView/             # 主编辑界面和 UI 组件
├── DataManager/             # 数据持久化和应用状态管理
├── ThirdParts/              # 第三方集成和自定义修改
├── Assets.xcassets/         # 图像资源（按功能组织）
│   ├── FilterView/          # 滤镜相关资源
│   ├── ToolBar/             # 工具栏图标
│   ├── Drawboard/           # 绘图板资源
│   └── ...
├── InAppPurchase/           # 应用内购买
├── Resource/                # 其他资源文件
└── *.lproj/                 # 多语言支持
```

### 多语言支持

- 🇨🇳 简体中文 / 繁体中文
- 🇺🇸 English
- 🇰🇷 Korean
- 🇯🇵 Japanese
- 🇸🇦 Arabic
- 🇩🇪 German
- 🇪🇸 Spanish
- 🇫🇷 French
- 🇵🇹 Portuguese
- 🇷🇺 Russian

### 构建命令

```bash
# 安装 CocoaPods 依赖
cd OC && pod install

# 打开项目（必须使用 .xcworkspace）
open PhotoDIY.xcworkspace

# 使用 Xcode 构建和运行
```

### 图标和启动图生成

```bash
# 安装工具
brew install imagemagick
sudo npm i -g ticons

# 生成图标
ticons icons ./PhotoDIY.png --output-dir ~/Pictures/icons --alloy --platforms iphone,ipad

# 生成启动屏幕
ticons splashes ./Launch.png --output-dir ~/Pictures/launch --alloy --platforms iphone,ipad
```

### 模拟器构建（Facebook 审核）

```bash
# 从 DerivedData 创建模拟器构建包
ditto -ck --sequesterRsrc --keepParent \
  `ls -1 -d -t ~/Library/Developer/Xcode/DerivedData/*/Build/Products/*-iphonesimulator/PhotoDIY.app | head -n 1` \
  ~/Desktop/PhotoDIY.zip

# 使用 ios-sim 验证
ios-sim --devicetypeid com.apple.CoreSimulator.SimDeviceType.iPhone-6s launch ~/Desktop/PhotoDIY.app
```

---

## 🚀 Swift 版本 (现代化重写)

### 项目路径
```
Swift/Photofy.xcodeproj
```

### 技术栈

- **语言**: Swift 5.9+
- **最低 iOS 版本**: 15.0+
- **架构**: MVVM + Coordinator Pattern
- **UI 框架**: SwiftUI + UIKit (混合)
- **响应式编程**: Combine Framework
- **依赖管理**: 无外部依赖管理器（原生 Swift）

### 核心技术

#### 图像处理
- **Core Image** - 滤镜和效果
- **Metal Performance Shaders** - 高性能图像处理
- **PhotoKit** - 现代化照片库访问

#### 架构特性
- **Dependency Injection** - 自定义 DI 容器
- **Coordinator Pattern** - 导航管理
- **Combine** - 响应式数据流
- **Core Data** - 数据持久化（支持 CloudKit 同步）

#### 分享功能
- **UIActivityViewController** - 原生分享
- 自定义社交活动扩展

### 项目结构

```
Swift/Photofy/
├── App/
│   ├── PhotofyApp.swift        # SwiftUI 应用入口
│   ├── ContentView.swift       # 主视图
│   └── AppState.swift          # 全局状态管理
├── Core/
│   ├── Models/
│   │   ├── EditingHistory.swift    # 编辑历史记录
│   │   └── ...
│   ├── Services/
│   │   ├── ImageFilterManager.swift     # 滤镜管理
│   │   ├── ImageCropManager.swift       # 裁剪管理
│   │   └── ...
│   ├── Theme/                   # 主题和样式系统
│   ├── DependencyInjection/    # DI 容器
│   ├── Coordinator/            # 导航协调器
│   ├── Extensions/             # Swift 扩展
│   └── Utilities/              # 工具类
├── Views/
│   ├── EditingOverlayView.swift     # 编辑覆盖层
│   ├── CropView.swift               # 裁剪视图
│   ├── StyleToolsView.swift         # 样式工具
│   ├── FilterSelectorView.swift     # 滤镜选择器
│   ├── EditingToolsPanel.swift      # 编辑工具面板
│   ├── AIFeaturesView.swift         # AI 功能
│   ├── CameraView.swift             # 相机视图
│   ├── SettingsView.swift           # 设置页面
│   ├── EditingHistoryView.swift     # 编辑历史
│   └── ZoomableImageView.swift      # 可缩放图片视图
├── Services/
│   ├── AIImageProcessor.swift           # AI 图像处理
│   ├── AIEnhancedImageProcessor.swift   # AI 增强处理器
│   └── AdvancedStyleProcessor.swift     # 高级样式处理器
├── Models/                     # 数据模型
├── Resources/                  # 资源文件
└── Tests/                      # 单元测试和 UI 测试
```

### 主要功能模块

#### 1. 图像编辑工具
- ✂️ **裁剪工具** (`CropView.swift`) - 支持自由裁剪和预设比例
- 🎨 **滤镜系统** (`FilterSelectorView.swift`) - 多种内置滤镜
- 🖌️ **样式工具** (`StyleToolsView.swift`) - 亮度、对比度、饱和度等调整
- 📝 **文本叠加** - 添加和编辑文本
- ✏️ **绘图功能** - 自由绘制

#### 2. AI 功能
- 🤖 **AI 图像处理** (`AIImageProcessor.swift`)
- ✨ **AI 增强** (`AIEnhancedImageProcessor.swift`)
- 🎭 **高级样式** (`AdvancedStyleProcessor.swift`)

#### 3. 编辑管理
- 📜 **编辑历史** (`EditingHistory.swift`, `EditingHistoryView.swift`)
  - 撤销/重做功能
  - 历史记录查看
- 💾 **状态持久化** - Core Data + CloudKit

#### 4. 用户界面
- 📷 **相机集成** (`CameraView.swift`)
- ⚙️ **设置页面** (`SettingsView.swift`)
- 🔍 **缩放和平移** (`ZoomableImageView.swift`)
- 🛠️ **编辑工具面板** (`EditingToolsPanel.swift`)

### 构建命令

```bash
# 使用 Xcode 打开项目
cd Swift/Photofy
open Photofy.xcodeproj

# 使用 xcodebuild 命令行构建
xcodebuild -project Photofy.xcodeproj \
  -scheme Photofy \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build

# 运行测试
xcodebuild -project Photofy.xcodeproj \
  -scheme Photofy \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  test
```

### 开发工作流

```bash
# 切换到 Swift 实现
git checkout swift

# 切换回 Objective-C
git checkout main
```

---

## 🔄 项目对比

| 特性 | OC 版本 | Swift 版本 |
|------|---------|------------|
| **语言** | Objective-C | Swift 5.9+ |
| **最低 iOS** | 7.0+ | 15.0+ |
| **UI 框架** | UIKit + Storyboard | SwiftUI + UIKit |
| **架构** | MVC | MVVM + Coordinator |
| **图像处理** | GPUImage | Core Image + Metal |
| **响应式** | KVO/Delegate | Combine |
| **依赖管理** | CocoaPods | 无（原生） |
| **状态** | 生产环境 | 开发中 |
| **分支** | `main` | `swift` |

---

## 🛠️ 开发指南

### 前置要求

- Xcode 15.0+
- macOS 13.0+
- iOS 15.0+ (Swift) 或 iOS 7.0+ (OC)
- CocoaPods (仅 OC 版本)

### 安装步骤

#### OC 版本
```bash
cd OC
pod install
open PhotoDIY.xcworkspace
```

#### Swift 版本
```bash
cd Swift
open Photofy.xcodeproj
```

### 权限配置

应用需要以下权限：
- 📷 **相机访问** - 拍摄照片
- 🖼️ **照片库访问** - 选择和保存照片
- 💾 **照片库添加** - 保存编辑后的图片

权限描述已在 `Info.plist` 中配置。

---

## 📦 发布流程

### App Store 信息
- **版本**: 1.2
- **功能**:
  - iPhone X 兼容性
  - 自定义字体下载
  - 推送通知支持
  - 远程通知后台模式

### 构建配置
- 支持设备: iPhone 和 iPad
- 支持方向:
  - iPhone: 仅竖屏
  - iPad: 所有方向

---

## 🔐 社交平台配置

### 已集成平台

#### 微信 (WeChat)
- App ID: `wxe9ee15bc76746188`
- URL Scheme: `wxe9ee15bc76746188`

#### 新浪微博 (Sina Weibo)
- App Key: `3082351787`
- URL Scheme: `wb3082351787`

#### QQ
- App ID: `1105751861`
- URL Schemes: `tencent1105751861`, `QQ41e86f35`

#### Facebook
- App ID: `326136004438567` (Test)
- Production: `325600794492088`
- URL Scheme: `fb326136004438567`

#### Twitter & Instagram
- 原生支持

---

## 📄 许可证

版权所有 © 2018 WodeData. 保留所有权利。

---

## 📞 支持

如有问题或建议，请访问：
- 支持网站: http://app.wodedata.com/myapp/photodiy.html
- App Store: https://itunes.apple.com/app/id1133036606

---

## 🗺️ 开发路线图

### 当前状态
- ✅ OC 版本已上线 App Store
- 🚧 Swift 版本正在开发中（`swift` 分支）

### Swift 版本待完成功能
- [ ] 完整的社交分享集成
- [ ] 应用内购买支持
- [ ] 推送通知
- [ ] 完整的本地化支持
- [ ] UI/UX 优化
- [ ] 性能优化
- [ ] 完整测试覆盖

---

**最后更新**: 2025-10-01
