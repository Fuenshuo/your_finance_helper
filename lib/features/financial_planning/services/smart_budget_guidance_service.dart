import 'dart:math';

import 'package:your_finance_flutter/core/models/asset_item.dart';
import 'package:your_finance_flutter/core/models/budget.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';
import 'package:your_finance_flutter/core/services/chinese_mortgage_service.dart';

/// 智能预算引导服务
/// 基于用户添加的资产类型，智能推荐相关的信封预算
class SmartBudgetGuidanceService {
  factory SmartBudgetGuidanceService() => _instance;
  SmartBudgetGuidanceService._internal();
  static final SmartBudgetGuidanceService _instance =
      SmartBudgetGuidanceService._internal();

  /// 基于资产类型获取推荐的预算建议
  List<BudgetSuggestion> getBudgetSuggestionsForAsset(AssetItem asset) {
    final suggestions = <BudgetSuggestion>[];

    switch (asset.category) {
      case AssetCategory.realEstate:
        suggestions.addAll(_getFixedAssetSuggestions(asset));
      case AssetCategory.liquidAssets:
        suggestions.addAll(_getLiquidAssetSuggestions(asset));
      case AssetCategory.investments:
        suggestions.addAll(_getInvestmentSuggestions(asset));
      case AssetCategory.consumptionAssets:
        suggestions.addAll(_getConsumptionAssetSuggestions(asset));
      case AssetCategory.receivables:
        suggestions.addAll(_getReceivableSuggestions(asset));
      case AssetCategory.liabilities:
        suggestions.addAll(_getLiabilitySuggestions(asset));
    }

    return suggestions;
  }

  /// 固定资产相关建议
  List<BudgetSuggestion> _getFixedAssetSuggestions(AssetItem asset) {
    final suggestions = <BudgetSuggestion>[];

    // 房产相关建议
    if (asset.subCategory.contains('房产') || asset.subCategory.contains('房屋')) {
      suggestions.add(
        BudgetSuggestion(
          type: BudgetSuggestionType.envelope,
          title: '房贷支出',
          description: '为您的房产设置房贷还款预算',
          category: TransactionCategory.housing,
          priority: BudgetSuggestionPriority.high,
          suggestedAmount: _calculateMortgageAmount(asset.amount),
          recurringRule: RecurringRule.monthly,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 365)),
        ),
      );

