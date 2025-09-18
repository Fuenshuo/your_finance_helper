import '../models/account.dart';
import '../models/budget.dart';

/// 总资产计算服务
/// 实现"总资产 = 所有账户余额 + 所有信封余额"的核心逻辑
class TotalAssetsService {
  
  /// 计算总资产
  /// 总资产 = 账户资产 + 信封可用余额
  static double calculateTotalAssets({
    required List<Account> accounts,
    required List<EnvelopeBudget> envelopeBudgets,
  }) {
    // 1. 计算账户资产
    final accountAssets = _calculateAccountAssets(accounts);
    
    // 2. 计算信封可用余额
    final envelopeAssets = _calculateEnvelopeAssets(envelopeBudgets);
    
    return accountAssets + envelopeAssets;
  }

  /// 计算账户资产
  /// 包括现金、银行、投资等资产账户，减去负债账户
  static double _calculateAccountAssets(List<Account> accounts) {
    double totalAssets = 0.0;
    
    for (final account in accounts) {
      if (account.status == AccountStatus.active) {
        if (account.type.isAsset) {
          // 资产账户：现金、银行、投资等
          totalAssets += account.balance;
        } else if (account.type.isLiability) {
          // 负债账户：信用卡、贷款等（显示为负数）
          totalAssets -= account.balance;
        }
      }
    }
    
    return totalAssets;
  }

  /// 计算信封资产
  /// 信封中的可用余额也是总资产的一部分
  static double _calculateEnvelopeAssets(List<EnvelopeBudget> envelopeBudgets) {
    return envelopeBudgets
        .where((budget) => budget.status == BudgetStatus.active)
        .fold(0.0, (sum, budget) => sum + budget.availableAmount);
  }

  /// 计算净资产
  /// 净资产 = 总资产 - 总负债
  static double calculateNetWorth({
    required List<Account> accounts,
    required List<EnvelopeBudget> envelopeBudgets,
  }) {
    final totalAssets = calculateTotalAssets(
      accounts: accounts,
      envelopeBudgets: envelopeBudgets,
    );
    
    final totalLiabilities = _calculateTotalLiabilities(accounts);
    
    return totalAssets - totalLiabilities;
  }

  /// 计算总负债
  static double _calculateTotalLiabilities(List<Account> accounts) {
    return accounts
        .where((account) => 
          account.status == AccountStatus.active && 
          account.type.isLiability
        )
        .fold(0.0, (sum, account) => sum + account.balance);
  }

  /// 计算负债率
  static double calculateDebtRatio({
    required List<Account> accounts,
    required List<EnvelopeBudget> envelopeBudgets,
  }) {
    final totalAssets = calculateTotalAssets(
      accounts: accounts,
      envelopeBudgets: envelopeBudgets,
    );
    
    if (totalAssets == 0) return 0.0;
    
    final totalLiabilities = _calculateTotalLiabilities(accounts);
    return (totalLiabilities / totalAssets) * 100;
  }

  /// 获取资产分布详情
  static Map<String, double> getAssetDistribution({
    required List<Account> accounts,
    required List<EnvelopeBudget> envelopeBudgets,
  }) {
    final distribution = <String, double>{};
    
    // 账户资产分布
    for (final account in accounts) {
      if (account.status == AccountStatus.active) {
        final key = account.type.displayName;
        if (account.type.isAsset) {
          distribution[key] = (distribution[key] ?? 0.0) + account.balance;
        } else if (account.type.isLiability) {
          distribution[key] = (distribution[key] ?? 0.0) - account.balance;
        }
      }
    }
    
    // 信封资产分布
    for (final budget in envelopeBudgets) {
      if (budget.status == BudgetStatus.active) {
        final key = '${budget.category.displayName}预算';
        distribution[key] = (distribution[key] ?? 0.0) + budget.availableAmount;
      }
    }
    
    return distribution;
  }

  /// 获取预算使用情况
  static Map<String, Map<String, double>> getBudgetUsage({
    required List<EnvelopeBudget> envelopeBudgets,
  }) {
    final usage = <String, Map<String, double>>{};
    
    for (final budget in envelopeBudgets) {
      if (budget.status == BudgetStatus.active) {
        usage[budget.name] = {
          'allocated': budget.allocatedAmount,
          'spent': budget.spentAmount,
          'available': budget.availableAmount,
          'usagePercentage': budget.usagePercentage,
        };
      }
    }
    
    return usage;
  }

  /// 计算预算健康度
  static BudgetHealthStatus getBudgetHealthStatus({
    required List<EnvelopeBudget> envelopeBudgets,
  }) {
    if (envelopeBudgets.isEmpty) {
      return BudgetHealthStatus.noBudget;
    }
    
    final activeBudgets = envelopeBudgets
        .where((b) => b.status == BudgetStatus.active)
        .toList();
    
    if (activeBudgets.isEmpty) {
      return BudgetHealthStatus.noActiveBudget;
    }
    
    final overBudgetCount = activeBudgets.where((b) => b.isOverBudget).length;
    final warningCount = activeBudgets.where((b) => b.isWarningThresholdReached && !b.isOverBudget).length;
    
    if (overBudgetCount > 0) {
      return BudgetHealthStatus.overBudget;
    } else if (warningCount > 0) {
      return BudgetHealthStatus.warning;
    } else {
      return BudgetHealthStatus.healthy;
    }
  }

  /// 获取预算建议
  static List<String> getBudgetSuggestions({
    required List<EnvelopeBudget> envelopeBudgets,
  }) {
    final suggestions = <String>[];
    final healthStatus = getBudgetHealthStatus(envelopeBudgets: envelopeBudgets);
    
    switch (healthStatus) {
      case BudgetHealthStatus.overBudget:
        final overBudgetEnvelopes = envelopeBudgets
            .where((b) => b.isOverBudget)
            .map((b) => b.name)
            .toList();
        suggestions.add('以下预算已超支：${overBudgetEnvelopes.join('、')}');
        suggestions.add('建议调整预算分配或减少相关支出');
        break;
        
      case BudgetHealthStatus.warning:
        final warningEnvelopes = envelopeBudgets
            .where((b) => b.isWarningThresholdReached && !b.isOverBudget)
            .map((b) => b.name)
            .toList();
        suggestions.add('以下预算接近上限：${warningEnvelopes.join('、')}');
        suggestions.add('请注意控制相关支出');
        break;
        
      case BudgetHealthStatus.healthy:
        suggestions.add('预算使用情况良好');
        break;
        
      case BudgetHealthStatus.noBudget:
        suggestions.add('建议创建预算来更好地管理支出');
        break;
        
      case BudgetHealthStatus.noActiveBudget:
        suggestions.add('当前没有活跃的预算，建议创建新的预算周期');
        break;
    }
    
    return suggestions;
  }
}

/// 预算健康状态枚举
enum BudgetHealthStatus {
  healthy('健康'),
  warning('警告'),
  overBudget('超支'),
  noBudget('无预算'),
  noActiveBudget('无活跃预算');

  const BudgetHealthStatus(this.displayName);
  final String displayName;
}
