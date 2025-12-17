/// 应用统一图标常量类
///
/// 统一使用 Material Design Outlined 风格的图标
/// 确保整个应用的图标风格一致
library your_finance_flutter.core.constants.app_icons;

import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/models/account.dart';
import 'package:your_finance_flutter/core/models/transaction.dart';

/// 应用图标常量
class AppIcons {
  AppIcons._(); // 私有构造函数，防止实例化

  // ========== 基础操作图标 ==========

  /// 添加
  static const add = Icons.add_outlined;

  /// 删除
  static const delete = Icons.delete_outline;

  /// 编辑
  static const edit = Icons.edit_outlined;

  /// 保存
  static const save = Icons.save_outlined;

  /// 确认/完成
  static const check = Icons.check_circle_outline;

  /// 错误
  static const error = Icons.error_outline;

  /// 警告
  static const warning = Icons.warning_amber_outlined;

  /// 信息
  static const info = Icons.info_outline;

  /// 帮助
  static const help = Icons.help_outline;

  /// 关闭/清除
  static const close = Icons.close_outlined;

  /// 搜索
  static const search = Icons.search_outlined;

  /// 刷新
  static const refresh = Icons.refresh_outlined;

  /// 分享
  static const share = Icons.share_outlined;

  /// 可见
  static const visibility = Icons.visibility_outlined;

  /// 不可见
  static const visibilityOff = Icons.visibility_off_outlined;

  // ========== 导航图标 ==========

  /// 前进箭头
  static const arrowForward = Icons.arrow_forward_ios_outlined;

  /// 下拉箭头
  static const arrowDropDown = Icons.arrow_drop_down_outlined;

  /// 右箭头
  static const chevronRight = Icons.chevron_right_outlined;

  /// 向下箭头（收入）
  static const arrowDownward = Icons.arrow_downward_outlined;

  /// 向上箭头（支出）
  static const arrowUpward = Icons.arrow_upward_outlined;

  /// 转账/交换
  static const swap = Icons.swap_horiz_outlined;

  /// 更多
  static const more = Icons.more_vert_outlined;

  // ========== 账户类型图标 ==========

  /// 现金
  static const cash = Icons.account_balance_wallet_outlined;

  /// 银行账户
  static const bank = Icons.account_balance_outlined;

  /// 信用卡
  static const creditCard = Icons.credit_card_outlined;

  /// 投资账户
  static const investment = Icons.trending_up_outlined;

  /// 贷款
  static const loan = Icons.account_balance_wallet_outlined;

  /// 资产账户
  static const asset = Icons.business_outlined;

  /// 负债账户
  static const liability = Icons.warning_amber_outlined;

  /// 钱包
  static const wallet = Icons.account_balance_wallet_outlined;

  // ========== 交易分类图标 ==========

  /// 工资
  static const salary = Icons.work_outlined;

  /// 奖金/礼物
  static const bonus = Icons.card_giftcard_outlined;

  /// 投资收益
  static const investmentIncome = Icons.trending_up_outlined;

  /// 其他收入
  static const otherIncome = Icons.attach_money_outlined;

  /// 餐饮
  static const food = Icons.restaurant_outlined;

  /// 交通
  static const transport = Icons.directions_car_outlined;

  /// 购物
  static const shopping = Icons.shopping_bag_outlined;

  /// 娱乐
  static const entertainment = Icons.movie_outlined;

  /// 医疗
  static const healthcare = Icons.local_hospital_outlined;

  /// 教育
  static const education = Icons.school_outlined;

  /// 住房
  static const housing = Icons.home_outlined;

  /// 水电费
  static const utilities = Icons.electrical_services_outlined;

  /// 保险
  static const insurance = Icons.security_outlined;

  /// 其他支出
  static const otherExpense = Icons.receipt_outlined;

  /// 其他/更多
  static const other = Icons.more_horiz_outlined;

  /// 收入趋势
  static const trendingUp = Icons.trending_up_outlined;

  /// 支出趋势
  static const trendingDown = Icons.trending_down_outlined;

  // ========== 交易类型图标 ==========

  /// 收入
  static const income = Icons.trending_up_outlined;

  /// 支出
  static const expense = Icons.trending_down_outlined;

