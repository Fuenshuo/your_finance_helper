# 测试图片目录

## 用途

此目录用于存放测试发票识别功能的测试图片。

## 使用方法

### 方法1：手动添加图片

1. 将测试图片（JPG、PNG格式）放入此目录
2. 运行脚本添加到模拟器：
   ```bash
   # iOS模拟器
   ./scripts/add_test_images_ios.sh
   
   # Android模拟器
   ./scripts/add_test_images_android.sh
   ```

### 方法2：直接拖拽到模拟器

**iOS模拟器**：
1. 启动iOS模拟器
2. 打开"照片"应用
3. 从Finder直接拖拽图片到模拟器窗口

**Android模拟器**：
1. 启动Android模拟器
2. 打开"文件管理器"或"照片"应用
3. 从电脑直接拖拽图片到模拟器窗口

## 推荐测试图片

### 发票类型
- `invoice_starbucks.jpg` - 星巴克小票（清晰、标准格式）
- `invoice_supermarket.jpg` - 超市购物小票（多商品）
- `invoice_restaurant.jpg` - 餐厅发票（含税信息）
- `receipt_transport.jpg` - 交通票据（简单格式）

### 图片要求
- 格式：JPG、PNG、JPEG
- 大小：建议 < 5MB
- 清晰度：清晰可读
- 内容：包含商家名称、金额、日期等信息

## 注意事项

1. **不要提交大文件到Git**：如果图片文件较大，建议使用Git LFS或添加到`.gitignore`
2. **保护隐私**：测试图片中不要包含真实的个人信息
3. **文件命名**：使用有意义的文件名，便于识别

## Git忽略规则

如果图片文件较大，可以在`.gitignore`中添加：

```
# 测试图片（如果文件较大）
test_images/*.jpg
test_images/*.png
!test_images/README.md
```

