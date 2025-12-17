import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// Tables
part 'app_database.g.dart';

/// Drift database for the financial management app
/// Implements type-safe SQLite operations for all financial data
@DriftDatabase(
  tables: [
    Assets,
    Transactions,
    Accounts,
    EnvelopeBudgets,
    ZeroBasedBudgets,
    SalaryIncomes,
    AssetHistories,
    ExpensePlans,
    IncomePlans,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// 构造函数
  AppDatabase() : super(_openConnection());

  /// 数据库schema版本
  @override
  int get schemaVersion => 1;

  /// 数据库迁移策略
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Handle future migrations here
        },
      );

  // ============================================================================
  // Asset Operations
  // ============================================================================

  /// 获取所有资产
  Future<List<Asset>> getAllAssets() => select(assets).get();

  /// 根据ID获取资产
  Future<Asset?> getAssetById(String id) =>
      (select(assets)..where((a) => a.id.equals(id))).getSingleOrNull();

  /// 插入新资产
  Future<int> insertAsset(AssetsCompanion asset) => into(assets).insert(asset);

  /// 更新资产信息
  Future<bool> updateAsset(AssetsCompanion asset) =>
      update(assets).replace(asset);

  /// 删除资产
  Future<int> deleteAsset(String id) =>
      (delete(assets)..where((a) => a.id.equals(id))).go();

  /// 监听所有资产变化
  Stream<List<Asset>> watchAllAssets() => select(assets).watch();

  // ============================================================================
  // Transaction Operations
  // ============================================================================

  /// 获取所有交易记录
  Future<List<Transaction>> getAllTransactions() => select(transactions).get();

  /// 获取指定账户的交易记录
  Future<List<Transaction>> getTransactionsByAccount(String accountId) =>
      (select(transactions)
            ..where(
              (t) =>
                  t.fromAccountId.equals(accountId) |
                  t.toAccountId.equals(accountId),
            ))
          .get();

  /// 插入新交易记录
  Future<int> insertTransaction(TransactionsCompanion transaction) =>
      into(transactions).insert(transaction);

  /// 更新交易记录
  Future<bool> updateTransaction(TransactionsCompanion transaction) =>
      update(transactions).replace(transaction);

  /// 删除交易记录
  Future<int> deleteTransaction(String id) =>
      (delete(transactions)..where((t) => t.id.equals(id))).go();

  // ============================================================================
  // Account Operations
  // ============================================================================

  /// 获取所有账户
  Future<List<Account>> getAllAccounts() => select(accounts).get();

  /// 根据ID获取账户
  Future<Account?> getAccountById(String id) =>
      (select(accounts)..where((a) => a.id.equals(id))).getSingleOrNull();

  /// 插入新账户
  Future<int> insertAccount(AccountsCompanion account) =>
      into(accounts).insert(account);

  /// 更新账户信息
  Future<bool> updateAccount(AccountsCompanion account) =>
      update(accounts).replace(account);

  /// 删除账户
  Future<int> deleteAccount(String id) =>
      (delete(accounts)..where((a) => a.id.equals(id))).go();

  // ============================================================================
  // Budget Operations
  // ============================================================================

  /// 获取所有信封预算
  Future<List<EnvelopeBudget>> getAllEnvelopeBudgets() =>
      select(envelopeBudgets).get();

  /// 获取所有零基预算
  Future<List<ZeroBasedBudget>> getAllZeroBasedBudgets() =>
      select(zeroBasedBudgets).get();

  /// 插入信封预算
  Future<int> insertEnvelopeBudget(EnvelopeBudgetsCompanion budget) =>
      into(envelopeBudgets).insert(budget);

  /// 插入零基预算
  Future<int> insertZeroBasedBudget(ZeroBasedBudgetsCompanion budget) =>
      into(zeroBasedBudgets).insert(budget);

  /// 删除信封预算
  Future<int> deleteEnvelopeBudget(String id) =>
      (delete(envelopeBudgets)..where((b) => b.id.equals(id))).go();

  /// 删除零基预算
  Future<int> deleteZeroBasedBudget(String id) =>
      (delete(zeroBasedBudgets)..where((b) => b.id.equals(id))).go();

  // ============================================================================
  // Salary Income Operations
  // ============================================================================

  /// 获取所有薪资收入
  Future<List<SalaryIncome>> getAllSalaryIncomes() =>
      select(salaryIncomes).get();

  /// 根据ID获取薪资收入
  Future<SalaryIncome?> getSalaryIncomeById(String id) =>
      (select(salaryIncomes)..where((s) => s.id.equals(id))).getSingleOrNull();

  /// 插入薪资收入
  Future<int> insertSalaryIncome(SalaryIncomesCompanion salary) =>
      into(salaryIncomes).insert(salary);

  /// 更新薪资收入
  Future<bool> updateSalaryIncome(SalaryIncomesCompanion salary) =>
      update(salaryIncomes).replace(salary);

  /// 删除薪资收入
  Future<int> deleteSalaryIncome(String id) =>
      (delete(salaryIncomes)..where((s) => s.id.equals(id))).go();

  // ============================================================================
  // History Operations
  // ============================================================================

  /// 获取指定资产的历史记录
  Future<List<AssetHistory>> getAssetHistoryByAsset(String assetId) =>
      (select(assetHistories)..where((h) => h.assetId.equals(assetId))).get();

  /// 获取所有资产历史记录
  Future<List<AssetHistory>> getAllAssetHistory() =>
      select(assetHistories).get();

  /// 插入资产历史记录
  Future<int> insertAssetHistory(AssetHistoriesCompanion history) =>
      into(assetHistories).insert(history);

  /// 删除指定资产的所有历史记录
  Future<int> deleteAssetHistoryByAsset(String assetId) =>
      (delete(assetHistories)..where((h) => h.assetId.equals(assetId))).go();

  // ============================================================================
  // Plan Operations
  // ============================================================================

  /// 获取所有支出计划
  Future<List<ExpensePlan>> getAllExpensePlans() => select(expensePlans).get();

  /// 获取所有收入计划
  Future<List<IncomePlan>> getAllIncomePlans() => select(incomePlans).get();

  /// 插入支出计划
  Future<int> insertExpensePlan(ExpensePlansCompanion plan) =>
      into(expensePlans).insert(plan);

  /// 插入收入计划
  Future<int> insertIncomePlan(IncomePlansCompanion plan) =>
      into(incomePlans).insert(plan);

  Future<int> deleteExpensePlan(String id) =>
      (delete(expensePlans)..where((p) => p.id.equals(id))).go();

  Future<int> deleteIncomePlan(String id) =>
      (delete(incomePlans)..where((p) => p.id.equals(id))).go();
}

