import 'package:flutter/material.dart';
import 'package:your_finance_flutter/widgets/amount_input_field.dart';

/// AmountInputField组件演示页面
class AmountInputDemo extends StatelessWidget {
  const AmountInputDemo({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('AmountInputField 样式演示'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '新的AmountInputField样式：',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // 公积金贷款输入框演示
              const Text('公积金贷款额度：',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              const AmountInputField(
                labelText: '公积金贷款额度',
                hintText: '请输入额度',
                prefixIcon:
                    Icon(Icons.account_balance_wallet, color: Colors.blue),
              ),

              const SizedBox(height: 20),

              // 商业贷款输入框演示
              const Text('商业贷款额度：',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              const AmountInputField(
                labelText: '商业贷款额度',
                hintText: '请输入额度',
                prefixIcon: Icon(Icons.business_center, color: Colors.orange),
              ),

              const SizedBox(height: 20),

              // 其他金额输入演示
              const Text('其他金额输入：',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Expanded(
                    child: AmountInputField(
                      labelText: '月薪',
                      hintText: '请输入月薪',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: AmountInputField(
                      labelText: '年终奖',
                      hintText: '请输入年终奖',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 样式说明
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🎨 样式特点：',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('• "元"字居中显示在右侧'),
                    Text('• 浅灰色背景块包裹整个输入区域'),
                    Text('• 输入数字不会超出底块边界'),
                    Text('• 统一的视觉风格和间距'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
