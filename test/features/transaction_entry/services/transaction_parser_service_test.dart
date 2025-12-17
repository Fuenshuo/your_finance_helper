import 'package:flutter_test/flutter_test.dart';
import 'package:your_finance_flutter/features/transaction_entry/services/transaction_parser_service.dart';
import 'package:your_finance_flutter/features/transaction_entry/models/draft_transaction.dart';

void main() {
  late TransactionParserService parserService;

  setUp(() {
    parserService = DefaultTransactionParserService();
  });

  group('TransactionParserService', () {
    group('parseAmount', () {
      test('should parse simple amount', () {
        expect(parserService.parseAmount('花了25元'), 25.0);
        expect(parserService.parseAmount('收入100'), 100.0);
        expect(parserService.parseAmount('消费50.5'), 50.5);
      });

      test('should parse amount with currency symbols', () {
        expect(parserService.parseAmount('¥100'), 100.0);
        expect(parserService.parseAmount('\$50'), 50.0);
        expect(parserService.parseAmount('€75.5'), 75.5);
        expect(parserService.parseAmount('£200'), 200.0);
      });

      test('should parse amount with Chinese characters', () {
        expect(parserService.parseAmount('一百元'), 100.0);
        expect(parserService.parseAmount('五十块'), 50.0);
        expect(parserService.parseAmount('二十五元五角'), 25.5);
      });

      test('should handle decimal amounts', () {
        expect(parserService.parseAmount('25.50'), 25.5);
        expect(parserService.parseAmount('100.00'), 100.0);
        expect(parserService.parseAmount('0.5'), 0.5);
      });

      test('should return null for invalid amounts', () {
        expect(parserService.parseAmount('没有金额'), isNull);
        expect(parserService.parseAmount(''), isNull);
        expect(parserService.parseAmount('abc'), isNull);
      });

      test('should prioritize first valid amount', () {
        expect(parserService.parseAmount('买了50元又花了25元'), 50.0);
        expect(parserService.parseAmount('收入100和支出50'), 100.0);
      });
    });

    group('parseDescription', () {
      test('should extract description from simple text', () {
        expect(parserService.parseDescription('午饭'), '午饭');
        expect(parserService.parseDescription('买咖啡'), '买咖啡');
        expect(parserService.parseDescription('地铁费'), '地铁费');
      });

      test('should extract description excluding amount', () {
        expect(parserService.parseDescription('午饭25元'), '午饭');
        expect(parserService.parseDescription('买咖啡50块'), '买咖啡');
        expect(parserService.parseDescription('地铁费15元'), '地铁费');
      });

      test('should handle complex descriptions', () {
        expect(parserService.parseDescription('星巴克买咖啡花了35元'), '星巴克买咖啡');
        expect(parserService.parseDescription('超市购物消费120.5元'), '超市购物');
        expect(parserService.parseDescription('电影票和爆米花一共80元'), '电影票和爆米花');
      });

      test('should return null for amount-only input', () {
        expect(parserService.parseDescription('25元'), isNull);
        expect(parserService.parseDescription('100'), isNull);
        expect(parserService.parseDescription('¥50'), isNull);
      });
    });

    group('inferTransactionType', () {
      test('should infer expense from keywords', () {
        expect(parserService.inferTransactionType('买午饭25元'), TransactionType.expense);
        expect(parserService.inferTransactionType('超市购物50元'), TransactionType.expense);
        expect(parserService.inferTransactionType('交水费30元'), TransactionType.expense);
        expect(parserService.inferTransactionType('消费100元'), TransactionType.expense);
      });

      test('should infer income from keywords', () {
        expect(parserService.inferTransactionType('工资收入5000元'), TransactionType.income);
        expect(parserService.inferTransactionType('奖金1000元'), TransactionType.income);
        expect(parserService.inferTransactionType('收到分红2000元'), TransactionType.income);
        expect(parserService.inferTransactionType('利息收入50元'), TransactionType.income);
      });

      test('should infer transfer from keywords', () {
        expect(parserService.inferTransactionType('转账给朋友100元'), TransactionType.transfer);
        expect(parserService.inferTransactionType('汇款200元'), TransactionType.transfer);
        expect(parserService.inferTransactionType('还款50元'), TransactionType.transfer);
      });

      test('should return null when type cannot be determined', () {
        expect(parserService.inferTransactionType('25元'), isNull);
        expect(parserService.inferTransactionType('中午'), isNull);
        expect(parserService.inferTransactionType(''), isNull);
      });
    });

    group('calculateConfidence', () {
      test('should calculate high confidence for complete information', () {
        final draft = DraftTransaction(
          amount: 25.0,
          description: '午饭',
          type: TransactionType.expense,
          confidence: 0.0, // Will be overridden
        );

        final confidence = parserService.calculateConfidence(draft);
        expect(confidence, greaterThan(0.8));
      });

      test('should calculate medium confidence for partial information', () {
        final draft = DraftTransaction(
          amount: 25.0,
          description: '午饭',
          type: null,
          confidence: 0.0,
        );

        final confidence = parserService.calculateConfidence(draft);
        expect(confidence, greaterThan(0.5));
        expect(confidence, lessThan(0.8));
      });

      test('should calculate low confidence for minimal information', () {
        final draft = DraftTransaction(
          amount: 25.0,
          description: null,
          type: null,
          confidence: 0.0,
        );

        final confidence = parserService.calculateConfidence(draft);
        expect(confidence, lessThan(0.5));
      });
    });

    group('parseTransaction - Integration Tests', () {
      test('should parse complete expense transaction', () async {
        const input = '星巴克买咖啡花了35元';

        final draft = await parserService.parseTransaction(input);

        expect(draft.amount, 35.0);
        expect(draft.description, contains('星巴克'));
        expect(draft.type, TransactionType.expense);
        expect(draft.confidence, greaterThan(0.7));
      });

      test('should parse income transaction', () async {
        const input = '工资收入5000元';

        final draft = await parserService.parseTransaction(input);

        expect(draft.amount, 5000.0);
        expect(draft.description, contains('工资'));
        expect(draft.type, TransactionType.income);
        expect(draft.confidence, greaterThan(0.7));
      });

      test('should parse transfer transaction', () async {
        const input = '转账给朋友200元';

        final draft = await parserService.parseTransaction(input);

        expect(draft.amount, 200.0);
        expect(draft.description, contains('转账'));
        expect(draft.type, TransactionType.transfer);
        expect(draft.confidence, greaterThan(0.6));
      });

      test('should handle complex transaction descriptions', () async {
        const input = '今天中午在麦当劳吃的午餐，花了45.5元，用信用卡支付';

        final draft = await parserService.parseTransaction(input);

        expect(draft.amount, 45.5);
        expect(draft.description, contains('麦当劳'));
        expect(draft.type, TransactionType.expense);
        expect(draft.confidence, greaterThan(0.7));
      });

      test('should handle minimal input', () async {
        const input = '25元';

        final draft = await parserService.parseTransaction(input);

        expect(draft.amount, 25.0);
        expect(draft.description, isNull);
        expect(draft.type, isNull);
        expect(draft.confidence, lessThan(0.5));
      });

      test('should reject empty input', () async {
        const input = '';

        expect(
          () => parserService.parseTransaction(input),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should reject whitespace-only input', () async {
        const input = '   \n\t   ';

        expect(
          () => parserService.parseTransaction(input),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should handle very large amounts', () async {
        const input = '大额转账100000元';

        final draft = await parserService.parseTransaction(input);

        expect(draft.amount, 100000.0);
        expect(draft.description, contains('大额转账'));
        expect(draft.type, TransactionType.transfer);
      });

      test('should handle small decimal amounts', () async {
        const input = '买口香糖花了2.5元';

        final draft = await parserService.parseTransaction(input);

        expect(draft.amount, 2.5);
        expect(draft.description, contains('口香糖'));
        expect(draft.type, TransactionType.expense);
      });
    });

    group('Edge Cases', () {
      test('should handle mixed currency symbols', () {
        expect(parserService.parseAmount('¥100\$50€25'), 100.0);
        expect(parserService.parseAmount('mixed_currency\$100¥50'), 100.0);
      });

      test('should handle Chinese numerals', () {
        expect(parserService.parseAmount('two_hundred_fifty_yuan'), 250.0);
        expect(parserService.parseAmount('one_thousand_yuan'), 1000.0);
        expect(parserService.parseAmount('fifty_five_yuan'), 55.0);
      });

      test('should handle multiple expense keywords', () {
        expect(parserService.inferTransactionType('买了东西又消费了'), TransactionType.expense);
        expect(parserService.inferTransactionType('购物并付款'), TransactionType.expense);
      });

      test('should handle overlapping income and expense keywords', () {
        // This is a design decision - expense keywords take precedence
        expect(parserService.inferTransactionType('收入消费100元'), TransactionType.expense);
        expect(parserService.inferTransactionType('消费收入200元'), TransactionType.expense);
      });

      test('should handle very long descriptions', () async {
        const longDescription = '这是一个非常非常长的描述，用来测试解析服务是否能够正确处理超长文本输入的情况，看看是否会影响解析的准确性和性能';
        const input = '$longDescription 100元';

        final draft = await parserService.parseTransaction(input);

        expect(draft.amount, 100.0);
        expect(draft.description, contains('非常非常长的描述'));
        expect(draft.confidence, greaterThan(0.3));
      });
    });
  });
}
