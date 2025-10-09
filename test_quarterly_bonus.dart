import 'package:your_finance_flutter/core/models/bonus_item.dart';

void main() {
  print('🔍 验证季度奖金和十三薪计算修复');
  print('=' * 50);

  // 测试季度奖金发放月份计算
  testQuarterlyPaymentMonths();

  // 测试十三薪发放月份计算
  testThirteenthSalaryCalculation();

  print('=' * 50);
  print('✅ 验证完成');
}

void testQuarterlyPaymentMonths() {
  print('🎯 测试季度奖金发放月份计算');
  print('=' * 30);

  // 测试不同开始日期的季度奖金发放月份
  final testDates = [
    DateTime(2024, 6, 20), // FY24奖金开始日期
    DateTime(2025, 5, 28), // FY25奖金开始日期
    DateTime(2025, 1, 15), // 1月开始
    DateTime(2025, 4, 15), // 4月开始
  ];

  for (final date in testDates) {
    final months = BonusItem.calculateQuarterlyPaymentMonths(date);
    print(
      '📅 开始日期: ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
    );
    print('   🎁 发放月份: ${months.join(', ')}月');
    print('');
  }
}

void testThirteenthSalaryCalculation() {
  print('🎯 测试十三薪发放月份计算');
  print('=' * 30);

  // 测试十三薪的计算逻辑
  final thirteenthSalaryBonus = BonusItem(
    id: 'test-thirteenth',
    name: '2025十三薪',
    amount: 30000.0,
    type: BonusType.thirteenthSalary,
    frequency: BonusFrequency.oneTime,
    paymentCount: 1, // 十三薪只发放一次
    startDate: DateTime(2025, 1, 15), // 1月开始
    thirteenthSalaryMonth: 1, // 设置为1月发放
    creationDate: DateTime.now(),
    updateDate: DateTime.now(),
  );

  print('📅 十三薪开始日期: ${thirteenthSalaryBonus.startDate}');
  print('   🎁 发放月份: ${thirteenthSalaryBonus.thirteenthSalaryMonth}月');
  print('   💰 发放金额: ¥${thirteenthSalaryBonus.amount}');

  // 测试各月奖金计算
  print('');
  print('📊 各月奖金计算结果:');
  for (var month = 1; month <= 12; month++) {
    final bonus = thirteenthSalaryBonus.calculateMonthlyBonus(2025, month);
    if (bonus > 0) {
      print('   $month月: ¥$bonus');
    }
  }
}

void testExistingQuarterlyBonuses() {
  // 测试数据基于终端输出 - 使用用户配置的发放月份 1/4/7/10
  final bonus1 = BonusItem(
    id: 'test-bonus-1',
    name: 'FY24',
    amount: 287840.0, // 全年总金额
    type: BonusType.quarterlyBonus,
    frequency: BonusFrequency.quarterly,
    startDate: DateTime(2024, 6, 20), // 开始日期
    paymentCount: 16, // 总发放次数
    quarterlyPaymentMonths: const [1, 4, 7, 10], // 用户配置的发放月份
    creationDate: DateTime.now(),
    updateDate: DateTime.now(),
  );

  final bonus2 = BonusItem(
    id: 'test-bonus-2',
    name: 'FY25',
    amount: 311700.0, // 全年总金额
    type: BonusType.quarterlyBonus,
    frequency: BonusFrequency.quarterly,
    startDate: DateTime(2025, 5, 28), // 开始日期
    paymentCount: 16, // 总发放次数
    quarterlyPaymentMonths: const [1, 4, 7, 10], // 用户配置的发放月份
    creationDate: DateTime.now(),
    updateDate: DateTime.now(),
  );

  final currentDate = DateTime(2025, 9, 17);
  final quarterlyMonths = [1, 4, 7, 10];
  const salaryDay = 15;

  print('🎯 奖金1 (FY24): ${bonus1.name}');
  print('   📊 总金额: ¥${bonus1.amount}');
  print('   📅 开始日期: ${bonus1.startDate}');
  print('   🔢 总发放次数: ${bonus1.paymentCount}');
  print('');

  print('🎯 奖金2 (FY25): ${bonus2.name}');
  print('   📊 总金额: ¥${bonus2.amount}');
  print('   📅 开始日期: ${bonus2.startDate}');
  print('   🔢 总发放次数: ${bonus2.paymentCount}');
  print('');

  // 手动计算应该在10月发放第几次
  print('🧮 手动计算10月应该发放第几次:');
  print('');

  calculateQuarterlyPayments(bonus1, currentDate, quarterlyMonths, salaryDay);
  print('');
  calculateQuarterlyPayments(bonus2, currentDate, quarterlyMonths, salaryDay);
}

void calculateQuarterlyPayments(
  BonusItem bonus,
  DateTime currentDate,
  List<int> quarterlyMonths,
  int salaryDay,
) {
  print('📋 计算奖金: ${bonus.name}');
  print('   开始日期: ${bonus.startDate}');
  print('   当前日期: $currentDate');

  // 找到第一个发放月份
  var tempYear = bonus.startDate.year;
  var tempMonth = bonus.startDate.month;

  // 如果开始日期不是季度月份，找到下一个季度月份
  var found = false;
  for (var i = 0; i < quarterlyMonths.length; i++) {
    final qMonth = quarterlyMonths[i];
    if (qMonth > bonus.startDate.month) {
      tempMonth = qMonth;
      found = true;
      break;
    } else if (qMonth == bonus.startDate.month) {
      if (bonus.startDate.day <= salaryDay) {
        tempMonth = qMonth;
        found = true;
      } else {
        if (i == quarterlyMonths.length - 1) {
          tempYear++;
          tempMonth = quarterlyMonths[0];
        } else {
          tempMonth = quarterlyMonths[i + 1];
        }
        found = true;
      }
      break;
    }
  }

  if (!found) {
    tempYear++;
    tempMonth = quarterlyMonths[0];
  }

  print('   🎯 第一个发放日期: $tempYear年$tempMonth月$salaryDay日');

  // 计算到10月的发放次数
  var paymentCount = 0;
  var checkYear = tempYear;
  var checkMonth = tempMonth;

  print('   📅 发放历史:');

  while (checkYear < 2025 || (checkYear == 2025 && checkMonth <= 10)) {
    final quarterlyDate = DateTime(checkYear, checkMonth, salaryDay);
    if (!quarterlyDate.isBefore(bonus.startDate)) {
      paymentCount++;
      print('      $checkYear年$checkMonth月$salaryDay日 - 第$paymentCount次发放');

      if (checkYear == 2025 && checkMonth == 10) {
        print('');
        print('   ✅ 2025年10月应该是第$paymentCount次发放');

        if (paymentCount <= 5) {
          print('   💰 应发放金额: ¥53,210 (前5次标准)');
          print('   📝 扣除费用: ¥5,525');
        } else {
          print('   💰 应发放金额: ¥72,691 (后7次标准)');
          print('   📝 扣除费用: ¥8,279');
        }
        break;
      }
    }

    var nextIdx = quarterlyMonths.indexOf(checkMonth) + 1;
    if (nextIdx >= quarterlyMonths.length) {
      nextIdx = 0;
      checkYear++;
    }
    checkMonth = quarterlyMonths[nextIdx];

    if (paymentCount >= bonus.paymentCount) {
      print('   ⏹️ 已达到最大发放次数 ${bonus.paymentCount}');
      break;
    }
  }

  print('');
}
