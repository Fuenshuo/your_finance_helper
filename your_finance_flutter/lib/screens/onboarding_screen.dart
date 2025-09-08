import 'package:flutter/material.dart';
import 'add_asset_flow_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              
              // 应用图标和标题
              Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.pie_chart,
                      size: 60,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '家庭资产记账',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '全面管理您的家庭资产和负债',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              
              const Spacer(),
              
              // 功能介绍
              Column(
                children: [
                  _buildFeatureRow(
                    context,
                    Icons.account_balance_wallet,
                    '流动资金',
                    '支付宝、微信、银行存款等',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureRow(
                    context,
                    Icons.home,
                    '固定资产',
                    '房产、汽车、收藏品等',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureRow(
                    context,
                    Icons.trending_up,
                    '投资理财',
                    '股票、基金、理财产品等',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureRow(
                    context,
                    Icons.people,
                    '应收款',
                    '借出款项、押金等',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureRow(
                    context,
                    Icons.credit_card,
                    '负债管理',
                    '信用卡、房贷、车贷等',
                  ),
                ],
              ),
              
              const Spacer(),
              
              // 开始按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AddAssetFlowScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '开始添加资产',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
