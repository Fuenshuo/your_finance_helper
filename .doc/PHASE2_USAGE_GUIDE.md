# Phase 2 AI功能使用指南

本文档说明Phase 2新增的AI功能应该在哪里使用，以及如何集成到现有UI中。

## 📍 功能使用位置

### 1. 智能分类推荐 (`CategoryRecommendationService`)

**使用位置**: `lib/features/transaction_flow/screens/add_transaction_screen.dart`

**集成方式**:
- 在用户输入交易描述时，自动调用分类推荐服务
- 当用户输入描述后（如：`_descriptionController` 的 `onChanged` 回调），调用推荐服务
- 显示推荐结果，用户可以确认或修改

**代码示例**:
```dart
// 在 AddTransactionScreen 中添加
void _onDescriptionChanged(String value) async {
  if (value.isNotEmpty && value.length > 3) {
    // 延迟500ms，避免频繁调用
    await Future.delayed(Duration(milliseconds: 500));
    
    final service = await CategoryRecommendationService.getInstance();
    final accounts = Provider.of<AccountProvider>(context, listen: false).accounts;
    final transactions = Provider.of<TransactionProvider>(context, listen: false).transactions;
    
    final recommendation = await service.recommendCategory(
      description: value,
      userHistory: transactions.take(50).toList(),
      transactionType: _selectedType,
    );
    
    if (recommendation.confidence > 0.5) {
      setState(() {
        _selectedCategory = recommendation.category;
        _selectedSubCategory = recommendation.subCategory;
      });
      
      // 可选：显示推荐理由
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('推荐分类: ${recommendation.category.displayName}')),
      );
    }
  }
}
```

**UI建议**:
- 在分类选择器上方显示"AI推荐"标签
- 如果置信度 > 0.7，高亮显示推荐分类
- 显示推荐理由（如果提供）

---

### 2. 银行账单识别 (`BankStatementRecognitionService`)

**使用位置**: `lib/features/transaction_flow/widgets/ai_smart_accounting_widget.dart`

**集成方式**:
- 在 `AiSmartAccountingWidget` 中添加第三个模式选项："银行账单识别"
- 创建新的Widget：`BankStatementRecognitionWidget`
- 识别完成后，批量创建交易记录

**代码示例**:
```dart
// 1. 更新 AiSmartAccountingMode 枚举
enum AiSmartAccountingMode {
  naturalLanguage,
  invoiceRecognition,
  bankStatement, // 新增
}

// 2. 在 _buildModeButton 中添加第三个按钮
Expanded(
  child: _buildModeButton(
    context,
    mode: AiSmartAccountingMode.bankStatement,
    icon: Icons.account_balance,
    title: '银行账单',
    subtitle: '批量识别',
    color: const Color(0xFF9C27B0),
  ),
),

// 3. 在 _buildAiContent 中添加处理逻辑
case AiSmartAccountingMode.bankStatement:
  return BankStatementRecognitionWidget(
    onRecognized: (result) => _handleBankStatementResult(context, result),
  );
```

**新建Widget**: `lib/features/transaction_flow/widgets/bank_statement_recognition_widget.dart`
- 参考 `InvoiceRecognitionWidget` 的实现
- 识别完成后，显示识别到的交易列表
- 用户可以选择要导入的交易（去重后）
- 批量创建交易记录

---

### 3. 工资条识别 (`PayrollRecognitionService`)

**使用位置**: `lib/features/family_info/screens/salary_income_setup_screen.dart`

**集成方式**:
- 在工资收入设置页面添加"拍照识别工资条"按钮
- 识别完成后，自动填充表单字段
- 用户确认后保存

**代码示例**:
```dart
// 在 SalaryIncomeSetupScreen 的 AppBar 或顶部添加按钮
AppBar(
  actions: [
    IconButton(
      icon: Icon(Icons.camera_alt),
      onPressed: () => _recognizePayroll(context),
      tooltip: '拍照识别工资条',
    ),
  ],
),

// 添加识别方法
Future<void> _recognizePayroll(BuildContext context) async {
  try {
    // 1. 选择图片
    final imageService = ImageProcessingService.getInstance();
    final imageFile = await imageService.pickImageFromGallery();
    if (imageFile == null) return;
    
    // 2. 保存图片
    final imagePath = await imageService.saveImageToAppDirectory(imageFile);
    
    // 3. 识别工资条
    final service = await PayrollRecognitionService.getInstance();
    final result = await service.recognizePayroll(imagePath: imagePath);
    
    // 4. 转换为SalaryIncome并填充表单
    final salaryIncome = result.toSalaryIncome(
      name: _nameController.text.isNotEmpty 
          ? _nameController.text 
          : '工资收入',
      salaryDay: _salaryDay,
    );
    
    // 5. 填充所有字段
    setState(() {
      _basicSalaryController.text = salaryIncome.basicSalary.toStringAsFixed(2);
      _housingAllowanceController.text = salaryIncome.housingAllowance.toStringAsFixed(2);
      _mealAllowanceController.text = salaryIncome.mealAllowance.toStringAsFixed(2);
      _transportationAllowanceController.text = salaryIncome.transportationAllowance.toStringAsFixed(2);
      _otherAllowanceController.text = salaryIncome.otherAllowance.toStringAsFixed(2);
      _personalIncomeTaxController.text = salaryIncome.personalIncomeTax.toStringAsFixed(2);
      _socialInsuranceController.text = salaryIncome.socialInsurance.toStringAsFixed(2);
      _housingFundController.text = salaryIncome.housingFund.toStringAsFixed(2);
      _otherDeductionsController.text = salaryIncome.otherDeductions.toStringAsFixed(2);
      _specialDeductionController.text = salaryIncome.specialDeductionMonthly.toStringAsFixed(2);
      _otherTaxDeductionsController.text = salaryIncome.otherTaxDeductions.toStringAsFixed(2);
      _bonuses = salaryIncome.bonuses;
      _salaryDay = salaryIncome.salaryDay;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('工资条识别成功！税前收入: ${result.summary.grossIncome}元')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('识别失败: $e')),
    );
  }
}
```

