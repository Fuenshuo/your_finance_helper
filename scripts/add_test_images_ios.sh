#!/bin/bash

# iOS模拟器图片添加脚本
# 使用方法: ./scripts/add_test_images_ios.sh

echo "🔍 查找正在运行的iOS模拟器..."

SIMULATOR_ID=$(xcrun simctl list devices | grep "Booted" | head -1 | grep -o '[0-9A-F]\{8\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{12\}')

if [ -z "$SIMULATOR_ID" ]; then
    echo "❌ 没有找到正在运行的iOS模拟器"
    echo "💡 请先启动iOS模拟器，然后重试"
    exit 1
fi

echo "✅ 找到模拟器: $SIMULATOR_ID"

DCIM_PATH="$HOME/Library/Developer/CoreSimulator/Devices/$SIMULATOR_ID/data/Media/DCIM"

# 创建DCIM目录（如果不存在）
mkdir -p "$DCIM_PATH/100APPLE"

# 检查测试图片目录
if [ ! -d "test_images" ]; then
    echo "⚠️ 未找到test_images目录"
    echo "💡 请在项目根目录创建test_images文件夹，并放入测试图片"
    exit 1
fi

# 复制测试图片
COUNT=0
for img in test_images/*.{jpg,jpeg,png,JPG,JPEG,PNG} 2>/dev/null; do
    if [ -f "$img" ]; then
        cp "$img" "$DCIM_PATH/100APPLE/"
        echo "  ✅ 已添加: $(basename "$img")"
        COUNT=$((COUNT + 1))
    fi
done

if [ $COUNT -eq 0 ]; then
    echo "⚠️ 未找到任何图片文件"
    echo "💡 请确保test_images目录中有.jpg、.jpeg或.png格式的图片"
else
    echo "✅ 成功添加 $COUNT 张图片到iOS模拟器相册"
    echo "💡 请重启模拟器的'照片'应用以查看新添加的图片"
fi

