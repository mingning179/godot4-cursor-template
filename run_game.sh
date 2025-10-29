#!/bin/bash
# 跳一跳游戏启动脚本

echo "🎮 启动跳一跳游戏..."
cd "$(dirname "$0")"
godot . --verbose --debug

