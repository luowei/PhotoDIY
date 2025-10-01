# GitHub Actions Secrets 配置指南

本文档说明如何为 PhotoDIY 项目配置 GitHub Actions CI/CD 所需的 Secrets。

## 📋 必需的 Secrets

在 GitHub 仓库的 **Settings → Secrets and variables → Actions** 中添加以下 secrets：

### 1. 代码签名证书

#### `IOS_CERTIFICATE_P12`
- **描述**: iOS 开发者证书（.p12 文件）的 Base64 编码
- **获取方式**:
  1. 从 Keychain Access 导出 iOS Distribution 证书为 `.p12` 文件
  2. 转换为 Base64:
     ```bash
     base64 -i certificate.p12 | pbcopy
     ```
  3. 粘贴到 GitHub Secret

#### `IOS_CERTIFICATE_PASSWORD`
- **描述**: .p12 证书的密码
- **获取方式**: 导出证书时设置的密码

#### `CODE_SIGN_IDENTITY`
- **描述**: 代码签名身份名称
- **示例**: `"Apple Distribution: Your Company Name (TEAM_ID)"`
- **获取方式**:
  ```bash
  security find-identity -v -p codesigning
  ```

### 2. Provisioning Profile

#### `IOS_PROVISIONING_PROFILE`
- **描述**: iOS Provisioning Profile 的 Base64 编码
- **获取方式**:
  1. 从 Apple Developer 下载 App Store Distribution Profile (.mobileprovision)
  2. 转换为 Base64:
     ```bash
     base64 -i YourProfile.mobileprovision | pbcopy
     ```
  3. 粘贴到 GitHub Secret

#### `PROVISIONING_PROFILE_NAME`
- **描述**: Provisioning Profile 的名称
- **示例**: `"PhotoDIY App Store Profile"`
- **获取方式**: 在 Apple Developer Portal 中查看

### 3. Apple Developer 信息

#### `APPLE_TEAM_ID`
- **描述**: Apple Developer Team ID
- **示例**: `"A1B2C3D4E5"`
- **获取方式**:
  - Apple Developer Portal → Membership → Team ID
  - 或在 Xcode → Preferences → Accounts 中查看

### 4. App Store Connect API

需要创建 App Store Connect API Key 用于自动上传到 TestFlight。

#### 创建 API Key 步骤：
1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 进入 **Users and Access → Keys → App Store Connect API**
3. 点击 **Generate API Key** 或使用现有的
4. 选择角色: **Admin** 或 **App Manager**
5. 下载 `.p8` 文件（只能下载一次，请妥善保管）

#### `APP_STORE_CONNECT_API_KEY_ID`
- **描述**: API Key ID
- **示例**: `"AB12CD34EF"`
- **获取方式**: App Store Connect → Keys 页面显示的 Key ID

#### `APP_STORE_CONNECT_ISSUER_ID`
- **描述**: Issuer ID
- **示例**: `"12345678-1234-1234-1234-123456789012"`
- **获取方式**: App Store Connect → Keys 页面顶部的 Issuer ID

#### `APP_STORE_CONNECT_API_KEY`
- **描述**: API Key 文件 (.p8) 的 Base64 编码
- **获取方式**:
  ```bash
  base64 -i AuthKey_KEYID.p8 | pbcopy
  ```

---

## 🔧 配置步骤

### 步骤 1: 准备证书和 Profile

```bash
# 1. 导出证书
# 在 Keychain Access 中：
# - 找到 "Apple Distribution" 证书
# - 右键 → 导出为 certificate.p12
# - 设置密码

# 2. 下载 Provisioning Profile
# 在 Apple Developer Portal：
# - Certificates, Identifiers & Profiles
# - Profiles → Distribution → App Store
# - 下载对应的 .mobileprovision 文件

# 3. 转换为 Base64
base64 -i certificate.p12 -o certificate_base64.txt
base64 -i YourProfile.mobileprovision -o profile_base64.txt
```

### 步骤 2: 创建 App Store Connect API Key

