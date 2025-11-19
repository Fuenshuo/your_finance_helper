# 模拟器图片测试指南

## 概述

在调试发票识别功能时，需要将测试图片添加到模拟器的相册中，以便测试图片选择功能。

## iOS模拟器

### 方法1：通过模拟器相册添加（推荐）

**步骤**：
1. 启动iOS模拟器
2. 打开 **Safari浏览器**
3. 在地址栏输入图片URL（可以是本地文件路径或网络图片）
4. 长按图片，选择 **"保存到照片"**
5. 图片会自动保存到模拟器的相册中

### 方法2：通过Xcode设备管理器

**步骤**：
1. 打开 **Xcode**
2. 菜单栏：**Window** → **Devices and Simulators**
3. 选择你的模拟器
4. 点击 **"Open Media Library"** 或 **"Add Media"**
5. 选择本地图片文件
6. 图片会自动添加到模拟器相册

### 方法3：通过模拟器文件系统（高级）

**iOS模拟器相册路径**：
```
~/Library/Developer/CoreSimulator/Devices/[设备ID]/data/Media/DCIM/[随机文件夹]/
```

**操作步骤**：
1. 找到模拟器的设备ID：
   ```bash
   xcrun simctl list devices
   ```
2. 将图片复制到DCIM目录下的任意文件夹
3. 重启模拟器或重启"照片"应用

### 方法4：通过拖拽（最简单）

**步骤**：
1. 启动iOS模拟器
2. 打开 **照片** 应用
3. 从Mac Finder直接拖拽图片到模拟器窗口
4. 图片会自动添加到相册

---

## Android模拟器

### 方法1：通过Device File Explorer（推荐）

**步骤**：
1. 启动Android模拟器
2. 打开 **Android Studio**
3. 菜单栏：**View** → **Tool Windows** → **Device File Explorer**
4. 导航到 `/sdcard/Pictures/` 或 `/sdcard/DCIM/Camera/`
5. 右键点击目录，选择 **Upload**
6. 选择本地图片文件上传
7. 图片会自动出现在模拟器的相册中

### 方法2：通过adb命令（命令行）

**步骤**：
1. 确保模拟器正在运行
2. 使用adb push命令：
   ```bash
   adb push /path/to/your/image.jpg /sdcard/Pictures/
   ```
3. 或者推送到DCIM目录：
   ```bash
   adb push /path/to/your/image.jpg /sdcard/DCIM/Camera/
   ```
4. 重启模拟器的"照片"应用或重启模拟器

### 方法3：通过模拟器设置

**步骤**：
1. 打开模拟器的 **设置**
2. 进入 **存储** 或 **Storage**
3. 使用文件管理器功能
4. 将图片文件复制到 `/sdcard/Pictures/` 目录

### 方法4：通过拖拽（Android 11+）

**步骤**：
1. 启动Android模拟器
2. 打开 **文件管理器** 或 **照片** 应用
3. 从电脑直接拖拽图片到模拟器窗口
4. 图片会自动保存到相册

---

## 快速测试脚本

### iOS模拟器测试脚本

创建 `scripts/add_test_images_ios.sh`：

```bash
#!/bin/bash

# iOS模拟器图片添加脚本
SIMULATOR_ID=$(xcrun simctl list devices | grep "Booted" | head -1 | grep -o '[0-9A-F]\{8\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{12\}')

if [ -z "$SIMULATOR_ID" ]; then
    echo "❌ 没有找到正在运行的模拟器"
    exit 1
fi

DCIM_PATH="$HOME/Library/Developer/CoreSimulator/Devices/$SIMULATOR_ID/data/Media/DCIM"

# 创建DCIM目录（如果不存在）
mkdir -p "$DCIM_PATH/100APPLE"

# 复制测试图片
if [ -d "test_images" ]; then
    cp test_images/*.jpg "$DCIM_PATH/100APPLE/" 2>/dev/null
    cp test_images/*.png "$DCIM_PATH/100APPLE/" 2>/dev/null
    echo "✅ 图片已添加到iOS模拟器相册"
else
    echo "⚠️ 未找到test_images目录"
fi
```

### Android模拟器测试脚本

