import 'package:intl/intl.dart';

/// AI日期解析工具类
/// 统一处理AI返回的日期解析逻辑，确保日期合理性和准确性
class AiDateParser {
  AiDateParser._();

  /// 解析AI返回的日期字符串
  ///
  /// [dateStr] AI返回的日期字符串（可能是各种格式）
  /// [defaultDate] 默认日期（如果解析失败或日期不合理，使用此日期）
  /// [maxDaysAgo] 允许的最大天数（默认365天，即1年前）
  /// [maxDaysFuture] 允许的最大未来天数（默认7天）
  ///
  /// 返回解析后的日期，如果解析失败或日期不合理，返回defaultDate
  static DateTime parseDate({
    String? dateStr,
    DateTime? defaultDate,
    int maxDaysAgo = 365,
    int maxDaysFuture = 7,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final defaultDateTime = defaultDate ?? today;

    // 如果没有提供日期字符串，返回默认日期
    if (dateStr == null || dateStr.trim().isEmpty) {
      return defaultDateTime;
    }

    try {
      // 尝试解析日期字符串
      DateTime? parsedDate;

      // 处理常见的中文日期表达
      final normalizedStr = _normalizeDateString(dateStr.trim());

      // 尝试多种日期格式
      final formats = [
        'yyyy-MM-dd',
        'yyyy/MM/dd',
        'yyyy-MM-dd HH:mm:ss',
        'yyyy/MM/dd HH:mm:ss',
        'MM-dd-yyyy',
        'MM/dd/yyyy',
        'dd-MM-yyyy',
        'dd/MM/yyyy',
      ];

      for (final format in formats) {
        try {
          parsedDate = DateFormat(format).parse(normalizedStr);
          break;
        } catch (e) {
          // 继续尝试下一个格式
        }
      }

      // 如果所有格式都失败，尝试直接解析ISO格式
      if (parsedDate == null) {
        try {
          parsedDate = DateTime.parse(normalizedStr);
        } catch (e) {
          // 解析失败
        }
      }

      // 如果仍然无法解析，返回默认日期
      if (parsedDate == null) {
        print('[AiDateParser.parseDate] ⚠️ 无法解析日期: $dateStr，使用默认日期');
        return defaultDateTime;
      }

      // 只保留日期部分（去掉时间）
      final dateOnly =
          DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

      // 验证日期合理性
      final daysDifference = dateOnly.difference(today).inDays;

      // 如果日期在未来超过maxDaysFuture天，认为不合理，使用默认日期
      if (daysDifference > maxDaysFuture) {
        print(
          '[AiDateParser.parseDate] ⚠️ 日期在未来过远: $dateStr ($daysDifference天后)，使用默认日期',
        );
        return defaultDateTime;
      }

      // 如果日期在过去超过maxDaysAgo天，认为不合理，使用默认日期
      if (daysDifference < -maxDaysAgo) {
        print(
          '[AiDateParser.parseDate] ⚠️ 日期在过去过远: $dateStr (${-daysDifference}天前)，使用默认日期',
        );
        return defaultDateTime;
      }

      print(
        '[AiDateParser.parseDate] ✅ 日期解析成功: $dateStr -> ${DateFormat('yyyy-MM-dd').format(dateOnly)}',
      );
      return dateOnly;
    } catch (e) {
      print('[AiDateParser.parseDate] ❌ 日期解析异常: $dateStr, 错误: $e，使用默认日期');
      return defaultDateTime;
    }
  }

  /// 标准化日期字符串
  /// 处理常见的中文日期表达和格式问题
  static String _normalizeDateString(String dateStr) {
    var normalized = dateStr;

    // 替换常见的中文日期表达
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    // 处理相对日期
    if (normalized.contains('今天') || normalized.contains('今日')) {
      normalized = DateFormat('yyyy-MM-dd').format(today);
    } else if (normalized.contains('昨天') || normalized.contains('昨日')) {
      normalized = DateFormat('yyyy-MM-dd').format(yesterday);
    } else if (normalized.contains('明天') || normalized.contains('明日')) {
      normalized = DateFormat('yyyy-MM-dd').format(tomorrow);
    } else if (normalized.contains('前天')) {
      final dayBeforeYesterday = today.subtract(const Duration(days: 2));
      normalized = DateFormat('yyyy-MM-dd').format(dayBeforeYesterday);
    } else if (normalized.contains('后天')) {
      final dayAfterTomorrow = today.add(const Duration(days: 2));
      normalized = DateFormat('yyyy-MM-dd').format(dayAfterTomorrow);
    }

    // 移除常见的中文标点
    normalized = normalized
        .replaceAll('年', '-')
        .replaceAll('月', '-')
        .replaceAll('日', '')
        .replaceAll('号', '');

    // 清理多余的空白字符
    normalized = normalized.trim();

    return normalized;
  }

  /// 验证日期是否合理
  ///
  /// [date] 要验证的日期
  /// [maxDaysAgo] 允许的最大天数（默认365天）
  /// [maxDaysFuture] 允许的最大未来天数（默认7天）
  ///
  /// 返回true表示日期合理，false表示不合理
  static bool isValidDate({
    required DateTime date,
    int maxDaysAgo = 365,
    int maxDaysFuture = 7,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final daysDifference = dateOnly.difference(today).inDays;

    return daysDifference >= -maxDaysAgo && daysDifference <= maxDaysFuture;
  }

  /// 格式化日期为字符串（用于显示）
  static String formatDate(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);
}
