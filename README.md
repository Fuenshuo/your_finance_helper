# 家庭资产记账应用 (Your Finance Flutter)

一个功能完整的跨平台家庭资产记账应用，支持Web、iOS、Android三端，采用Flutter开发。

## ✨ 核心功能

### 🏠 资产管理系统
- **五大资产分类**：流动资金、固定资产、投资理财、应收款、负债
- **分步式资产录入**：引导式添加流程，支持批量管理
- **资产总览仪表盘**：总资产、净资产、负债率实时计算
- **资产分布可视化**：饼图、柱状图展示资产构成
- **隐私保护**：金额隐藏/显示功能

### 💰 预算管理系统
- **信封预算(EnvelopeBudget)**：为特定类别设定支出限额
- **零基预算(ZeroBasedBudget)**：将收入分配到各个类别
- **预算管理界面**：创建、编辑、删除预算
- **预算详情页面**：显示预算使用情况和交易记录
- **预算状态管理**：活跃、暂停、完成状态
- **预算与交易集成**：自动关联交易到对应预算

### 📊 交易记录系统
- **交易管理界面**：总览、交易记录、草稿三个标签页
- **添加交易功能**：支持收入、支出、转账三种类型
- **交易详情页面**：完整的交易信息展示和编辑
- **交易列表管理**：搜索、筛选、按日期分组
- **草稿功能**：保存未完成的交易
- **多账户支持**：现金、银行、信用卡等账户类型
- **交易列表样式优化**：使用分类图标、分隔线，支持快速删除

### 🔄 差额式周期清账系统
- **周期对账**：支持自定义时间周期的定期对账
- **差额计算**：自动计算期初和期末余额的差额
- **差额分解**：手动添加重要交易来解释差额
- **自动归类**：剩余差额自动归类为"其他收入"或"其他支出"
- **财务总结**：生成周期性的财务报告，包括收支分析、分类统计
- **历史追溯**：完整的清账历史记录，支持查看和删除未完成的清账
- **数据集成**：清账完成后自动将交易转换为实际交易记录

## 🛠 技术架构

### 核心技术栈
- **框架**：Flutter 3.x
- **状态管理**：Provider模式 + Riverpod（部分功能）
- **本地存储**：SharedPreferences + Drift（SQLite）
- **图表库**：fl_chart + Syncfusion Flutter Charts
- **UI设计**：Material Design 3
- **图标库**：Material Icons + Cupertino Icons

### 项目结构
```
lib/
├── models/          # 数据模型
├── providers/       # 状态管理
├── screens/         # 页面界面
├── widgets/         # 可复用组件
├── services/        # 业务逻辑服务
└── theme/           # 主题和样式
```

### 设计系统
- **色彩规范**：基于Material Design 3的柔和配色
- **布局规范**：8pt间距系统，12pt圆角半径
- **动效系统**：统一的页面转场和微交互动效
- **组件库**：AppCard、AppAnimations等自定义组件

## 🚀 快速开始

### 环境要求
- Flutter SDK 3.x
- Dart SDK 3.x
- Android Studio / Xcode (移动端开发)
- Chrome (Web端开发)

### 安装步骤

1. **克隆项目**
```bash
git clone https://github.com/Fuenshuo/your_finance_helper.git
cd your_finance_helper
```

2. **安装依赖**
```bash
flutter pub get
```

3. **运行应用**
```bash
# Web端
flutter run -d chrome

# iOS模拟器
flutter run -d ios

# Android设备
flutter run -d android
```

### 构建发布版本

```bash
# Web版本
flutter build web --release

# iOS版本
flutter build ios --release --no-codesign

# Android版本
flutter build apk --release
```

## 📱 平台支持

- ✅ **Web端**：完全支持，可直接在浏览器中运行
- ✅ **iOS端**：支持iOS 12+，可在模拟器和真机上运行
- ⚠️ **Android端**：支持Android 5.0+，建议使用Android Studio构建

## 🔧 开发工具

### 代码质量
- **静态分析**：very_good_analysis
- **代码格式化**：dart format
- **预提交检查**：scripts/check_code.sh

### 调试功能
- **数据导出**：JSON格式导出所有数据
- **数据导入**：从剪贴板导入数据
- **测试数据生成**：一键生成示例数据
- **数据清空**：清除所有本地数据
- **历史清账数据处理**：将已完成清账的交易转换为实际交易记录
- **强制数据迁移**：重新执行数据迁移流程

## 📋 功能特性

### 已实现功能
- [x] 资产管理系统（100%完成）
- [x] 预算管理系统（100%完成）
- [x] 交易记录系统（100%完成）
- [x] 差额式周期清账系统（100%完成）
- [x] 多账户管理
- [x] 数据导入导出
- [x] 响应式UI设计
- [x] 深色模式支持
- [x] 标准图标库支持（Material Icons）

### 计划功能
- [ ] 多币种支持
- [ ] 自动化记账（OCR识别）
- [ ] 银行同步
- [ ] 数据云同步
- [ ] 无限账户（付费功能）

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 📞 联系方式

- 项目链接：[https://github.com/Fuenshuo/your_finance_helper](https://github.com/Fuenshuo/your_finance_helper)
- 问题反馈：[Issues](https://github.com/Fuenshuo/your_finance_helper/issues)

---

**注意**：这是一个个人财务管理应用，请确保在安全的环境中使用，并定期备份重要数据。