**UI建议**:
- 在页面顶部添加一个醒目的"📷 拍照识别工资条"按钮
- 识别过程中显示进度指示器
- 识别完成后高亮显示填充的字段

---

### 4. 资产照片估值 (`AssetValuationService`)

**使用位置**: 
- `lib/features/family_info/screens/add_asset_flow_screen.dart` (添加资产时)
- `lib/features/family_info/screens/edit_asset_sheet.dart` (编辑资产时)

**集成方式**:
- 在添加/编辑资产时，提供"拍照估值"选项
- 识别完成后，自动填充资产信息（品牌、型号、成色、估值）

**代码示例**:
```dart
// 在 AddAssetSheet 或 EditAssetSheet 中添加按钮
ElevatedButton.icon(
  icon: Icon(Icons.camera_alt),
  label: Text('拍照估值'),
  onPressed: () => _valuateAsset(context),
),

// 添加估值方法
Future<void> _valuateAsset(BuildContext context) async {
  try {
    // 1. 选择图片
    final imageService = ImageProcessingService.getInstance();
    final imageFile = await imageService.pickImageFromGallery();
    if (imageFile == null) return;
    
    // 2. 保存图片
    final imagePath = await imageService.saveImageToAppDirectory(imageFile);
    
    // 3. 识别并估值
    final service = await AssetValuationService.getInstance();
    final result = await service.valuateAsset(imagePath: imagePath);
    
    // 4. 填充表单字段
    setState(() {
      _nameController.text = '${result.brand} ${result.model}';
      _amountController.text = result.estimatedValue.toStringAsFixed(2);
      // 根据assetType设置分类
      // 根据condition设置备注
      _notesController.text = '成色: ${result.condition.displayName}\n'
          '品牌: ${result.brand}\n'
          '型号: ${result.model}\n'
          '${result.valuationReason ?? ''}';
    });
    
    // 5. 显示估值结果对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('估值结果'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('品牌: ${result.brand}'),
            Text('型号: ${result.model}'),
            Text('成色: ${result.condition.displayName}'),
            Text('估算价值: ¥${result.estimatedValue.toStringAsFixed(2)}'),
            Text('置信度: ${(result.confidence * 100).toStringAsFixed(0)}%'),
            if (result.valuationReason != null)
              Text('理由: ${result.valuationReason}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('确认'),
          ),
        ],
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('估值失败: $e')),
    );
  }
}
```

**UI建议**:
- 在资产名称输入框旁边添加"📷 拍照"按钮
- 估值完成后，显示估值结果卡片（品牌、型号、成色、价值、置信度）
- 用户可以确认使用估值结果，或手动修改

---

## 🔧 集成步骤总结

### 步骤1: 智能分类推荐
1. 在 `AddTransactionScreen` 中添加描述输入监听
2. 调用 `CategoryRecommendationService.recommendCategory()`
3. 更新UI显示推荐结果

### 步骤2: 银行账单识别
1. 创建 `BankStatementRecognitionWidget`
2. 在 `AiSmartAccountingWidget` 中添加新模式
3. 实现批量交易创建逻辑

### 步骤3: 工资条识别
1. 在 `SalaryIncomeSetupScreen` 添加拍照按钮
2. 调用 `PayrollRecognitionService.recognizePayroll()`
3. 自动填充表单字段

### 步骤4: 资产照片估值
1. 在资产添加/编辑页面添加拍照按钮
2. 调用 `AssetValuationService.valuateAsset()`
3. 自动填充资产信息

---

## 📝 注意事项

1. **错误处理**: 所有AI调用都应该有try-catch错误处理
2. **加载状态**: 显示加载指示器，让用户知道AI正在处理
3. **用户确认**: AI结果应该允许用户修改和确认
4. **性能优化**: 分类推荐可以添加防抖（debounce），避免频繁调用
5. **权限检查**: 拍照功能需要检查相机和相册权限

---

## 🎯 优先级建议

1. **高优先级**: 智能分类推荐（提升用户体验最明显）
2. **中优先级**: 工资条识别（高频场景）
3. **中优先级**: 资产照片估值（实用功能）
4. **低优先级**: 银行账单识别（需要批量处理逻辑）

---

**文档版本**: v1.0  
**创建时间**: 2025-01-13  
**维护者**: 开发团队

