# Godot 4 项目模板

## 🎯 模板概述

这是一个基于 Git 分支管理的 Godot 4 项目模板，使用 Cursor Commands 实现自动化流程。

## 🏗️ 模板架构

### Git 分支管理
- `main` 分支：用于实际项目开发
- `template` 分支：存储模板文件和命令

### Cursor Commands
模板提供了以下自动化命令：

- `/init` - 初始化项目结构
- `/config` - 配置项目信息
- `/check` - 检查项目语法
- `/export` - 导出 APK

## 🚀 快速开始

### 1. 获取模板
```bash
# 克隆模板仓库
git clone <template-repo-url> my-project
cd my-project

# 切换到模板分支
git checkout template
```

### 2. 初始化项目
在 AI 对话中使用命令：
```
/init
```

### 3. 配置项目
在 AI 对话中使用命令：
```
/config "我的游戏" "com.mycompany.mygame"
```

### 4. 开始开发
```bash
# 切换到主分支开始开发
git checkout main
git add .
git commit -m "Initial project setup"

# 打开 Godot 编辑器
godot --path .
```

### 5. 导出 APK
在 AI 对话中使用命令：
```
/check
/export debug
/export release
```

## 📁 项目结构

```
my-project/
├── .cursor/
│   ├── commands/          # Cursor 命令
│   │   ├── init.md
│   │   ├── config.md
│   │   ├── check.md
│   │   └── export.md
│   └── rules/
│       └── base.mdc      # 开发规则
├── scenes/               # 场景文件
├── scripts/              # GDScript 脚本
├── assets/               # 资源文件
│   ├── materials/        # 材质资源
│   ├── textures/         # 纹理资源
│   └── sounds/           # 音频资源
├── autoload/             # 全局单例
├── builds/               # 构建输出
├── export_presets.cfg    # 导出预设
├── project.godot         # 项目配置
└── README.md             # 项目说明
```

## 🔧 命令详解

### /init
初始化项目结构，创建必要的目录和基础文件。

**功能：**
- 创建项目目录结构
- 生成基础主场景
- 创建基础脚本文件
- 更新项目配置

### /config
配置项目的基本信息。

**用法：**
在 AI 对话中输入：
```
/config "项目名称" "包名"
```

**示例：**
```
/config "我的游戏" "com.mycompany.mygame"
```

### /check
检查项目的语法错误和警告。

**功能：**
- 运行 Godot 语法检查
- 显示检查结果
- 提供修复建议

### /export
导出 APK 文件（支持 Android）。

**用法：**
在 AI 对话中输入：
```
/export [debug|release]
```

**功能：**
- 安装 Android 构建模板
- 导出 APK 文件
- 提供安装和启动命令

## 📋 开发流程

1. **初始化** - 使用 `/init` 创建项目结构
2. **配置** - 使用 `/config` 设置项目信息
3. **开发** - 在 `main` 分支进行开发
4. **检查** - 使用 `/check` 验证代码
5. **导出** - 使用 `/export` 生成 APK

## 🎮 游戏开发

### 基础场景
模板提供了基础的主场景，包含：
- 3D 环境设置
- 相机配置
- 基础光照
- UI 框架

### 脚本结构
遵循 Godot 4 最佳实践：
- 类型注解
- 信号通信
- 错误处理
- 资源管理

## 📱 Android 导出

### 环境要求
- Godot 4.5.1+
- Android Studio (SDK/NDK)
- Android 导出模板

### 导出流程
1. 配置 Android SDK 路径
2. 安装导出模板
3. 在 AI 对话中运行 `/export` 命令

### 安装测试
```bash
# 安装 APK
adb install -r builds/app_debug.apk

# 启动应用
adb shell monkey -p <包名> -c android.intent.category.LAUNCHER 1
```

## 🔄 模板更新

### 更新模板
```bash
# 切换到模板分支
git checkout template

# 拉取最新模板
git pull origin template

# 切换回主分支
git checkout main
```

### 自定义命令
可以在 `.cursor/commands/` 目录中添加自定义命令。

## 📚 参考资源

- [Godot 4 官方文档](https://docs.godotengine.org/)
- [Cursor Commands 文档](https://cursor.com/cn/docs/agent/chat/commands)
- [Android 开发指南](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)