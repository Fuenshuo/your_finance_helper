**版本: 1.0**

**日期: 2025年9月8日**

## 1. 方案概述
本文档根据《家庭资产记账应用产品需求文档(PRD)》，为该应用的 **iOS 纯本地版** 提供一套具体、可落地的技术实现方案。

此方案的核心目标是：**快速、高效地开发一款性能优良、体验流畅的纯粹iOS应用**，所有用户数据将仅存储在用户设备本地，不依赖任何网络和后端服务器。

## 2. 核心技术选型
为了充分利用苹果生态的最新特性，并保证最佳的开发效率和应用性能，我们选择以下技术栈：

+ **开发语言**: **Swift 5.10+**
    - 苹果官方的现代、安全、高效的编程语言。
+ **UI 框架**: **SwiftUI**
    - 苹果新一代的声明式UI框架，能够用更少的代码构建美观、动态的界面，并天然支持iOS、iPadOS等所有苹果平台。非常适合构建PRD中描述的这类数据驱动型视图。
+ **数据持久化 (本地存储)**: **SwiftData**
    - 这是苹果在iOS 17中推出的全新数据持久化框架，它基于Core Data，但提供了极其简洁、现代的Swift原生API。
    - **优点**:
        * 与SwiftUI无缝集成，可以用最少的代码实现数据的增、删、改、查和视图的自动刷新。
        * 代码简洁易懂，使用`@Model`宏即可定义数据模型。
        * 性能强大，底层由成熟的Core Data驱动。
    - **注意**: 使用SwiftData意味着应用的最低系统支持需要设置为 **iOS 17**。如果需要支持更早的系统版本，可以替换为 **Core Data** 方案，但开发复杂度会相应增加。
+ **图表绘制**: **Swift Charts**
    - 苹果在iOS 16中推出的官方图表框架，与SwiftUI完美结合。
    - 足以实现PRD中描述的资产构成柱状图等可视化需求，无需引入第三方库。

## 3. 数据模型设计 (Data Modeling)
我们将使用SwiftData来定义数据模型。核心模型如下：

```plain
import Foundation
import SwiftData

// 定义资产/负债的大分类
enum AssetCategory: String, Codable, CaseIterable {
    case liquidAssets = "流动资金"
    case fixedAssets = "固定资产"
    case investments = "投资理财"
    case receivables = "应收款"
    case liabilities = "负债"
}

// 主数据模型：代表每一笔资产或负债
@Model
class AssetItem {
    @Attribute(.unique) var id: UUID
    var name: String                 // 名称 (如: 支付宝, 房产(自住))
    var amount: Double               // 金额
    var category: AssetCategory      // 所属大分类
    var subCategory: String          // 子分类 (自定义或预设名称)
    var creationDate: Date           // 创建日期
    var updateDate: Date             // 最后更新日期

    init(name: String, amount: Double, category: AssetCategory, subCategory: String) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.category = category
        self.subCategory = subCategory
        self.creationDate = Date()
        self.updateDate = Date()
    }
}
```

**说明**:

+ `@Model` 宏会自动为 `AssetItem` 类添加SwiftData所需的所有能力。
+ `AssetCategory` 枚举清晰地定义了五大资产类别，便于查询和分类统计。
+ 这个单一模型 `AssetItem` 足以存储所有类型的资产和负债信息，通过 `category` 字段进行区分。

## 4. 功能模块实现方案
### 4.1 资产添加流程 (Onboarding Flow)
+ **视图结构**: 使用 SwiftUI 的 `NavigationStack` 来构建分步引导流程。
+ **页面**:
    1. 创建一个主容器视图 `AddAssetFlowView`，内部通过 `TabView` 或自定义的步骤条来管理五个分类页面。
    2. 每个分类（如 `LiquidAssetsView`）负责展示该分类下已添加的项目，并提供一个“添加”按钮。
    3. 点击“添加”后，弹出一个 `Sheet`（模态弹窗），让用户选择预设的子分类或自定义输入，并填写金额。
+ **状态管理**: 在 `AddAssetFlowView` 中创建一个临时的状态对象，用于暂存用户在整个流程中录入的所有数据，当用户最终点击“完成”时，一次性将所有数据存入SwiftData。

### 4.2 总览仪表盘 (Dashboard)
+ **数据获取**: 在 `DashboardView` 中，使用 `@Query` 属性包装器直接从SwiftData中获取所有的 `AssetItem` 数据。

```plain
@Query var assetItems: [AssetItem]
```

当本地数据库中的数据发生变化时，视图会自动刷新，无需手动操作。

+ **数据计算**:
    - **总资产**: `assetItems.filter { $0.category != .liabilities }.reduce(0) { $0 + $1.amount }`
    - **总负债**: `assetItems.filter { $0.category == .liabilities }.reduce(0) { $0 + $1.amount }`
    - **净资产**: `总资产 - 总负债`
    - **负债率**: `总负债 / 总资产`
    - 这些计算逻辑可以封装在一个 `ViewModel` 中，或直接作为 `DashboardView` 的计算属性，保持视图代码的整洁。
+ **隐私模式**: 使用一个 `@State` 变量 `isAmountHidden` 来控制金额的显示与隐藏，界面上显示为 `****`。

### 4.3 资产组成图表 (Charts)
+ 使用 `Swift Charts` 框架。
+ 将计算好的各类资产总额传入 `Chart` 视图。

```plain
import Charts

Chart {
    BarMark(
        x: .value("资产类型", "净资产"),
        y: .value("金额", netAssets)
    )
    BarMark(
        x: .value("资产类型", "总资产"),
        y: .value("金额", totalAssets)
    )
    // ... more BarMarks for other categories
}
```

通过简单的配置即可生成PRD中描述的堆叠柱状图。

## 5. 项目架构
推荐采用 **MVVM (Model-View-ViewModel)** 架构，这是SwiftUI社区最主流和推荐的架构模式。

+ **Model**: 即我们用 `@Model` 定义的 `AssetItem` 类。
+ **View**: 使用SwiftUI编写的所有视图文件（如 `DashboardView`, `AddAssetFlowView` 等）。视图应保持“哑”状态，只负责展示数据和传递用户操作。
+ **ViewModel**: 遵从 `ObservableObject` 协议的类。负责处理业务逻辑（如复杂的计算、数据格式化），并为View提供其需要的数据。这样可以使View的代码非常简洁，也便于逻辑的复用和测试。

**总结**: 这套纯粹的Apple原生技术栈（Swift, SwiftUI, SwiftData）是当前开发iOS应用的最佳选择。它不仅能提供无与伦比的性能和系统集成度，还能让开发过程变得更加高效和愉快。对于一个无需后端的本地记账工具来说，这套方案是简单、强大且面向未来的。

