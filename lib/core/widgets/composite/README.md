# Composite Components 复合组件文档

## 概述

`core/widgets/composite/` 是Flux Ledger的高级复合组件集合，将基础组件和交互逻辑组合成完整的UI模块，提高开发效率和用户体验一致性。

**文件统计**: 7个Dart文件，实现7种复合组件模式

## 架构定位

### 层级关系
```
UI Layer (页面实现)               # 组合使用
    ↓ (复合组件)
core/widgets/composite/            # 🔵 当前层级 - 复合组件
    ↓ (基础组件)
core/widgets/                      # 基础组件
    ↓ (设计系统)
core/theme/                        # 设计令牌
```

### 职责边界
- ✅ **组件组合**: 将基础组件组合成完整UI模块
- ✅ **交互封装**: 封装常见的用户交互模式
- ✅ **样式统一**: 确保复合组件的视觉一致性
- ✅ **逻辑复用**: 复用复杂的交互和状态逻辑
- ❌ **业务逻辑**: 不包含具体的业务规则
- ❌ **数据处理**: 不负责复杂的数据转换

## 复合组件分类

### 1. 列表项组件 (4个文件)

#### StandardListItem (`standard_list_item.dart`)
**职责**: 标准列表项组件，提供统一的列表项样式和交互

**核心功能**:
- 统一的列表项布局
- 标题、副标题、图标支持
- 点击和长按交互
- 状态指示器

**关联关系**:
- **依赖**: `core/widgets/app_card.dart` (卡片容器)
- **被依赖**: 设置页面、配置页面等列表展示
- **级联影响**: 列表页面的视觉一致性

#### ActionableListItem (`actionable_list_item.dart`)
**职责**: 可操作列表项，扩展标准列表项的交互能力

**核心功能**:
- 继承标准列表项的所有功能
- 支持操作按钮和快捷操作
- 滑动操作支持
- 上下文菜单

**关联关系**:
- **依赖**: `StandardListItem` (基础样式)
- **被依赖**: 需要操作的列表项场景
- **级联影响**: 操作密集界面的用户体验

#### NavigableListItem (`navigable_list_item.dart`)
**职责**: 可导航列表项，集成路由跳转功能

**核心功能**:
- 继承标准列表项样式
- 自动路由导航处理
- 导航状态反馈
- 返回栈管理

**关联关系**:
- **依赖**: `core/router/flux_router.dart` (路由系统)
- **被依赖**: 导航菜单和设置页面
- **级联影响**: 应用内的页面导航体验

#### SwitchControlListItem (`switch_control_list_item.dart`)
**职责**: 开关控制列表项，集成开关控件和状态管理

**核心功能**:
- 开关状态显示和控制
- 状态变更回调处理
- 开关样式定制
- 状态持久化支持

**关联关系**:
- **依赖**: `StandardListItem` + Flutter Switch
- **被依赖**: 设置页面和配置开关
- **级联影响**: 配置界面的交互一致性

### 2. 计算展示组件 (1个文件)

#### ExpandableCalculationItem (`expandable_calculation_item.dart`)
**职责**: 可展开计算项，用于展示复杂的计算过程和结果

**核心功能**:
- 计算结果的折叠/展开
- 详细计算步骤展示
- 结果高亮显示
- 动画过渡效果

**关联关系**:
- **依赖**: `StandardListItem` + 动画组件
- **被依赖**: 工资计算、税费计算等复杂计算展示
- **级联影响**: 计算结果的可读性和用户理解

### 3. 高级复合组件 (2个文件)

#### 待扩展组件
复合组件库预留了扩展空间，支持未来添加更多高级复合组件。

## 组件设计模式

### 组合模式
复合组件通过组合基础组件实现复杂功能：

```dart
class NavigableListItem extends StatelessWidget {
  // 属性定义
  final String title;
  final String? subtitle;
  final Widget? leading;
  final String routeName;
  final Map<String, dynamic>? routeParams;

  @override
  Widget build(BuildContext context) {
    return StandardListItem(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: Icon(Icons.chevron_right),
      onTap: () => context.goNamed(routeName, extra: routeParams),
    );
  }
}
```

### 模板方法模式
通过抽象基类定义组件框架，具体组件实现特定逻辑：

```dart
abstract class BaseListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;

  const BaseListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
  });

  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(AppDesignTokens.spaceMedium),
          child: Row(
            children: [
              if (leading != null) leading!,
              Expanded(child: buildContent(context)),
              buildTrailing(context),
            ],
          ),
        ),
      ),
    );
  }

  VoidCallback? get onTap;
  Widget buildTrailing(BuildContext context);
}
```

## 使用模式

### 标准列表项
```dart
StandardListItem(
  title: '账户设置',
  subtitle: '管理您的账户信息',
  leading: Icon(Icons.account_circle),
  onTap: () => navigateToAccountSettings(),
)
```

