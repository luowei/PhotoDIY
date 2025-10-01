# GitHub Actions Workflows

本目录包含 PhotoDIY 项目的 CI/CD 自动化工作流配置。

## 📦 可用工作流

### 1. OC Version - TestFlight 部署
**文件**: `oc-testflight.yml`

自动构建和部署 Objective-C 版本到 TestFlight。

**触发条件**:
- ✅ Push 到 `main` 分支且修改了 `OC/` 目录
- ✅ Pull Request 到 `main` 分支且修改了 `OC/` 目录
- ✅ 手动触发

**构建流程**:
1. 检出代码
2. 设置 Xcode 环境
3. 安装 CocoaPods 依赖
4. 配置代码签名
5. 构建 Archive
6. 导出 IPA
7. 上传到 TestFlight
8. 保存构建产物

**产物**:
- `PhotoDIY-OC-IPA` (保留 30 天)
- `PhotoDIY-OC-Archive` (保留 7 天)

---

### 2. Swift Version - TestFlight 部署
**文件**: `swift-testflight.yml`

自动构建、测试和部署 Swift 版本到 TestFlight。

**触发条件**:
- ✅ Push 到 `swift` 分支且修改了 `Swift/` 目录
- ✅ Pull Request 到 `swift` 分支且修改了 `Swift/` 目录
- ✅ 手动触发

**构建流程**:

**Job 1: 测试**
1. 检出代码
2. 运行单元测试
3. 上传测试结果

**Job 2: 构建和部署**
1. 检出代码
2. 设置 Xcode 环境
3. 配置代码签名
4. 自动递增构建号
5. 构建 Archive
6. 导出 IPA
7. 上传到 TestFlight
8. 保存构建产物和符号文件

**产物**:
- `Photofy-Swift-IPA` (保留 30 天)
- `Photofy-Swift-Archive` (保留 7 天)
- `Photofy-dSYMs` (保留 90 天) - 用于崩溃分析
- `Test-Results` (保留 7 天)

---

## 🚀 使用方法

### 自动触发

工作流会在满足触发条件时自动运行：

```bash
# OC 版本 - 修改 OC 目录后推送到 main
git add OC/
git commit -m "Update OC version"
git push origin main

# Swift 版本 - 修改 Swift 目录后推送到 swift
git checkout swift
git add Swift/
git commit -m "Update Swift version"
git push origin swift
```

### 手动触发

1. 访问 GitHub 仓库的 **Actions** 页面
2. 选择要运行的工作流:
   - `OC Version - Build and Deploy to TestFlight`
   - `Swift Version - Build and Deploy to TestFlight`
3. 点击 **Run workflow** 按钮
4. 选择分支（默认为对应的分支）
5. 点击 **Run workflow** 确认

---

## ⚙️ 配置要求

### 必需的 GitHub Secrets

在使用这些工作流之前，必须在 GitHub 仓库中配置以下 Secrets：

| Secret 名称 | 描述 | 获取方式 |
|------------|------|---------|
| `IOS_CERTIFICATE_P12` | iOS Distribution 证书 (Base64) | 从 Keychain 导出 |
| `IOS_CERTIFICATE_PASSWORD` | 证书密码 | 导出时设置 |
| `CODE_SIGN_IDENTITY` | 代码签名身份 | `security find-identity` |
| `IOS_PROVISIONING_PROFILE` | Provisioning Profile (Base64) | Apple Developer Portal |
| `PROVISIONING_PROFILE_NAME` | Profile 名称 | Apple Developer Portal |
| `APPLE_TEAM_ID` | Apple Team ID | Developer Portal Membership |
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API Key ID | App Store Connect |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID | App Store Connect |
| `APP_STORE_CONNECT_API_KEY` | API Key 文件 (Base64) | App Store Connect |

**详细配置指南**: 请参阅 [SECRETS_SETUP.md](../SECRETS_SETUP.md)

---

## 📊 工作流状态

### 查看运行状态

1. 访问 **Actions** 页面
2. 查看最近的工作流运行
3. 点击运行记录查看详细日志

### 状态徽章

可以在 README 中添加状态徽章：

```markdown
<!-- OC Version -->
![OC Build](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/oc-testflight.yml/badge.svg)

<!-- Swift Version -->
![Swift Build](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/swift-testflight.yml/badge.svg)
```

---

## 🔧 自定义配置

### 修改 Xcode 版本

在工作流文件中修改 `XCODE_VERSION` 环境变量：

```yaml
env:
  XCODE_VERSION: '15.0'  # 修改为需要的版本
```

### 修改部署目标

```yaml
env:
  IOS_DEPLOYMENT_TARGET: '15.0'  # 修改最低 iOS 版本
```

### 修改测试设备

在 Swift 工作流的测试步骤中：

```yaml
- name: Run Unit Tests
  run: |
    xcodebuild test \
      -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'  # 修改设备
```

### 添加 Slack 通知

在工作流末尾添加：

```yaml
- name: Slack Notification
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

---

## 📋 工作流对比

| 特性 | OC Workflow | Swift Workflow |
|------|-------------|----------------|
| **触发分支** | `main` | `swift` |
| **依赖安装** | CocoaPods | 无 |
| **测试** | ❌ | ✅ |
| **自动递增版本** | ❌ | ✅ |
| **dSYM 上传** | ❌ | ✅ |
| **构建时间** | ~15-20 分钟 | ~10-15 分钟 |

---

## 🐛 故障排查

### 常见问题

#### 1. 构建失败：证书问题
```
Error: Code signing is required
```
**解决**: 检查证书 Secrets 配置，参考 [SECRETS_SETUP.md](../SECRETS_SETUP.md)

#### 2. CocoaPods 安装失败 (OC)
```
Error: [!] Unable to find a specification for...
```
**解决**:
- 确认 `Podfile.lock` 已提交
- 尝试更新 pod specs: `pod repo update`

#### 3. TestFlight 上传失败
```
Error: Could not upload to TestFlight
```
**解决**:
- 检查 API Key 权限
- 确认 Bundle ID 在 App Store Connect 中存在
- 检查版本号是否已存在

#### 4. 测试失败 (Swift)
```
Error: Test suite failed
```
**解决**:
- 在本地运行测试: `xcodebuild test -project ...`
- 检查测试代码
- 查看详细日志

### 查看详细日志

1. 进入失败的工作流运行
2. 展开失败的步骤
3. 查看详细输出
4. 下载日志文件（右上角 ... 菜单）

---

## 🔒 安全最佳实践

1. **不要在日志中打印敏感信息**
   - 证书内容
   - 密码
   - API Keys

2. **定期更新 Secrets**
   - 证书过期前续期
   - 定期轮换 API Keys

3. **限制工作流权限**
   - 仅在必要的分支触发
   - 使用最小权限的 API Keys

4. **保护分支**
   - 为 `main` 和 `swift` 分支启用保护规则
   - 要求 PR 审查
   - 要求状态检查通过

---

## 📚 相关资源

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Xcode Build Settings](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
- [CocoaPods 文档](https://cocoapods.org/)
- [TestFlight 文档](https://developer.apple.com/testflight/)

---

## 📞 支持

如有问题或需要帮助：
1. 查看工作流日志
2. 参考 [SECRETS_SETUP.md](../SECRETS_SETUP.md)
3. 查看 [故障排查](#-故障排查) 部分
4. 提交 Issue

---

**最后更新**: 2025-10-01
