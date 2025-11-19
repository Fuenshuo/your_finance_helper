#!/bin/bash

# Android模拟器图片添加脚本
# 使用方法: ./scripts/add_test_images_android.sh

echo "🔍 检查Android设备连接..."

# 检查adb是否可用
if ! command -v adb &> /dev/null; then
    echo "❌ adb未找到"
    echo "💡 请确保Android SDK已安装，并将adb添加到PATH"
    exit 1
fi

# 检查设备是否连接
DEVICE_COUNT=$(adb devices | grep -c "device$")
if [ $DEVICE_COUNT -eq 0 ]; then
    echo "❌ 没有找到Android设备或模拟器"
    echo "💡 请确保Android模拟器正在运行"
    exit 1
fi

echo "✅ 找到 $DEVICE_COUNT 个设备"

# 创建Pictures目录（如果不存在）
adb shell mkdir -p /sdcard/Pictures 2>/dev/null

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
        adb push "$img" /sdcard/Pictures/ 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "  ✅ 已添加: $(basename "$img")"
            COUNT=$((COUNT + 1))
        else
            echo "  ❌ 添加失败: $(basename "$img")"
        fi
    fi
done

if [ $COUNT -eq 0 ]; then
    echo "⚠️ 未找到任何图片文件"
    echo "💡 请确保test_images目录中有.jpg、.jpeg或.png格式的图片"
else
    echo "✅ 成功添加 $COUNT 张图片到Android模拟器相册"
    echo "💡 请重启模拟器的'照片'或'图库'应用以查看新添加的图片"
fi