  /// 转账
  static const transfer = Icons.swap_horiz_outlined;

  // ========== 功能模块图标 ==========

  /// 首页
  static const home = Icons.home_outlined;

  /// 分析/统计
  static const analytics = Icons.analytics_outlined;

  /// 财务概览
  static const finance = Icons.monetization_on_outlined;

  /// 账户管理
  static const accountManagement = Icons.account_balance_outlined;

  /// 清账功能
  static const clearance = Icons.checklist_outlined;

  /// AI功能
  static const ai = Icons.auto_awesome_outlined;

  /// 开发者模式
  static const developerMode = Icons.developer_mode_outlined;

  /// 调试
  static const debug = Icons.bug_report_outlined;

  /// 历史记录
  static const history = Icons.history_outlined;

  /// 恢复
  static const restore = Icons.restore_outlined;

  /// 预览
  static const preview = Icons.preview_outlined;

  /// 上传
  static const upload = Icons.cloud_upload_outlined;

  /// 动画
  static const animation = Icons.animation_outlined;

  /// 日期
  static const calendar = Icons.calendar_today_outlined;

  /// 时间
  static const schedule = Icons.schedule_outlined;

  /// 图片
  static const image = Icons.image_outlined;

  /// 文本
  static const text = Icons.text_fields_outlined;

  /// 提示/建议
  static const lightbulb = Icons.lightbulb_outline;

  /// 播放
  static const play = Icons.play_arrow_outlined;

  /// 清单
  static const checklist = Icons.checklist_outlined;

  /// 交易记录
  static const receipt = Icons.receipt_long_outlined;

  // ========== 资产分类图标 ==========

  /// 银行存款
  static const bankDeposit = Icons.account_balance_outlined;

  /// 现金/钱包
  static const cashWallet = Icons.wallet_outlined;

  /// 基金/股票
  static const fundStock = Icons.trending_up_outlined;

  /// 理财/保险
  static const financialInsurance = Icons.shield_outlined;

  /// 其他流动资产
  static const otherLiquidAsset = Icons.monetization_on_outlined;

  /// 房产
  static const realEstate = Icons.home_outlined;

  /// 车辆
  static const vehicle = Icons.directions_car_outlined;

  /// 黄金/珠宝
  static const goldJewelry = Icons.diamond_outlined;

  /// 收藏/艺术品
  static const collection = Icons.palette_outlined;

  /// 其他固定资产
  static const otherFixedAsset = Icons.inventory_2_outlined;

  // ========== 状态图标 ==========

  /// 待处理
  static const pending = Icons.pending_outlined;

  /// 成功
  static const success = Icons.check_circle_outline;

  /// 失败
  static const failure = Icons.error_outline;

  /// 加载中
  static const loading = Icons.hourglass_empty_outlined;

  // ========== 工具方法 ==========

  /// 根据账户类型获取图标
  static IconData getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return cash;
      case AccountType.bank:
        return bank;
      case AccountType.creditCard:
        return creditCard;
      case AccountType.investment:
        return investment;
      case AccountType.loan:
        return loan;
      case AccountType.asset:
        return asset;
      case AccountType.liability:
        return liability;
    }
  }

  /// 根据交易分类获取图标
  static IconData getCategoryIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.salary:
        return salary;
      case TransactionCategory.bonus:
      case TransactionCategory.gift:
        return bonus;
      case TransactionCategory.food:
        return food;
      case TransactionCategory.transport:
        return transport;
      case TransactionCategory.shopping:
        return shopping;
      case TransactionCategory.entertainment:
        return entertainment;
      case TransactionCategory.healthcare:
        return healthcare;
      case TransactionCategory.education:
        return education;
      case TransactionCategory.housing:
        return housing;
      case TransactionCategory.utilities:
        return utilities;
      case TransactionCategory.insurance:
        return insurance;
      case TransactionCategory.investment:
        return investmentIncome;
      case TransactionCategory.otherIncome:
        return otherIncome;
      case TransactionCategory.otherExpense:
        return otherExpense;
      case TransactionCategory.freelance:
        return salary;
    }
  }

  /// 根据交易类型获取图标
  static IconData getTransactionTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return income;
      case TransactionType.expense:
        return expense;
      case TransactionType.transfer:
        return transfer;
    }
  }
}
