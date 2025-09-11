class SalaryFormValidators {
  /// 验证收入名称
  static String? validateIncomeName(String? value) {
    if (value?.isEmpty ?? true) {
      return '请输入收入名称';
    }
    return null;
  }

  /// 验证基本工资
  static String? validateBasicSalary(String? value) {
    if (value?.isEmpty ?? true) {
      return '请输入基本工资';
    }
    final amount = double.tryParse(value!);
    if (amount == null || amount <= 0) {
      return '请输入有效的金额';
    }
    return null;
  }

  /// 验证金额（可选字段）
  static String? validateAmount(String? value) {
    if (value?.isEmpty ?? true) {
      return null; // 可选字段
    }
    final amount = double.tryParse(value!);
    if (amount == null || amount < 0) {
      return '请输入有效的金额';
    }
    return null;
  }

  /// 验证奖金名称
  static String? validateBonusName(String? value) {
    if (value?.isEmpty ?? true) {
      return '请输入奖金名称';
    }
    return null;
  }

  /// 验证奖金金额
  static String? validateBonusAmount(String? value) {
    if (value?.isEmpty ?? true) {
      return '请输入奖金金额';
    }
    final amount = double.tryParse(value!);
    if (amount == null || amount <= 0) {
      return '请输入有效的金额';
    }
    return null;
  }

  /// 验证个人养老金年度缴费金额
  static String? validatePensionContribution(String? value,
      {double maxAmount = 12000}) {
    if (value?.isEmpty ?? true) {
      return null; // 可选字段
    }
    final amount = double.tryParse(value!);
    if (amount == null || amount < 0) {
      return '请输入有效的金额';
    }
    if (amount > maxAmount) {
      return '年度缴费金额不能超过${maxAmount.toStringAsFixed(0)}元';
    }
    return null;
  }

  /// 验证子女数量
  static String? validateChildrenCount(String? value) {
    if (value?.isEmpty ?? true) {
      return null;
    }
    final count = int.tryParse(value!);
    if (count == null || count < 0) {
      return '请输入有效的数量';
    }
    if (count > 10) {
      return '子女数量不能超过10个';
    }
    return null;
  }

  /// 验证老人数量
  static String? validateElderlyCount(String? value) {
    if (value?.isEmpty ?? true) {
      return null;
    }
    final count = int.tryParse(value!);
    if (count == null || count < 0) {
      return '请输入有效的数量';
    }
    if (count > 10) {
      return '赡养老人数量不能超过10个';
    }
    return null;
  }

  /// 验证婴幼儿数量
  static String? validateInfantCount(String? value) {
    if (value?.isEmpty ?? true) {
      return null;
    }
    final count = int.tryParse(value!);
    if (count == null || count < 0) {
      return '请输入有效的数量';
    }
    if (count > 10) {
      return '婴幼儿数量不能超过10个';
    }
    return null;
  }

  /// 验证工资历史金额
  static String? validateSalaryHistoryAmount(String? value) {
    if (value?.isEmpty ?? true) {
      return '请输入工资金额';
    }
    final amount = double.tryParse(value!);
    if (amount == null || amount <= 0) {
      return '请输入有效的工资金额';
    }
    return null;
  }

  /// 验证工资历史日期
  static String? validateSalaryHistoryDate(DateTime? date) {
    if (date == null) {
      return '请选择生效日期';
    }
    if (date.isAfter(DateTime.now().add(const Duration(days: 365)))) {
      return '生效日期不能超过一年后';
    }
    if (date.isBefore(DateTime(2020))) {
      return '生效日期不能早于2020年';
    }
    return null;
  }

  /// 验证奖金生效日期
  static String? validateBonusStartDate(DateTime? date) {
    if (date == null) {
      return '请选择开始日期';
    }
    if (date.isAfter(DateTime(2030))) {
      return '开始日期不能超过2030年';
    }
    if (date.isBefore(DateTime(2020))) {
      return '开始日期不能早于2020年';
    }
    return null;
  }

  /// 验证奖金结束日期（可选）
  static String? validateBonusEndDate(DateTime? startDate, DateTime? endDate) {
    if (endDate == null) {
      return null; // 可选字段
    }
    if (startDate != null && endDate.isBefore(startDate)) {
      return '结束日期不能早于开始日期';
    }
    if (endDate.isAfter(DateTime(2030))) {
      return '结束日期不能超过2030年';
    }
    return null;
  }

  /// 验证专项附加扣除金额
  static String? validateSpecialDeduction(String? value) {
    if (value?.isEmpty ?? true) {
      return null;
    }
    final amount = double.tryParse(value!);
    if (amount == null || amount < 0) {
      return '请输入有效的金额';
    }
    if (amount > 60000) {
      return '专项附加扣除全年最高6万元';
    }
    return null;
  }

  /// 验证月份数
  static String? validateMonths(String? value, {int maxMonths = 12}) {
    if (value?.isEmpty ?? true) {
      return '请输入月份数';
    }
    final months = int.tryParse(value!);
    if (months == null || months < 1) {
      return '请输入有效的月份数';
    }
    if (months > maxMonths) {
      return '月份数不能超过$maxMonths';
    }
    return null;
  }
}
