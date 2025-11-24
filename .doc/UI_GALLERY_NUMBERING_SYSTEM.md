# UI Gallery 页面编号体系分析

## 📋 当前编号方式

这个页面使用了**三套不同的编号系统**，导致混乱：

### 1️⃣ 主分类编号（1-10）- 用于大分类

```
1. Typography (排版)
2. Buttons (按钮)
3. Inputs (输入框)
4. Selection Controls (选择控件)
5. Tags (标签)
6. Shimmer (骨架屏)
7. Cards & Shadows
8. Composite Styles (复合样式)
9. State & Feedback Styles (状态与反馈样式)
10. Input Components (输入组件)
```

### 2️⃣ 样式编号（S1-S31）- 用于具体样式组件

**已使用的 S 编号：**
- **S3**: Date Picker (日期选择器) - 在 Section 10 中
- **S4**: Dropdown (下拉框) - 在 Section 10 中
- **S22**: Core Data Card (核心数据卡片) - 在 Section 8 中
- **S23**: Read-Only Result Row (只读结果展示行) - 在 Section 8 中
- **S24**: Calculation Transparency (计算透明度详情) - 在 Section 8 中
- **S25**: Transaction Flow List Item (收支流水列表项) - 在 Section 8 中
- **S26**: AI Natural Language Input (AI自然语言输入框) - 在 Section 8 中
- **S27**: Chart Container Card (图表容器卡片) - 在 Section 8 中
- **S29**: Shimmer Loading (骨架屏加载) - 在 Section 9 中
- **S30**: Empty State Illustration (空状态插画) - 在 Section 9 中
- **S31**: Notification Banner (通知横幅) - 在 Section 9 中

### 3️⃣ 描述性标题（不使用编号）

**在 Section 8 中：**
- `Asset Allocation Card (资产配置卡片)` - 无编号
- `List Item Styles: Switch Control (列表行样式：开关控制)` - 无编号
- `List Item Styles: Navigable & Read-Only (列表行样式：导航行和只读数据行)` - 无编号

**在 Section 1-7 中：**
- 所有组件都没有使用 S 编号，只有主分类编号

## 🔍 问题分析

### 问题1：编号系统不统一
- **Section 1-7**：只使用主分类编号（1-7），组件没有 S 编号
- **Section 8**：混合使用 S 编号（S22-S27）和描述性标题
- **Section 9**：使用 S 编号（S29-S31）
- **Section 10**：使用 S 编号（S3, S4）

### 问题2：S 编号不完整
- **Section 1 (Typography)**：没有标注 S 编号（实际上没有对应的 S 编号）
- **Section 2 (Buttons)**：没有标注 S11（Primary Button）
- **Section 3 (Inputs)**：没有标注 S1（Standard Text Field）
- **Section 4 (Selection Controls)**：没有标注 S5（Checkbox）、S6（Switch）、S9（Segmented Control）
- **Section 5 (Tags)**：没有标注 S10（Tag）
- **Section 6 (Shimmer)**：标注了 S29，但 Section 6 和 Section 9 都有 Shimmer
- **Section 7 (Cards)**：没有标注编号

### 问题3：编号位置混乱
- S3 和 S4 在 Section 10，而不是在 Section 3（Inputs）中
- S29 在 Section 9，但 Section 6 也有 Shimmer 展示

## 📊 完整的组件清单

### Section 1: Typography (排版)
- ❌ 无 S 编号
- 展示：Large Title, Title 1, Headline, Body, Caption

### Section 2: Buttons (按钮)
- ❌ 无 S 编号（应该是 S11）
- 展示：AppPrimaryButton（各种状态）

### Section 3: Inputs (输入框)
- ❌ 无 S 编号（应该是 S1）
- 展示：AppTextField（各种状态）

### Section 4: Selection Controls (选择控件)
- ❌ 无 S 编号（应该是 S5, S6, S9）
- 展示：AppSwitch, AppCheckbox, AppSegmentedControl

### Section 5: Tags (标签)
- ❌ 无 S 编号（应该是 S10）
- 展示：AppTag（各种状态）

### Section 6: Shimmer (骨架屏)
- ❌ 无 S 编号（但 Section 9 有 S29）
- 展示：AppShimmer（各种形态）

### Section 7: Cards & Shadows
- ❌ 无 S 编号
- 展示：AppCard 示例

### Section 8: Composite Styles (复合样式)
- ✅ **S22**: Core Data Card
- ✅ **S23**: Read-Only Result Row
- ✅ **S24**: Calculation Transparency
- ❌ **Asset Allocation Card** - 无编号（新增组件）
- ✅ **S25**: Transaction Flow List Item
- ✅ **S26**: AI Natural Language Input
- ❌ **List Item Styles: Switch Control** - 无编号（新增组件）
- ✅ **S27**: Chart Container Card
- ❌ **List Item Styles: Navigable & Read-Only** - 无编号（新增组件）

### Section 9: State & Feedback Styles (状态与反馈样式)
- ✅ **S29**: Shimmer Loading
- ✅ **S30**: Empty State Illustration
- ✅ **S31**: Notification Banner

### Section 10: Input Components (输入组件)
- ✅ **S3**: Date Picker
- ✅ **S4**: Dropdown

## 💡 建议的统一编号方案

### 方案A：完整标注所有 S 编号
- Section 2 → 标注 S11
- Section 3 → 标注 S1
- Section 4 → 标注 S5, S6, S9
- Section 5 → 标注 S10
- Section 6 → 标注 S29（或移除，因为 Section 9 已有）
- Section 8 → 新增组件使用新编号或描述性标题

### 方案B：只标注复合样式和特殊样式
- 保持 Section 1-7 不标注 S 编号（基础组件）
- Section 8-10 继续使用 S 编号（复合样式和特殊场景）

### 方案C：完全统一编号体系
- 所有组件都使用 S 编号
- 主分类编号仅作为分组，不作为组件标识