LazyDatabase _openConnection() => LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'app_database.db'));
      return NativeDatabase(file);
    });

// ============================================================================
// Table Definitions
// ============================================================================

/// Assets table - stores all financial assets and liabilities
class Assets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  TextColumn get category => text()(); // AssetCategory enum name
  TextColumn get subCategory => text()();
  DateTimeColumn get creationDate => dateTime()();
  DateTimeColumn get updateDate => dateTime()();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  TextColumn get depreciationMethod =>
      text().nullable()(); // DepreciationMethod enum name
  RealColumn get depreciationRate => real().nullable()();
  RealColumn get currentValue => real().nullable()();
  BoolColumn get isIdle => boolean().withDefault(const Constant(false))();
  RealColumn get idleValue => real().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Transactions table - stores all financial transactions
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get description => text()();
  RealColumn get amount => real()();
  TextColumn get flow => text().nullable()(); // TransactionFlow enum name
  TextColumn get type =>
      text().nullable()(); // TransactionType enum name (legacy)
  TextColumn get category => text()(); // TransactionCategory enum name
  TextColumn get subCategory => text().nullable()();
  TextColumn get fromWalletId => text().nullable()();
  TextColumn get toWalletId => text().nullable()();
  TextColumn get fromAssetId => text().nullable()();
  TextColumn get toAssetId => text().nullable()();
  TextColumn get fromAccountId => text().nullable()(); // Legacy support
  TextColumn get toAccountId => text().nullable()(); // Legacy support
  TextColumn get envelopeBudgetId => text().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();
  TextColumn get tags => text()(); // JSON string of List<String>
  TextColumn get status => text()(); // TransactionStatus enum name
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get recurringRule => text().nullable()();
  TextColumn get parentTransactionId => text().nullable()();
  DateTimeColumn get creationDate => dateTime()();
  DateTimeColumn get updateDate => dateTime()();
  TextColumn get imagePath => text().nullable()();
  BoolColumn get isAutoGenerated =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Accounts table - stores account information (cash, bank, credit cards, etc.)
class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get type => text()(); // AccountType enum name
  TextColumn get status => text()(); // AccountStatus enum name
  RealColumn get balance => real()();
  RealColumn get initialBalance => real().withDefault(const Constant(0.0))();
  TextColumn get currency => text().withDefault(const Constant('CNY'))();
  TextColumn get bankName => text().nullable()();
  TextColumn get accountNumber => text().nullable()();
  TextColumn get cardNumber => text().nullable()();
  RealColumn get creditLimit => real().nullable()();
  RealColumn get interestRate => real().nullable()();
  DateTimeColumn get openDate => dateTime().nullable()();
  DateTimeColumn get closeDate => dateTime().nullable()();
  TextColumn get loanType => text().nullable()(); // LoanType enum name
  RealColumn get loanAmount => real().nullable()();
  RealColumn get secondInterestRate => real().nullable()();
  IntColumn get loanTerm => integer().nullable()();
  TextColumn get repaymentMethod =>
      text().nullable()(); // RepaymentMethod enum name
  DateTimeColumn get firstPaymentDate => dateTime().nullable()();
  RealColumn get remainingPrincipal => real().nullable()();
  RealColumn get monthlyPayment => real().nullable()();
  BoolColumn get isRecurringPayment =>
      boolean().withDefault(const Constant(false))();
  TextColumn get iconName => text().nullable()();
  TextColumn get color => text().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();
  TextColumn get tags => text()(); // JSON string of List<String>
  DateTimeColumn get creationDate => dateTime()();
  DateTimeColumn get updateDate => dateTime()();
  TextColumn get syncProvider => text().nullable()();
  TextColumn get syncAccountId => text().nullable()();
  DateTimeColumn get lastSyncDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Envelope Budgets table - stores envelope budget configurations