### 可导航列表项
```dart
NavigableListItem(
  title: '通知设置',
  subtitle: '推送通知和提醒',
  leading: Icon(Icons.notifications),
  routeName: FluxRoutes.notifications,
)
```

### 开关控制项
```dart
SwitchControlListItem(
  title: '自动备份',
  subtitle: '每天自动备份数据',
  value: autoBackupEnabled,
  onChanged: (value) {
    setState(() => autoBackupEnabled = value);
    saveSetting('auto_backup', value);
  },
)
```

### 可展开计算项
```dart
ExpandableCalculationItem(
  title: '工资计算',
  result: '¥12,345.67',
  details: [
    CalculationStep('基本工资', '¥10,000.00'),
    CalculationStep('奖金', '¥2,000.00'),
    CalculationStep('扣除个税', '¥654.33'),
  ],
  initiallyExpanded: false,
)
```

## 样式一致性

### 设计令牌应用
所有复合组件都使用统一的设计令牌：

```dart
Padding(
  padding: EdgeInsets.all(AppDesignTokens.spaceMedium),
  child: Text(
    title,
    style: AppDesignTokens.titleMedium,
  ),
)
```

### 主题适配
自动适配亮色和暗色主题：

```dart
Color backgroundColor = Theme.of(context).colorScheme.surface;
Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
```

## 性能优化

### 1. 组件缓存
常用复合组件的实例缓存。

### 2. 懒加载
子组件的按需加载。

### 3. 状态优化
最小化不必要的重绘。

### 4. 内存管理
及时清理事件监听器。

## 测试策略

### 组件测试
- 复合组件的渲染正确性
- 属性传递和状态管理
- 交互行为验证

### 集成测试
- 复合组件在页面中的表现
- 多组件间的交互
- 导航和路由集成

### 用户体验测试
- 触摸目标大小验证
- 视觉层次确认
- 无障碍功能测试

## 扩展开发

### 创建新的列表项组件
```dart
class CustomListItem extends StatelessWidget {
  final String title;
  final Widget customWidget;

  const CustomListItem({
    super.key,
    required this.title,
    required this.customWidget,
  });

  @override
  Widget build(BuildContext context) {
    return StandardListItem(
      title: title,
      trailing: customWidget,
      onTap: () => print('Custom action'),
    );
  }
}
```

### 添加新的复合组件
```dart
class SearchableList extends StatefulWidget {
  final List<String> items;
  final ValueChanged<String> onItemSelected;

  const SearchableList({
    super.key,
    required this.items,
    required this.onItemSelected,
  });

  @override
  State<SearchableList> createState() => _SearchableListState();
}

class _SearchableListState extends State<SearchableList> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.items
        .where((item) => item.contains(_searchQuery))
        .toList();

    return Column(
      children: [
        AppTextField(
          hintText: '搜索...',
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              return StandardListItem(
                title: filteredItems[index],
                onTap: () => widget.onItemSelected(filteredItems[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

### 扩展现有组件
```dart
class EnhancedNavigableListItem extends NavigableListItem {
  final bool showBadge;
  final Color badgeColor;

  const EnhancedNavigableListItem({
    super.key,
    required super.title,
    super.subtitle,
    super.leading,
    required super.routeName,
    this.showBadge = false,
    this.badgeColor = Colors.red,
  });

  @override
  Widget buildTrailing(BuildContext context) {
    if (showBadge) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          super.buildTrailing(context),
        ],
      );
    }
    return super.buildTrailing(context);
  }
}
```

## 使用指南

### 选择合适的组件
1. **StandardListItem**: 基础列表展示
2. **ActionableListItem**: 需要操作的列表项
3. **NavigableListItem**: 页面导航的列表项
4. **SwitchControlListItem**: 开关配置的列表项
5. **ExpandableCalculationItem**: 复杂计算结果展示

### 组件组合
复合组件可以相互嵌套和组合：

```dart
Column(
  children: [
    NavigableListItem(
      title: '账户管理',
      routeName: '/accounts',
    ),
    SwitchControlListItem(
      title: '通知提醒',
      value: notificationsEnabled,
      onChanged: (value) => setState(() => notificationsEnabled = value),
    ),
    ExpandableCalculationItem(
      title: '月度预算',
      result: '¥5,000.00',
      details: budgetDetails,
    ),
  ],
)
```

### 自定义样式
通过属性和主题覆盖自定义样式：

```dart
StandardListItem(
  title: '自定义样式',
  titleStyle: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  ),
  backgroundColor: Colors.grey[100],
  borderRadius: 12.0,
)
```

## 相关文档

- [Widgets组件库文档](../README.md)
- [设计系统文档](../../theme/README.md)
- [UI设计规范](../../../../.cursor/rules/ui-design-system.mdc)


