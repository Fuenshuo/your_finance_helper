# 家庭资产记账应用 (Your Finance Helper)

一个跨平台的家庭资产记账应用，帮助用户全面管理家庭财务状况。

## 📱 功能特性

### 核心功能
- **资产分类管理**: 支持五大类资产分类（流动资金、固定资产、投资理财、应收款、负债）
- **分步式引导**: 直观的资产添加流程，降低使用门槛
- **实时统计**: 自动计算总资产、净资产、负债率等关键指标
- **数据可视化**: 资产分布图表，直观展示财务状况
- **隐私保护**: 支持金额隐藏功能，保护用户隐私

### 技术特性
- **跨平台支持**: 基于Flutter开发，支持iOS、Android、Web三端
- **本地存储**: 使用SharedPreferences进行数据持久化
- **响应式设计**: 适配不同屏幕尺寸
- **现代化UI**: 遵循Material Design 3设计规范

## 🎨 设计系统

### 色彩规范
- **主背景色**: 淡雅灰 (#F7F7FA)
- **主题色**: 活力蓝 (#007AFF)
- **辅助色**: 温柔紫 (#EAEAFB)
- **文字色**: 深邃灰 (#1C1C1E)

### 字体规范
- **字体家族**: Inter (优先) / 系统默认字体
- **大标题**: 34pt, SemiBold
- **页面标题**: 28pt, Bold
- **卡片标题**: 17pt, SemiBold

## 🚀 快速开始

### 环境要求
- Flutter 3.24.0+
- Dart 3.5.0+
- iOS 12.0+ / Android API 21+ / 现代浏览器

### 安装步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/Fuenshuo/your_finance_helper.git
   cd your_finance_helper
   ```

2. **安装依赖**
   ```bash
   cd your_finance_flutter
   flutter pub get
   ```

3. **运行应用**
   ```bash
   # Web版本
   flutter run -d chrome
   
   # iOS版本 (需要Xcode)
   flutter run -d ios
   
   # Android版本 (需要Android Studio)
   flutter run -d android
   ```

## 📁 项目结构

```
your_finance/
├── .doc/                          # 项目文档
│   ├── 家庭资产记账应用 - 产品需求文档 (PRD).md
│   ├── 家庭资产记账应用 - iOS本地版技术实现方案.md
│   └── 家庭资产记账应用 - UI_UX设计及动效方案.md
├── your_finance_flutter/          # Flutter项目
│   ├── lib/
│   │   ├── models/               # 数据模型
│   │   ├── providers/            # 状态管理
│   │   ├── screens/              # 页面组件
│   │   ├── widgets/              # 通用组件
│   │   ├── theme/                # 主题配置
│   │   └── services/             # 服务层
│   ├── pubspec.yaml              # 依赖配置
│   └── README.md                 # Flutter项目说明
└── README.md                     # 项目总览
```

## 🛠 技术栈

### 前端
- **框架**: Flutter 3.24.0
- **语言**: Dart 3.5.0
- **状态管理**: Provider
- **本地存储**: SharedPreferences
- **图表库**: fl_chart
- **工具库**: uuid, intl

### 设计
- **UI框架**: Material Design 3
- **字体**: Inter
- **图标**: Material Icons
- **动效**: Flutter Animation

## 📋 开发计划

### 已完成 ✅
- [x] 基础项目架构
- [x] 数据模型设计
- [x] 核心功能实现
- [x] UI/UX设计系统
- [x] 跨平台适配

### 进行中 🚧
- [ ] 数据导入导出
- [ ] 多语言支持
- [ ] 深色模式

### 计划中 📅
- [ ] 云端同步
- [ ] 数据备份
- [ ] 高级图表分析
- [ ] 预算管理功能

## 🤝 贡献指南

欢迎提交Issue和Pull Request来帮助改进项目！

### 开发规范
1. 遵循Dart代码规范
2. 使用有意义的提交信息
3. 添加必要的注释和文档
4. 确保代码通过所有测试

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 联系方式

- 项目地址: [https://github.com/Fuenshuo/your_finance_helper](https://github.com/Fuenshuo/your_finance_helper)
- 问题反馈: [Issues](https://github.com/Fuenshuo/your_finance_helper/issues)

---

**注意**: 这是一个个人财务管理工具，所有数据均存储在本地设备上，请妥善保管您的设备。