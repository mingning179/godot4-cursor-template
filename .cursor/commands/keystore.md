# 签名管理命令

## 描述
帮助用户生成和管理 Android 签名文件，配置调试和发布版本的签名。

## 使用方式
在 AI 对话中输入：`/keystore`

## 功能
- 生成调试签名文件
- 生成发布签名文件
- 配置导出预设
- 验证签名文件
- 提供签名管理指导

## AI 交互流程
1. 检查当前签名配置状态
2. 生成或验证调试签名
3. 引导生成发布签名
4. 更新导出预设配置
5. 测试签名配置
6. 提供签名管理最佳实践

## 关键命令

### 生成调试签名
```bash
# 生成默认调试签名
keytool -genkey -v \
    -keystore android/keystore/debug.keystore \
    -alias androiddebugkey \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -storepass android \
    -keypass android \
    -dname "CN=Android Debug,O=Android,C=US"
```

### 生成发布签名
```bash
# 交互式生成发布签名
keytool -genkey -v \
    -keystore android/keystore/release.keystore \
    -alias release \
    -keyalg RSA \
    -keysize 2048 \
    -validity 36500 \
    -storepass YOUR_PASSWORD \
    -keypass YOUR_PASSWORD \
    -dname "CN=Your Name,O=Your Company,C=CN"
```

### 验证签名文件
```bash
# 列出签名文件内容
keytool -list -v -keystore android/keystore/debug.keystore -storepass android

# 检查签名文件完整性
keytool -list -keystore android/keystore/release.keystore
```

### 更新导出预设
```bash
# 更新 export_presets.cfg 中的签名配置
# 调试签名配置
keystore/debug="res://android/keystore/debug.keystore"
keystore/debug_user="androiddebugkey"
keystore/debug_password="android"

# 发布签名配置（需要用户提供）
keystore/release="res://android/keystore/release.keystore"
keystore/release_user="release"
keystore/release_password="YOUR_PASSWORD"
```

### 测试签名导出
```bash
# 测试调试版本导出
godot --headless --quit --export-debug "Android" builds/app_debug.apk

# 测试发布版本导出
godot --headless --quit --export-release "Android" builds/app_release.apk
```

## 预期结果
- 调试签名文件自动生成和配置
- 发布签名文件生成指导
- 导出预设正确配置签名信息
- 签名文件验证通过
- 提供完整的签名管理文档

## 签名文件结构
```
android/
└── keystore/
    ├── debug.keystore      # 调试签名（自动生成）
    └── release.keystore    # 发布签名（用户生成）
```

## 安全提醒
- 调试签名使用默认密码，仅用于开发测试
- 发布签名必须使用强密码
- 妥善保管签名文件和密码
- 不要将签名文件提交到版本控制
- 建议备份签名文件到安全位置

## 故障排除

### 签名文件不存在
```bash
# 重新生成调试签名
mkdir -p android/keystore
keytool -genkey -v -keystore android/keystore/debug.keystore -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 -storepass android -keypass android -dname "CN=Android Debug,O=Android,C=US"
```

### 密码错误
检查 `export_presets.cfg` 中的密码配置，确保与签名文件密码一致。

### 权限问题
```bash
chmod 600 android/keystore/*.keystore
```

## 最佳实践
1. 使用不同的签名文件用于调试和发布
2. 设置较长的有效期（建议100年）
3. 使用强密码保护发布签名
4. 定期备份签名文件
5. 在团队中安全共享签名信息
