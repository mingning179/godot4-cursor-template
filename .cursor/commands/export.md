# 导出 Android APK

## 描述
帮助用户导出 Android APK，处理构建过程中的各种问题，包括签名配置。

## 使用方式
在 AI 对话中输入：`/export`

## 功能
- 检查导出环境
- 自动安装构建模板
- 配置签名文件
- 执行 APK 导出
- 解决导出问题
- 提供安装和测试指导

## AI 交互流程
1. 检查项目配置状态
2. 检查 Android 环境（Java、Godot）
3. 检查导出预设配置
4. 检查签名文件配置
5. 自动安装 Android 构建模板
6. 执行 APK 导出过程
7. 分析导出结果
8. 提供安装和测试命令
9. 解决可能的问题

## 关键命令
### 环境检查
```bash
# 检查 Java 版本
java -version

# 检查 Godot 版本
godot --version

# 检查项目配置
cat project.godot
cat export_presets.cfg
```

### 签名配置检查
```bash
# 检查签名文件是否存在
ls -la android/keystore/

# 验证调试签名
keytool -list -v -keystore android/keystore/debug.keystore -storepass android

# 检查导出预设中的签名配置
grep -A 10 "keystore" export_presets.cfg
```

### 导出命令
```bash
# 自动安装模板并导出 Debug APK（使用调试签名）
godot --headless --quit --export-debug "Android" builds/app_debug.apk --install-android-build-template

# 导出 Release APK（使用发布签名）
godot --headless --quit --export-release "Android" builds/app_release.apk --install-android-build-template
```

### 安装和测试
```bash
# 使用 ADB 安装
adb install builds/app_debug.apk

# 启动应用
adb shell am start -n com.example.game/com.godot.game.GodotApp

# 强制重新安装
adb install -r builds/app_debug.apk
```

## 签名配置

### 调试签名（自动配置）
- 文件：`android/keystore/debug.keystore`
- 别名：`androiddebugkey`
- 密码：`android`
- 用途：开发和测试

### 发布签名（需要配置）
- 文件：`android/keystore/release.keystore`
- 别名：`release`
- 密码：用户自定义
- 用途：正式发布

### 生成发布签名
```bash
# 使用签名管理命令
/keystore

# 或手动生成
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

## 预期结果
- APK 文件成功生成（通常 100-200MB）
- Android 构建模板自动安装到 `android/` 目录
- 签名文件正确配置
- 提供完整的安装和测试指导
- 问题解决方案（如有）

## 注意事项
- 首次导出会自动下载并安装 Android 构建模板
- Debug APK 使用调试签名，可直接安装测试
- Release APK 需要配置发布签名才能安装
- 确保 Android 设备支持 ARM64 或 ARMv7 架构
- 签名文件丢失将无法更新应用

## 相关命令
- `/keystore` - 签名文件管理
- `/config` - 项目配置管理
