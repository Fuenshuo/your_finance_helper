import 'package:equatable/equatable.dart';

// 币种信息模型
class Currency extends Equatable { // 是否启用

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    this.decimalPlaces = 2,
    this.flag,
    this.isActive = true,
  });

  // 反序列化
  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
      code: json['code'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      decimalPlaces: json['decimalPlaces'] as int? ?? 2,
      flag: json['flag'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  final String code; // 币种代码，如 'CNY', 'USD', 'EUR'
  final String name; // 币种名称，如 '人民币', '美元', '欧元'
  final String symbol; // 币种符号，如 '¥', '$', '€'
  final int decimalPlaces; // 小数位数
  final String? flag; // 国旗emoji
  final bool isActive;

  // 常用币种
  static const List<Currency> commonCurrencies = [
    Currency(code: 'CNY', name: '人民币', symbol: '¥', flag: '🇨🇳'),
    Currency(code: 'USD', name: '美元', symbol: r'$', flag: '🇺🇸'),
    Currency(code: 'EUR', name: '欧元', symbol: '€', flag: '🇪🇺'),
    Currency(code: 'GBP', name: '英镑', symbol: '£', flag: '🇬🇧'),
    Currency(code: 'JPY', name: '日元', symbol: '¥', flag: '🇯🇵'),
    Currency(code: 'HKD', name: '港币', symbol: r'HK$', flag: '🇭🇰'),
    Currency(code: 'KRW', name: '韩元', symbol: '₩', flag: '🇰🇷'),
    Currency(code: 'SGD', name: '新加坡元', symbol: r'S$', flag: '🇸🇬'),
    Currency(code: 'AUD', name: '澳元', symbol: r'A$', flag: '🇦🇺'),
    Currency(code: 'CAD', name: '加元', symbol: r'C$', flag: '🇨🇦'),
  ];

  // 根据代码获取币种
  static Currency? fromCode(String code) {
    try {
      return commonCurrencies.firstWhere((currency) => currency.code == code);
    } catch (e) {
      return null;
    }
  }

  // 复制并修改
  Currency copyWith({
    String? code,
    String? name,
    String? symbol,
    int? decimalPlaces,
    String? flag,
    bool? isActive,
  }) => Currency(
      code: code ?? this.code,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
      flag: flag ?? this.flag,
      isActive: isActive ?? this.isActive,
    );

  // 序列化
  Map<String, dynamic> toJson() => {
      'code': code,
      'name': name,
      'symbol': symbol,
      'decimalPlaces': decimalPlaces,
      'flag': flag,
      'isActive': isActive,
    };

  @override
  List<Object?> get props => [code, name, symbol, decimalPlaces, flag, isActive];
}

// 汇率信息模型
class ExchangeRate extends Equatable { // 数据来源

  const ExchangeRate({
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.updateTime,
    this.source,
  });

  // 反序列化
  factory ExchangeRate.fromJson(Map<String, dynamic> json) => ExchangeRate(
      fromCurrency: json['fromCurrency'] as String,
      toCurrency: json['toCurrency'] as String,
      rate: json['rate'] as double,
      updateTime: DateTime.parse(json['updateTime'] as String),
      source: json['source'] as String?,
    );
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final DateTime updateTime;
  final String? source;

  // 复制并修改
  ExchangeRate copyWith({
    String? fromCurrency,
    String? toCurrency,
    double? rate,
    DateTime? updateTime,
    String? source,
  }) => ExchangeRate(
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      rate: rate ?? this.rate,
      updateTime: updateTime ?? this.updateTime,
      source: source ?? this.source,
    );

  // 序列化
  Map<String, dynamic> toJson() => {
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'rate': rate,
      'updateTime': updateTime.toIso8601String(),
      'source': source,
    };

  @override
  List<Object?> get props => [fromCurrency, toCurrency, rate, updateTime, source];
}

// 币种转换工具类
class CurrencyConverter {
  static double convertAmount({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
    required List<ExchangeRate> exchangeRates,
  }) {
    if (fromCurrency == toCurrency) {
      return amount;
    }

    // 查找直接汇率
    final directRate = exchangeRates.firstWhere(
      (rate) => rate.fromCurrency == fromCurrency && rate.toCurrency == toCurrency,
      orElse: () => throw Exception('No direct exchange rate found for $fromCurrency to $toCurrency'),
    );

    return amount * directRate.rate;
  }

  // 格式化金额显示
  static String formatAmount({
    required double amount,
    required Currency currency,
    bool showSymbol = true,
  }) {
    final formattedAmount = amount.toStringAsFixed(currency.decimalPlaces);
    if (showSymbol) {
      return '${currency.symbol}$formattedAmount';
    }
    return formattedAmount;
  }

  // 获取汇率键
  static String getRateKey(String fromCurrency, String toCurrency) => '${fromCurrency}_$toCurrency';
}