      suggestions.add(
        BudgetSuggestion(
          type: BudgetSuggestionType.envelope,
          title: '房屋维护',
          description: '房屋维修、装修等维护费用预算',
          category: TransactionCategory.housing,
          priority: BudgetSuggestionPriority.medium,
          suggestedAmount: asset.amount * 0.01, // 房产价值的1%作为维护预算
          recurringRule: RecurringRule.monthly,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 365)),
        ),
      );

      suggestions.add(
        BudgetSuggestion(
          type: BudgetSuggestionType.envelope,
          title: '物业费',
          description: '物业管理费预算',
          category: TransactionCategory.housing,
          priority: BudgetSuggestionPriority.medium,
          suggestedAmount: 500, // 默认500元/月
          recurringRule: RecurringRule.monthly,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 365)),
        ),
      );
    }

    // 汽车相关建议
    if (asset.subCategory.contains('汽车') || asset.subCategory.contains('车辆')) {
      suggestions.add(
        BudgetSuggestion(
          type: BudgetSuggestionType.envelope,
          title: '车贷支出',
          description: '为您的汽车设置车贷还款预算',
          category: TransactionCategory.transport,
          priority: BudgetSuggestionPriority.high,
          suggestedAmount: _calculateCarLoanAmount(asset.amount),
          recurringRule: RecurringRule.monthly,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 365)),
        ),
      );

      suggestions.add(
        BudgetSuggestion(
          type: BudgetSuggestionType.envelope,
          title: '汽车维护',
          description: '汽车保养、维修、保险等费用预算',
          category: TransactionCategory.transport,
          priority: BudgetSuggestionPriority.medium,
          suggestedAmount: asset.amount * 0.02, // 车价的2%作为维护预算
          recurringRule: RecurringRule.monthly,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 365)),
        ),
      );

      suggestions.add(
        BudgetSuggestion(
          type: BudgetSuggestionType.envelope,
          title: '燃油费',
          description: '汽车燃油费用预算',
          category: TransactionCategory.transport,
          priority: BudgetSuggestionPriority.medium,
          suggestedAmount: 800, // 默认800元/月
          recurringRule: RecurringRule.monthly,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 365)),
        ),
      );
    }

    return suggestions;
  }

  /// 流动资产相关建议
  List<BudgetSuggestion> _getLiquidAssetSuggestions(AssetItem asset) {
    final suggestions = <BudgetSuggestion>[];

    // 银行账户相关建议
    if (asset.subCategory.contains('银行') || asset.subCategory.contains('储蓄')) {
      suggestions.add(
        BudgetSuggestion(
          type: BudgetSuggestionType.income,
          title: '工资收入',
          description: '设置您的工资收入预算',
          category: TransactionCategory.salary,
          priority: BudgetSuggestionPriority.high,
          suggestedAmount: 8000, // 默认8000元/月
          recurringRule: RecurringRule.monthly,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 365)),
        ),
      );

      suggestions.add(
        BudgetSuggestion(
          type: BudgetSuggestionType.envelope,
          title: '日常消费',
          description: '日常餐饮、购物等消费预算',
          category: TransactionCategory.food,
          priority: BudgetSuggestionPriority.high,
          suggestedAmount: 2000, // 默认2000元/月
          recurringRule: RecurringRule.monthly,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 365)),
        ),
      );
    }

    return suggestions;
  }

  /// 投资相关建议
  List<BudgetSuggestion> _getInvestmentSuggestions(AssetItem asset) {
    final suggestions = <BudgetSuggestion>[];

    suggestions.add(
      BudgetSuggestion(
        type: BudgetSuggestionType.envelope,
        title: '投资理财',
        description: '定期投资理财产品的预算',
        category: TransactionCategory.investment,
        priority: BudgetSuggestionPriority.medium,
        suggestedAmount: 1000, // 默认1000元/月
        recurringRule: RecurringRule.monthly,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 365)),
      ),
    );

    return suggestions;
  }

  /// 消费资产相关建议
  List<BudgetSuggestion> _getConsumptionAssetSuggestions(AssetItem asset) {
    final suggestions = <BudgetSuggestion>[];

    // 电子产品维护建议
    if (asset.subCategory.contains('电子产品')) {
      suggestions.add(
        BudgetSuggestion(
          type: BudgetSuggestionType.envelope,
          title: '电子产品维护',
          description: '为电子产品设置维护和更换预算',
          category: TransactionCategory.shopping,
          priority: BudgetSuggestionPriority.low,
          suggestedAmount: asset.amount * 0.1, // 10%作为维护预算
          recurringRule: RecurringRule.yearly,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 365)),
        ),
      );
    }

    // 家具保养建议
    if (asset.subCategory.contains('家具')) {
      suggestions.add(
        BudgetSuggestion(
          type: BudgetSuggestionType.envelope,
          title: '家具保养',
          description: '家具维修和保养费用预算',
          category: TransactionCategory.shopping,
          priority: BudgetSuggestionPriority.low,
          suggestedAmount: asset.amount * 0.05, // 5%作为保养预算
          recurringRule: RecurringRule.yearly,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 365)),
        ),
      );
    }

    // 服装更换建议
    if (asset.subCategory.contains('服装')) {
      suggestions.add(
        BudgetSuggestion(
          type: BudgetSuggestionType.envelope,
          title: '服装更新',
          description: '为服装设置更新和更换预算',
          category: TransactionCategory.shopping,
          priority: BudgetSuggestionPriority.low,
          suggestedAmount: asset.amount * 0.3, // 30%作为更新预算
          recurringRule: RecurringRule.yearly,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 365)),
        ),
      );
    }

    return suggestions;
  }

  /// 应收款相关建议
  List<BudgetSuggestion> _getReceivableSuggestions(AssetItem asset) {
    final suggestions = <BudgetSuggestion>[];

    suggestions.add(
      BudgetSuggestion(
        type: BudgetSuggestionType.income,
        title: '应收款回收',
        description: '设置应收款回收的收入预算',
        category: TransactionCategory.otherExpense,
        priority: BudgetSuggestionPriority.medium,
        suggestedAmount: asset.amount * 0.1, // 应收款的10%作为月度回收预算
        recurringRule: RecurringRule.monthly,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 365)),
      ),
    );

    return suggestions;
  }

  /// 负债相关建议
  List<BudgetSuggestion> _getLiabilitySuggestions(AssetItem asset) {
    final suggestions = <BudgetSuggestion>[];

    // 信用卡相关建议
    if (asset.subCategory.contains('信用卡') || asset.subCategory.contains('信用')) {
      suggestions.add(
        BudgetSuggestion(
          type: BudgetSuggestionType.envelope,
          title: '信用卡还款',
          description: '信用卡账单还款预算',
          category: TransactionCategory.otherExpense,
          priority: BudgetSuggestionPriority.high,
          suggestedAmount: asset.amount * 0.1, // 信用卡额度的10%作为还款预算
          recurringRule: RecurringRule.monthly,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 365)),
        ),
      );
    }

    // 贷款相关建议
    if (asset.subCategory.contains('贷款') || asset.subCategory.contains('借款')) {
      suggestions.add(
        BudgetSuggestion(
          type: BudgetSuggestionType.envelope,
          title: '贷款还款',
          description: '贷款本金和利息还款预算',
          category: TransactionCategory.otherExpense,
          priority: BudgetSuggestionPriority.high,
          suggestedAmount: _calculateLoanPayment(asset.amount),
          recurringRule: RecurringRule.monthly,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 365)),
        ),
      );
    }

    return suggestions;
  }

  /// 计算房贷金额（使用中国房贷计算服务）
  double _calculateMortgageAmount(double propertyValue) {
    final mortgageService = ChineseMortgageService();

    // 获取推荐的房贷方案
    final recommendations = mortgageService.getMortgageRecommendations(
      propertyValue: propertyValue,
      downPaymentRatio: 0.3, // 首付30%
    );

    if (recommendations.isNotEmpty) {
      // 返回最佳方案的月供
      return recommendations.first.result.monthlyPayment;
    }

    // 如果没有推荐方案，使用组合贷款计算
    final loanAmount = propertyValue * 0.7; // 贷款70%
    final commercialAmount = max(0, loanAmount - 1200000); // 公积金最多120万
    final gongjijinAmount = min(loanAmount, 1200000);

    final result = mortgageService.calculateMortgage(
      totalAmount: loanAmount,
      type: MortgageType.combined,
      years: 30,
      commercialAmount: commercialAmount.toDouble(),
      gongjijinAmount: gongjijinAmount.toDouble(),
    );

    return result.monthlyPayment;
  }

  /// 计算车贷金额（简化计算）
  double _calculateCarLoanAmount(double carValue) {
    // 假设5年期，利率6%，首付30%
    final loanAmount = carValue * 0.7; // 贷款70%
    const monthlyRate = 0.06 / 12; // 月利率
    const months = 5 * 12; // 5年

    if (monthlyRate == 0) return loanAmount / months;

    return loanAmount *
        monthlyRate *
        pow(1 + monthlyRate, months) /
        (pow(1 + monthlyRate, months) - 1);
  }

  /// 计算贷款还款金额（简化计算）
  double _calculateLoanPayment(double loanAmount) {
    // 假设5年期，利率8%
    const monthlyRate = 0.08 / 12; // 月利率
    const months = 5 * 12; // 5年

    if (monthlyRate == 0) return loanAmount / months;

    return loanAmount *
        monthlyRate *
        pow(1 + monthlyRate, months) /
        (pow(1 + monthlyRate, months) - 1);
  }

  /// 获取所有建议的优先级排序
  List<BudgetSuggestion> getPrioritizedSuggestions(
    List<BudgetSuggestion> suggestions,
  ) {
    suggestions.sort((a, b) {
      // 先按优先级排序
      final priorityOrder = {
        BudgetSuggestionPriority.high: 0,
        BudgetSuggestionPriority.medium: 1,
        BudgetSuggestionPriority.low: 2,
      };

      final priorityComparison =
          priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
      if (priorityComparison != 0) return priorityComparison;

      // 再按类型排序（收入优先）
      if (a.type != b.type) {
        return a.type == BudgetSuggestionType.income ? -1 : 1;
      }

      return 0;
    });

    return suggestions;
  }
}

