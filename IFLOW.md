# iFlow Context: 家庭资产记账应用 (Your Finance Flutter)

## 项目概述

这是一个功能完整的跨平台家庭资产记账应用，采用Flutter框架开发，支持Web、iOS、Android三端。项目专注于家庭财务管理，提供资产追踪、预算管理、交易记录等核心功能。

### 核心技术栈
- **框架**: Flutter 3.x + Dart 3.x
- **状态管理**: Provider模式
- **本地存储**: SharedPreferences
- **图表库**: fl_chart, syncfusion_flutter_charts
- **UI设计**: Material Design 3
- **代码质量**: very_good_analysis

### 主要功能模块
1. **资产管理系统** - 五大资产分类管理（流动资金、固定资产、投资理财、应收款、负债）
2. **预算管理系统** - 信封预算、零基预算、分类预算
3. **交易记录系统** - 收入、支出、转账记录管理
4. **工资与奖金管理** - 薪资收入、季度奖金、年终奖等
5. **多账户支持** - 现金、银行、信用卡等账户类型

## 项目结构

```
lib/
├── core/                    # 核心功能
│   ├── models/             # 数据模型（AssetItem, Budget, Transaction等）
│   ├── providers/          # 状态管理（Provider模式）
│   ├── services/           # 业务逻辑服务
│   ├── theme/              # 主题和样式
│   └── utils/              # 工具类
├── features/               # 功能模块
│   ├── family_info/        # 家庭信息管理（工资、奖金等）
│   └── transaction_flow/   # 交易流程管理
├── screens/                # 主要页面
└── widgets/               # 可复用组件
```

## 开发环境配置

### 环境要求
- Flutter SDK 3.x
- Dart SDK 3.x
- Android Studio / Xcode (移动端开发)
- Chrome (Web端开发)

### 快速开始
```bash
# 安装依赖
flutter pub get

# 运行应用
flutter run -d chrome        # Web端
flutter run -d ios           # iOS模拟器
flutter run -d android       # Android设备
```

### 构建发布
```bash
flutter build web --release    # Web版本
flutter build ios --release    # iOS版本
flutter build apk --release    # Android版本
```

## 代码质量与规范

### 代码检查
项目使用严格的代码质量工具：
- **静态分析**: `flutter analyze`
- **代码格式化**: `dart format`
- **代码质量**: very_good_analysis规则集
- **预提交检查**: `./scripts/check_code.sh`

### 开发规范
- 使用Provider模式进行状态管理
- 遵循Material Design 3设计规范
- 8pt间距系统，12pt圆角半径
- 完整的日志系统（Logger）
- 数据迁移服务支持版本升级

## 关键功能实现

### 季度奖金管理
- **文件位置**: `lib/features/family_info/widgets/bonus_dialog_manager.dart`
- **问题修复**: 简化月份选择逻辑，使用GridView替代复杂ExpansionTile
- **核心功能**: 支持1-4个月份选择，一键清空，直观按钮界面

### 数据持久化
- 使用SharedPreferences进行本地数据存储
- 支持数据导入导出（JSON格式）
- 完整的数据迁移机制

### 响应式设计
- 支持Web、iOS、Android三端
- 自适应布局设计
- 深色模式支持

## 测试与调试

### 测试命令
```bash
flutter test                    # 运行所有测试
flutter test --coverage        # 运行测试并生成覆盖率报告
```

### 调试功能
- 数据导出功能（JSON格式）
- 测试数据生成
- 完整的数据清空功能
- 详细的日志系统

## 注意事项

1. **中文优先**: 这是一个中文应用，所有用户界面和文档都使用中文
2. **代码风格**: 遵循very_good_analysis的严格代码规范
3. **状态管理**: 使用Provider模式，避免直接状态修改
4. **数据安全**: 定期备份重要数据，应用提供数据导出功能
5. **平台差异**: 注意Web端和移动端的UI差异处理

## 常见问题解决

### 构建问题
- 确保Flutter SDK版本匹配
- 运行`flutter pub get`获取最新依赖
- 使用`flutter clean`清理构建缓存

### 代码质量问题
- 运行`./scripts/check_code.sh`进行完整检查
- 修复所有`flutter analyze`报告的问题
- 遵循80字符行宽限制（可选）

### 数据问题
- 使用数据迁移服务处理版本升级
- 定期导出数据备份
- 测试数据可用于功能验证

## 扩展开发建议

1. **新功能开发**: 遵循现有模块结构，在`features`目录下创建新模块
2. **UI组件**: 使用现有的设计系统组件（AppCard, AppAnimations等）
3. **数据模型**: 继承现有模型结构，确保数据一致性
4. **状态管理**: 遵循Provider模式，创建相应的Provider类

这个应用已经实现了完整的家庭财务管理功能，代码结构清晰，质量规范严格，适合作为Flutter开发的参考项目。