```bash
# 1. 在 App Store Connect 创建 API Key（参考上文）
# 2. 下载 .p8 文件
# 3. 转换为 Base64
base64 -i AuthKey_KEYID.p8 -o apikey_base64.txt
```

### 步骤 3: 添加到 GitHub Secrets

1. 访问: `https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions`
2. 点击 **New repository secret**
3. 逐个添加上述所有 secrets

### 步骤 4: 验证配置

```bash
# 在本地验证证书和 profile
security find-identity -v -p codesigning

# 查看 provisioning profile 信息
security cms -D -i YourProfile.mobileprovision
```

---

## 📝 Secrets 检查清单

使用此清单确保所有必需的 secrets 都已配置：

- [ ] `IOS_CERTIFICATE_P12` - 证书 Base64
- [ ] `IOS_CERTIFICATE_PASSWORD` - 证书密码
- [ ] `CODE_SIGN_IDENTITY` - 签名身份
- [ ] `IOS_PROVISIONING_PROFILE` - Profile Base64
- [ ] `PROVISIONING_PROFILE_NAME` - Profile 名称
- [ ] `APPLE_TEAM_ID` - Team ID
- [ ] `APP_STORE_CONNECT_API_KEY_ID` - API Key ID
- [ ] `APP_STORE_CONNECT_ISSUER_ID` - Issuer ID
- [ ] `APP_STORE_CONNECT_API_KEY` - API Key Base64

---

## 🚀 触发构建

配置完成后，GitHub Actions 将在以下情况下自动触发：

### OC 版本 (`.github/workflows/oc-testflight.yml`)
- Push 到 `main` 分支且修改了 `OC/` 目录
- 对 `main` 分支的 Pull Request 修改了 `OC/` 目录
- 手动触发（Actions 页面 → 选择 workflow → Run workflow）

### Swift 版本 (`.github/workflows/swift-testflight.yml`)
- Push 到 `swift` 分支且修改了 `Swift/` 目录
- 对 `swift` 分支的 Pull Request 修改了 `Swift/` 目录
- 手动触发（Actions 页面 → 选择 workflow → Run workflow）

---

## 🐛 故障排查

### 问题 1: 证书验证失败

```
Error: Code signing is required
```

**解决方案**:
- 确认 `IOS_CERTIFICATE_P12` 是正确的 Base64 编码
- 确认 `IOS_CERTIFICATE_PASSWORD` 密码正确
- 确认证书未过期

### 问题 2: Provisioning Profile 不匹配

```
Error: No profiles for 'com.wodedata.PhotoDIY' were found
```

**解决方案**:
- 确认 Bundle ID 匹配
- 确认 Profile 类型为 App Store Distribution
- 确认 Profile 包含正确的证书
- 重新下载并转换 Profile

### 问题 3: TestFlight 上传失败

```
Error: Could not upload to TestFlight
```

**解决方案**:
- 确认 App Store Connect API Key 有效
- 确认 Issuer ID 和 Key ID 正确
- 确认 API Key 有 "App Manager" 或 "Admin" 权限
- 检查 App Store Connect 中应用状态

### 问题 4: CocoaPods 安装失败 (OC)

```
Error: pod install failed
```

**解决方案**:
- 确认 `Podfile.lock` 已提交到仓库
- 检查 pods 是否兼容当前 iOS 版本
- 查看详细日志确定具体错误

---

## 🔐 安全建议

1. **定期更新证书**: 在证书过期前续期
2. **限制 API Key 权限**: 仅授予必要的权限
3. **定期轮换 secrets**: 每 3-6 个月更新一次
4. **保护 .p12 和 .p8 文件**: 不要提交到代码仓库
5. **使用环境变量**: 不要在代码中硬编码敏感信息
6. **监控构建日志**: 确保没有泄露敏感信息

---

## 📚 相关文档

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Xcode Build Settings Reference](https://developer.apple.com/documentation/xcode/build-settings-reference)

---

**最后更新**: 2025-10-01
