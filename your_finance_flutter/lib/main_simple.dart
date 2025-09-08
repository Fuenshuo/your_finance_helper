import 'package:flutter/material.dart';

void main() {
  runApp(const SimpleApp());
}

class SimpleApp extends StatelessWidget {
  const SimpleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '家庭资产记账 - 简化版',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SimpleHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SimpleHomePage extends StatelessWidget {
  const SimpleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('家庭资产记账'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              '家庭资产记账应用',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Flutter版本已成功运行！',
              style: TextStyle(
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 30),
            Text(
              '功能包括：',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text('• 五大资产分类管理'),
            Text('• 资产总览仪表盘'),
            Text('• 数据可视化图表'),
            Text('• 隐私保护功能'),
            Text('• 跨平台支持'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('应用运行正常！'),
              backgroundColor: Colors.green,
            ),
          );
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
