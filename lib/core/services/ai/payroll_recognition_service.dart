import 'package:your_finance_flutter/core/database/app_database.dart';
class PayrollRecognitionResult {
  const PayrollRecognitionResult({
    required this.salary,
    required this.details,
    required this.confidence,
    this.salaryDate,
    this.netIncome,
  });

  final double salary;
  final Map<String, dynamic> details;
  final double confidence;
  final DateTime? salaryDate;
  final double? netIncome;

  // Convert to SalaryIncome object
  SalaryIncome toSalaryIncome({
    required String name,
    required int salaryDay,
  }) {
    final netIncome = this.netIncome ?? salary;
    return SalaryIncome(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: '通过工资条识别创建',
      basicSalary: netIncome,
      salaryHistory: null,
      housingAllowance: 0.0,
      mealAllowance: 0.0,
      transportationAllowance: 0.0,
      otherAllowance: 0.0,
      monthlyAllowances: null,
      bonuses: '[]',
      personalIncomeTax: 0.0,
      socialInsurance: 0.0,
      housingFund: 0.0,
      otherDeductions: 0.0,
      specialDeductionMonthly: 0.0,
      otherTaxDeductions: 0.0,
      salaryDay: salaryDay,
      period: 'monthly',
      lastSalaryDate: salaryDate,
      nextSalaryDate: null,
      incomeType: 'salary',
      creationDate: DateTime.now(),
      updateDate: DateTime.now(),
    );
  }
}

class PayrollRecognitionService {
  PayrollRecognitionService._();

  static PayrollRecognitionService? _instance;

  static Future<PayrollRecognitionService> getInstance() async {
    if (_instance == null) {
      _instance = PayrollRecognitionService._();
      await _instance!._initialize();
    }
    return _instance!;
  }

  Future<void> _initialize() async {
    // TODO: Initialize AI model and OCR dependencies
  }

  Future<PayrollRecognitionResult> recognizePayroll({
    required String imagePath,
  }) async {
    // TODO: Implement AI-powered payroll recognition
    // For now, return a placeholder result
    return const PayrollRecognitionResult(
      salary: 0.0,
      details: {},
      confidence: 0.0,
    );
  }
}