class EnvelopeBudgets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text()(); // TransactionCategory enum name
  RealColumn get allocatedAmount => real()();
  RealColumn get spentAmount => real().withDefault(const Constant(0.0))();
  TextColumn get period => text()(); // BudgetPeriod enum name
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get status => text()(); // BudgetStatus enum name
  TextColumn get color => text().nullable()();
  TextColumn get iconName => text().nullable()();
  BoolColumn get isEssential => boolean().withDefault(const Constant(false))();
  RealColumn get warningThreshold => real().nullable()();
  RealColumn get limitThreshold => real().nullable()();
  TextColumn get tags => text()(); // JSON string of List<String>
  DateTimeColumn get creationDate => dateTime()();
  DateTimeColumn get updateDate => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Zero-Based Budgets table - stores zero-based budget configurations
class ZeroBasedBudgets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  RealColumn get totalIncome => real()();
  RealColumn get totalAllocated => real().withDefault(const Constant(0.0))();
  TextColumn get envelopes => text()(); // JSON string of List<EnvelopeBudget>
  TextColumn get period => text()(); // BudgetPeriod enum name
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get status => text()(); // BudgetStatus enum name
  DateTimeColumn get creationDate => dateTime()();
  DateTimeColumn get updateDate => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Salary Income table - stores salary income configurations
class SalaryIncomes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  RealColumn get basicSalary => real()();
  TextColumn get salaryHistory =>
      text().nullable()(); // JSON string of Map<DateTime, double>
  RealColumn get housingAllowance => real().withDefault(const Constant(0.0))();
  RealColumn get mealAllowance => real().withDefault(const Constant(0.0))();
  RealColumn get transportationAllowance =>
      real().withDefault(const Constant(0.0))();
  RealColumn get otherAllowance => real().withDefault(const Constant(0.0))();
  TextColumn get monthlyAllowances =>
      text().nullable()(); // JSON string of Map<int, AllowanceRecord>
  TextColumn get bonuses => text()(); // JSON string of List<BonusItem>
  RealColumn get personalIncomeTax => real().withDefault(const Constant(0.0))();
  RealColumn get socialInsurance => real().withDefault(const Constant(0.0))();
  RealColumn get housingFund => real().withDefault(const Constant(0.0))();
  RealColumn get otherDeductions => real().withDefault(const Constant(0.0))();
  RealColumn get specialDeductionMonthly =>
      real().withDefault(const Constant(0.0))();
  RealColumn get otherTaxDeductions =>
      real().withDefault(const Constant(0.0))();
  IntColumn get salaryDay => integer()();
  TextColumn get period => text()(); // BudgetPeriod enum name
  DateTimeColumn get lastSalaryDate => dateTime().nullable()();
  DateTimeColumn get nextSalaryDate => dateTime().nullable()();
  TextColumn get incomeType => text()(); // IncomeType enum name
  DateTimeColumn get creationDate => dateTime()();
  DateTimeColumn get updateDate => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Asset History table - tracks all asset changes for auditing
class AssetHistories extends Table {
  TextColumn get id => text()();
  TextColumn get assetId => text()();
  TextColumn get action => text()(); // AssetHistoryAction enum name
  TextColumn get description => text()();
  TextColumn get previousState =>
      text().nullable()(); // JSON string of previous AssetItem
  TextColumn get newState =>
      text().nullable()(); // JSON string of new AssetItem
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get userId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Expense Plans table - stores expense planning data
class ExpensePlans extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text()(); // TransactionCategory enum name
  RealColumn get targetAmount => real()();
  RealColumn get currentAmount => real().withDefault(const Constant(0.0))();
  TextColumn get period => text()(); // BudgetPeriod enum name
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get status => text()(); // Plan status
  DateTimeColumn get creationDate => dateTime()();
  DateTimeColumn get updateDate => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Income Plans table - stores income planning data
class IncomePlans extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get incomeType => text()(); // IncomeType enum name
  RealColumn get targetAmount => real()();
  RealColumn get currentAmount => real().withDefault(const Constant(0.0))();
  TextColumn get period => text()(); // BudgetPeriod enum name
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get status => text()(); // Plan status
  DateTimeColumn get creationDate => dateTime()();
  DateTimeColumn get updateDate => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
