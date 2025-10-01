# GitHub Actions Secrets 配置指南

本文档说明如何为 PhotoDIY 项目配置 GitHub Actions CI/CD 所需的 Secrets。

## ✨ 简化配置说明

本配置使用 **Xcode 自动管理签名（Automatic Signing）** 方式，仅需配置 **App Store Connect API Key**，无需手动管理证书和描述文件。

## 📋 必需的 Secrets（仅 3 个！）

在 GitHub 仓库的 **Settings → Secrets and variables → Actions** 中添加以下 secrets：

### App Store Connect API Key

需要创建 App Store Connect API Key 用于自动签名、构建和上传到 TestFlight。

#### 创建 API Key 步骤：

1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 进入 **Users and Access → Keys → App Store Connect API**
3. 点击 **Generate API Key** 或使用现有的 Key
4. 设置 Key 名称（如 "GitHub Actions CI/CD"）
5. 选择访问权限:
   - **推荐**: App Manager（可管理应用和 TestFlight）
   - **或**: Admin（完整权限）
6. 点击 **Generate**
7. **重要**: 立即下载 `.p8` 文件（只能下载一次，请妥善保管！）
8. 记录 **Key ID** 和 **Issuer ID**（显示在页面上）

### 配置的 3 个 Secrets

#### 1️⃣ `APP_STORE_CONNECT_API_KEY_ID`
- **描述**: App Store Connect API Key ID
- **示例**: `"AB12CD34EF"`
- **获取**: App Store Connect → Keys 页面显示的 Key ID（10 个字符）

#### 2️⃣ `APP_STORE_CONNECT_ISSUER_ID`
- **描述**: App Store Connect Issuer ID
- **示例**: `"12345678-1234-1234-1234-123456789012"`
- **获取**: App Store Connect → Keys 页面顶部的 Issuer ID（UUID 格式）

#### 3️⃣ `APP_STORE_CONNECT_API_KEY`
- **描述**: API Key 文件 (.p8) 的 Base64 编码内容
- **获取**:
  ```bash
  # 将下载的 .p8 文件转换为 Base64
  base64 -i AuthKey_YOUR_KEY_ID.p8 | pbcopy
  # 内容已复制到剪贴板，直接粘贴到 GitHub Secret
  ```

---

## 🔧 快速配置步骤

### 步骤 1: 创建 App Store Connect API Key

在 App Store Connect 创建 API Key 并下载 `.p8` 文件（参考上文步骤）。

### 步骤 2: 准备 API Key Base64

```bash
# 转换 API Key 为 Base64
base64 -i AuthKey_YOUR_KEY_ID.p8 | pbcopy
```

内容自动复制到剪贴板。

### 步骤 3: 添加到 GitHub Secrets

1. 访问 GitHub 仓库设置:
   ```
   https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions
   ```

2. 点击 **New repository secret**

3. 添加以下 3 个 secrets:

   | Name | Value |
   |------|-------|
   | `APP_STORE_CONNECT_API_KEY_ID` | 你的 Key ID（如 `AB12CD34EF`） |
   | `APP_STORE_CONNECT_ISSUER_ID` | 你的 Issuer ID（UUID 格式） |
   | `APP_STORE_CONNECT_API_KEY` | 粘贴 Base64 编码的 .p8 内容 |

### 步骤 4: 完成 ✅

配置完成！GitHub Actions 将自动使用这些凭证进行构建和部署。

---

## 📝 Secrets 检查清单

使用此清单确保所有必需的 secrets 都已配置：

- [ ] `APP_STORE_CONNECT_API_KEY_ID` - API Key ID（10 字符）
- [ ] `APP_STORE_CONNECT_ISSUER_ID` - Issuer ID（UUID 格式）
- [ ] `APP_STORE_CONNECT_API_KEY` - API Key 文件 Base64 编码

**仅需 3 个 Secrets！** ✨

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

### 问题 1: API Key 认证失败

```
Error: Authentication credentials are missing or invalid
```

**解决方案**:
- 确认 `APP_STORE_CONNECT_API_KEY` 是正确的 Base64 编码
- 确认 Base64 编码时没有额外的空格或换行
- 重新转换并复制 API Key:
  ```bash
  base64 -i AuthKey_KEYID.p8 | tr -d '\n' | pbcopy
  ```
- 确认 Key ID 和 Issuer ID 正确无误

### 问题 2: 自动签名失败

```
Error: No signing certificate "iOS Distribution" found
```

**解决方案**:
- 确认 App Store Connect API Key 有足够权限（App Manager 或 Admin）
- 在 Xcode 中启用 "Automatically manage signing"
- 确认 Bundle ID 在 App Store Connect 中已注册
- 检查 Apple Developer Program 会员资格是否有效

### 问题 3: Provisioning Profile 下载失败

```
Error: Unable to download matching provisioning profiles
```

**解决方案**:
- 确认 API Key 权限正确
- 在 Apple Developer Portal 手动创建 App Store Distribution Profile
- 确认设备和证书都添加到 Profile 中
- 等待几分钟后重试（Apple 服务器同步延迟）

### 问题 4: TestFlight 上传失败

```
Error: Could not upload to TestFlight
```

**解决方案**:
- 确认应用在 App Store Connect 中已创建
- 确认 Bundle ID 匹配
- 确认版本号和构建号未重复
- 检查 API Key 是否过期或被撤销

### 问题 5: CocoaPods 安装失败 (OC)

```
Error: pod install failed
```

**解决方案**:
- 确认 `Podfile.lock` 已提交到仓库
- 检查 pods 是否兼容当前 iOS 版本
- 清除缓存重试:
  ```bash
  pod cache clean --all
  pod install --repo-update
  ```

---

## 🔐 安全建议

1. **保护 API Key 文件**:
   - 不要将 `.p8` 文件提交到代码仓库
   - 存储在安全的位置（如密码管理器）
   - 只能下载一次，请妥善备份

2. **限制 API Key 权限**:
   - 优先使用 "App Manager" 而非 "Admin"
   - 仅授予 CI/CD 所需的最小权限

3. **定期轮换 API Keys**:
   - 建议每 6-12 个月轮换一次
   - 撤销不再使用的旧 Key

4. **监控使用情况**:
   - 在 App Store Connect 中查看 API Key 使用记录
   - 发现异常立即撤销 Key

5. **GitHub Secrets 安全**:
   - 不要在日志中打印 secrets
   - 限制仓库访问权限
   - 启用双因素认证

6. **审计构建日志**:
   - 定期检查 GitHub Actions 日志
   - 确保没有泄露敏感信息
   - 使用私有仓库存储敏感项目

---

## 📚 相关文档

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Xcode Build Settings Reference](https://developer.apple.com/documentation/xcode/build-settings-reference)

---

**最后更新**: 2025-10-01
