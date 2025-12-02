import 'dart:convert';
import 'dart:io';

import 'package:your_finance_flutter/core/models/budget.dart' show SalaryIncome;
import 'package:your_finance_flutter/core/models/ai_config.dart';
import 'package:your_finance_flutter/core/services/ai/ai_config_service.dart';
import 'package:your_finance_flutter/core/services/ai/ai_service_factory.dart' as ai_factory;
import 'package:your_finance_flutter/core/services/ai/image_processing_service.dart';
import 'package:your_finance_flutter/core/services/ai/prompts/prompt_loader.dart';
import 'package:your_finance_flutter/core/utils/ai_date_parser.dart';

/// 工资条识别结果（简化版 - 只识别实发金额）
class PayrollRecognitionResult {
  final double netIncome; // 实发金额（税后收入）
  final DateTime? salaryDate; // 发薪日期
  final double confidence; // 置信度

  PayrollRecognitionResult({
    required this.netIncome,
    this.salaryDate,
    required this.confidence,
  });

  /// 转换为SalaryIncome对象（简化版 - 只填充实发金额）
  SalaryIncome toSalaryIncome({
    required String name,
    String? id,
    String? description,
    int? salaryDay,
  }) {
    // 使用识别到的日期或当前日期
    final salaryDate = this.salaryDate ?? DateTime.now();
    final day = salaryDay ?? salaryDate.day;

    // 简化版：只设置基本工资为实发金额，其他字段为0
    // 用户可以在UI中手动调整其他字段
    return SalaryIncome(
      id: id,
      name: name,
      description: description,
      basicSalary: netIncome, // 将实发金额作为基本工资
      housingAllowance: 0.0,
      mealAllowance: 0.0,
      transportationAllowance: 0.0,
      otherAllowance: 0.0,
      bonuses: [],
      personalIncomeTax: 0.0,
      socialInsurance: 0.0,
      housingFund: 0.0,
      otherDeductions: 0.0,
      specialDeductionMonthly: 0.0,
      otherTaxDeductions: 0.0,
      salaryDay: day,
      lastSalaryDate: salaryDate,
      nextSalaryDate: _calculateNextSalaryDate(salaryDate, day),
    );
  }

  /// 计算下次发薪日期
  DateTime _calculateNextSalaryDate(DateTime currentDate, int salaryDay) {
    var nextMonth = DateTime(currentDate.year, currentDate.month + 1, 1);
    // 确保日期有效（处理月末情况）
    final daysInMonth = DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
    final day = salaryDay > daysInMonth ? daysInMonth : salaryDay;
    return DateTime(nextMonth.year, nextMonth.month, day);
  }
}

/// 工资条识别服务（简化版）
/// 只识别工资条的实发金额，不解析复杂字段
class PayrollRecognitionService {
  PayrollRecognitionService._();
  static PayrollRecognitionService? _instance;

  static Future<PayrollRecognitionService> getInstance() async {
    _instance ??= PayrollRecognitionService._();
    return _instance!;
  }

  /// 识别工资条
  ///
  /// [imagePath] 工资条图片路径
  ///
  /// 返回识别结果
  Future<PayrollRecognitionResult> recognizePayroll({
    required String imagePath,
  }) async {
    print(
      '[PayrollRecognitionService.recognizePayroll] 📸 开始识别工资条: $imagePath',
    );

    try {
      // 1. 获取AI配置
      final configService = await AiConfigService.getInstance();
      final config = await configService.loadConfig();

      if (config == null || !config.enabled) {
        throw Exception('AI服务未配置或已禁用');
      }

      // 2. 创建AI服务实例
      final aiService = ai_factory.aiServiceFactory.createService(config);

      // 3. 处理图片
      final imageService = ImageProcessingService.getInstance();
      final imageFile = File(imagePath);
      final imageBase64 = await imageService.convertToBase64(imageFile);

      // 4. 构建提示词
      final systemPrompt = await PromptLoader.loadPayrollRecognitionPrompt();

      // 5. 调用Vision模型
      final response = await aiService.sendVisionMessage(
        messages: [
          AiMessage(
            role: 'user',
            content: systemPrompt,
            images: [imageBase64],
          ),
        ],
        temperature: 0.2, // 降低温度以提高准确性
        maxTokens: 1500,
      );

      print(
        '[PayrollRecognitionService.recognizePayroll] ✅ AI响应: ${response.content}',
      );

      // 6. 解析响应
      final result = _parseAiResponse(response.content);

      print(
        '[PayrollRecognitionService.recognizePayroll] ✅ 识别完成: 实发金额=${result.netIncome}元, 置信度=${result.confidence}',
      );

      return result;
    } catch (e, stackTrace) {
      print(
        '[PayrollRecognitionService.recognizePayroll] ❌ 识别失败: $e',
      );
      print(
        '[PayrollRecognitionService.recognizePayroll] 堆栈: $stackTrace',
      );
      rethrow;
    }
  }

  /// 解析AI响应（简化版 - 只解析实发金额）
  PayrollRecognitionResult _parseAiResponse(String response) {
    try {
      // 尝试提取JSON（可能包含markdown代码块）
      var jsonStr = response.trim();

      // 移除markdown代码块标记
      if (jsonStr.startsWith('```')) {
        final lines = jsonStr.split('\n');
        jsonStr = lines.skip(1).take(lines.length - 2).join('\n');
      }

      // 移除可能的json标记
      if (jsonStr.startsWith('json')) {
        jsonStr = jsonStr.substring(4).trim();
      }

      // 解析JSON
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      // 解析实发金额
      final netIncome = (json['netIncome'] as num?)?.toDouble() ?? 0.0;

      // 解析发薪日期
      DateTime? salaryDate;
      final salaryDateStr = json['salaryDate'] as String?;
      if (salaryDateStr != null && salaryDateStr.isNotEmpty) {
        try {
          salaryDate = AiDateParser.parseDate(
            dateStr: salaryDateStr,
            defaultDate: DateTime.now(),
          );
        } catch (e) {
          print(
            '[PayrollRecognitionService._parseAiResponse] ⚠️ 日期解析失败: $salaryDateStr',
          );
        }
      }

      // 解析置信度
      final confidence = (json['confidence'] as num?)?.toDouble() ?? 0.5;

      return PayrollRecognitionResult(
        netIncome: netIncome,
        salaryDate: salaryDate,
        confidence: confidence,
      );
    } catch (e) {
      print(
        '[PayrollRecognitionService._parseAiResponse] ❌ JSON解析失败: $e',
      );
      print(
        '[PayrollRecognitionService._parseAiResponse] 响应内容: $response',
      );
      rethrow;
    }
  }
}

