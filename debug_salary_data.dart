import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final prefs = await SharedPreferences.getInstance();
  final salaryData = prefs.getString('salary_incomes_data');

  if (salaryData != null) {
    final jsonData = jsonDecode(salaryData);
    print('工资数据:');
    print(jsonEncode(jsonData, indent: '  '));

    if (jsonData is List && jsonData.isNotEmpty) {
      final firstSalary = jsonData[0];
      print('\n第一条工资记录详情:');
      print('基本工资: ${firstSalary['basicSalary']}');
      print('个税: ${firstSalary['personalIncomeTax']}');
      print('社保: ${firstSalary['socialInsurance']}');
      print('公积金: ${firstSalary['housingFund']}');
      print('专项附加扣除: ${firstSalary['specialDeductionMonthly']}');
      print('其他扣除: ${firstSalary['otherDeductions']}');
      print('其他税收扣除: ${firstSalary['otherTaxDeductions']}');
      print('净收入: ${firstSalary['netIncome']}');

      // 重新计算
      final basicSalary = firstSalary['basicSalary'] as double;
      final personalIncomeTax =
          firstSalary['personalIncomeTax'] as double? ?? 0.0;
      final socialInsurance = firstSalary['socialInsurance'] as double? ?? 0.0;
      final housingFund = firstSalary['housingFund'] as double? ?? 0.0;
      final specialDeductionMonthly =
          firstSalary['specialDeductionMonthly'] as double? ?? 0.0;
      final otherDeductions = firstSalary['otherDeductions'] as double? ?? 0.0;
      final otherTaxDeductions =
          firstSalary['otherTaxDeductions'] as double? ?? 0.0;

      final calculatedNetIncome = basicSalary -
          personalIncomeTax -
          socialInsurance -
          housingFund -
          specialDeductionMonthly -
          otherDeductions -
          otherTaxDeductions;

      print('\n重新计算的净收入: $calculatedNetIncome');
      print('存储的净收入: ${firstSalary['netIncome']}');
      print(
          '差异: ${calculatedNetIncome - (firstSalary['netIncome'] as double)}');
    }
  } else {
    print('没有找到工资数据');
  }
}
