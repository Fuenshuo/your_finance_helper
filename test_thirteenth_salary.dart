import 'package:your_finance_flutter/core/models/bonus_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('十三薪在1月份应该正确显示', () {
    // 创建一个2025年1月15日开始的十三薪
    final thirteenthSalaryBonus = BonusItem(
      id: 'test-thirteenth',
      name: '2025十三薪',
      amount: 30000.0,
      type: BonusType.thirteenthSalary,
      frequency: BonusFrequency.oneTime,
      paymentCount: 1,
      startDate: DateTime(2025, 1, 15),
      thirteenthSalaryMonth: 1, // 设置为1月发放
      creationDate: DateTime.now(),
      updateDate: DateTime.now(),
    );

    // 测试1月份应该有奖金
    final januaryBonus = thirteenthSalaryBonus.calculateMonthlyBonus(2025, 1);
    print('1月份奖金: $januaryBonus');
    
    // 验证1月份应该有奖金
    expect(januaryBonus, 30000.0);
    
    // 测试其他月份应该没有奖金
    for (var month = 2; month <= 12; month++) {
      final bonus = thirteenthSalaryBonus.calculateMonthlyBonus(2025, month);
      print('$month月份奖金: $bonus');
      expect(bonus, 0.0);
    }
  });
}