/// 预算建议类型
enum BudgetSuggestionType {
  envelope, // 信封预算
  income, // 收入预算
}

/// 预算建议优先级
enum BudgetSuggestionPriority {
  high, // 高优先级
  medium, // 中优先级
  low, // 低优先级
}

/// 预算建议模型
class BudgetSuggestion {
  BudgetSuggestion({
    required this.type,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.suggestedAmount,
    required this.recurringRule,
    required this.startDate,
    required this.endDate,
  });
  final BudgetSuggestionType type;
  final String title;
  final String description;
  final TransactionCategory category;
  final BudgetSuggestionPriority priority;
  final double suggestedAmount;
  final RecurringRule recurringRule;
  final DateTime startDate;
  final DateTime endDate;

  /// 转换为信封预算
  EnvelopeBudget toEnvelopeBudget() => EnvelopeBudget(
        id: '', // 将在创建时生成
        name: title,
        category: category,
        allocatedAmount: suggestedAmount,
        period: _convertToBudgetPeriod(recurringRule),
        startDate: startDate,
        endDate: endDate,
        creationDate: DateTime.now(),
        updateDate: DateTime.now(),
      );

  /// 转换为周期性交易
  Transaction toRecurringTransaction({String? fromAccountId}) => Transaction(
        id: '', // 将在创建时生成
        amount: type == BudgetSuggestionType.income
            ? suggestedAmount
            : -suggestedAmount,
        description: title,
        type: type == BudgetSuggestionType.income
            ? TransactionType.income
            : TransactionType.expense,
        category: category,
        subCategory: title,
        fromAccountId: fromAccountId ?? 'default', // 使用默认账户或传入的账户
        date: startDate,
        isRecurring: true,
        recurringRule: _convertToRecurringRule(recurringRule),
      );

  BudgetPeriod _convertToBudgetPeriod(RecurringRule rule) {
    switch (rule) {
      case RecurringRule.daily:
        return BudgetPeriod.weekly; // 使用周作为最小单位
      case RecurringRule.weekly:
        return BudgetPeriod.weekly;
      case RecurringRule.monthly:
        return BudgetPeriod.monthly;
      case RecurringRule.yearly:
        return BudgetPeriod.yearly;
    }
  }

  String _convertToRecurringRule(RecurringRule rule) {
    switch (rule) {
      case RecurringRule.daily:
        return 'daily';
      case RecurringRule.weekly:
        return 'weekly';
      case RecurringRule.monthly:
        return 'monthly';
      case RecurringRule.yearly:
        return 'yearly';
    }
  }
}

/// 周期性规则枚举
enum RecurringRule {
  daily,
  weekly,
  monthly,
  yearly,
}