创建 `scripts/add_test_images_android.sh`：

```bash
#!/bin/bash

# Android模拟器图片添加脚本

# 检查adb是否可用
if ! command -v adb &> /dev/null; then
    echo "❌ adb未找到，请确保Android SDK已安装"
    exit 1
fi

# 检查设备是否连接
if ! adb devices | grep -q "device$"; then
    echo "❌ 没有找到Android设备或模拟器"
    exit 1
fi

# 创建Pictures目录（如果不存在）
adb shell mkdir -p /sdcard/Pictures

# 复制测试图片
if [ -d "test_images" ]; then
    for img in test_images/*.{jpg,jpeg,png}; do
        if [ -f "$img" ]; then
            adb push "$img" /sdcard/Pictures/
        fi
    done
    echo "✅ 图片已添加到Android模拟器相册"
else
    echo "⚠️ 未找到test_images目录"
fi
```

---

## 测试图片目录结构

建议在项目根目录创建测试图片目录：

```
your_finance/
├── test_images/              # 测试图片目录
│   ├── invoice_starbucks.jpg      # 星巴克小票
│   ├── invoice_supermarket.jpg    # 超市购物小票
│   ├── receipt_restaurant.jpg     # 餐厅发票
│   └── receipt_transport.jpg      # 交通票据
├── scripts/
│   ├── add_test_images_ios.sh
│   └── add_test_images_android.sh
└── ...
```

---

## 权限配置

### iOS权限

在 `ios/Runner/Info.plist` 中添加：

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问相册以选择发票图片</string>
<key>NSCameraUsageDescription</key>
<string>需要访问相机以拍摄发票照片</string>
```

### Android权限

在 `android/app/src/main/AndroidManifest.xml` 中添加：

```xml
<!-- Android 10 (API 29) 及以下 -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>

<!-- Android 13 (API 33) 及以上 -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

---

## 验证图片是否添加成功

### iOS模拟器

1. 打开模拟器的 **照片** 应用
2. 查看 **所有照片**
3. 确认测试图片已显示

### Android模拟器

1. 打开模拟器的 **照片** 或 **图库** 应用
2. 查看所有图片
3. 确认测试图片已显示

---

## 常见问题

### 问题1：iOS模拟器找不到图片

**解决方案**：
- 使用拖拽方法（最简单）
- 或者重启模拟器
- 或者重启"照片"应用

### 问题2：Android模拟器权限被拒绝

**解决方案**：
1. 检查 `AndroidManifest.xml` 中的权限配置
2. 在应用运行时请求权限
3. 在模拟器设置中手动授予权限

### 问题3：图片格式不支持

**解决方案**：
- 确保图片格式为 JPG、PNG、JPEG
- 检查图片文件是否损坏
- 尝试使用不同的图片文件

---

## 推荐工作流程

### 开发阶段

1. **准备测试图片**：
   - 在项目根目录创建 `test_images/` 文件夹
   - 添加各种格式的测试图片（发票、收据等）

2. **添加到模拟器**：
   - iOS：使用拖拽方法（最快）
   - Android：使用Device File Explorer

3. **测试功能**：
   - 打开应用的发票识别功能
   - 选择"相册选择"
   - 选择测试图片
   - 验证识别结果

### 自动化测试

1. **创建测试脚本**：
   - 使用上面的shell脚本自动添加图片
   - 集成到CI/CD流程中

2. **测试数据管理**：
   - 将测试图片纳入版本控制（如果文件不大）
   - 或使用Git LFS管理大文件

---

## 快速命令参考

### iOS模拟器

```bash
# 列出所有模拟器
xcrun simctl list devices

# 查看模拟器文件系统
open ~/Library/Developer/CoreSimulator/Devices/
```

### Android模拟器

```bash
# 列出所有设备
adb devices

# 推送图片到模拟器
adb push test_images/invoice.jpg /sdcard/Pictures/

# 查看模拟器文件
adb shell ls /sdcard/Pictures/

# 打开文件管理器
adb shell am start -a android.intent.action.VIEW -d file:///sdcard/Pictures/
```

---

**文档版本**：v1.0  
**创建时间**：2025-01-13  
**维护者**：开发团队

