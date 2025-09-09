#!/bin/bash

# Flutter代码质量检查脚本
# 使用方法: ./scripts/check_code.sh

echo "🔍 开始Flutter代码质量检查..."

# 检查Flutter环境
echo "📋 检查Flutter环境..."
flutter doctor

# 获取依赖
echo "📦 获取依赖..."
flutter pub get

# 代码格式化
echo "🎨 格式化代码..."
flutter format .

# 静态代码分析
echo "🔍 运行静态代码分析..."
flutter analyze

# 运行测试
echo "🧪 运行测试..."
flutter test

# 检查代码覆盖率
echo "📊 检查代码覆盖率..."
flutter test --coverage

echo "✅ 代码质量检查完成！"
