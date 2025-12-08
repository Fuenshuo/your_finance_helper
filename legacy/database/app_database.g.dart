// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AssetsTable extends Assets with TableInfo<$AssetsTable, Asset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subCategoryMeta =
      const VerificationMeta('subCategory');
  @override
  late final GeneratedColumn<String> subCategory = GeneratedColumn<String>(
      'sub_category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _creationDateMeta =
      const VerificationMeta('creationDate');
  @override
  late final GeneratedColumn<DateTime> creationDate = GeneratedColumn<DateTime>(
      'creation_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updateDateMeta =
      const VerificationMeta('updateDate');
  @override
  late final GeneratedColumn<DateTime> updateDate = GeneratedColumn<DateTime>(
      'update_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _purchaseDateMeta =
      const VerificationMeta('purchaseDate');
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
      'purchase_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _depreciationMethodMeta =
      const VerificationMeta('depreciationMethod');
  @override
  late final GeneratedColumn<String> depreciationMethod =
      GeneratedColumn<String>('depreciation_method', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _depreciationRateMeta =
      const VerificationMeta('depreciationRate');
  @override
  late final GeneratedColumn<double> depreciationRate = GeneratedColumn<double>(
      'depreciation_rate', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _currentValueMeta =
      const VerificationMeta('currentValue');
  @override
  late final GeneratedColumn<double> currentValue = GeneratedColumn<double>(
      'current_value', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _isIdleMeta = const VerificationMeta('isIdle');
  @override
  late final GeneratedColumn<bool> isIdle = GeneratedColumn<bool>(
      'is_idle', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_idle" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _idleValueMeta =
      const VerificationMeta('idleValue');
  @override
  late final GeneratedColumn<double> idleValue = GeneratedColumn<double>(
      'idle_value', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        amount,
        category,
        subCategory,
        creationDate,
        updateDate,
        purchaseDate,
        depreciationMethod,
        depreciationRate,
        currentValue,
        isIdle,
        idleValue,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assets';
  @override
  VerificationContext validateIntegrity(Insertable<Asset> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('sub_category')) {
      context.handle(
          _subCategoryMeta,
          subCategory.isAcceptableOrUnknown(
              data['sub_category']!, _subCategoryMeta));
    } else if (isInserting) {
      context.missing(_subCategoryMeta);
    }
    if (data.containsKey('creation_date')) {
      context.handle(
          _creationDateMeta,
          creationDate.isAcceptableOrUnknown(
              data['creation_date']!, _creationDateMeta));
    } else if (isInserting) {
      context.missing(_creationDateMeta);
    }
    if (data.containsKey('update_date')) {
      context.handle(
          _updateDateMeta,
          updateDate.isAcceptableOrUnknown(
              data['update_date']!, _updateDateMeta));
    } else if (isInserting) {
      context.missing(_updateDateMeta);
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
          _purchaseDateMeta,
          purchaseDate.isAcceptableOrUnknown(
              data['purchase_date']!, _purchaseDateMeta));
    }
    if (data.containsKey('depreciation_method')) {
      context.handle(
          _depreciationMethodMeta,
          depreciationMethod.isAcceptableOrUnknown(
              data['depreciation_method']!, _depreciationMethodMeta));
    }
    if (data.containsKey('depreciation_rate')) {
      context.handle(
          _depreciationRateMeta,
          depreciationRate.isAcceptableOrUnknown(
              data['depreciation_rate']!, _depreciationRateMeta));
    }
    if (data.containsKey('current_value')) {
      context.handle(
          _currentValueMeta,
          currentValue.isAcceptableOrUnknown(
              data['current_value']!, _currentValueMeta));
    }
    if (data.containsKey('is_idle')) {
      context.handle(_isIdleMeta,
          isIdle.isAcceptableOrUnknown(data['is_idle']!, _isIdleMeta));
    }
    if (data.containsKey('idle_value')) {
      context.handle(_idleValueMeta,
          idleValue.isAcceptableOrUnknown(data['idle_value']!, _idleValueMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Asset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Asset(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      subCategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sub_category'])!,
      creationDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}creation_date'])!,
      updateDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}update_date'])!,
      purchaseDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}purchase_date']),
      depreciationMethod: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}depreciation_method']),
      depreciationRate: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}depreciation_rate']),
      currentValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}current_value']),
      isIdle: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_idle'])!,
      idleValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}idle_value']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $AssetsTable createAlias(String alias) {
    return $AssetsTable(attachedDatabase, alias);
  }
}

class Asset extends DataClass implements Insertable<Asset> {
  final String id;
  final String name;
  final double amount;
  final String category;
  final String subCategory;
  final DateTime creationDate;
  final DateTime updateDate;
  final DateTime? purchaseDate;
  final String? depreciationMethod;
  final double? depreciationRate;
  final double? currentValue;
  final bool isIdle;
  final double? idleValue;
  final String? notes;
  const Asset(
      {required this.id,
      required this.name,
      required this.amount,
      required this.category,
      required this.subCategory,
      required this.creationDate,
      required this.updateDate,
      this.purchaseDate,
      this.depreciationMethod,
      this.depreciationRate,
      this.currentValue,
      required this.isIdle,
      this.idleValue,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<double>(amount);
    map['category'] = Variable<String>(category);
    map['sub_category'] = Variable<String>(subCategory);
    map['creation_date'] = Variable<DateTime>(creationDate);
    map['update_date'] = Variable<DateTime>(updateDate);
    if (!nullToAbsent || purchaseDate != null) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate);
    }
    if (!nullToAbsent || depreciationMethod != null) {
      map['depreciation_method'] = Variable<String>(depreciationMethod);
    }
    if (!nullToAbsent || depreciationRate != null) {
      map['depreciation_rate'] = Variable<double>(depreciationRate);
    }
    if (!nullToAbsent || currentValue != null) {
      map['current_value'] = Variable<double>(currentValue);
    }
    map['is_idle'] = Variable<bool>(isIdle);
    if (!nullToAbsent || idleValue != null) {
      map['idle_value'] = Variable<double>(idleValue);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  AssetsCompanion toCompanion(bool nullToAbsent) {
    return AssetsCompanion(
      id: Value(id),
      name: Value(name),
      amount: Value(amount),
      category: Value(category),
      subCategory: Value(subCategory),
      creationDate: Value(creationDate),
      updateDate: Value(updateDate),
      purchaseDate: purchaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseDate),
      depreciationMethod: depreciationMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(depreciationMethod),
      depreciationRate: depreciationRate == null && nullToAbsent
          ? const Value.absent()
          : Value(depreciationRate),
      currentValue: currentValue == null && nullToAbsent
          ? const Value.absent()
          : Value(currentValue),
      isIdle: Value(isIdle),
      idleValue: idleValue == null && nullToAbsent
          ? const Value.absent()
          : Value(idleValue),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory Asset.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Asset(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
      category: serializer.fromJson<String>(json['category']),
      subCategory: serializer.fromJson<String>(json['subCategory']),
      creationDate: serializer.fromJson<DateTime>(json['creationDate']),
      updateDate: serializer.fromJson<DateTime>(json['updateDate']),
      purchaseDate: serializer.fromJson<DateTime?>(json['purchaseDate']),
      depreciationMethod:
          serializer.fromJson<String?>(json['depreciationMethod']),
      depreciationRate: serializer.fromJson<double?>(json['depreciationRate']),
      currentValue: serializer.fromJson<double?>(json['currentValue']),
      isIdle: serializer.fromJson<bool>(json['isIdle']),
      idleValue: serializer.fromJson<double?>(json['idleValue']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<double>(amount),
      'category': serializer.toJson<String>(category),
      'subCategory': serializer.toJson<String>(subCategory),
      'creationDate': serializer.toJson<DateTime>(creationDate),
      'updateDate': serializer.toJson<DateTime>(updateDate),
      'purchaseDate': serializer.toJson<DateTime?>(purchaseDate),
      'depreciationMethod': serializer.toJson<String?>(depreciationMethod),
      'depreciationRate': serializer.toJson<double?>(depreciationRate),
      'currentValue': serializer.toJson<double?>(currentValue),
      'isIdle': serializer.toJson<bool>(isIdle),
      'idleValue': serializer.toJson<double?>(idleValue),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Asset copyWith(
          {String? id,
          String? name,
          double? amount,
          String? category,
          String? subCategory,
          DateTime? creationDate,
          DateTime? updateDate,
          Value<DateTime?> purchaseDate = const Value.absent(),
          Value<String?> depreciationMethod = const Value.absent(),
          Value<double?> depreciationRate = const Value.absent(),
          Value<double?> currentValue = const Value.absent(),
          bool? isIdle,
          Value<double?> idleValue = const Value.absent(),
          Value<String?> notes = const Value.absent()}) =>
      Asset(
        id: id ?? this.id,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        subCategory: subCategory ?? this.subCategory,
        creationDate: creationDate ?? this.creationDate,
        updateDate: updateDate ?? this.updateDate,
        purchaseDate:
            purchaseDate.present ? purchaseDate.value : this.purchaseDate,
        depreciationMethod: depreciationMethod.present
            ? depreciationMethod.value
            : this.depreciationMethod,
        depreciationRate: depreciationRate.present
            ? depreciationRate.value
            : this.depreciationRate,
        currentValue:
            currentValue.present ? currentValue.value : this.currentValue,
        isIdle: isIdle ?? this.isIdle,
        idleValue: idleValue.present ? idleValue.value : this.idleValue,
        notes: notes.present ? notes.value : this.notes,
      );
  Asset copyWithCompanion(AssetsCompanion data) {
    return Asset(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      amount: data.amount.present ? data.amount.value : this.amount,
      category: data.category.present ? data.category.value : this.category,
      subCategory:
          data.subCategory.present ? data.subCategory.value : this.subCategory,
      creationDate: data.creationDate.present
          ? data.creationDate.value
          : this.creationDate,
      updateDate:
          data.updateDate.present ? data.updateDate.value : this.updateDate,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      depreciationMethod: data.depreciationMethod.present
          ? data.depreciationMethod.value
          : this.depreciationMethod,
      depreciationRate: data.depreciationRate.present
          ? data.depreciationRate.value
          : this.depreciationRate,
      currentValue: data.currentValue.present
          ? data.currentValue.value
          : this.currentValue,
      isIdle: data.isIdle.present ? data.isIdle.value : this.isIdle,
      idleValue: data.idleValue.present ? data.idleValue.value : this.idleValue,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Asset(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('creationDate: $creationDate, ')
          ..write('updateDate: $updateDate, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('depreciationMethod: $depreciationMethod, ')
          ..write('depreciationRate: $depreciationRate, ')
          ..write('currentValue: $currentValue, ')
          ..write('isIdle: $isIdle, ')
          ..write('idleValue: $idleValue, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      amount,
      category,
      subCategory,
      creationDate,
      updateDate,
      purchaseDate,
      depreciationMethod,
      depreciationRate,
      currentValue,
      isIdle,
      idleValue,
      notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Asset &&
          other.id == this.id &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.category == this.category &&
          other.subCategory == this.subCategory &&
          other.creationDate == this.creationDate &&
          other.updateDate == this.updateDate &&
          other.purchaseDate == this.purchaseDate &&
          other.depreciationMethod == this.depreciationMethod &&
          other.depreciationRate == this.depreciationRate &&
          other.currentValue == this.currentValue &&
          other.isIdle == this.isIdle &&
          other.idleValue == this.idleValue &&
          other.notes == this.notes);
}

class AssetsCompanion extends UpdateCompanion<Asset> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> amount;
  final Value<String> category;
  final Value<String> subCategory;
  final Value<DateTime> creationDate;
  final Value<DateTime> updateDate;
  final Value<DateTime?> purchaseDate;
  final Value<String?> depreciationMethod;
  final Value<double?> depreciationRate;
  final Value<double?> currentValue;
  final Value<bool> isIdle;
  final Value<double?> idleValue;
  final Value<String?> notes;
  final Value<int> rowid;
  const AssetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.subCategory = const Value.absent(),
    this.creationDate = const Value.absent(),
    this.updateDate = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.depreciationMethod = const Value.absent(),
    this.depreciationRate = const Value.absent(),
    this.currentValue = const Value.absent(),
    this.isIdle = const Value.absent(),
    this.idleValue = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssetsCompanion.insert({
    required String id,
    required String name,
    required double amount,
    required String category,
    required String subCategory,
    required DateTime creationDate,
    required DateTime updateDate,
    this.purchaseDate = const Value.absent(),
    this.depreciationMethod = const Value.absent(),
    this.depreciationRate = const Value.absent(),
    this.currentValue = const Value.absent(),
    this.isIdle = const Value.absent(),
    this.idleValue = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        amount = Value(amount),
        category = Value(category),
        subCategory = Value(subCategory),
        creationDate = Value(creationDate),
        updateDate = Value(updateDate);
  static Insertable<Asset> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? amount,
    Expression<String>? category,
    Expression<String>? subCategory,
    Expression<DateTime>? creationDate,
    Expression<DateTime>? updateDate,
    Expression<DateTime>? purchaseDate,
    Expression<String>? depreciationMethod,
    Expression<double>? depreciationRate,
    Expression<double>? currentValue,
    Expression<bool>? isIdle,
    Expression<double>? idleValue,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (subCategory != null) 'sub_category': subCategory,
      if (creationDate != null) 'creation_date': creationDate,
      if (updateDate != null) 'update_date': updateDate,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (depreciationMethod != null) 'depreciation_method': depreciationMethod,
      if (depreciationRate != null) 'depreciation_rate': depreciationRate,
      if (currentValue != null) 'current_value': currentValue,
      if (isIdle != null) 'is_idle': isIdle,
      if (idleValue != null) 'idle_value': idleValue,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssetsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<double>? amount,
      Value<String>? category,
      Value<String>? subCategory,
      Value<DateTime>? creationDate,
      Value<DateTime>? updateDate,
      Value<DateTime?>? purchaseDate,
      Value<String?>? depreciationMethod,
      Value<double?>? depreciationRate,
      Value<double?>? currentValue,
      Value<bool>? isIdle,
      Value<double?>? idleValue,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return AssetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      creationDate: creationDate ?? this.creationDate,
      updateDate: updateDate ?? this.updateDate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      depreciationMethod: depreciationMethod ?? this.depreciationMethod,
      depreciationRate: depreciationRate ?? this.depreciationRate,
      currentValue: currentValue ?? this.currentValue,
      isIdle: isIdle ?? this.isIdle,
      idleValue: idleValue ?? this.idleValue,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subCategory.present) {
      map['sub_category'] = Variable<String>(subCategory.value);
    }
    if (creationDate.present) {
      map['creation_date'] = Variable<DateTime>(creationDate.value);
    }
    if (updateDate.present) {
      map['update_date'] = Variable<DateTime>(updateDate.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (depreciationMethod.present) {
      map['depreciation_method'] = Variable<String>(depreciationMethod.value);
    }
    if (depreciationRate.present) {
      map['depreciation_rate'] = Variable<double>(depreciationRate.value);
    }
    if (currentValue.present) {
      map['current_value'] = Variable<double>(currentValue.value);
    }
    if (isIdle.present) {
      map['is_idle'] = Variable<bool>(isIdle.value);
    }
    if (idleValue.present) {
      map['idle_value'] = Variable<double>(idleValue.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('creationDate: $creationDate, ')
          ..write('updateDate: $updateDate, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('depreciationMethod: $depreciationMethod, ')
          ..write('depreciationRate: $depreciationRate, ')
          ..write('currentValue: $currentValue, ')
          ..write('isIdle: $isIdle, ')
          ..write('idleValue: $idleValue, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _flowMeta = const VerificationMeta('flow');
  @override
  late final GeneratedColumn<String> flow = GeneratedColumn<String>(
      'flow', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subCategoryMeta =
      const VerificationMeta('subCategory');
  @override
  late final GeneratedColumn<String> subCategory = GeneratedColumn<String>(
      'sub_category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fromWalletIdMeta =
      const VerificationMeta('fromWalletId');
  @override
  late final GeneratedColumn<String> fromWalletId = GeneratedColumn<String>(
      'from_wallet_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _toWalletIdMeta =
      const VerificationMeta('toWalletId');
  @override
  late final GeneratedColumn<String> toWalletId = GeneratedColumn<String>(
      'to_wallet_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fromAssetIdMeta =
      const VerificationMeta('fromAssetId');
  @override
  late final GeneratedColumn<String> fromAssetId = GeneratedColumn<String>(
      'from_asset_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _toAssetIdMeta =
      const VerificationMeta('toAssetId');
  @override
  late final GeneratedColumn<String> toAssetId = GeneratedColumn<String>(
      'to_asset_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fromAccountIdMeta =
      const VerificationMeta('fromAccountId');
  @override
  late final GeneratedColumn<String> fromAccountId = GeneratedColumn<String>(
      'from_account_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _toAccountIdMeta =
      const VerificationMeta('toAccountId');
  @override
  late final GeneratedColumn<String> toAccountId = GeneratedColumn<String>(
      'to_account_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _envelopeBudgetIdMeta =
      const VerificationMeta('envelopeBudgetId');
  @override
  late final GeneratedColumn<String> envelopeBudgetId = GeneratedColumn<String>(
      'envelope_budget_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isRecurringMeta =
      const VerificationMeta('isRecurring');
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
      'is_recurring', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_recurring" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _recurringRuleMeta =
      const VerificationMeta('recurringRule');
  @override
  late final GeneratedColumn<String> recurringRule = GeneratedColumn<String>(
      'recurring_rule', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _parentTransactionIdMeta =
      const VerificationMeta('parentTransactionId');
  @override
  late final GeneratedColumn<String> parentTransactionId =
      GeneratedColumn<String>('parent_transaction_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _creationDateMeta =
      const VerificationMeta('creationDate');
  @override
  late final GeneratedColumn<DateTime> creationDate = GeneratedColumn<DateTime>(
      'creation_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updateDateMeta =
      const VerificationMeta('updateDate');
  @override
  late final GeneratedColumn<DateTime> updateDate = GeneratedColumn<DateTime>(
      'update_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isAutoGeneratedMeta =
      const VerificationMeta('isAutoGenerated');
  @override
  late final GeneratedColumn<bool> isAutoGenerated = GeneratedColumn<bool>(
      'is_auto_generated', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_auto_generated" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        description,
        amount,
        flow,
        type,
        category,
        subCategory,
        fromWalletId,
        toWalletId,
        fromAssetId,
        toAssetId,
        fromAccountId,
        toAccountId,
        envelopeBudgetId,
        date,
        notes,
        tags,
        status,
        isRecurring,
        recurringRule,
        parentTransactionId,
        creationDate,
        updateDate,
        imagePath,
        isAutoGenerated
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('flow')) {
      context.handle(
          _flowMeta, flow.isAcceptableOrUnknown(data['flow']!, _flowMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('sub_category')) {
      context.handle(
          _subCategoryMeta,
          subCategory.isAcceptableOrUnknown(
              data['sub_category']!, _subCategoryMeta));
    }
    if (data.containsKey('from_wallet_id')) {
      context.handle(
          _fromWalletIdMeta,
          fromWalletId.isAcceptableOrUnknown(
              data['from_wallet_id']!, _fromWalletIdMeta));
    }
    if (data.containsKey('to_wallet_id')) {
      context.handle(
          _toWalletIdMeta,
          toWalletId.isAcceptableOrUnknown(
              data['to_wallet_id']!, _toWalletIdMeta));
    }
    if (data.containsKey('from_asset_id')) {
      context.handle(
          _fromAssetIdMeta,
          fromAssetId.isAcceptableOrUnknown(
              data['from_asset_id']!, _fromAssetIdMeta));
    }
    if (data.containsKey('to_asset_id')) {
      context.handle(
          _toAssetIdMeta,
          toAssetId.isAcceptableOrUnknown(
              data['to_asset_id']!, _toAssetIdMeta));
    }
    if (data.containsKey('from_account_id')) {
      context.handle(
          _fromAccountIdMeta,
          fromAccountId.isAcceptableOrUnknown(
              data['from_account_id']!, _fromAccountIdMeta));
    }
    if (data.containsKey('to_account_id')) {
      context.handle(
          _toAccountIdMeta,
          toAccountId.isAcceptableOrUnknown(
              data['to_account_id']!, _toAccountIdMeta));
    }
    if (data.containsKey('envelope_budget_id')) {
      context.handle(
          _envelopeBudgetIdMeta,
          envelopeBudgetId.isAcceptableOrUnknown(
              data['envelope_budget_id']!, _envelopeBudgetIdMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    } else if (isInserting) {
      context.missing(_tagsMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
          _isRecurringMeta,
          isRecurring.isAcceptableOrUnknown(
              data['is_recurring']!, _isRecurringMeta));
    }
    if (data.containsKey('recurring_rule')) {
      context.handle(
          _recurringRuleMeta,
          recurringRule.isAcceptableOrUnknown(
              data['recurring_rule']!, _recurringRuleMeta));
    }
    if (data.containsKey('parent_transaction_id')) {
      context.handle(
          _parentTransactionIdMeta,
          parentTransactionId.isAcceptableOrUnknown(
              data['parent_transaction_id']!, _parentTransactionIdMeta));
    }
    if (data.containsKey('creation_date')) {
      context.handle(
          _creationDateMeta,
          creationDate.isAcceptableOrUnknown(
              data['creation_date']!, _creationDateMeta));
    } else if (isInserting) {
      context.missing(_creationDateMeta);
    }
    if (data.containsKey('update_date')) {
      context.handle(
          _updateDateMeta,
          updateDate.isAcceptableOrUnknown(
              data['update_date']!, _updateDateMeta));
    } else if (isInserting) {
      context.missing(_updateDateMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('is_auto_generated')) {
      context.handle(
          _isAutoGeneratedMeta,
          isAutoGenerated.isAcceptableOrUnknown(
              data['is_auto_generated']!, _isAutoGeneratedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      flow: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}flow']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      subCategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sub_category']),
      fromWalletId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}from_wallet_id']),
      toWalletId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}to_wallet_id']),
      fromAssetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}from_asset_id']),
      toAssetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}to_asset_id']),
      fromAccountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}from_account_id']),
      toAccountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}to_account_id']),
      envelopeBudgetId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}envelope_budget_id']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      isRecurring: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_recurring'])!,
      recurringRule: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recurring_rule']),
      parentTransactionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}parent_transaction_id']),
      creationDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}creation_date'])!,
      updateDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}update_date'])!,
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      isAutoGenerated: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_auto_generated'])!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String id;
  final String description;
  final double amount;
  final String? flow;
  final String? type;
  final String category;
  final String? subCategory;
  final String? fromWalletId;
  final String? toWalletId;
  final String? fromAssetId;
  final String? toAssetId;
  final String? fromAccountId;
  final String? toAccountId;
  final String? envelopeBudgetId;
  final DateTime date;
  final String? notes;
  final String tags;
  final String status;
  final bool isRecurring;
  final String? recurringRule;
  final String? parentTransactionId;
  final DateTime creationDate;
  final DateTime updateDate;
  final String? imagePath;
  final bool isAutoGenerated;
  const Transaction(
      {required this.id,
      required this.description,
      required this.amount,
      this.flow,
      this.type,
      required this.category,
      this.subCategory,
      this.fromWalletId,
      this.toWalletId,
      this.fromAssetId,
      this.toAssetId,
      this.fromAccountId,
      this.toAccountId,
      this.envelopeBudgetId,
      required this.date,
      this.notes,
      required this.tags,
      required this.status,
      required this.isRecurring,
      this.recurringRule,
      this.parentTransactionId,
      required this.creationDate,
      required this.updateDate,
      this.imagePath,
      required this.isAutoGenerated});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['description'] = Variable<String>(description);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || flow != null) {
      map['flow'] = Variable<String>(flow);
    }
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || subCategory != null) {
      map['sub_category'] = Variable<String>(subCategory);
    }
    if (!nullToAbsent || fromWalletId != null) {
      map['from_wallet_id'] = Variable<String>(fromWalletId);
    }
    if (!nullToAbsent || toWalletId != null) {
      map['to_wallet_id'] = Variable<String>(toWalletId);
    }
    if (!nullToAbsent || fromAssetId != null) {
      map['from_asset_id'] = Variable<String>(fromAssetId);
    }
    if (!nullToAbsent || toAssetId != null) {
      map['to_asset_id'] = Variable<String>(toAssetId);
    }
    if (!nullToAbsent || fromAccountId != null) {
      map['from_account_id'] = Variable<String>(fromAccountId);
    }
    if (!nullToAbsent || toAccountId != null) {
      map['to_account_id'] = Variable<String>(toAccountId);
    }
    if (!nullToAbsent || envelopeBudgetId != null) {
      map['envelope_budget_id'] = Variable<String>(envelopeBudgetId);
    }
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['tags'] = Variable<String>(tags);
    map['status'] = Variable<String>(status);
    map['is_recurring'] = Variable<bool>(isRecurring);
    if (!nullToAbsent || recurringRule != null) {
      map['recurring_rule'] = Variable<String>(recurringRule);
    }
    if (!nullToAbsent || parentTransactionId != null) {
      map['parent_transaction_id'] = Variable<String>(parentTransactionId);
    }
    map['creation_date'] = Variable<DateTime>(creationDate);
    map['update_date'] = Variable<DateTime>(updateDate);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['is_auto_generated'] = Variable<bool>(isAutoGenerated);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      description: Value(description),
      amount: Value(amount),
      flow: flow == null && nullToAbsent ? const Value.absent() : Value(flow),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      category: Value(category),
      subCategory: subCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(subCategory),
      fromWalletId: fromWalletId == null && nullToAbsent
          ? const Value.absent()
          : Value(fromWalletId),
      toWalletId: toWalletId == null && nullToAbsent
          ? const Value.absent()
          : Value(toWalletId),
      fromAssetId: fromAssetId == null && nullToAbsent
          ? const Value.absent()
          : Value(fromAssetId),
      toAssetId: toAssetId == null && nullToAbsent
          ? const Value.absent()
          : Value(toAssetId),
      fromAccountId: fromAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(fromAccountId),
      toAccountId: toAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(toAccountId),
      envelopeBudgetId: envelopeBudgetId == null && nullToAbsent
          ? const Value.absent()
          : Value(envelopeBudgetId),
      date: Value(date),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      tags: Value(tags),
      status: Value(status),
      isRecurring: Value(isRecurring),
      recurringRule: recurringRule == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringRule),
      parentTransactionId: parentTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentTransactionId),
      creationDate: Value(creationDate),
      updateDate: Value(updateDate),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      isAutoGenerated: Value(isAutoGenerated),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<String>(json['id']),
      description: serializer.fromJson<String>(json['description']),
      amount: serializer.fromJson<double>(json['amount']),
      flow: serializer.fromJson<String?>(json['flow']),
      type: serializer.fromJson<String?>(json['type']),
      category: serializer.fromJson<String>(json['category']),
      subCategory: serializer.fromJson<String?>(json['subCategory']),
      fromWalletId: serializer.fromJson<String?>(json['fromWalletId']),
      toWalletId: serializer.fromJson<String?>(json['toWalletId']),
      fromAssetId: serializer.fromJson<String?>(json['fromAssetId']),
      toAssetId: serializer.fromJson<String?>(json['toAssetId']),
      fromAccountId: serializer.fromJson<String?>(json['fromAccountId']),
      toAccountId: serializer.fromJson<String?>(json['toAccountId']),
      envelopeBudgetId: serializer.fromJson<String?>(json['envelopeBudgetId']),
      date: serializer.fromJson<DateTime>(json['date']),
      notes: serializer.fromJson<String?>(json['notes']),
      tags: serializer.fromJson<String>(json['tags']),
      status: serializer.fromJson<String>(json['status']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      recurringRule: serializer.fromJson<String?>(json['recurringRule']),
      parentTransactionId:
          serializer.fromJson<String?>(json['parentTransactionId']),
      creationDate: serializer.fromJson<DateTime>(json['creationDate']),
      updateDate: serializer.fromJson<DateTime>(json['updateDate']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      isAutoGenerated: serializer.fromJson<bool>(json['isAutoGenerated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'description': serializer.toJson<String>(description),
      'amount': serializer.toJson<double>(amount),
      'flow': serializer.toJson<String?>(flow),
      'type': serializer.toJson<String?>(type),
      'category': serializer.toJson<String>(category),
      'subCategory': serializer.toJson<String?>(subCategory),
      'fromWalletId': serializer.toJson<String?>(fromWalletId),
      'toWalletId': serializer.toJson<String?>(toWalletId),
      'fromAssetId': serializer.toJson<String?>(fromAssetId),
      'toAssetId': serializer.toJson<String?>(toAssetId),
      'fromAccountId': serializer.toJson<String?>(fromAccountId),
      'toAccountId': serializer.toJson<String?>(toAccountId),
      'envelopeBudgetId': serializer.toJson<String?>(envelopeBudgetId),
      'date': serializer.toJson<DateTime>(date),
      'notes': serializer.toJson<String?>(notes),
      'tags': serializer.toJson<String>(tags),
      'status': serializer.toJson<String>(status),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'recurringRule': serializer.toJson<String?>(recurringRule),
      'parentTransactionId': serializer.toJson<String?>(parentTransactionId),
      'creationDate': serializer.toJson<DateTime>(creationDate),
      'updateDate': serializer.toJson<DateTime>(updateDate),
      'imagePath': serializer.toJson<String?>(imagePath),
      'isAutoGenerated': serializer.toJson<bool>(isAutoGenerated),
    };
  }

  Transaction copyWith(
          {String? id,
          String? description,
          double? amount,
          Value<String?> flow = const Value.absent(),
          Value<String?> type = const Value.absent(),
          String? category,
          Value<String?> subCategory = const Value.absent(),
          Value<String?> fromWalletId = const Value.absent(),
          Value<String?> toWalletId = const Value.absent(),
          Value<String?> fromAssetId = const Value.absent(),
          Value<String?> toAssetId = const Value.absent(),
          Value<String?> fromAccountId = const Value.absent(),
          Value<String?> toAccountId = const Value.absent(),
          Value<String?> envelopeBudgetId = const Value.absent(),
          DateTime? date,
          Value<String?> notes = const Value.absent(),
          String? tags,
          String? status,
          bool? isRecurring,
          Value<String?> recurringRule = const Value.absent(),
          Value<String?> parentTransactionId = const Value.absent(),
          DateTime? creationDate,
          DateTime? updateDate,
          Value<String?> imagePath = const Value.absent(),
          bool? isAutoGenerated}) =>
      Transaction(
        id: id ?? this.id,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        flow: flow.present ? flow.value : this.flow,
        type: type.present ? type.value : this.type,
        category: category ?? this.category,
        subCategory: subCategory.present ? subCategory.value : this.subCategory,
        fromWalletId:
            fromWalletId.present ? fromWalletId.value : this.fromWalletId,
        toWalletId: toWalletId.present ? toWalletId.value : this.toWalletId,
        fromAssetId: fromAssetId.present ? fromAssetId.value : this.fromAssetId,
        toAssetId: toAssetId.present ? toAssetId.value : this.toAssetId,
        fromAccountId:
            fromAccountId.present ? fromAccountId.value : this.fromAccountId,
        toAccountId: toAccountId.present ? toAccountId.value : this.toAccountId,
        envelopeBudgetId: envelopeBudgetId.present
            ? envelopeBudgetId.value
            : this.envelopeBudgetId,
        date: date ?? this.date,
        notes: notes.present ? notes.value : this.notes,
        tags: tags ?? this.tags,
        status: status ?? this.status,
        isRecurring: isRecurring ?? this.isRecurring,
        recurringRule:
            recurringRule.present ? recurringRule.value : this.recurringRule,
        parentTransactionId: parentTransactionId.present
            ? parentTransactionId.value
            : this.parentTransactionId,
        creationDate: creationDate ?? this.creationDate,
        updateDate: updateDate ?? this.updateDate,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        isAutoGenerated: isAutoGenerated ?? this.isAutoGenerated,
      );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      description:
          data.description.present ? data.description.value : this.description,
      amount: data.amount.present ? data.amount.value : this.amount,
      flow: data.flow.present ? data.flow.value : this.flow,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      subCategory:
          data.subCategory.present ? data.subCategory.value : this.subCategory,
      fromWalletId: data.fromWalletId.present
          ? data.fromWalletId.value
          : this.fromWalletId,
      toWalletId:
          data.toWalletId.present ? data.toWalletId.value : this.toWalletId,
      fromAssetId:
          data.fromAssetId.present ? data.fromAssetId.value : this.fromAssetId,
      toAssetId: data.toAssetId.present ? data.toAssetId.value : this.toAssetId,
      fromAccountId: data.fromAccountId.present
          ? data.fromAccountId.value
          : this.fromAccountId,
      toAccountId:
          data.toAccountId.present ? data.toAccountId.value : this.toAccountId,
      envelopeBudgetId: data.envelopeBudgetId.present
          ? data.envelopeBudgetId.value
          : this.envelopeBudgetId,
      date: data.date.present ? data.date.value : this.date,
      notes: data.notes.present ? data.notes.value : this.notes,
      tags: data.tags.present ? data.tags.value : this.tags,
      status: data.status.present ? data.status.value : this.status,
      isRecurring:
          data.isRecurring.present ? data.isRecurring.value : this.isRecurring,
      recurringRule: data.recurringRule.present
          ? data.recurringRule.value
          : this.recurringRule,
      parentTransactionId: data.parentTransactionId.present
          ? data.parentTransactionId.value
          : this.parentTransactionId,
      creationDate: data.creationDate.present
          ? data.creationDate.value
          : this.creationDate,
      updateDate:
          data.updateDate.present ? data.updateDate.value : this.updateDate,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      isAutoGenerated: data.isAutoGenerated.present
          ? data.isAutoGenerated.value
          : this.isAutoGenerated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('flow: $flow, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('fromWalletId: $fromWalletId, ')
          ..write('toWalletId: $toWalletId, ')
          ..write('fromAssetId: $fromAssetId, ')
          ..write('toAssetId: $toAssetId, ')
          ..write('fromAccountId: $fromAccountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('envelopeBudgetId: $envelopeBudgetId, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('tags: $tags, ')
          ..write('status: $status, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurringRule: $recurringRule, ')
          ..write('parentTransactionId: $parentTransactionId, ')
          ..write('creationDate: $creationDate, ')
          ..write('updateDate: $updateDate, ')
          ..write('imagePath: $imagePath, ')
          ..write('isAutoGenerated: $isAutoGenerated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        description,
        amount,
        flow,
        type,
        category,
        subCategory,
        fromWalletId,
        toWalletId,
        fromAssetId,
        toAssetId,
        fromAccountId,
        toAccountId,
        envelopeBudgetId,
        date,
        notes,
        tags,
        status,
        isRecurring,
        recurringRule,
        parentTransactionId,
        creationDate,
        updateDate,
        imagePath,
        isAutoGenerated
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.description == this.description &&
          other.amount == this.amount &&
          other.flow == this.flow &&
          other.type == this.type &&
          other.category == this.category &&
          other.subCategory == this.subCategory &&
          other.fromWalletId == this.fromWalletId &&
          other.toWalletId == this.toWalletId &&
          other.fromAssetId == this.fromAssetId &&
          other.toAssetId == this.toAssetId &&
          other.fromAccountId == this.fromAccountId &&
          other.toAccountId == this.toAccountId &&
          other.envelopeBudgetId == this.envelopeBudgetId &&
          other.date == this.date &&
          other.notes == this.notes &&
          other.tags == this.tags &&
          other.status == this.status &&
          other.isRecurring == this.isRecurring &&
          other.recurringRule == this.recurringRule &&
          other.parentTransactionId == this.parentTransactionId &&
          other.creationDate == this.creationDate &&
          other.updateDate == this.updateDate &&
          other.imagePath == this.imagePath &&
          other.isAutoGenerated == this.isAutoGenerated);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> id;
  final Value<String> description;
  final Value<double> amount;
  final Value<String?> flow;
  final Value<String?> type;
  final Value<String> category;
  final Value<String?> subCategory;
  final Value<String?> fromWalletId;
  final Value<String?> toWalletId;
  final Value<String?> fromAssetId;
  final Value<String?> toAssetId;
  final Value<String?> fromAccountId;
  final Value<String?> toAccountId;
  final Value<String?> envelopeBudgetId;
  final Value<DateTime> date;
  final Value<String?> notes;
  final Value<String> tags;
  final Value<String> status;
  final Value<bool> isRecurring;
  final Value<String?> recurringRule;
  final Value<String?> parentTransactionId;
  final Value<DateTime> creationDate;
  final Value<DateTime> updateDate;
  final Value<String?> imagePath;
  final Value<bool> isAutoGenerated;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.flow = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.subCategory = const Value.absent(),
    this.fromWalletId = const Value.absent(),
    this.toWalletId = const Value.absent(),
    this.fromAssetId = const Value.absent(),
    this.toAssetId = const Value.absent(),
    this.fromAccountId = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.envelopeBudgetId = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.tags = const Value.absent(),
    this.status = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurringRule = const Value.absent(),
    this.parentTransactionId = const Value.absent(),
    this.creationDate = const Value.absent(),
    this.updateDate = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.isAutoGenerated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String description,
    required double amount,
    this.flow = const Value.absent(),
    this.type = const Value.absent(),
    required String category,
    this.subCategory = const Value.absent(),
    this.fromWalletId = const Value.absent(),
    this.toWalletId = const Value.absent(),
    this.fromAssetId = const Value.absent(),
    this.toAssetId = const Value.absent(),
    this.fromAccountId = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.envelopeBudgetId = const Value.absent(),
    required DateTime date,
    this.notes = const Value.absent(),
    required String tags,
    required String status,
    this.isRecurring = const Value.absent(),
    this.recurringRule = const Value.absent(),
    this.parentTransactionId = const Value.absent(),
    required DateTime creationDate,
    required DateTime updateDate,
    this.imagePath = const Value.absent(),
    this.isAutoGenerated = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        description = Value(description),
        amount = Value(amount),
        category = Value(category),
        date = Value(date),
        tags = Value(tags),
        status = Value(status),
        creationDate = Value(creationDate),
        updateDate = Value(updateDate);
  static Insertable<Transaction> custom({
    Expression<String>? id,
    Expression<String>? description,
    Expression<double>? amount,
    Expression<String>? flow,
    Expression<String>? type,
    Expression<String>? category,
    Expression<String>? subCategory,
    Expression<String>? fromWalletId,
    Expression<String>? toWalletId,
    Expression<String>? fromAssetId,
    Expression<String>? toAssetId,
    Expression<String>? fromAccountId,
    Expression<String>? toAccountId,
    Expression<String>? envelopeBudgetId,
    Expression<DateTime>? date,
    Expression<String>? notes,
    Expression<String>? tags,
    Expression<String>? status,
    Expression<bool>? isRecurring,
    Expression<String>? recurringRule,
    Expression<String>? parentTransactionId,
    Expression<DateTime>? creationDate,
    Expression<DateTime>? updateDate,
    Expression<String>? imagePath,
    Expression<bool>? isAutoGenerated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (flow != null) 'flow': flow,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (subCategory != null) 'sub_category': subCategory,
      if (fromWalletId != null) 'from_wallet_id': fromWalletId,
      if (toWalletId != null) 'to_wallet_id': toWalletId,
      if (fromAssetId != null) 'from_asset_id': fromAssetId,
      if (toAssetId != null) 'to_asset_id': toAssetId,
      if (fromAccountId != null) 'from_account_id': fromAccountId,
      if (toAccountId != null) 'to_account_id': toAccountId,
      if (envelopeBudgetId != null) 'envelope_budget_id': envelopeBudgetId,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
      if (tags != null) 'tags': tags,
      if (status != null) 'status': status,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (recurringRule != null) 'recurring_rule': recurringRule,
      if (parentTransactionId != null)
        'parent_transaction_id': parentTransactionId,
      if (creationDate != null) 'creation_date': creationDate,
      if (updateDate != null) 'update_date': updateDate,
      if (imagePath != null) 'image_path': imagePath,
      if (isAutoGenerated != null) 'is_auto_generated': isAutoGenerated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? description,
      Value<double>? amount,
      Value<String?>? flow,
      Value<String?>? type,
      Value<String>? category,
      Value<String?>? subCategory,
      Value<String?>? fromWalletId,
      Value<String?>? toWalletId,
      Value<String?>? fromAssetId,
      Value<String?>? toAssetId,
      Value<String?>? fromAccountId,
      Value<String?>? toAccountId,
      Value<String?>? envelopeBudgetId,
      Value<DateTime>? date,
      Value<String?>? notes,
      Value<String>? tags,
      Value<String>? status,
      Value<bool>? isRecurring,
      Value<String?>? recurringRule,
      Value<String?>? parentTransactionId,
      Value<DateTime>? creationDate,
      Value<DateTime>? updateDate,
      Value<String?>? imagePath,
      Value<bool>? isAutoGenerated,
      Value<int>? rowid}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      flow: flow ?? this.flow,
      type: type ?? this.type,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      fromWalletId: fromWalletId ?? this.fromWalletId,
      toWalletId: toWalletId ?? this.toWalletId,
      fromAssetId: fromAssetId ?? this.fromAssetId,
      toAssetId: toAssetId ?? this.toAssetId,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      toAccountId: toAccountId ?? this.toAccountId,
      envelopeBudgetId: envelopeBudgetId ?? this.envelopeBudgetId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringRule: recurringRule ?? this.recurringRule,
      parentTransactionId: parentTransactionId ?? this.parentTransactionId,
      creationDate: creationDate ?? this.creationDate,
      updateDate: updateDate ?? this.updateDate,
      imagePath: imagePath ?? this.imagePath,
      isAutoGenerated: isAutoGenerated ?? this.isAutoGenerated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (flow.present) {
      map['flow'] = Variable<String>(flow.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subCategory.present) {
      map['sub_category'] = Variable<String>(subCategory.value);
    }
    if (fromWalletId.present) {
      map['from_wallet_id'] = Variable<String>(fromWalletId.value);
    }
    if (toWalletId.present) {
      map['to_wallet_id'] = Variable<String>(toWalletId.value);
    }
    if (fromAssetId.present) {
      map['from_asset_id'] = Variable<String>(fromAssetId.value);
    }
    if (toAssetId.present) {
      map['to_asset_id'] = Variable<String>(toAssetId.value);
    }
    if (fromAccountId.present) {
      map['from_account_id'] = Variable<String>(fromAccountId.value);
    }
    if (toAccountId.present) {
      map['to_account_id'] = Variable<String>(toAccountId.value);
    }
    if (envelopeBudgetId.present) {
      map['envelope_budget_id'] = Variable<String>(envelopeBudgetId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (recurringRule.present) {
      map['recurring_rule'] = Variable<String>(recurringRule.value);
    }
    if (parentTransactionId.present) {
      map['parent_transaction_id'] =
          Variable<String>(parentTransactionId.value);
    }
    if (creationDate.present) {
      map['creation_date'] = Variable<DateTime>(creationDate.value);
    }
    if (updateDate.present) {
      map['update_date'] = Variable<DateTime>(updateDate.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (isAutoGenerated.present) {
      map['is_auto_generated'] = Variable<bool>(isAutoGenerated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('flow: $flow, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('fromWalletId: $fromWalletId, ')
          ..write('toWalletId: $toWalletId, ')
          ..write('fromAssetId: $fromAssetId, ')
          ..write('toAssetId: $toAssetId, ')
          ..write('fromAccountId: $fromAccountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('envelopeBudgetId: $envelopeBudgetId, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('tags: $tags, ')
          ..write('status: $status, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurringRule: $recurringRule, ')
          ..write('parentTransactionId: $parentTransactionId, ')
          ..write('creationDate: $creationDate, ')
          ..write('updateDate: $updateDate, ')
          ..write('imagePath: $imagePath, ')
          ..write('isAutoGenerated: $isAutoGenerated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _balanceMeta =
      const VerificationMeta('balance');
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
      'balance', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _initialBalanceMeta =
      const VerificationMeta('initialBalance');
  @override
  late final GeneratedColumn<double> initialBalance = GeneratedColumn<double>(
      'initial_balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('CNY'));
  static const VerificationMeta _bankNameMeta =
      const VerificationMeta('bankName');
  @override
  late final GeneratedColumn<String> bankName = GeneratedColumn<String>(
      'bank_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _accountNumberMeta =
      const VerificationMeta('accountNumber');
  @override
  late final GeneratedColumn<String> accountNumber = GeneratedColumn<String>(
      'account_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cardNumberMeta =
      const VerificationMeta('cardNumber');
  @override
  late final GeneratedColumn<String> cardNumber = GeneratedColumn<String>(
      'card_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _creditLimitMeta =
      const VerificationMeta('creditLimit');
  @override
  late final GeneratedColumn<double> creditLimit = GeneratedColumn<double>(
      'credit_limit', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _interestRateMeta =
      const VerificationMeta('interestRate');
  @override
  late final GeneratedColumn<double> interestRate = GeneratedColumn<double>(
      'interest_rate', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _openDateMeta =
      const VerificationMeta('openDate');
  @override
  late final GeneratedColumn<DateTime> openDate = GeneratedColumn<DateTime>(
      'open_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _closeDateMeta =
      const VerificationMeta('closeDate');
  @override
  late final GeneratedColumn<DateTime> closeDate = GeneratedColumn<DateTime>(
      'close_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _loanTypeMeta =
      const VerificationMeta('loanType');
  @override
  late final GeneratedColumn<String> loanType = GeneratedColumn<String>(
      'loan_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _loanAmountMeta =
      const VerificationMeta('loanAmount');
  @override
  late final GeneratedColumn<double> loanAmount = GeneratedColumn<double>(
      'loan_amount', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _secondInterestRateMeta =
      const VerificationMeta('secondInterestRate');
  @override
  late final GeneratedColumn<double> secondInterestRate =
      GeneratedColumn<double>('second_interest_rate', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _loanTermMeta =
      const VerificationMeta('loanTerm');
  @override
  late final GeneratedColumn<int> loanTerm = GeneratedColumn<int>(
      'loan_term', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _repaymentMethodMeta =
      const VerificationMeta('repaymentMethod');
  @override
  late final GeneratedColumn<String> repaymentMethod = GeneratedColumn<String>(
      'repayment_method', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _firstPaymentDateMeta =
      const VerificationMeta('firstPaymentDate');
  @override
  late final GeneratedColumn<DateTime> firstPaymentDate =
      GeneratedColumn<DateTime>('first_payment_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _remainingPrincipalMeta =
      const VerificationMeta('remainingPrincipal');
  @override
  late final GeneratedColumn<double> remainingPrincipal =
      GeneratedColumn<double>('remaining_principal', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _monthlyPaymentMeta =
      const VerificationMeta('monthlyPayment');
  @override
  late final GeneratedColumn<double> monthlyPayment = GeneratedColumn<double>(
      'monthly_payment', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _isRecurringPaymentMeta =
      const VerificationMeta('isRecurringPayment');
  @override
  late final GeneratedColumn<bool> isRecurringPayment = GeneratedColumn<bool>(
      'is_recurring_payment', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_recurring_payment" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _iconNameMeta =
      const VerificationMeta('iconName');
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
      'icon_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isHiddenMeta =
      const VerificationMeta('isHidden');
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
      'is_hidden', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_hidden" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _creationDateMeta =
      const VerificationMeta('creationDate');
  @override
  late final GeneratedColumn<DateTime> creationDate = GeneratedColumn<DateTime>(
      'creation_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updateDateMeta =
      const VerificationMeta('updateDate');
  @override
  late final GeneratedColumn<DateTime> updateDate = GeneratedColumn<DateTime>(
      'update_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncProviderMeta =
      const VerificationMeta('syncProvider');
  @override
  late final GeneratedColumn<String> syncProvider = GeneratedColumn<String>(
      'sync_provider', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncAccountIdMeta =
      const VerificationMeta('syncAccountId');
  @override
  late final GeneratedColumn<String> syncAccountId = GeneratedColumn<String>(
      'sync_account_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncDateMeta =
      const VerificationMeta('lastSyncDate');
  @override
  late final GeneratedColumn<DateTime> lastSyncDate = GeneratedColumn<DateTime>(
      'last_sync_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        type,
        status,
        balance,
        initialBalance,
        currency,
        bankName,
        accountNumber,
        cardNumber,
        creditLimit,
        interestRate,
        openDate,
        closeDate,
        loanType,
        loanAmount,
        secondInterestRate,
        loanTerm,
        repaymentMethod,
        firstPaymentDate,
        remainingPrincipal,
        monthlyPayment,
        isRecurringPayment,
        iconName,
        color,
        isDefault,
        isHidden,
        tags,
        creationDate,
        updateDate,
        syncProvider,
        syncAccountId,
        lastSyncDate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(Insertable<Account> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('balance')) {
      context.handle(_balanceMeta,
          balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta));
    } else if (isInserting) {
      context.missing(_balanceMeta);
    }
    if (data.containsKey('initial_balance')) {
      context.handle(
          _initialBalanceMeta,
          initialBalance.isAcceptableOrUnknown(
              data['initial_balance']!, _initialBalanceMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('bank_name')) {
      context.handle(_bankNameMeta,
          bankName.isAcceptableOrUnknown(data['bank_name']!, _bankNameMeta));
    }
    if (data.containsKey('account_number')) {
      context.handle(
          _accountNumberMeta,
          accountNumber.isAcceptableOrUnknown(
              data['account_number']!, _accountNumberMeta));
    }
    if (data.containsKey('card_number')) {
      context.handle(
          _cardNumberMeta,
          cardNumber.isAcceptableOrUnknown(
              data['card_number']!, _cardNumberMeta));
    }
    if (data.containsKey('credit_limit')) {
      context.handle(
          _creditLimitMeta,
          creditLimit.isAcceptableOrUnknown(
              data['credit_limit']!, _creditLimitMeta));
    }
    if (data.containsKey('interest_rate')) {
      context.handle(
          _interestRateMeta,
          interestRate.isAcceptableOrUnknown(
              data['interest_rate']!, _interestRateMeta));
    }
    if (data.containsKey('open_date')) {
      context.handle(_openDateMeta,
          openDate.isAcceptableOrUnknown(data['open_date']!, _openDateMeta));
    }
    if (data.containsKey('close_date')) {
      context.handle(_closeDateMeta,
          closeDate.isAcceptableOrUnknown(data['close_date']!, _closeDateMeta));
    }
    if (data.containsKey('loan_type')) {
      context.handle(_loanTypeMeta,
          loanType.isAcceptableOrUnknown(data['loan_type']!, _loanTypeMeta));
    }
    if (data.containsKey('loan_amount')) {
      context.handle(
          _loanAmountMeta,
          loanAmount.isAcceptableOrUnknown(
              data['loan_amount']!, _loanAmountMeta));
    }
    if (data.containsKey('second_interest_rate')) {
      context.handle(
          _secondInterestRateMeta,
          secondInterestRate.isAcceptableOrUnknown(
              data['second_interest_rate']!, _secondInterestRateMeta));
    }
    if (data.containsKey('loan_term')) {
      context.handle(_loanTermMeta,
          loanTerm.isAcceptableOrUnknown(data['loan_term']!, _loanTermMeta));
    }
    if (data.containsKey('repayment_method')) {
      context.handle(
          _repaymentMethodMeta,
          repaymentMethod.isAcceptableOrUnknown(
              data['repayment_method']!, _repaymentMethodMeta));
    }
    if (data.containsKey('first_payment_date')) {
      context.handle(
          _firstPaymentDateMeta,
          firstPaymentDate.isAcceptableOrUnknown(
              data['first_payment_date']!, _firstPaymentDateMeta));
    }
    if (data.containsKey('remaining_principal')) {
      context.handle(
          _remainingPrincipalMeta,
          remainingPrincipal.isAcceptableOrUnknown(
              data['remaining_principal']!, _remainingPrincipalMeta));
    }
    if (data.containsKey('monthly_payment')) {
      context.handle(
          _monthlyPaymentMeta,
          monthlyPayment.isAcceptableOrUnknown(
              data['monthly_payment']!, _monthlyPaymentMeta));
    }
    if (data.containsKey('is_recurring_payment')) {
      context.handle(
          _isRecurringPaymentMeta,
          isRecurringPayment.isAcceptableOrUnknown(
              data['is_recurring_payment']!, _isRecurringPaymentMeta));
    }
    if (data.containsKey('icon_name')) {
      context.handle(_iconNameMeta,
          iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('is_hidden')) {
      context.handle(_isHiddenMeta,
          isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    } else if (isInserting) {
      context.missing(_tagsMeta);
    }
    if (data.containsKey('creation_date')) {
      context.handle(
          _creationDateMeta,
          creationDate.isAcceptableOrUnknown(
              data['creation_date']!, _creationDateMeta));
    } else if (isInserting) {
      context.missing(_creationDateMeta);
    }
    if (data.containsKey('update_date')) {
      context.handle(
          _updateDateMeta,
          updateDate.isAcceptableOrUnknown(
              data['update_date']!, _updateDateMeta));
    } else if (isInserting) {
      context.missing(_updateDateMeta);
    }
    if (data.containsKey('sync_provider')) {
      context.handle(
          _syncProviderMeta,
          syncProvider.isAcceptableOrUnknown(
              data['sync_provider']!, _syncProviderMeta));
    }
    if (data.containsKey('sync_account_id')) {
      context.handle(
          _syncAccountIdMeta,
          syncAccountId.isAcceptableOrUnknown(
              data['sync_account_id']!, _syncAccountIdMeta));
    }
    if (data.containsKey('last_sync_date')) {
      context.handle(
          _lastSyncDateMeta,
          lastSyncDate.isAcceptableOrUnknown(
              data['last_sync_date']!, _lastSyncDateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      balance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}balance'])!,
      initialBalance: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}initial_balance'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      bankName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bank_name']),
      accountNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_number']),
      cardNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}card_number']),
      creditLimit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}credit_limit']),
      interestRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}interest_rate']),
      openDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}open_date']),
      closeDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}close_date']),
      loanType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}loan_type']),
      loanAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}loan_amount']),
      secondInterestRate: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}second_interest_rate']),
      loanTerm: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}loan_term']),
      repaymentMethod: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}repayment_method']),
      firstPaymentDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}first_payment_date']),
      remainingPrincipal: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}remaining_principal']),
      monthlyPayment: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monthly_payment']),
      isRecurringPayment: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_recurring_payment'])!,
      iconName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_name']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      isHidden: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_hidden'])!,
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      creationDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}creation_date'])!,
      updateDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}update_date'])!,
      syncProvider: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_provider']),
      syncAccountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_account_id']),
      lastSyncDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_sync_date']),
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final String id;
  final String name;
  final String? description;
  final String type;
  final String status;
  final double balance;
  final double initialBalance;
  final String currency;
  final String? bankName;
  final String? accountNumber;
  final String? cardNumber;
  final double? creditLimit;
  final double? interestRate;
  final DateTime? openDate;
  final DateTime? closeDate;
  final String? loanType;
  final double? loanAmount;
  final double? secondInterestRate;
  final int? loanTerm;
  final String? repaymentMethod;
  final DateTime? firstPaymentDate;
  final double? remainingPrincipal;
  final double? monthlyPayment;
  final bool isRecurringPayment;
  final String? iconName;
  final String? color;
  final bool isDefault;
  final bool isHidden;
  final String tags;
  final DateTime creationDate;
  final DateTime updateDate;
  final String? syncProvider;
  final String? syncAccountId;
  final DateTime? lastSyncDate;
  const Account(
      {required this.id,
      required this.name,
      this.description,
      required this.type,
      required this.status,
      required this.balance,
      required this.initialBalance,
      required this.currency,
      this.bankName,
      this.accountNumber,
      this.cardNumber,
      this.creditLimit,
      this.interestRate,
      this.openDate,
      this.closeDate,
      this.loanType,
      this.loanAmount,
      this.secondInterestRate,
      this.loanTerm,
      this.repaymentMethod,
      this.firstPaymentDate,
      this.remainingPrincipal,
      this.monthlyPayment,
      required this.isRecurringPayment,
      this.iconName,
      this.color,
      required this.isDefault,
      required this.isHidden,
      required this.tags,
      required this.creationDate,
      required this.updateDate,
      this.syncProvider,
      this.syncAccountId,
      this.lastSyncDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    map['balance'] = Variable<double>(balance);
    map['initial_balance'] = Variable<double>(initialBalance);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || bankName != null) {
      map['bank_name'] = Variable<String>(bankName);
    }
    if (!nullToAbsent || accountNumber != null) {
      map['account_number'] = Variable<String>(accountNumber);
    }
    if (!nullToAbsent || cardNumber != null) {
      map['card_number'] = Variable<String>(cardNumber);
    }
    if (!nullToAbsent || creditLimit != null) {
      map['credit_limit'] = Variable<double>(creditLimit);
    }
    if (!nullToAbsent || interestRate != null) {
      map['interest_rate'] = Variable<double>(interestRate);
    }
    if (!nullToAbsent || openDate != null) {
      map['open_date'] = Variable<DateTime>(openDate);
    }
    if (!nullToAbsent || closeDate != null) {
      map['close_date'] = Variable<DateTime>(closeDate);
    }
    if (!nullToAbsent || loanType != null) {
      map['loan_type'] = Variable<String>(loanType);
    }
    if (!nullToAbsent || loanAmount != null) {
      map['loan_amount'] = Variable<double>(loanAmount);
    }
    if (!nullToAbsent || secondInterestRate != null) {
      map['second_interest_rate'] = Variable<double>(secondInterestRate);
    }
    if (!nullToAbsent || loanTerm != null) {
      map['loan_term'] = Variable<int>(loanTerm);
    }
    if (!nullToAbsent || repaymentMethod != null) {
      map['repayment_method'] = Variable<String>(repaymentMethod);
    }
    if (!nullToAbsent || firstPaymentDate != null) {
      map['first_payment_date'] = Variable<DateTime>(firstPaymentDate);
    }
    if (!nullToAbsent || remainingPrincipal != null) {
      map['remaining_principal'] = Variable<double>(remainingPrincipal);
    }
    if (!nullToAbsent || monthlyPayment != null) {
      map['monthly_payment'] = Variable<double>(monthlyPayment);
    }
    map['is_recurring_payment'] = Variable<bool>(isRecurringPayment);
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String>(iconName);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['is_hidden'] = Variable<bool>(isHidden);
    map['tags'] = Variable<String>(tags);
    map['creation_date'] = Variable<DateTime>(creationDate);
    map['update_date'] = Variable<DateTime>(updateDate);
    if (!nullToAbsent || syncProvider != null) {
      map['sync_provider'] = Variable<String>(syncProvider);
    }
    if (!nullToAbsent || syncAccountId != null) {
      map['sync_account_id'] = Variable<String>(syncAccountId);
    }
    if (!nullToAbsent || lastSyncDate != null) {
      map['last_sync_date'] = Variable<DateTime>(lastSyncDate);
    }
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      type: Value(type),
      status: Value(status),
      balance: Value(balance),
      initialBalance: Value(initialBalance),
      currency: Value(currency),
      bankName: bankName == null && nullToAbsent
          ? const Value.absent()
          : Value(bankName),
      accountNumber: accountNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(accountNumber),
      cardNumber: cardNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(cardNumber),
      creditLimit: creditLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(creditLimit),
      interestRate: interestRate == null && nullToAbsent
          ? const Value.absent()
          : Value(interestRate),
      openDate: openDate == null && nullToAbsent
          ? const Value.absent()
          : Value(openDate),
      closeDate: closeDate == null && nullToAbsent
          ? const Value.absent()
          : Value(closeDate),
      loanType: loanType == null && nullToAbsent
          ? const Value.absent()
          : Value(loanType),
      loanAmount: loanAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(loanAmount),
      secondInterestRate: secondInterestRate == null && nullToAbsent
          ? const Value.absent()
          : Value(secondInterestRate),
      loanTerm: loanTerm == null && nullToAbsent
          ? const Value.absent()
          : Value(loanTerm),
      repaymentMethod: repaymentMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(repaymentMethod),
      firstPaymentDate: firstPaymentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(firstPaymentDate),
      remainingPrincipal: remainingPrincipal == null && nullToAbsent
          ? const Value.absent()
          : Value(remainingPrincipal),
      monthlyPayment: monthlyPayment == null && nullToAbsent
          ? const Value.absent()
          : Value(monthlyPayment),
      isRecurringPayment: Value(isRecurringPayment),
      iconName: iconName == null && nullToAbsent
          ? const Value.absent()
          : Value(iconName),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      isDefault: Value(isDefault),
      isHidden: Value(isHidden),
      tags: Value(tags),
      creationDate: Value(creationDate),
      updateDate: Value(updateDate),
      syncProvider: syncProvider == null && nullToAbsent
          ? const Value.absent()
          : Value(syncProvider),
      syncAccountId: syncAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(syncAccountId),
      lastSyncDate: lastSyncDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncDate),
    );
  }

  factory Account.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      balance: serializer.fromJson<double>(json['balance']),
      initialBalance: serializer.fromJson<double>(json['initialBalance']),
      currency: serializer.fromJson<String>(json['currency']),
      bankName: serializer.fromJson<String?>(json['bankName']),
      accountNumber: serializer.fromJson<String?>(json['accountNumber']),
      cardNumber: serializer.fromJson<String?>(json['cardNumber']),
      creditLimit: serializer.fromJson<double?>(json['creditLimit']),
      interestRate: serializer.fromJson<double?>(json['interestRate']),
      openDate: serializer.fromJson<DateTime?>(json['openDate']),
      closeDate: serializer.fromJson<DateTime?>(json['closeDate']),
      loanType: serializer.fromJson<String?>(json['loanType']),
      loanAmount: serializer.fromJson<double?>(json['loanAmount']),
      secondInterestRate:
          serializer.fromJson<double?>(json['secondInterestRate']),
      loanTerm: serializer.fromJson<int?>(json['loanTerm']),
      repaymentMethod: serializer.fromJson<String?>(json['repaymentMethod']),
      firstPaymentDate:
          serializer.fromJson<DateTime?>(json['firstPaymentDate']),
      remainingPrincipal:
          serializer.fromJson<double?>(json['remainingPrincipal']),
      monthlyPayment: serializer.fromJson<double?>(json['monthlyPayment']),
      isRecurringPayment: serializer.fromJson<bool>(json['isRecurringPayment']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      color: serializer.fromJson<String?>(json['color']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
      tags: serializer.fromJson<String>(json['tags']),
      creationDate: serializer.fromJson<DateTime>(json['creationDate']),
      updateDate: serializer.fromJson<DateTime>(json['updateDate']),
      syncProvider: serializer.fromJson<String?>(json['syncProvider']),
      syncAccountId: serializer.fromJson<String?>(json['syncAccountId']),
      lastSyncDate: serializer.fromJson<DateTime?>(json['lastSyncDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'balance': serializer.toJson<double>(balance),
      'initialBalance': serializer.toJson<double>(initialBalance),
      'currency': serializer.toJson<String>(currency),
      'bankName': serializer.toJson<String?>(bankName),
      'accountNumber': serializer.toJson<String?>(accountNumber),
      'cardNumber': serializer.toJson<String?>(cardNumber),
      'creditLimit': serializer.toJson<double?>(creditLimit),
      'interestRate': serializer.toJson<double?>(interestRate),
      'openDate': serializer.toJson<DateTime?>(openDate),
      'closeDate': serializer.toJson<DateTime?>(closeDate),
      'loanType': serializer.toJson<String?>(loanType),
      'loanAmount': serializer.toJson<double?>(loanAmount),
      'secondInterestRate': serializer.toJson<double?>(secondInterestRate),
      'loanTerm': serializer.toJson<int?>(loanTerm),
      'repaymentMethod': serializer.toJson<String?>(repaymentMethod),
      'firstPaymentDate': serializer.toJson<DateTime?>(firstPaymentDate),
      'remainingPrincipal': serializer.toJson<double?>(remainingPrincipal),
      'monthlyPayment': serializer.toJson<double?>(monthlyPayment),
      'isRecurringPayment': serializer.toJson<bool>(isRecurringPayment),
      'iconName': serializer.toJson<String?>(iconName),
      'color': serializer.toJson<String?>(color),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isHidden': serializer.toJson<bool>(isHidden),
      'tags': serializer.toJson<String>(tags),
      'creationDate': serializer.toJson<DateTime>(creationDate),
      'updateDate': serializer.toJson<DateTime>(updateDate),
      'syncProvider': serializer.toJson<String?>(syncProvider),
      'syncAccountId': serializer.toJson<String?>(syncAccountId),
      'lastSyncDate': serializer.toJson<DateTime?>(lastSyncDate),
    };
  }

  Account copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          String? type,
          String? status,
          double? balance,
          double? initialBalance,
          String? currency,
          Value<String?> bankName = const Value.absent(),
          Value<String?> accountNumber = const Value.absent(),
          Value<String?> cardNumber = const Value.absent(),
          Value<double?> creditLimit = const Value.absent(),
          Value<double?> interestRate = const Value.absent(),
          Value<DateTime?> openDate = const Value.absent(),
          Value<DateTime?> closeDate = const Value.absent(),
          Value<String?> loanType = const Value.absent(),
          Value<double?> loanAmount = const Value.absent(),
          Value<double?> secondInterestRate = const Value.absent(),
          Value<int?> loanTerm = const Value.absent(),
          Value<String?> repaymentMethod = const Value.absent(),
          Value<DateTime?> firstPaymentDate = const Value.absent(),
          Value<double?> remainingPrincipal = const Value.absent(),
          Value<double?> monthlyPayment = const Value.absent(),
          bool? isRecurringPayment,
          Value<String?> iconName = const Value.absent(),
          Value<String?> color = const Value.absent(),
          bool? isDefault,
          bool? isHidden,
          String? tags,
          DateTime? creationDate,
          DateTime? updateDate,
          Value<String?> syncProvider = const Value.absent(),
          Value<String?> syncAccountId = const Value.absent(),
          Value<DateTime?> lastSyncDate = const Value.absent()}) =>
      Account(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        type: type ?? this.type,
        status: status ?? this.status,
        balance: balance ?? this.balance,
        initialBalance: initialBalance ?? this.initialBalance,
        currency: currency ?? this.currency,
        bankName: bankName.present ? bankName.value : this.bankName,
        accountNumber:
            accountNumber.present ? accountNumber.value : this.accountNumber,
        cardNumber: cardNumber.present ? cardNumber.value : this.cardNumber,
        creditLimit: creditLimit.present ? creditLimit.value : this.creditLimit,
        interestRate:
            interestRate.present ? interestRate.value : this.interestRate,
        openDate: openDate.present ? openDate.value : this.openDate,
        closeDate: closeDate.present ? closeDate.value : this.closeDate,
        loanType: loanType.present ? loanType.value : this.loanType,
        loanAmount: loanAmount.present ? loanAmount.value : this.loanAmount,
        secondInterestRate: secondInterestRate.present
            ? secondInterestRate.value
            : this.secondInterestRate,
        loanTerm: loanTerm.present ? loanTerm.value : this.loanTerm,
        repaymentMethod: repaymentMethod.present
            ? repaymentMethod.value
            : this.repaymentMethod,
        firstPaymentDate: firstPaymentDate.present
            ? firstPaymentDate.value
            : this.firstPaymentDate,
        remainingPrincipal: remainingPrincipal.present
            ? remainingPrincipal.value
            : this.remainingPrincipal,
        monthlyPayment:
            monthlyPayment.present ? monthlyPayment.value : this.monthlyPayment,
        isRecurringPayment: isRecurringPayment ?? this.isRecurringPayment,
        iconName: iconName.present ? iconName.value : this.iconName,
        color: color.present ? color.value : this.color,
        isDefault: isDefault ?? this.isDefault,
        isHidden: isHidden ?? this.isHidden,
        tags: tags ?? this.tags,
        creationDate: creationDate ?? this.creationDate,
        updateDate: updateDate ?? this.updateDate,
        syncProvider:
            syncProvider.present ? syncProvider.value : this.syncProvider,
        syncAccountId:
            syncAccountId.present ? syncAccountId.value : this.syncAccountId,
        lastSyncDate:
            lastSyncDate.present ? lastSyncDate.value : this.lastSyncDate,
      );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      balance: data.balance.present ? data.balance.value : this.balance,
      initialBalance: data.initialBalance.present
          ? data.initialBalance.value
          : this.initialBalance,
      currency: data.currency.present ? data.currency.value : this.currency,
      bankName: data.bankName.present ? data.bankName.value : this.bankName,
      accountNumber: data.accountNumber.present
          ? data.accountNumber.value
          : this.accountNumber,
      cardNumber:
          data.cardNumber.present ? data.cardNumber.value : this.cardNumber,
      creditLimit:
          data.creditLimit.present ? data.creditLimit.value : this.creditLimit,
      interestRate: data.interestRate.present
          ? data.interestRate.value
          : this.interestRate,
      openDate: data.openDate.present ? data.openDate.value : this.openDate,
      closeDate: data.closeDate.present ? data.closeDate.value : this.closeDate,
      loanType: data.loanType.present ? data.loanType.value : this.loanType,
      loanAmount:
          data.loanAmount.present ? data.loanAmount.value : this.loanAmount,
      secondInterestRate: data.secondInterestRate.present
          ? data.secondInterestRate.value
          : this.secondInterestRate,
      loanTerm: data.loanTerm.present ? data.loanTerm.value : this.loanTerm,
      repaymentMethod: data.repaymentMethod.present
          ? data.repaymentMethod.value
          : this.repaymentMethod,
      firstPaymentDate: data.firstPaymentDate.present
          ? data.firstPaymentDate.value
          : this.firstPaymentDate,
      remainingPrincipal: data.remainingPrincipal.present
          ? data.remainingPrincipal.value
          : this.remainingPrincipal,
      monthlyPayment: data.monthlyPayment.present
          ? data.monthlyPayment.value
          : this.monthlyPayment,
      isRecurringPayment: data.isRecurringPayment.present
          ? data.isRecurringPayment.value
          : this.isRecurringPayment,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      color: data.color.present ? data.color.value : this.color,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
      tags: data.tags.present ? data.tags.value : this.tags,
      creationDate: data.creationDate.present
          ? data.creationDate.value
          : this.creationDate,
      updateDate:
          data.updateDate.present ? data.updateDate.value : this.updateDate,
      syncProvider: data.syncProvider.present
          ? data.syncProvider.value
          : this.syncProvider,
      syncAccountId: data.syncAccountId.present
          ? data.syncAccountId.value
          : this.syncAccountId,
      lastSyncDate: data.lastSyncDate.present
          ? data.lastSyncDate.value
          : this.lastSyncDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('balance: $balance, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('currency: $currency, ')
          ..write('bankName: $bankName, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('cardNumber: $cardNumber, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('interestRate: $interestRate, ')
          ..write('openDate: $openDate, ')
          ..write('closeDate: $closeDate, ')
          ..write('loanType: $loanType, ')
          ..write('loanAmount: $loanAmount, ')
          ..write('secondInterestRate: $secondInterestRate, ')
          ..write('loanTerm: $loanTerm, ')
          ..write('repaymentMethod: $repaymentMethod, ')
          ..write('firstPaymentDate: $firstPaymentDate, ')
          ..write('remainingPrincipal: $remainingPrincipal, ')
          ..write('monthlyPayment: $monthlyPayment, ')
          ..write('isRecurringPayment: $isRecurringPayment, ')
          ..write('iconName: $iconName, ')
          ..write('color: $color, ')
          ..write('isDefault: $isDefault, ')
          ..write('isHidden: $isHidden, ')
          ..write('tags: $tags, ')
          ..write('creationDate: $creationDate, ')
          ..write('updateDate: $updateDate, ')
          ..write('syncProvider: $syncProvider, ')
          ..write('syncAccountId: $syncAccountId, ')
          ..write('lastSyncDate: $lastSyncDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        description,
        type,
        status,
        balance,
        initialBalance,
        currency,
        bankName,
        accountNumber,
        cardNumber,
        creditLimit,
        interestRate,
        openDate,
        closeDate,
        loanType,
        loanAmount,
        secondInterestRate,
        loanTerm,
        repaymentMethod,
        firstPaymentDate,
        remainingPrincipal,
        monthlyPayment,
        isRecurringPayment,
        iconName,
        color,
        isDefault,
        isHidden,
        tags,
        creationDate,
        updateDate,
        syncProvider,
        syncAccountId,
        lastSyncDate
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.type == this.type &&
          other.status == this.status &&
          other.balance == this.balance &&
          other.initialBalance == this.initialBalance &&
          other.currency == this.currency &&
          other.bankName == this.bankName &&
          other.accountNumber == this.accountNumber &&
          other.cardNumber == this.cardNumber &&
          other.creditLimit == this.creditLimit &&
          other.interestRate == this.interestRate &&
          other.openDate == this.openDate &&
          other.closeDate == this.closeDate &&
          other.loanType == this.loanType &&
          other.loanAmount == this.loanAmount &&
          other.secondInterestRate == this.secondInterestRate &&
          other.loanTerm == this.loanTerm &&
          other.repaymentMethod == this.repaymentMethod &&
          other.firstPaymentDate == this.firstPaymentDate &&
          other.remainingPrincipal == this.remainingPrincipal &&
          other.monthlyPayment == this.monthlyPayment &&
          other.isRecurringPayment == this.isRecurringPayment &&
          other.iconName == this.iconName &&
          other.color == this.color &&
          other.isDefault == this.isDefault &&
          other.isHidden == this.isHidden &&
          other.tags == this.tags &&
          other.creationDate == this.creationDate &&
          other.updateDate == this.updateDate &&
          other.syncProvider == this.syncProvider &&
          other.syncAccountId == this.syncAccountId &&
          other.lastSyncDate == this.lastSyncDate);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> type;
  final Value<String> status;
  final Value<double> balance;
  final Value<double> initialBalance;
  final Value<String> currency;
  final Value<String?> bankName;
  final Value<String?> accountNumber;
  final Value<String?> cardNumber;
  final Value<double?> creditLimit;
  final Value<double?> interestRate;
  final Value<DateTime?> openDate;
  final Value<DateTime?> closeDate;
  final Value<String?> loanType;
  final Value<double?> loanAmount;
  final Value<double?> secondInterestRate;
  final Value<int?> loanTerm;
  final Value<String?> repaymentMethod;
  final Value<DateTime?> firstPaymentDate;
  final Value<double?> remainingPrincipal;
  final Value<double?> monthlyPayment;
  final Value<bool> isRecurringPayment;
  final Value<String?> iconName;
  final Value<String?> color;
  final Value<bool> isDefault;
  final Value<bool> isHidden;
  final Value<String> tags;
  final Value<DateTime> creationDate;
  final Value<DateTime> updateDate;
  final Value<String?> syncProvider;
  final Value<String?> syncAccountId;
  final Value<DateTime?> lastSyncDate;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.balance = const Value.absent(),
    this.initialBalance = const Value.absent(),
    this.currency = const Value.absent(),
    this.bankName = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.cardNumber = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.interestRate = const Value.absent(),
    this.openDate = const Value.absent(),
    this.closeDate = const Value.absent(),
    this.loanType = const Value.absent(),
    this.loanAmount = const Value.absent(),
    this.secondInterestRate = const Value.absent(),
    this.loanTerm = const Value.absent(),
    this.repaymentMethod = const Value.absent(),
    this.firstPaymentDate = const Value.absent(),
    this.remainingPrincipal = const Value.absent(),
    this.monthlyPayment = const Value.absent(),
    this.isRecurringPayment = const Value.absent(),
    this.iconName = const Value.absent(),
    this.color = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.tags = const Value.absent(),
    this.creationDate = const Value.absent(),
    this.updateDate = const Value.absent(),
    this.syncProvider = const Value.absent(),
    this.syncAccountId = const Value.absent(),
    this.lastSyncDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String type,
    required String status,
    required double balance,
    this.initialBalance = const Value.absent(),
    this.currency = const Value.absent(),
    this.bankName = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.cardNumber = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.interestRate = const Value.absent(),
    this.openDate = const Value.absent(),
    this.closeDate = const Value.absent(),
    this.loanType = const Value.absent(),
    this.loanAmount = const Value.absent(),
    this.secondInterestRate = const Value.absent(),
    this.loanTerm = const Value.absent(),
    this.repaymentMethod = const Value.absent(),
    this.firstPaymentDate = const Value.absent(),
    this.remainingPrincipal = const Value.absent(),
    this.monthlyPayment = const Value.absent(),
    this.isRecurringPayment = const Value.absent(),
    this.iconName = const Value.absent(),
    this.color = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isHidden = const Value.absent(),
    required String tags,
    required DateTime creationDate,
    required DateTime updateDate,
    this.syncProvider = const Value.absent(),
    this.syncAccountId = const Value.absent(),
    this.lastSyncDate = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        type = Value(type),
        status = Value(status),
        balance = Value(balance),
        tags = Value(tags),
        creationDate = Value(creationDate),
        updateDate = Value(updateDate);
  static Insertable<Account> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? type,
    Expression<String>? status,
    Expression<double>? balance,
    Expression<double>? initialBalance,
    Expression<String>? currency,
    Expression<String>? bankName,
    Expression<String>? accountNumber,
    Expression<String>? cardNumber,
    Expression<double>? creditLimit,
    Expression<double>? interestRate,
    Expression<DateTime>? openDate,
    Expression<DateTime>? closeDate,
    Expression<String>? loanType,
    Expression<double>? loanAmount,
    Expression<double>? secondInterestRate,
    Expression<int>? loanTerm,
    Expression<String>? repaymentMethod,
    Expression<DateTime>? firstPaymentDate,
    Expression<double>? remainingPrincipal,
    Expression<double>? monthlyPayment,
    Expression<bool>? isRecurringPayment,
    Expression<String>? iconName,
    Expression<String>? color,
    Expression<bool>? isDefault,
    Expression<bool>? isHidden,
    Expression<String>? tags,
    Expression<DateTime>? creationDate,
    Expression<DateTime>? updateDate,
    Expression<String>? syncProvider,
    Expression<String>? syncAccountId,
    Expression<DateTime>? lastSyncDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (balance != null) 'balance': balance,
      if (initialBalance != null) 'initial_balance': initialBalance,
      if (currency != null) 'currency': currency,
      if (bankName != null) 'bank_name': bankName,
      if (accountNumber != null) 'account_number': accountNumber,
      if (cardNumber != null) 'card_number': cardNumber,
      if (creditLimit != null) 'credit_limit': creditLimit,
      if (interestRate != null) 'interest_rate': interestRate,
      if (openDate != null) 'open_date': openDate,
      if (closeDate != null) 'close_date': closeDate,
      if (loanType != null) 'loan_type': loanType,
      if (loanAmount != null) 'loan_amount': loanAmount,
      if (secondInterestRate != null)
        'second_interest_rate': secondInterestRate,
      if (loanTerm != null) 'loan_term': loanTerm,
      if (repaymentMethod != null) 'repayment_method': repaymentMethod,
      if (firstPaymentDate != null) 'first_payment_date': firstPaymentDate,
      if (remainingPrincipal != null) 'remaining_principal': remainingPrincipal,
      if (monthlyPayment != null) 'monthly_payment': monthlyPayment,
      if (isRecurringPayment != null)
        'is_recurring_payment': isRecurringPayment,
      if (iconName != null) 'icon_name': iconName,
      if (color != null) 'color': color,
      if (isDefault != null) 'is_default': isDefault,
      if (isHidden != null) 'is_hidden': isHidden,
      if (tags != null) 'tags': tags,
      if (creationDate != null) 'creation_date': creationDate,
      if (updateDate != null) 'update_date': updateDate,
      if (syncProvider != null) 'sync_provider': syncProvider,
      if (syncAccountId != null) 'sync_account_id': syncAccountId,
      if (lastSyncDate != null) 'last_sync_date': lastSyncDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? type,
      Value<String>? status,
      Value<double>? balance,
      Value<double>? initialBalance,
      Value<String>? currency,
      Value<String?>? bankName,
      Value<String?>? accountNumber,
      Value<String?>? cardNumber,
      Value<double?>? creditLimit,
      Value<double?>? interestRate,
      Value<DateTime?>? openDate,
      Value<DateTime?>? closeDate,
      Value<String?>? loanType,
      Value<double?>? loanAmount,
      Value<double?>? secondInterestRate,
      Value<int?>? loanTerm,
      Value<String?>? repaymentMethod,
      Value<DateTime?>? firstPaymentDate,
      Value<double?>? remainingPrincipal,
      Value<double?>? monthlyPayment,
      Value<bool>? isRecurringPayment,
      Value<String?>? iconName,
      Value<String?>? color,
      Value<bool>? isDefault,
      Value<bool>? isHidden,
      Value<String>? tags,
      Value<DateTime>? creationDate,
      Value<DateTime>? updateDate,
      Value<String?>? syncProvider,
      Value<String?>? syncAccountId,
      Value<DateTime?>? lastSyncDate,
      Value<int>? rowid}) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      balance: balance ?? this.balance,
      initialBalance: initialBalance ?? this.initialBalance,
      currency: currency ?? this.currency,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      cardNumber: cardNumber ?? this.cardNumber,
      creditLimit: creditLimit ?? this.creditLimit,
      interestRate: interestRate ?? this.interestRate,
      openDate: openDate ?? this.openDate,
      closeDate: closeDate ?? this.closeDate,
      loanType: loanType ?? this.loanType,
      loanAmount: loanAmount ?? this.loanAmount,
      secondInterestRate: secondInterestRate ?? this.secondInterestRate,
      loanTerm: loanTerm ?? this.loanTerm,
      repaymentMethod: repaymentMethod ?? this.repaymentMethod,
      firstPaymentDate: firstPaymentDate ?? this.firstPaymentDate,
      remainingPrincipal: remainingPrincipal ?? this.remainingPrincipal,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      isRecurringPayment: isRecurringPayment ?? this.isRecurringPayment,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      isHidden: isHidden ?? this.isHidden,
      tags: tags ?? this.tags,
      creationDate: creationDate ?? this.creationDate,
      updateDate: updateDate ?? this.updateDate,
      syncProvider: syncProvider ?? this.syncProvider,
      syncAccountId: syncAccountId ?? this.syncAccountId,
      lastSyncDate: lastSyncDate ?? this.lastSyncDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (initialBalance.present) {
      map['initial_balance'] = Variable<double>(initialBalance.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (bankName.present) {
      map['bank_name'] = Variable<String>(bankName.value);
    }
    if (accountNumber.present) {
      map['account_number'] = Variable<String>(accountNumber.value);
    }
    if (cardNumber.present) {
      map['card_number'] = Variable<String>(cardNumber.value);
    }
    if (creditLimit.present) {
      map['credit_limit'] = Variable<double>(creditLimit.value);
    }
    if (interestRate.present) {
      map['interest_rate'] = Variable<double>(interestRate.value);
    }
    if (openDate.present) {
      map['open_date'] = Variable<DateTime>(openDate.value);
    }
    if (closeDate.present) {
      map['close_date'] = Variable<DateTime>(closeDate.value);
    }
    if (loanType.present) {
      map['loan_type'] = Variable<String>(loanType.value);
    }
    if (loanAmount.present) {
      map['loan_amount'] = Variable<double>(loanAmount.value);
    }
    if (secondInterestRate.present) {
      map['second_interest_rate'] = Variable<double>(secondInterestRate.value);
    }
    if (loanTerm.present) {
      map['loan_term'] = Variable<int>(loanTerm.value);
    }
    if (repaymentMethod.present) {
      map['repayment_method'] = Variable<String>(repaymentMethod.value);
    }
    if (firstPaymentDate.present) {
      map['first_payment_date'] = Variable<DateTime>(firstPaymentDate.value);
    }
    if (remainingPrincipal.present) {
      map['remaining_principal'] = Variable<double>(remainingPrincipal.value);
    }
    if (monthlyPayment.present) {
      map['monthly_payment'] = Variable<double>(monthlyPayment.value);
    }
    if (isRecurringPayment.present) {
      map['is_recurring_payment'] = Variable<bool>(isRecurringPayment.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (creationDate.present) {
      map['creation_date'] = Variable<DateTime>(creationDate.value);
    }
    if (updateDate.present) {
      map['update_date'] = Variable<DateTime>(updateDate.value);
    }
    if (syncProvider.present) {
      map['sync_provider'] = Variable<String>(syncProvider.value);
    }
    if (syncAccountId.present) {
      map['sync_account_id'] = Variable<String>(syncAccountId.value);
    }
    if (lastSyncDate.present) {
      map['last_sync_date'] = Variable<DateTime>(lastSyncDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('balance: $balance, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('currency: $currency, ')
          ..write('bankName: $bankName, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('cardNumber: $cardNumber, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('interestRate: $interestRate, ')
          ..write('openDate: $openDate, ')
          ..write('closeDate: $closeDate, ')
          ..write('loanType: $loanType, ')
          ..write('loanAmount: $loanAmount, ')
          ..write('secondInterestRate: $secondInterestRate, ')
          ..write('loanTerm: $loanTerm, ')
          ..write('repaymentMethod: $repaymentMethod, ')
          ..write('firstPaymentDate: $firstPaymentDate, ')
          ..write('remainingPrincipal: $remainingPrincipal, ')
          ..write('monthlyPayment: $monthlyPayment, ')
          ..write('isRecurringPayment: $isRecurringPayment, ')
          ..write('iconName: $iconName, ')
          ..write('color: $color, ')
          ..write('isDefault: $isDefault, ')
          ..write('isHidden: $isHidden, ')
          ..write('tags: $tags, ')
          ..write('creationDate: $creationDate, ')
          ..write('updateDate: $updateDate, ')
          ..write('syncProvider: $syncProvider, ')
          ..write('syncAccountId: $syncAccountId, ')
          ..write('lastSyncDate: $lastSyncDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EnvelopeBudgetsTable extends EnvelopeBudgets
    with TableInfo<$EnvelopeBudgetsTable, EnvelopeBudget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnvelopeBudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _allocatedAmountMeta =
      const VerificationMeta('allocatedAmount');
  @override
  late final GeneratedColumn<double> allocatedAmount = GeneratedColumn<double>(
      'allocated_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _spentAmountMeta =
      const VerificationMeta('spentAmount');
  @override
  late final GeneratedColumn<double> spentAmount = GeneratedColumn<double>(
      'spent_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
      'period', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _iconNameMeta =
      const VerificationMeta('iconName');
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
      'icon_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isEssentialMeta =
      const VerificationMeta('isEssential');
  @override
  late final GeneratedColumn<bool> isEssential = GeneratedColumn<bool>(
      'is_essential', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_essential" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _warningThresholdMeta =
      const VerificationMeta('warningThreshold');
  @override
  late final GeneratedColumn<double> warningThreshold = GeneratedColumn<double>(
      'warning_threshold', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _limitThresholdMeta =
      const VerificationMeta('limitThreshold');
  @override
  late final GeneratedColumn<double> limitThreshold = GeneratedColumn<double>(
      'limit_threshold', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _creationDateMeta =
      const VerificationMeta('creationDate');
  @override
  late final GeneratedColumn<DateTime> creationDate = GeneratedColumn<DateTime>(
      'creation_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updateDateMeta =
      const VerificationMeta('updateDate');
  @override
  late final GeneratedColumn<DateTime> updateDate = GeneratedColumn<DateTime>(
      'update_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        category,
        allocatedAmount,
        spentAmount,
        period,
        startDate,
        endDate,
        status,
        color,
        iconName,
        isEssential,
        warningThreshold,
        limitThreshold,
        tags,
        creationDate,
        updateDate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'envelope_budgets';
  @override
  VerificationContext validateIntegrity(Insertable<EnvelopeBudget> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('allocated_amount')) {
      context.handle(
          _allocatedAmountMeta,
          allocatedAmount.isAcceptableOrUnknown(
              data['allocated_amount']!, _allocatedAmountMeta));
    } else if (isInserting) {
      context.missing(_allocatedAmountMeta);
    }
    if (data.containsKey('spent_amount')) {
      context.handle(
          _spentAmountMeta,
          spentAmount.isAcceptableOrUnknown(
              data['spent_amount']!, _spentAmountMeta));
    }
    if (data.containsKey('period')) {
      context.handle(_periodMeta,
          period.isAcceptableOrUnknown(data['period']!, _periodMeta));
    } else if (isInserting) {
      context.missing(_periodMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('icon_name')) {
      context.handle(_iconNameMeta,
          iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta));
    }
    if (data.containsKey('is_essential')) {
      context.handle(
          _isEssentialMeta,
          isEssential.isAcceptableOrUnknown(
              data['is_essential']!, _isEssentialMeta));
    }
    if (data.containsKey('warning_threshold')) {
      context.handle(
          _warningThresholdMeta,
          warningThreshold.isAcceptableOrUnknown(
              data['warning_threshold']!, _warningThresholdMeta));
    }
    if (data.containsKey('limit_threshold')) {
      context.handle(
          _limitThresholdMeta,
          limitThreshold.isAcceptableOrUnknown(
              data['limit_threshold']!, _limitThresholdMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    } else if (isInserting) {
      context.missing(_tagsMeta);
    }
    if (data.containsKey('creation_date')) {
      context.handle(
          _creationDateMeta,
          creationDate.isAcceptableOrUnknown(
              data['creation_date']!, _creationDateMeta));
    } else if (isInserting) {
      context.missing(_creationDateMeta);
    }
    if (data.containsKey('update_date')) {
      context.handle(
          _updateDateMeta,
          updateDate.isAcceptableOrUnknown(
              data['update_date']!, _updateDateMeta));
    } else if (isInserting) {
      context.missing(_updateDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EnvelopeBudget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnvelopeBudget(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      allocatedAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}allocated_amount'])!,
      spentAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}spent_amount'])!,
      period: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}period'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      iconName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_name']),
      isEssential: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_essential'])!,
      warningThreshold: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}warning_threshold']),
      limitThreshold: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}limit_threshold']),
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      creationDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}creation_date'])!,
      updateDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}update_date'])!,
    );
  }

  @override
  $EnvelopeBudgetsTable createAlias(String alias) {
    return $EnvelopeBudgetsTable(attachedDatabase, alias);
  }
}

class EnvelopeBudget extends DataClass implements Insertable<EnvelopeBudget> {
  final String id;
  final String name;
  final String? description;
  final String category;
  final double allocatedAmount;
  final double spentAmount;
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String? color;
  final String? iconName;
  final bool isEssential;
  final double? warningThreshold;
  final double? limitThreshold;
  final String tags;
  final DateTime creationDate;
  final DateTime updateDate;
  const EnvelopeBudget(
      {required this.id,
      required this.name,
      this.description,
      required this.category,
      required this.allocatedAmount,
      required this.spentAmount,
      required this.period,
      required this.startDate,
      required this.endDate,
      required this.status,
      this.color,
      this.iconName,
      required this.isEssential,
      this.warningThreshold,
      this.limitThreshold,
      required this.tags,
      required this.creationDate,
      required this.updateDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['category'] = Variable<String>(category);
    map['allocated_amount'] = Variable<double>(allocatedAmount);
    map['spent_amount'] = Variable<double>(spentAmount);
    map['period'] = Variable<String>(period);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String>(iconName);
    }
    map['is_essential'] = Variable<bool>(isEssential);
    if (!nullToAbsent || warningThreshold != null) {
      map['warning_threshold'] = Variable<double>(warningThreshold);
    }
    if (!nullToAbsent || limitThreshold != null) {
      map['limit_threshold'] = Variable<double>(limitThreshold);
    }
    map['tags'] = Variable<String>(tags);
    map['creation_date'] = Variable<DateTime>(creationDate);
    map['update_date'] = Variable<DateTime>(updateDate);
    return map;
  }

  EnvelopeBudgetsCompanion toCompanion(bool nullToAbsent) {
    return EnvelopeBudgetsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      category: Value(category),
      allocatedAmount: Value(allocatedAmount),
      spentAmount: Value(spentAmount),
      period: Value(period),
      startDate: Value(startDate),
      endDate: Value(endDate),
      status: Value(status),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      iconName: iconName == null && nullToAbsent
          ? const Value.absent()
          : Value(iconName),
      isEssential: Value(isEssential),
      warningThreshold: warningThreshold == null && nullToAbsent
          ? const Value.absent()
          : Value(warningThreshold),
      limitThreshold: limitThreshold == null && nullToAbsent
          ? const Value.absent()
          : Value(limitThreshold),
      tags: Value(tags),
      creationDate: Value(creationDate),
      updateDate: Value(updateDate),
    );
  }

  factory EnvelopeBudget.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnvelopeBudget(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      category: serializer.fromJson<String>(json['category']),
      allocatedAmount: serializer.fromJson<double>(json['allocatedAmount']),
      spentAmount: serializer.fromJson<double>(json['spentAmount']),
      period: serializer.fromJson<String>(json['period']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      status: serializer.fromJson<String>(json['status']),
      color: serializer.fromJson<String?>(json['color']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      isEssential: serializer.fromJson<bool>(json['isEssential']),
      warningThreshold: serializer.fromJson<double?>(json['warningThreshold']),
      limitThreshold: serializer.fromJson<double?>(json['limitThreshold']),
      tags: serializer.fromJson<String>(json['tags']),
      creationDate: serializer.fromJson<DateTime>(json['creationDate']),
      updateDate: serializer.fromJson<DateTime>(json['updateDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'category': serializer.toJson<String>(category),
      'allocatedAmount': serializer.toJson<double>(allocatedAmount),
      'spentAmount': serializer.toJson<double>(spentAmount),
      'period': serializer.toJson<String>(period),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'status': serializer.toJson<String>(status),
      'color': serializer.toJson<String?>(color),
      'iconName': serializer.toJson<String?>(iconName),
      'isEssential': serializer.toJson<bool>(isEssential),
      'warningThreshold': serializer.toJson<double?>(warningThreshold),
      'limitThreshold': serializer.toJson<double?>(limitThreshold),
      'tags': serializer.toJson<String>(tags),
      'creationDate': serializer.toJson<DateTime>(creationDate),
      'updateDate': serializer.toJson<DateTime>(updateDate),
    };
  }

  EnvelopeBudget copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          String? category,
          double? allocatedAmount,
          double? spentAmount,
          String? period,
          DateTime? startDate,
          DateTime? endDate,
          String? status,
          Value<String?> color = const Value.absent(),
          Value<String?> iconName = const Value.absent(),
          bool? isEssential,
          Value<double?> warningThreshold = const Value.absent(),
          Value<double?> limitThreshold = const Value.absent(),
          String? tags,
          DateTime? creationDate,
          DateTime? updateDate}) =>
      EnvelopeBudget(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        category: category ?? this.category,
        allocatedAmount: allocatedAmount ?? this.allocatedAmount,
        spentAmount: spentAmount ?? this.spentAmount,
        period: period ?? this.period,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        status: status ?? this.status,
        color: color.present ? color.value : this.color,
        iconName: iconName.present ? iconName.value : this.iconName,
        isEssential: isEssential ?? this.isEssential,
        warningThreshold: warningThreshold.present
            ? warningThreshold.value
            : this.warningThreshold,
        limitThreshold:
            limitThreshold.present ? limitThreshold.value : this.limitThreshold,
        tags: tags ?? this.tags,
        creationDate: creationDate ?? this.creationDate,
        updateDate: updateDate ?? this.updateDate,
      );
  EnvelopeBudget copyWithCompanion(EnvelopeBudgetsCompanion data) {
    return EnvelopeBudget(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      category: data.category.present ? data.category.value : this.category,
      allocatedAmount: data.allocatedAmount.present
          ? data.allocatedAmount.value
          : this.allocatedAmount,
      spentAmount:
          data.spentAmount.present ? data.spentAmount.value : this.spentAmount,
      period: data.period.present ? data.period.value : this.period,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      status: data.status.present ? data.status.value : this.status,
      color: data.color.present ? data.color.value : this.color,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      isEssential:
          data.isEssential.present ? data.isEssential.value : this.isEssential,
      warningThreshold: data.warningThreshold.present
          ? data.warningThreshold.value
          : this.warningThreshold,
      limitThreshold: data.limitThreshold.present
          ? data.limitThreshold.value
          : this.limitThreshold,
      tags: data.tags.present ? data.tags.value : this.tags,
      creationDate: data.creationDate.present
          ? data.creationDate.value
          : this.creationDate,
      updateDate:
          data.updateDate.present ? data.updateDate.value : this.updateDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnvelopeBudget(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('allocatedAmount: $allocatedAmount, ')
          ..write('spentAmount: $spentAmount, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('color: $color, ')
          ..write('iconName: $iconName, ')
          ..write('isEssential: $isEssential, ')
          ..write('warningThreshold: $warningThreshold, ')
          ..write('limitThreshold: $limitThreshold, ')
          ..write('tags: $tags, ')
          ..write('creationDate: $creationDate, ')
          ..write('updateDate: $updateDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      description,
      category,
      allocatedAmount,
      spentAmount,
      period,
      startDate,
      endDate,
      status,
      color,
      iconName,
      isEssential,
      warningThreshold,
      limitThreshold,
      tags,
      creationDate,
      updateDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnvelopeBudget &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.category == this.category &&
          other.allocatedAmount == this.allocatedAmount &&
          other.spentAmount == this.spentAmount &&
          other.period == this.period &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.status == this.status &&
          other.color == this.color &&
          other.iconName == this.iconName &&
          other.isEssential == this.isEssential &&
          other.warningThreshold == this.warningThreshold &&
          other.limitThreshold == this.limitThreshold &&
          other.tags == this.tags &&
          other.creationDate == this.creationDate &&
          other.updateDate == this.updateDate);
}

class EnvelopeBudgetsCompanion extends UpdateCompanion<EnvelopeBudget> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> category;
  final Value<double> allocatedAmount;
  final Value<double> spentAmount;
  final Value<String> period;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<String> status;
  final Value<String?> color;
  final Value<String?> iconName;
  final Value<bool> isEssential;
  final Value<double?> warningThreshold;
  final Value<double?> limitThreshold;
  final Value<String> tags;
  final Value<DateTime> creationDate;
  final Value<DateTime> updateDate;
  final Value<int> rowid;
  const EnvelopeBudgetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.allocatedAmount = const Value.absent(),
    this.spentAmount = const Value.absent(),
    this.period = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.status = const Value.absent(),
    this.color = const Value.absent(),
    this.iconName = const Value.absent(),
    this.isEssential = const Value.absent(),
    this.warningThreshold = const Value.absent(),
    this.limitThreshold = const Value.absent(),
    this.tags = const Value.absent(),
    this.creationDate = const Value.absent(),
    this.updateDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EnvelopeBudgetsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String category,
    required double allocatedAmount,
    this.spentAmount = const Value.absent(),
    required String period,
    required DateTime startDate,
    required DateTime endDate,
    required String status,
    this.color = const Value.absent(),
    this.iconName = const Value.absent(),
    this.isEssential = const Value.absent(),
    this.warningThreshold = const Value.absent(),
    this.limitThreshold = const Value.absent(),
    required String tags,
    required DateTime creationDate,
    required DateTime updateDate,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        category = Value(category),
        allocatedAmount = Value(allocatedAmount),
        period = Value(period),
        startDate = Value(startDate),
        endDate = Value(endDate),
        status = Value(status),
        tags = Value(tags),
        creationDate = Value(creationDate),
        updateDate = Value(updateDate);
  static Insertable<EnvelopeBudget> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? category,
    Expression<double>? allocatedAmount,
    Expression<double>? spentAmount,
    Expression<String>? period,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? status,
    Expression<String>? color,
    Expression<String>? iconName,
    Expression<bool>? isEssential,
    Expression<double>? warningThreshold,
    Expression<double>? limitThreshold,
    Expression<String>? tags,
    Expression<DateTime>? creationDate,
    Expression<DateTime>? updateDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (allocatedAmount != null) 'allocated_amount': allocatedAmount,
      if (spentAmount != null) 'spent_amount': spentAmount,
      if (period != null) 'period': period,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (status != null) 'status': status,
      if (color != null) 'color': color,
      if (iconName != null) 'icon_name': iconName,
      if (isEssential != null) 'is_essential': isEssential,
      if (warningThreshold != null) 'warning_threshold': warningThreshold,
      if (limitThreshold != null) 'limit_threshold': limitThreshold,
      if (tags != null) 'tags': tags,
      if (creationDate != null) 'creation_date': creationDate,
      if (updateDate != null) 'update_date': updateDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EnvelopeBudgetsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? category,
      Value<double>? allocatedAmount,
      Value<double>? spentAmount,
      Value<String>? period,
      Value<DateTime>? startDate,
      Value<DateTime>? endDate,
      Value<String>? status,
      Value<String?>? color,
      Value<String?>? iconName,
      Value<bool>? isEssential,
      Value<double?>? warningThreshold,
      Value<double?>? limitThreshold,
      Value<String>? tags,
      Value<DateTime>? creationDate,
      Value<DateTime>? updateDate,
      Value<int>? rowid}) {
    return EnvelopeBudgetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      color: color ?? this.color,
      iconName: iconName ?? this.iconName,
      isEssential: isEssential ?? this.isEssential,
      warningThreshold: warningThreshold ?? this.warningThreshold,
      limitThreshold: limitThreshold ?? this.limitThreshold,
      tags: tags ?? this.tags,
      creationDate: creationDate ?? this.creationDate,
      updateDate: updateDate ?? this.updateDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (allocatedAmount.present) {
      map['allocated_amount'] = Variable<double>(allocatedAmount.value);
    }
    if (spentAmount.present) {
      map['spent_amount'] = Variable<double>(spentAmount.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (isEssential.present) {
      map['is_essential'] = Variable<bool>(isEssential.value);
    }
    if (warningThreshold.present) {
      map['warning_threshold'] = Variable<double>(warningThreshold.value);
    }
    if (limitThreshold.present) {
      map['limit_threshold'] = Variable<double>(limitThreshold.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (creationDate.present) {
      map['creation_date'] = Variable<DateTime>(creationDate.value);
    }
    if (updateDate.present) {
      map['update_date'] = Variable<DateTime>(updateDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnvelopeBudgetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('allocatedAmount: $allocatedAmount, ')
          ..write('spentAmount: $spentAmount, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('color: $color, ')
          ..write('iconName: $iconName, ')
          ..write('isEssential: $isEssential, ')
          ..write('warningThreshold: $warningThreshold, ')
          ..write('limitThreshold: $limitThreshold, ')
          ..write('tags: $tags, ')
          ..write('creationDate: $creationDate, ')
          ..write('updateDate: $updateDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ZeroBasedBudgetsTable extends ZeroBasedBudgets
    with TableInfo<$ZeroBasedBudgetsTable, ZeroBasedBudget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ZeroBasedBudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _totalIncomeMeta =
      const VerificationMeta('totalIncome');
  @override
  late final GeneratedColumn<double> totalIncome = GeneratedColumn<double>(
      'total_income', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalAllocatedMeta =
      const VerificationMeta('totalAllocated');
  @override
  late final GeneratedColumn<double> totalAllocated = GeneratedColumn<double>(
      'total_allocated', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _envelopesMeta =
      const VerificationMeta('envelopes');
  @override
  late final GeneratedColumn<String> envelopes = GeneratedColumn<String>(
      'envelopes', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
      'period', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _creationDateMeta =
      const VerificationMeta('creationDate');
  @override
  late final GeneratedColumn<DateTime> creationDate = GeneratedColumn<DateTime>(
      'creation_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updateDateMeta =
      const VerificationMeta('updateDate');
  @override
  late final GeneratedColumn<DateTime> updateDate = GeneratedColumn<DateTime>(
      'update_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        totalIncome,
        totalAllocated,
        envelopes,
        period,
        startDate,
        endDate,
        status,
        creationDate,
        updateDate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'zero_based_budgets';
  @override
  VerificationContext validateIntegrity(Insertable<ZeroBasedBudget> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('total_income')) {
      context.handle(
          _totalIncomeMeta,
          totalIncome.isAcceptableOrUnknown(
              data['total_income']!, _totalIncomeMeta));
    } else if (isInserting) {
      context.missing(_totalIncomeMeta);
    }
    if (data.containsKey('total_allocated')) {
      context.handle(
          _totalAllocatedMeta,
          totalAllocated.isAcceptableOrUnknown(
              data['total_allocated']!, _totalAllocatedMeta));
    }
    if (data.containsKey('envelopes')) {
      context.handle(_envelopesMeta,
          envelopes.isAcceptableOrUnknown(data['envelopes']!, _envelopesMeta));
    } else if (isInserting) {
      context.missing(_envelopesMeta);
    }
    if (data.containsKey('period')) {
      context.handle(_periodMeta,
          period.isAcceptableOrUnknown(data['period']!, _periodMeta));
    } else if (isInserting) {
      context.missing(_periodMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('creation_date')) {
      context.handle(
          _creationDateMeta,
          creationDate.isAcceptableOrUnknown(
              data['creation_date']!, _creationDateMeta));
    } else if (isInserting) {
      context.missing(_creationDateMeta);
    }
    if (data.containsKey('update_date')) {
      context.handle(
          _updateDateMeta,
          updateDate.isAcceptableOrUnknown(
              data['update_date']!, _updateDateMeta));
    } else if (isInserting) {
      context.missing(_updateDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ZeroBasedBudget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ZeroBasedBudget(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      totalIncome: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_income'])!,
      totalAllocated: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}total_allocated'])!,
      envelopes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}envelopes'])!,
      period: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}period'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      creationDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}creation_date'])!,
      updateDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}update_date'])!,
    );
  }

  @override
  $ZeroBasedBudgetsTable createAlias(String alias) {
    return $ZeroBasedBudgetsTable(attachedDatabase, alias);
  }
}

class ZeroBasedBudget extends DataClass implements Insertable<ZeroBasedBudget> {
  final String id;
  final String name;
  final String? description;
  final double totalIncome;
  final double totalAllocated;
  final String envelopes;
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final DateTime creationDate;
  final DateTime updateDate;
  const ZeroBasedBudget(
      {required this.id,
      required this.name,
      this.description,
      required this.totalIncome,
      required this.totalAllocated,
      required this.envelopes,
      required this.period,
      required this.startDate,
      required this.endDate,
      required this.status,
      required this.creationDate,
      required this.updateDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['total_income'] = Variable<double>(totalIncome);
    map['total_allocated'] = Variable<double>(totalAllocated);
    map['envelopes'] = Variable<String>(envelopes);
    map['period'] = Variable<String>(period);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['status'] = Variable<String>(status);
    map['creation_date'] = Variable<DateTime>(creationDate);
    map['update_date'] = Variable<DateTime>(updateDate);
    return map;
  }

  ZeroBasedBudgetsCompanion toCompanion(bool nullToAbsent) {
    return ZeroBasedBudgetsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      totalIncome: Value(totalIncome),
      totalAllocated: Value(totalAllocated),
      envelopes: Value(envelopes),
      period: Value(period),
      startDate: Value(startDate),
      endDate: Value(endDate),
      status: Value(status),
      creationDate: Value(creationDate),
      updateDate: Value(updateDate),
    );
  }

  factory ZeroBasedBudget.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ZeroBasedBudget(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      totalIncome: serializer.fromJson<double>(json['totalIncome']),
      totalAllocated: serializer.fromJson<double>(json['totalAllocated']),
      envelopes: serializer.fromJson<String>(json['envelopes']),
      period: serializer.fromJson<String>(json['period']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      status: serializer.fromJson<String>(json['status']),
      creationDate: serializer.fromJson<DateTime>(json['creationDate']),
      updateDate: serializer.fromJson<DateTime>(json['updateDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'totalIncome': serializer.toJson<double>(totalIncome),
      'totalAllocated': serializer.toJson<double>(totalAllocated),
      'envelopes': serializer.toJson<String>(envelopes),
      'period': serializer.toJson<String>(period),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'status': serializer.toJson<String>(status),
      'creationDate': serializer.toJson<DateTime>(creationDate),
      'updateDate': serializer.toJson<DateTime>(updateDate),
    };
  }

  ZeroBasedBudget copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          double? totalIncome,
          double? totalAllocated,
          String? envelopes,
          String? period,
          DateTime? startDate,
          DateTime? endDate,
          String? status,
          DateTime? creationDate,
          DateTime? updateDate}) =>
      ZeroBasedBudget(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        totalIncome: totalIncome ?? this.totalIncome,
        totalAllocated: totalAllocated ?? this.totalAllocated,
        envelopes: envelopes ?? this.envelopes,
        period: period ?? this.period,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        status: status ?? this.status,
        creationDate: creationDate ?? this.creationDate,
        updateDate: updateDate ?? this.updateDate,
      );
  ZeroBasedBudget copyWithCompanion(ZeroBasedBudgetsCompanion data) {
    return ZeroBasedBudget(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      totalIncome:
          data.totalIncome.present ? data.totalIncome.value : this.totalIncome,
      totalAllocated: data.totalAllocated.present
          ? data.totalAllocated.value
          : this.totalAllocated,
      envelopes: data.envelopes.present ? data.envelopes.value : this.envelopes,
      period: data.period.present ? data.period.value : this.period,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      status: data.status.present ? data.status.value : this.status,
      creationDate: data.creationDate.present
          ? data.creationDate.value
          : this.creationDate,
      updateDate:
          data.updateDate.present ? data.updateDate.value : this.updateDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ZeroBasedBudget(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('totalIncome: $totalIncome, ')
          ..write('totalAllocated: $totalAllocated, ')
          ..write('envelopes: $envelopes, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('creationDate: $creationDate, ')
          ..write('updateDate: $updateDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      description,
      totalIncome,
      totalAllocated,
      envelopes,
      period,
      startDate,
      endDate,
      status,
      creationDate,
      updateDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ZeroBasedBudget &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.totalIncome == this.totalIncome &&
          other.totalAllocated == this.totalAllocated &&
          other.envelopes == this.envelopes &&
          other.period == this.period &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.status == this.status &&
          other.creationDate == this.creationDate &&
          other.updateDate == this.updateDate);
}

class ZeroBasedBudgetsCompanion extends UpdateCompanion<ZeroBasedBudget> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<double> totalIncome;
  final Value<double> totalAllocated;
  final Value<String> envelopes;
  final Value<String> period;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<String> status;
  final Value<DateTime> creationDate;
  final Value<DateTime> updateDate;
  final Value<int> rowid;
  const ZeroBasedBudgetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.totalIncome = const Value.absent(),
    this.totalAllocated = const Value.absent(),
    this.envelopes = const Value.absent(),
    this.period = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.status = const Value.absent(),
    this.creationDate = const Value.absent(),
    this.updateDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ZeroBasedBudgetsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required double totalIncome,
    this.totalAllocated = const Value.absent(),
    required String envelopes,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
    required String status,
    required DateTime creationDate,
    required DateTime updateDate,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        totalIncome = Value(totalIncome),
        envelopes = Value(envelopes),
        period = Value(period),
        startDate = Value(startDate),
        endDate = Value(endDate),
        status = Value(status),
        creationDate = Value(creationDate),
        updateDate = Value(updateDate);
  static Insertable<ZeroBasedBudget> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<double>? totalIncome,
    Expression<double>? totalAllocated,
    Expression<String>? envelopes,
    Expression<String>? period,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? status,
    Expression<DateTime>? creationDate,
    Expression<DateTime>? updateDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (totalIncome != null) 'total_income': totalIncome,
      if (totalAllocated != null) 'total_allocated': totalAllocated,
      if (envelopes != null) 'envelopes': envelopes,
      if (period != null) 'period': period,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (status != null) 'status': status,
      if (creationDate != null) 'creation_date': creationDate,
      if (updateDate != null) 'update_date': updateDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ZeroBasedBudgetsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<double>? totalIncome,
      Value<double>? totalAllocated,
      Value<String>? envelopes,
      Value<String>? period,
      Value<DateTime>? startDate,
      Value<DateTime>? endDate,
      Value<String>? status,
      Value<DateTime>? creationDate,
      Value<DateTime>? updateDate,
      Value<int>? rowid}) {
    return ZeroBasedBudgetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      totalIncome: totalIncome ?? this.totalIncome,
      totalAllocated: totalAllocated ?? this.totalAllocated,
      envelopes: envelopes ?? this.envelopes,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      creationDate: creationDate ?? this.creationDate,
      updateDate: updateDate ?? this.updateDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (totalIncome.present) {
      map['total_income'] = Variable<double>(totalIncome.value);
    }
    if (totalAllocated.present) {
      map['total_allocated'] = Variable<double>(totalAllocated.value);
    }
    if (envelopes.present) {
      map['envelopes'] = Variable<String>(envelopes.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (creationDate.present) {
      map['creation_date'] = Variable<DateTime>(creationDate.value);
    }
    if (updateDate.present) {
      map['update_date'] = Variable<DateTime>(updateDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ZeroBasedBudgetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('totalIncome: $totalIncome, ')
          ..write('totalAllocated: $totalAllocated, ')
          ..write('envelopes: $envelopes, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('creationDate: $creationDate, ')
          ..write('updateDate: $updateDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalaryIncomesTable extends SalaryIncomes
    with TableInfo<$SalaryIncomesTable, SalaryIncome> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalaryIncomesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _basicSalaryMeta =
      const VerificationMeta('basicSalary');
  @override
  late final GeneratedColumn<double> basicSalary = GeneratedColumn<double>(
      'basic_salary', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _salaryHistoryMeta =
      const VerificationMeta('salaryHistory');
  @override
  late final GeneratedColumn<String> salaryHistory = GeneratedColumn<String>(
      'salary_history', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _housingAllowanceMeta =
      const VerificationMeta('housingAllowance');
  @override
  late final GeneratedColumn<double> housingAllowance = GeneratedColumn<double>(
      'housing_allowance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _mealAllowanceMeta =
      const VerificationMeta('mealAllowance');
  @override
  late final GeneratedColumn<double> mealAllowance = GeneratedColumn<double>(
      'meal_allowance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _transportationAllowanceMeta =
      const VerificationMeta('transportationAllowance');
  @override
  late final GeneratedColumn<double> transportationAllowance =
      GeneratedColumn<double>('transportation_allowance', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _otherAllowanceMeta =
      const VerificationMeta('otherAllowance');
  @override
  late final GeneratedColumn<double> otherAllowance = GeneratedColumn<double>(
      'other_allowance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _monthlyAllowancesMeta =
      const VerificationMeta('monthlyAllowances');
  @override
  late final GeneratedColumn<String> monthlyAllowances =
      GeneratedColumn<String>('monthly_allowances', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bonusesMeta =
      const VerificationMeta('bonuses');
  @override
  late final GeneratedColumn<String> bonuses = GeneratedColumn<String>(
      'bonuses', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _personalIncomeTaxMeta =
      const VerificationMeta('personalIncomeTax');
  @override
  late final GeneratedColumn<double> personalIncomeTax =
      GeneratedColumn<double>('personal_income_tax', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _socialInsuranceMeta =
      const VerificationMeta('socialInsurance');
  @override
  late final GeneratedColumn<double> socialInsurance = GeneratedColumn<double>(
      'social_insurance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _housingFundMeta =
      const VerificationMeta('housingFund');
  @override
  late final GeneratedColumn<double> housingFund = GeneratedColumn<double>(
      'housing_fund', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _otherDeductionsMeta =
      const VerificationMeta('otherDeductions');
  @override
  late final GeneratedColumn<double> otherDeductions = GeneratedColumn<double>(
      'other_deductions', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _specialDeductionMonthlyMeta =
      const VerificationMeta('specialDeductionMonthly');
  @override
  late final GeneratedColumn<double> specialDeductionMonthly =
      GeneratedColumn<double>('special_deduction_monthly', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _otherTaxDeductionsMeta =
      const VerificationMeta('otherTaxDeductions');
  @override
  late final GeneratedColumn<double> otherTaxDeductions =
      GeneratedColumn<double>('other_tax_deductions', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _salaryDayMeta =
      const VerificationMeta('salaryDay');
  @override
  late final GeneratedColumn<int> salaryDay = GeneratedColumn<int>(
      'salary_day', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
      'period', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastSalaryDateMeta =
      const VerificationMeta('lastSalaryDate');
  @override
  late final GeneratedColumn<DateTime> lastSalaryDate =
      GeneratedColumn<DateTime>('last_salary_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nextSalaryDateMeta =
      const VerificationMeta('nextSalaryDate');
  @override
  late final GeneratedColumn<DateTime> nextSalaryDate =
      GeneratedColumn<DateTime>('next_salary_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _incomeTypeMeta =
      const VerificationMeta('incomeType');
  @override
  late final GeneratedColumn<String> incomeType = GeneratedColumn<String>(
      'income_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _creationDateMeta =
      const VerificationMeta('creationDate');
  @override
  late final GeneratedColumn<DateTime> creationDate = GeneratedColumn<DateTime>(
      'creation_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updateDateMeta =
      const VerificationMeta('updateDate');
  @override
  late final GeneratedColumn<DateTime> updateDate = GeneratedColumn<DateTime>(
      'update_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        basicSalary,
        salaryHistory,
        housingAllowance,
        mealAllowance,
        transportationAllowance,
        otherAllowance,
        monthlyAllowances,
        bonuses,
        personalIncomeTax,
        socialInsurance,
        housingFund,
        otherDeductions,
        specialDeductionMonthly,
        otherTaxDeductions,
        salaryDay,
        period,
        lastSalaryDate,
        nextSalaryDate,
        incomeType,
        creationDate,
        updateDate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'salary_incomes';
  @override
  VerificationContext validateIntegrity(Insertable<SalaryIncome> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('basic_salary')) {
      context.handle(
          _basicSalaryMeta,
          basicSalary.isAcceptableOrUnknown(
              data['basic_salary']!, _basicSalaryMeta));
    } else if (isInserting) {
      context.missing(_basicSalaryMeta);
    }
    if (data.containsKey('salary_history')) {
      context.handle(
          _salaryHistoryMeta,
          salaryHistory.isAcceptableOrUnknown(
              data['salary_history']!, _salaryHistoryMeta));
    }
    if (data.containsKey('housing_allowance')) {
      context.handle(
          _housingAllowanceMeta,
          housingAllowance.isAcceptableOrUnknown(
              data['housing_allowance']!, _housingAllowanceMeta));
    }
    if (data.containsKey('meal_allowance')) {
      context.handle(
          _mealAllowanceMeta,
          mealAllowance.isAcceptableOrUnknown(
              data['meal_allowance']!, _mealAllowanceMeta));
    }
    if (data.containsKey('transportation_allowance')) {
      context.handle(
          _transportationAllowanceMeta,
          transportationAllowance.isAcceptableOrUnknown(
              data['transportation_allowance']!, _transportationAllowanceMeta));
    }
    if (data.containsKey('other_allowance')) {
      context.handle(
          _otherAllowanceMeta,
          otherAllowance.isAcceptableOrUnknown(
              data['other_allowance']!, _otherAllowanceMeta));
    }
    if (data.containsKey('monthly_allowances')) {
      context.handle(
          _monthlyAllowancesMeta,
          monthlyAllowances.isAcceptableOrUnknown(
              data['monthly_allowances']!, _monthlyAllowancesMeta));
    }
    if (data.containsKey('bonuses')) {
      context.handle(_bonusesMeta,
          bonuses.isAcceptableOrUnknown(data['bonuses']!, _bonusesMeta));
    } else if (isInserting) {
      context.missing(_bonusesMeta);
    }
    if (data.containsKey('personal_income_tax')) {
      context.handle(
          _personalIncomeTaxMeta,
          personalIncomeTax.isAcceptableOrUnknown(
              data['personal_income_tax']!, _personalIncomeTaxMeta));
    }
    if (data.containsKey('social_insurance')) {
      context.handle(
          _socialInsuranceMeta,
          socialInsurance.isAcceptableOrUnknown(
              data['social_insurance']!, _socialInsuranceMeta));
    }
    if (data.containsKey('housing_fund')) {
      context.handle(
          _housingFundMeta,
          housingFund.isAcceptableOrUnknown(
              data['housing_fund']!, _housingFundMeta));
    }
    if (data.containsKey('other_deductions')) {
      context.handle(
          _otherDeductionsMeta,
          otherDeductions.isAcceptableOrUnknown(
              data['other_deductions']!, _otherDeductionsMeta));
    }
    if (data.containsKey('special_deduction_monthly')) {
      context.handle(
          _specialDeductionMonthlyMeta,
          specialDeductionMonthly.isAcceptableOrUnknown(
              data['special_deduction_monthly']!,
              _specialDeductionMonthlyMeta));
    }
    if (data.containsKey('other_tax_deductions')) {
      context.handle(
          _otherTaxDeductionsMeta,
          otherTaxDeductions.isAcceptableOrUnknown(
              data['other_tax_deductions']!, _otherTaxDeductionsMeta));
    }
    if (data.containsKey('salary_day')) {
      context.handle(_salaryDayMeta,
          salaryDay.isAcceptableOrUnknown(data['salary_day']!, _salaryDayMeta));
    } else if (isInserting) {
      context.missing(_salaryDayMeta);
    }
    if (data.containsKey('period')) {
      context.handle(_periodMeta,
          period.isAcceptableOrUnknown(data['period']!, _periodMeta));
    } else if (isInserting) {
      context.missing(_periodMeta);
    }
    if (data.containsKey('last_salary_date')) {
      context.handle(
          _lastSalaryDateMeta,
          lastSalaryDate.isAcceptableOrUnknown(
              data['last_salary_date']!, _lastSalaryDateMeta));
    }
    if (data.containsKey('next_salary_date')) {
      context.handle(
          _nextSalaryDateMeta,
          nextSalaryDate.isAcceptableOrUnknown(
              data['next_salary_date']!, _nextSalaryDateMeta));
    }
    if (data.containsKey('income_type')) {
      context.handle(
          _incomeTypeMeta,
          incomeType.isAcceptableOrUnknown(
              data['income_type']!, _incomeTypeMeta));
    } else if (isInserting) {
      context.missing(_incomeTypeMeta);
    }
    if (data.containsKey('creation_date')) {
      context.handle(
          _creationDateMeta,
          creationDate.isAcceptableOrUnknown(
              data['creation_date']!, _creationDateMeta));
    } else if (isInserting) {
      context.missing(_creationDateMeta);
    }
    if (data.containsKey('update_date')) {
      context.handle(
          _updateDateMeta,
          updateDate.isAcceptableOrUnknown(
              data['update_date']!, _updateDateMeta));
    } else if (isInserting) {
      context.missing(_updateDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SalaryIncome map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SalaryIncome(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      basicSalary: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}basic_salary'])!,
      salaryHistory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}salary_history']),
      housingAllowance: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}housing_allowance'])!,
      mealAllowance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}meal_allowance'])!,
      transportationAllowance: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}transportation_allowance'])!,
      otherAllowance: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}other_allowance'])!,
      monthlyAllowances: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}monthly_allowances']),
      bonuses: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bonuses'])!,
      personalIncomeTax: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}personal_income_tax'])!,
      socialInsurance: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}social_insurance'])!,
      housingFund: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}housing_fund'])!,
      otherDeductions: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}other_deductions'])!,
      specialDeductionMonthly: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}special_deduction_monthly'])!,
      otherTaxDeductions: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}other_tax_deductions'])!,
      salaryDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}salary_day'])!,
      period: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}period'])!,
      lastSalaryDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_salary_date']),
      nextSalaryDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_salary_date']),
      incomeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}income_type'])!,
      creationDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}creation_date'])!,
      updateDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}update_date'])!,
    );
  }

  @override
  $SalaryIncomesTable createAlias(String alias) {
    return $SalaryIncomesTable(attachedDatabase, alias);
  }
}

class SalaryIncome extends DataClass implements Insertable<SalaryIncome> {
  final String id;
  final String name;
  final String? description;
  final double basicSalary;
  final String? salaryHistory;
  final double housingAllowance;
  final double mealAllowance;
  final double transportationAllowance;
  final double otherAllowance;
  final String? monthlyAllowances;
  final String bonuses;
  final double personalIncomeTax;
  final double socialInsurance;
  final double housingFund;
  final double otherDeductions;
  final double specialDeductionMonthly;
  final double otherTaxDeductions;
  final int salaryDay;
  final String period;
  final DateTime? lastSalaryDate;
  final DateTime? nextSalaryDate;
  final String incomeType;
  final DateTime creationDate;
  final DateTime updateDate;
  const SalaryIncome(
      {required this.id,
      required this.name,
      this.description,
      required this.basicSalary,
      this.salaryHistory,
      required this.housingAllowance,
      required this.mealAllowance,
      required this.transportationAllowance,
      required this.otherAllowance,
      this.monthlyAllowances,
      required this.bonuses,
      required this.personalIncomeTax,
      required this.socialInsurance,
      required this.housingFund,
      required this.otherDeductions,
      required this.specialDeductionMonthly,
      required this.otherTaxDeductions,
      required this.salaryDay,
      required this.period,
      this.lastSalaryDate,
      this.nextSalaryDate,
      required this.incomeType,
      required this.creationDate,
      required this.updateDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['basic_salary'] = Variable<double>(basicSalary);
    if (!nullToAbsent || salaryHistory != null) {
      map['salary_history'] = Variable<String>(salaryHistory);
    }
    map['housing_allowance'] = Variable<double>(housingAllowance);
    map['meal_allowance'] = Variable<double>(mealAllowance);
    map['transportation_allowance'] = Variable<double>(transportationAllowance);
    map['other_allowance'] = Variable<double>(otherAllowance);
    if (!nullToAbsent || monthlyAllowances != null) {
      map['monthly_allowances'] = Variable<String>(monthlyAllowances);
    }
    map['bonuses'] = Variable<String>(bonuses);
    map['personal_income_tax'] = Variable<double>(personalIncomeTax);
    map['social_insurance'] = Variable<double>(socialInsurance);
    map['housing_fund'] = Variable<double>(housingFund);
    map['other_deductions'] = Variable<double>(otherDeductions);
    map['special_deduction_monthly'] =
        Variable<double>(specialDeductionMonthly);
    map['other_tax_deductions'] = Variable<double>(otherTaxDeductions);
    map['salary_day'] = Variable<int>(salaryDay);
    map['period'] = Variable<String>(period);
    if (!nullToAbsent || lastSalaryDate != null) {
      map['last_salary_date'] = Variable<DateTime>(lastSalaryDate);
    }
    if (!nullToAbsent || nextSalaryDate != null) {
      map['next_salary_date'] = Variable<DateTime>(nextSalaryDate);
    }
    map['income_type'] = Variable<String>(incomeType);
    map['creation_date'] = Variable<DateTime>(creationDate);
    map['update_date'] = Variable<DateTime>(updateDate);
    return map;
  }

  SalaryIncomesCompanion toCompanion(bool nullToAbsent) {
    return SalaryIncomesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      basicSalary: Value(basicSalary),
      salaryHistory: salaryHistory == null && nullToAbsent
          ? const Value.absent()
          : Value(salaryHistory),
      housingAllowance: Value(housingAllowance),
      mealAllowance: Value(mealAllowance),
      transportationAllowance: Value(transportationAllowance),
      otherAllowance: Value(otherAllowance),
      monthlyAllowances: monthlyAllowances == null && nullToAbsent
          ? const Value.absent()
          : Value(monthlyAllowances),
      bonuses: Value(bonuses),
      personalIncomeTax: Value(personalIncomeTax),
      socialInsurance: Value(socialInsurance),
      housingFund: Value(housingFund),
      otherDeductions: Value(otherDeductions),
      specialDeductionMonthly: Value(specialDeductionMonthly),
      otherTaxDeductions: Value(otherTaxDeductions),
      salaryDay: Value(salaryDay),
      period: Value(period),
      lastSalaryDate: lastSalaryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSalaryDate),
      nextSalaryDate: nextSalaryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(nextSalaryDate),
      incomeType: Value(incomeType),
      creationDate: Value(creationDate),
      updateDate: Value(updateDate),
    );
  }

  factory SalaryIncome.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SalaryIncome(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      basicSalary: serializer.fromJson<double>(json['basicSalary']),
      salaryHistory: serializer.fromJson<String?>(json['salaryHistory']),
      housingAllowance: serializer.fromJson<double>(json['housingAllowance']),
      mealAllowance: serializer.fromJson<double>(json['mealAllowance']),
      transportationAllowance:
          serializer.fromJson<double>(json['transportationAllowance']),
      otherAllowance: serializer.fromJson<double>(json['otherAllowance']),
      monthlyAllowances:
          serializer.fromJson<String?>(json['monthlyAllowances']),
      bonuses: serializer.fromJson<String>(json['bonuses']),
      personalIncomeTax: serializer.fromJson<double>(json['personalIncomeTax']),
      socialInsurance: serializer.fromJson<double>(json['socialInsurance']),
      housingFund: serializer.fromJson<double>(json['housingFund']),
      otherDeductions: serializer.fromJson<double>(json['otherDeductions']),
      specialDeductionMonthly:
          serializer.fromJson<double>(json['specialDeductionMonthly']),
      otherTaxDeductions:
          serializer.fromJson<double>(json['otherTaxDeductions']),
      salaryDay: serializer.fromJson<int>(json['salaryDay']),
      period: serializer.fromJson<String>(json['period']),
      lastSalaryDate: serializer.fromJson<DateTime?>(json['lastSalaryDate']),
      nextSalaryDate: serializer.fromJson<DateTime?>(json['nextSalaryDate']),
      incomeType: serializer.fromJson<String>(json['incomeType']),
      creationDate: serializer.fromJson<DateTime>(json['creationDate']),
      updateDate: serializer.fromJson<DateTime>(json['updateDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'basicSalary': serializer.toJson<double>(basicSalary),
      'salaryHistory': serializer.toJson<String?>(salaryHistory),
      'housingAllowance': serializer.toJson<double>(housingAllowance),
      'mealAllowance': serializer.toJson<double>(mealAllowance),
      'transportationAllowance':
          serializer.toJson<double>(transportationAllowance),
      'otherAllowance': serializer.toJson<double>(otherAllowance),
      'monthlyAllowances': serializer.toJson<String?>(monthlyAllowances),
      'bonuses': serializer.toJson<String>(bonuses),
      'personalIncomeTax': serializer.toJson<double>(personalIncomeTax),
      'socialInsurance': serializer.toJson<double>(socialInsurance),
      'housingFund': serializer.toJson<double>(housingFund),
      'otherDeductions': serializer.toJson<double>(otherDeductions),
      'specialDeductionMonthly':
          serializer.toJson<double>(specialDeductionMonthly),
      'otherTaxDeductions': serializer.toJson<double>(otherTaxDeductions),
      'salaryDay': serializer.toJson<int>(salaryDay),
      'period': serializer.toJson<String>(period),
      'lastSalaryDate': serializer.toJson<DateTime?>(lastSalaryDate),
      'nextSalaryDate': serializer.toJson<DateTime?>(nextSalaryDate),
      'incomeType': serializer.toJson<String>(incomeType),
      'creationDate': serializer.toJson<DateTime>(creationDate),
      'updateDate': serializer.toJson<DateTime>(updateDate),
    };
  }

  SalaryIncome copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          double? basicSalary,
          Value<String?> salaryHistory = const Value.absent(),
          double? housingAllowance,
          double? mealAllowance,
          double? transportationAllowance,
          double? otherAllowance,
          Value<String?> monthlyAllowances = const Value.absent(),
          String? bonuses,
          double? personalIncomeTax,
          double? socialInsurance,
          double? housingFund,
          double? otherDeductions,
          double? specialDeductionMonthly,
          double? otherTaxDeductions,
          int? salaryDay,
          String? period,
          Value<DateTime?> lastSalaryDate = const Value.absent(),
          Value<DateTime?> nextSalaryDate = const Value.absent(),
          String? incomeType,
          DateTime? creationDate,
          DateTime? updateDate}) =>
      SalaryIncome(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        basicSalary: basicSalary ?? this.basicSalary,
        salaryHistory:
            salaryHistory.present ? salaryHistory.value : this.salaryHistory,
        housingAllowance: housingAllowance ?? this.housingAllowance,
        mealAllowance: mealAllowance ?? this.mealAllowance,
        transportationAllowance:
            transportationAllowance ?? this.transportationAllowance,
        otherAllowance: otherAllowance ?? this.otherAllowance,
        monthlyAllowances: monthlyAllowances.present
            ? monthlyAllowances.value
            : this.monthlyAllowances,
        bonuses: bonuses ?? this.bonuses,
        personalIncomeTax: personalIncomeTax ?? this.personalIncomeTax,
        socialInsurance: socialInsurance ?? this.socialInsurance,
        housingFund: housingFund ?? this.housingFund,
        otherDeductions: otherDeductions ?? this.otherDeductions,
        specialDeductionMonthly:
            specialDeductionMonthly ?? this.specialDeductionMonthly,
        otherTaxDeductions: otherTaxDeductions ?? this.otherTaxDeductions,
        salaryDay: salaryDay ?? this.salaryDay,
        period: period ?? this.period,
        lastSalaryDate:
            lastSalaryDate.present ? lastSalaryDate.value : this.lastSalaryDate,
        nextSalaryDate:
            nextSalaryDate.present ? nextSalaryDate.value : this.nextSalaryDate,
        incomeType: incomeType ?? this.incomeType,
        creationDate: creationDate ?? this.creationDate,
        updateDate: updateDate ?? this.updateDate,
      );
  SalaryIncome copyWithCompanion(SalaryIncomesCompanion data) {
    return SalaryIncome(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      basicSalary:
          data.basicSalary.present ? data.basicSalary.value : this.basicSalary,
      salaryHistory: data.salaryHistory.present
          ? data.salaryHistory.value
          : this.salaryHistory,
      housingAllowance: data.housingAllowance.present
          ? data.housingAllowance.value
          : this.housingAllowance,
      mealAllowance: data.mealAllowance.present
          ? data.mealAllowance.value
          : this.mealAllowance,
      transportationAllowance: data.transportationAllowance.present
          ? data.transportationAllowance.value
          : this.transportationAllowance,
      otherAllowance: data.otherAllowance.present
          ? data.otherAllowance.value
          : this.otherAllowance,
      monthlyAllowances: data.monthlyAllowances.present
          ? data.monthlyAllowances.value
          : this.monthlyAllowances,
      bonuses: data.bonuses.present ? data.bonuses.value : this.bonuses,
      personalIncomeTax: data.personalIncomeTax.present
          ? data.personalIncomeTax.value
          : this.personalIncomeTax,
      socialInsurance: data.socialInsurance.present
          ? data.socialInsurance.value
          : this.socialInsurance,
      housingFund:
          data.housingFund.present ? data.housingFund.value : this.housingFund,
      otherDeductions: data.otherDeductions.present
          ? data.otherDeductions.value
          : this.otherDeductions,
      specialDeductionMonthly: data.specialDeductionMonthly.present
          ? data.specialDeductionMonthly.value
          : this.specialDeductionMonthly,
      otherTaxDeductions: data.otherTaxDeductions.present
          ? data.otherTaxDeductions.value
          : this.otherTaxDeductions,
      salaryDay: data.salaryDay.present ? data.salaryDay.value : this.salaryDay,
      period: data.period.present ? data.period.value : this.period,
      lastSalaryDate: data.lastSalaryDate.present
          ? data.lastSalaryDate.value
          : this.lastSalaryDate,
      nextSalaryDate: data.nextSalaryDate.present
          ? data.nextSalaryDate.value
          : this.nextSalaryDate,
      incomeType:
          data.incomeType.present ? data.incomeType.value : this.incomeType,
      creationDate: data.creationDate.present
          ? data.creationDate.value
          : this.creationDate,
      updateDate:
          data.updateDate.present ? data.updateDate.value : this.updateDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SalaryIncome(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('basicSalary: $basicSalary, ')
          ..write('salaryHistory: $salaryHistory, ')
          ..write('housingAllowance: $housingAllowance, ')
          ..write('mealAllowance: $mealAllowance, ')
          ..write('transportationAllowance: $transportationAllowance, ')
          ..write('otherAllowance: $otherAllowance, ')
          ..write('monthlyAllowances: $monthlyAllowances, ')
          ..write('bonuses: $bonuses, ')
          ..write('personalIncomeTax: $personalIncomeTax, ')
          ..write('socialInsurance: $socialInsurance, ')
          ..write('housingFund: $housingFund, ')
          ..write('otherDeductions: $otherDeductions, ')
          ..write('specialDeductionMonthly: $specialDeductionMonthly, ')
          ..write('otherTaxDeductions: $otherTaxDeductions, ')
          ..write('salaryDay: $salaryDay, ')
          ..write('period: $period, ')
          ..write('lastSalaryDate: $lastSalaryDate, ')
          ..write('nextSalaryDate: $nextSalaryDate, ')
          ..write('incomeType: $incomeType, ')
          ..write('creationDate: $creationDate, ')
          ..write('updateDate: $updateDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        description,
        basicSalary,
        salaryHistory,
        housingAllowance,
        mealAllowance,
        transportationAllowance,
        otherAllowance,
        monthlyAllowances,
        bonuses,
        personalIncomeTax,
        socialInsurance,
        housingFund,
        otherDeductions,
        specialDeductionMonthly,
        otherTaxDeductions,
        salaryDay,
        period,
        lastSalaryDate,
        nextSalaryDate,
        incomeType,
        creationDate,
        updateDate
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SalaryIncome &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.basicSalary == this.basicSalary &&
          other.salaryHistory == this.salaryHistory &&
          other.housingAllowance == this.housingAllowance &&
          other.mealAllowance == this.mealAllowance &&
          other.transportationAllowance == this.transportationAllowance &&
          other.otherAllowance == this.otherAllowance &&
          other.monthlyAllowances == this.monthlyAllowances &&
          other.bonuses == this.bonuses &&
          other.personalIncomeTax == this.personalIncomeTax &&
          other.socialInsurance == this.socialInsurance &&
          other.housingFund == this.housingFund &&
          other.otherDeductions == this.otherDeductions &&
          other.specialDeductionMonthly == this.specialDeductionMonthly &&
          other.otherTaxDeductions == this.otherTaxDeductions &&
          other.salaryDay == this.salaryDay &&
          other.period == this.period &&
          other.lastSalaryDate == this.lastSalaryDate &&
          other.nextSalaryDate == this.nextSalaryDate &&
          other.incomeType == this.incomeType &&
          other.creationDate == this.creationDate &&
          other.updateDate == this.updateDate);
}

class SalaryIncomesCompanion extends UpdateCompanion<SalaryIncome> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<double> basicSalary;
  final Value<String?> salaryHistory;
  final Value<double> housingAllowance;
  final Value<double> mealAllowance;
  final Value<double> transportationAllowance;
  final Value<double> otherAllowance;
  final Value<String?> monthlyAllowances;
  final Value<String> bonuses;
  final Value<double> personalIncomeTax;
  final Value<double> socialInsurance;
  final Value<double> housingFund;
  final Value<double> otherDeductions;
  final Value<double> specialDeductionMonthly;
  final Value<double> otherTaxDeductions;
  final Value<int> salaryDay;
  final Value<String> period;
  final Value<DateTime?> lastSalaryDate;
  final Value<DateTime?> nextSalaryDate;
  final Value<String> incomeType;
  final Value<DateTime> creationDate;
  final Value<DateTime> updateDate;
  final Value<int> rowid;
  const SalaryIncomesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.basicSalary = const Value.absent(),
    this.salaryHistory = const Value.absent(),
    this.housingAllowance = const Value.absent(),
    this.mealAllowance = const Value.absent(),
    this.transportationAllowance = const Value.absent(),
    this.otherAllowance = const Value.absent(),
    this.monthlyAllowances = const Value.absent(),
    this.bonuses = const Value.absent(),
    this.personalIncomeTax = const Value.absent(),
    this.socialInsurance = const Value.absent(),
    this.housingFund = const Value.absent(),
    this.otherDeductions = const Value.absent(),
    this.specialDeductionMonthly = const Value.absent(),
    this.otherTaxDeductions = const Value.absent(),
    this.salaryDay = const Value.absent(),
    this.period = const Value.absent(),
    this.lastSalaryDate = const Value.absent(),
    this.nextSalaryDate = const Value.absent(),
    this.incomeType = const Value.absent(),
    this.creationDate = const Value.absent(),
    this.updateDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalaryIncomesCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required double basicSalary,
    this.salaryHistory = const Value.absent(),
    this.housingAllowance = const Value.absent(),
    this.mealAllowance = const Value.absent(),
    this.transportationAllowance = const Value.absent(),
    this.otherAllowance = const Value.absent(),
    this.monthlyAllowances = const Value.absent(),
    required String bonuses,
    this.personalIncomeTax = const Value.absent(),
    this.socialInsurance = const Value.absent(),
    this.housingFund = const Value.absent(),
    this.otherDeductions = const Value.absent(),
    this.specialDeductionMonthly = const Value.absent(),
    this.otherTaxDeductions = const Value.absent(),
    required int salaryDay,
    required String period,
    this.lastSalaryDate = const Value.absent(),
    this.nextSalaryDate = const Value.absent(),
    required String incomeType,
    required DateTime creationDate,
    required DateTime updateDate,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        basicSalary = Value(basicSalary),
        bonuses = Value(bonuses),
        salaryDay = Value(salaryDay),
        period = Value(period),
        incomeType = Value(incomeType),
        creationDate = Value(creationDate),
        updateDate = Value(updateDate);
  static Insertable<SalaryIncome> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<double>? basicSalary,
    Expression<String>? salaryHistory,
    Expression<double>? housingAllowance,
    Expression<double>? mealAllowance,
    Expression<double>? transportationAllowance,
    Expression<double>? otherAllowance,
    Expression<String>? monthlyAllowances,
    Expression<String>? bonuses,
    Expression<double>? personalIncomeTax,
    Expression<double>? socialInsurance,
    Expression<double>? housingFund,
    Expression<double>? otherDeductions,
    Expression<double>? specialDeductionMonthly,
    Expression<double>? otherTaxDeductions,
    Expression<int>? salaryDay,
    Expression<String>? period,
    Expression<DateTime>? lastSalaryDate,
    Expression<DateTime>? nextSalaryDate,
    Expression<String>? incomeType,
    Expression<DateTime>? creationDate,
    Expression<DateTime>? updateDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (basicSalary != null) 'basic_salary': basicSalary,
      if (salaryHistory != null) 'salary_history': salaryHistory,
      if (housingAllowance != null) 'housing_allowance': housingAllowance,
      if (mealAllowance != null) 'meal_allowance': mealAllowance,
      if (transportationAllowance != null)
        'transportation_allowance': transportationAllowance,
      if (otherAllowance != null) 'other_allowance': otherAllowance,
      if (monthlyAllowances != null) 'monthly_allowances': monthlyAllowances,
      if (bonuses != null) 'bonuses': bonuses,
      if (personalIncomeTax != null) 'personal_income_tax': personalIncomeTax,
      if (socialInsurance != null) 'social_insurance': socialInsurance,
      if (housingFund != null) 'housing_fund': housingFund,
      if (otherDeductions != null) 'other_deductions': otherDeductions,
      if (specialDeductionMonthly != null)
        'special_deduction_monthly': specialDeductionMonthly,
      if (otherTaxDeductions != null)
        'other_tax_deductions': otherTaxDeductions,
      if (salaryDay != null) 'salary_day': salaryDay,
      if (period != null) 'period': period,
      if (lastSalaryDate != null) 'last_salary_date': lastSalaryDate,
      if (nextSalaryDate != null) 'next_salary_date': nextSalaryDate,
      if (incomeType != null) 'income_type': incomeType,
      if (creationDate != null) 'creation_date': creationDate,
      if (updateDate != null) 'update_date': updateDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalaryIncomesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<double>? basicSalary,
      Value<String?>? salaryHistory,
      Value<double>? housingAllowance,
      Value<double>? mealAllowance,
      Value<double>? transportationAllowance,
      Value<double>? otherAllowance,
      Value<String?>? monthlyAllowances,
      Value<String>? bonuses,
      Value<double>? personalIncomeTax,
      Value<double>? socialInsurance,
      Value<double>? housingFund,
      Value<double>? otherDeductions,
      Value<double>? specialDeductionMonthly,
      Value<double>? otherTaxDeductions,
      Value<int>? salaryDay,
      Value<String>? period,
      Value<DateTime?>? lastSalaryDate,
      Value<DateTime?>? nextSalaryDate,
      Value<String>? incomeType,
      Value<DateTime>? creationDate,
      Value<DateTime>? updateDate,
      Value<int>? rowid}) {
    return SalaryIncomesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      basicSalary: basicSalary ?? this.basicSalary,
      salaryHistory: salaryHistory ?? this.salaryHistory,
      housingAllowance: housingAllowance ?? this.housingAllowance,
      mealAllowance: mealAllowance ?? this.mealAllowance,
      transportationAllowance:
          transportationAllowance ?? this.transportationAllowance,
      otherAllowance: otherAllowance ?? this.otherAllowance,
      monthlyAllowances: monthlyAllowances ?? this.monthlyAllowances,
      bonuses: bonuses ?? this.bonuses,
      personalIncomeTax: personalIncomeTax ?? this.personalIncomeTax,
      socialInsurance: socialInsurance ?? this.socialInsurance,
      housingFund: housingFund ?? this.housingFund,
      otherDeductions: otherDeductions ?? this.otherDeductions,
      specialDeductionMonthly:
          specialDeductionMonthly ?? this.specialDeductionMonthly,
      otherTaxDeductions: otherTaxDeductions ?? this.otherTaxDeductions,
      salaryDay: salaryDay ?? this.salaryDay,
      period: period ?? this.period,
      lastSalaryDate: lastSalaryDate ?? this.lastSalaryDate,
      nextSalaryDate: nextSalaryDate ?? this.nextSalaryDate,
      incomeType: incomeType ?? this.incomeType,
      creationDate: creationDate ?? this.creationDate,
      updateDate: updateDate ?? this.updateDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (basicSalary.present) {
      map['basic_salary'] = Variable<double>(basicSalary.value);
    }
    if (salaryHistory.present) {
      map['salary_history'] = Variable<String>(salaryHistory.value);
    }
    if (housingAllowance.present) {
      map['housing_allowance'] = Variable<double>(housingAllowance.value);
    }
    if (mealAllowance.present) {
      map['meal_allowance'] = Variable<double>(mealAllowance.value);
    }
    if (transportationAllowance.present) {
      map['transportation_allowance'] =
          Variable<double>(transportationAllowance.value);
    }
    if (otherAllowance.present) {
      map['other_allowance'] = Variable<double>(otherAllowance.value);
    }
    if (monthlyAllowances.present) {
      map['monthly_allowances'] = Variable<String>(monthlyAllowances.value);
    }
    if (bonuses.present) {
      map['bonuses'] = Variable<String>(bonuses.value);
    }
    if (personalIncomeTax.present) {
      map['personal_income_tax'] = Variable<double>(personalIncomeTax.value);
    }
    if (socialInsurance.present) {
      map['social_insurance'] = Variable<double>(socialInsurance.value);
    }
    if (housingFund.present) {
      map['housing_fund'] = Variable<double>(housingFund.value);
    }
    if (otherDeductions.present) {
      map['other_deductions'] = Variable<double>(otherDeductions.value);
    }
    if (specialDeductionMonthly.present) {
      map['special_deduction_monthly'] =
          Variable<double>(specialDeductionMonthly.value);
    }
    if (otherTaxDeductions.present) {
      map['other_tax_deductions'] = Variable<double>(otherTaxDeductions.value);
    }
    if (salaryDay.present) {
      map['salary_day'] = Variable<int>(salaryDay.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (lastSalaryDate.present) {
      map['last_salary_date'] = Variable<DateTime>(lastSalaryDate.value);
    }
    if (nextSalaryDate.present) {
      map['next_salary_date'] = Variable<DateTime>(nextSalaryDate.value);
    }
    if (incomeType.present) {
      map['income_type'] = Variable<String>(incomeType.value);
    }
    if (creationDate.present) {
      map['creation_date'] = Variable<DateTime>(creationDate.value);
    }
    if (updateDate.present) {
      map['update_date'] = Variable<DateTime>(updateDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalaryIncomesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('basicSalary: $basicSalary, ')
          ..write('salaryHistory: $salaryHistory, ')
          ..write('housingAllowance: $housingAllowance, ')
          ..write('mealAllowance: $mealAllowance, ')
          ..write('transportationAllowance: $transportationAllowance, ')
          ..write('otherAllowance: $otherAllowance, ')
          ..write('monthlyAllowances: $monthlyAllowances, ')
          ..write('bonuses: $bonuses, ')
          ..write('personalIncomeTax: $personalIncomeTax, ')
          ..write('socialInsurance: $socialInsurance, ')
          ..write('housingFund: $housingFund, ')
          ..write('otherDeductions: $otherDeductions, ')
          ..write('specialDeductionMonthly: $specialDeductionMonthly, ')
          ..write('otherTaxDeductions: $otherTaxDeductions, ')
          ..write('salaryDay: $salaryDay, ')
          ..write('period: $period, ')
          ..write('lastSalaryDate: $lastSalaryDate, ')
          ..write('nextSalaryDate: $nextSalaryDate, ')
          ..write('incomeType: $incomeType, ')
          ..write('creationDate: $creationDate, ')
          ..write('updateDate: $updateDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssetHistoriesTable extends AssetHistories
    with TableInfo<$AssetHistoriesTable, AssetHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assetIdMeta =
      const VerificationMeta('assetId');
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
      'asset_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _previousStateMeta =
      const VerificationMeta('previousState');
  @override
  late final GeneratedColumn<String> previousState = GeneratedColumn<String>(
      'previous_state', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _newStateMeta =
      const VerificationMeta('newState');
  @override
  late final GeneratedColumn<String> newState = GeneratedColumn<String>(
      'new_state', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        assetId,
        action,
        description,
        previousState,
        newState,
        timestamp,
        userId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset_histories';
  @override
  VerificationContext validateIntegrity(Insertable<AssetHistory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('asset_id')) {
      context.handle(_assetIdMeta,
          assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta));
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('previous_state')) {
      context.handle(
          _previousStateMeta,
          previousState.isAcceptableOrUnknown(
              data['previous_state']!, _previousStateMeta));
    }
    if (data.containsKey('new_state')) {
      context.handle(_newStateMeta,
          newState.isAcceptableOrUnknown(data['new_state']!, _newStateMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssetHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetHistory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      assetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asset_id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      previousState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}previous_state']),
      newState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}new_state']),
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
    );
  }

  @override
  $AssetHistoriesTable createAlias(String alias) {
    return $AssetHistoriesTable(attachedDatabase, alias);
  }
}

class AssetHistory extends DataClass implements Insertable<AssetHistory> {
  final String id;
  final String assetId;
  final String action;
  final String description;
  final String? previousState;
  final String? newState;
  final DateTime timestamp;
  final String? userId;
  const AssetHistory(
      {required this.id,
      required this.assetId,
      required this.action,
      required this.description,
      this.previousState,
      this.newState,
      required this.timestamp,
      this.userId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['asset_id'] = Variable<String>(assetId);
    map['action'] = Variable<String>(action);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || previousState != null) {
      map['previous_state'] = Variable<String>(previousState);
    }
    if (!nullToAbsent || newState != null) {
      map['new_state'] = Variable<String>(newState);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    return map;
  }

  AssetHistoriesCompanion toCompanion(bool nullToAbsent) {
    return AssetHistoriesCompanion(
      id: Value(id),
      assetId: Value(assetId),
      action: Value(action),
      description: Value(description),
      previousState: previousState == null && nullToAbsent
          ? const Value.absent()
          : Value(previousState),
      newState: newState == null && nullToAbsent
          ? const Value.absent()
          : Value(newState),
      timestamp: Value(timestamp),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
    );
  }

  factory AssetHistory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetHistory(
      id: serializer.fromJson<String>(json['id']),
      assetId: serializer.fromJson<String>(json['assetId']),
      action: serializer.fromJson<String>(json['action']),
      description: serializer.fromJson<String>(json['description']),
      previousState: serializer.fromJson<String?>(json['previousState']),
      newState: serializer.fromJson<String?>(json['newState']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      userId: serializer.fromJson<String?>(json['userId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'assetId': serializer.toJson<String>(assetId),
      'action': serializer.toJson<String>(action),
      'description': serializer.toJson<String>(description),
      'previousState': serializer.toJson<String?>(previousState),
      'newState': serializer.toJson<String?>(newState),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'userId': serializer.toJson<String?>(userId),
    };
  }

  AssetHistory copyWith(
          {String? id,
          String? assetId,
          String? action,
          String? description,
          Value<String?> previousState = const Value.absent(),
          Value<String?> newState = const Value.absent(),
          DateTime? timestamp,
          Value<String?> userId = const Value.absent()}) =>
      AssetHistory(
        id: id ?? this.id,
        assetId: assetId ?? this.assetId,
        action: action ?? this.action,
        description: description ?? this.description,
        previousState:
            previousState.present ? previousState.value : this.previousState,
        newState: newState.present ? newState.value : this.newState,
        timestamp: timestamp ?? this.timestamp,
        userId: userId.present ? userId.value : this.userId,
      );
  AssetHistory copyWithCompanion(AssetHistoriesCompanion data) {
    return AssetHistory(
      id: data.id.present ? data.id.value : this.id,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      action: data.action.present ? data.action.value : this.action,
      description:
          data.description.present ? data.description.value : this.description,
      previousState: data.previousState.present
          ? data.previousState.value
          : this.previousState,
      newState: data.newState.present ? data.newState.value : this.newState,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      userId: data.userId.present ? data.userId.value : this.userId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetHistory(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('action: $action, ')
          ..write('description: $description, ')
          ..write('previousState: $previousState, ')
          ..write('newState: $newState, ')
          ..write('timestamp: $timestamp, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, assetId, action, description,
      previousState, newState, timestamp, userId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetHistory &&
          other.id == this.id &&
          other.assetId == this.assetId &&
          other.action == this.action &&
          other.description == this.description &&
          other.previousState == this.previousState &&
          other.newState == this.newState &&
          other.timestamp == this.timestamp &&
          other.userId == this.userId);
}

class AssetHistoriesCompanion extends UpdateCompanion<AssetHistory> {
  final Value<String> id;
  final Value<String> assetId;
  final Value<String> action;
  final Value<String> description;
  final Value<String?> previousState;
  final Value<String?> newState;
  final Value<DateTime> timestamp;
  final Value<String?> userId;
  final Value<int> rowid;
  const AssetHistoriesCompanion({
    this.id = const Value.absent(),
    this.assetId = const Value.absent(),
    this.action = const Value.absent(),
    this.description = const Value.absent(),
    this.previousState = const Value.absent(),
    this.newState = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.userId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssetHistoriesCompanion.insert({
    required String id,
    required String assetId,
    required String action,
    required String description,
    this.previousState = const Value.absent(),
    this.newState = const Value.absent(),
    required DateTime timestamp,
    this.userId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        assetId = Value(assetId),
        action = Value(action),
        description = Value(description),
        timestamp = Value(timestamp);
  static Insertable<AssetHistory> custom({
    Expression<String>? id,
    Expression<String>? assetId,
    Expression<String>? action,
    Expression<String>? description,
    Expression<String>? previousState,
    Expression<String>? newState,
    Expression<DateTime>? timestamp,
    Expression<String>? userId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assetId != null) 'asset_id': assetId,
      if (action != null) 'action': action,
      if (description != null) 'description': description,
      if (previousState != null) 'previous_state': previousState,
      if (newState != null) 'new_state': newState,
      if (timestamp != null) 'timestamp': timestamp,
      if (userId != null) 'user_id': userId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssetHistoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? assetId,
      Value<String>? action,
      Value<String>? description,
      Value<String?>? previousState,
      Value<String?>? newState,
      Value<DateTime>? timestamp,
      Value<String?>? userId,
      Value<int>? rowid}) {
    return AssetHistoriesCompanion(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      action: action ?? this.action,
      description: description ?? this.description,
      previousState: previousState ?? this.previousState,
      newState: newState ?? this.newState,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (previousState.present) {
      map['previous_state'] = Variable<String>(previousState.value);
    }
    if (newState.present) {
      map['new_state'] = Variable<String>(newState.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetHistoriesCompanion(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('action: $action, ')
          ..write('description: $description, ')
          ..write('previousState: $previousState, ')
          ..write('newState: $newState, ')
          ..write('timestamp: $timestamp, ')
          ..write('userId: $userId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensePlansTable extends ExpensePlans
    with TableInfo<$ExpensePlansTable, ExpensePlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensePlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetAmountMeta =
      const VerificationMeta('targetAmount');
  @override
  late final GeneratedColumn<double> targetAmount = GeneratedColumn<double>(
      'target_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _currentAmountMeta =
      const VerificationMeta('currentAmount');
  @override
  late final GeneratedColumn<double> currentAmount = GeneratedColumn<double>(
      'current_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
      'period', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _creationDateMeta =
      const VerificationMeta('creationDate');
  @override
  late final GeneratedColumn<DateTime> creationDate = GeneratedColumn<DateTime>(
      'creation_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updateDateMeta =
      const VerificationMeta('updateDate');
  @override
  late final GeneratedColumn<DateTime> updateDate = GeneratedColumn<DateTime>(
      'update_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        category,
        targetAmount,
        currentAmount,
        period,
        startDate,
        endDate,
        status,
        creationDate,
        updateDate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_plans';
  @override
  VerificationContext validateIntegrity(Insertable<ExpensePlan> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('target_amount')) {
      context.handle(
          _targetAmountMeta,
          targetAmount.isAcceptableOrUnknown(
              data['target_amount']!, _targetAmountMeta));
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('current_amount')) {
      context.handle(
          _currentAmountMeta,
          currentAmount.isAcceptableOrUnknown(
              data['current_amount']!, _currentAmountMeta));
    }
    if (data.containsKey('period')) {
      context.handle(_periodMeta,
          period.isAcceptableOrUnknown(data['period']!, _periodMeta));
    } else if (isInserting) {
      context.missing(_periodMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('creation_date')) {
      context.handle(
          _creationDateMeta,
          creationDate.isAcceptableOrUnknown(
              data['creation_date']!, _creationDateMeta));
    } else if (isInserting) {
      context.missing(_creationDateMeta);
    }
    if (data.containsKey('update_date')) {
      context.handle(
          _updateDateMeta,
          updateDate.isAcceptableOrUnknown(
              data['update_date']!, _updateDateMeta));
    } else if (isInserting) {
      context.missing(_updateDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpensePlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpensePlan(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      targetAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_amount'])!,
      currentAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}current_amount'])!,
      period: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}period'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      creationDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}creation_date'])!,
      updateDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}update_date'])!,
    );
  }

  @override
  $ExpensePlansTable createAlias(String alias) {
    return $ExpensePlansTable(attachedDatabase, alias);
  }
}

class ExpensePlan extends DataClass implements Insertable<ExpensePlan> {
  final String id;
  final String name;
  final String? description;
  final String category;
  final double targetAmount;
  final double currentAmount;
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final DateTime creationDate;
  final DateTime updateDate;
  const ExpensePlan(
      {required this.id,
      required this.name,
      this.description,
      required this.category,
      required this.targetAmount,
      required this.currentAmount,
      required this.period,
      required this.startDate,
      required this.endDate,
      required this.status,
      required this.creationDate,
      required this.updateDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['category'] = Variable<String>(category);
    map['target_amount'] = Variable<double>(targetAmount);
    map['current_amount'] = Variable<double>(currentAmount);
    map['period'] = Variable<String>(period);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['status'] = Variable<String>(status);
    map['creation_date'] = Variable<DateTime>(creationDate);
    map['update_date'] = Variable<DateTime>(updateDate);
    return map;
  }

  ExpensePlansCompanion toCompanion(bool nullToAbsent) {
    return ExpensePlansCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      category: Value(category),
      targetAmount: Value(targetAmount),
      currentAmount: Value(currentAmount),
      period: Value(period),
      startDate: Value(startDate),
      endDate: Value(endDate),
      status: Value(status),
      creationDate: Value(creationDate),
      updateDate: Value(updateDate),
    );
  }

  factory ExpensePlan.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpensePlan(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      category: serializer.fromJson<String>(json['category']),
      targetAmount: serializer.fromJson<double>(json['targetAmount']),
      currentAmount: serializer.fromJson<double>(json['currentAmount']),
      period: serializer.fromJson<String>(json['period']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      status: serializer.fromJson<String>(json['status']),
      creationDate: serializer.fromJson<DateTime>(json['creationDate']),
      updateDate: serializer.fromJson<DateTime>(json['updateDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'category': serializer.toJson<String>(category),
      'targetAmount': serializer.toJson<double>(targetAmount),
      'currentAmount': serializer.toJson<double>(currentAmount),
      'period': serializer.toJson<String>(period),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'status': serializer.toJson<String>(status),
      'creationDate': serializer.toJson<DateTime>(creationDate),
      'updateDate': serializer.toJson<DateTime>(updateDate),
    };
  }

  ExpensePlan copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          String? category,
          double? targetAmount,
          double? currentAmount,
          String? period,
          DateTime? startDate,
          DateTime? endDate,
          String? status,
          DateTime? creationDate,
          DateTime? updateDate}) =>
      ExpensePlan(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        category: category ?? this.category,
        targetAmount: targetAmount ?? this.targetAmount,
        currentAmount: currentAmount ?? this.currentAmount,
        period: period ?? this.period,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        status: status ?? this.status,
        creationDate: creationDate ?? this.creationDate,
        updateDate: updateDate ?? this.updateDate,
      );
  ExpensePlan copyWithCompanion(ExpensePlansCompanion data) {
    return ExpensePlan(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      category: data.category.present ? data.category.value : this.category,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      currentAmount: data.currentAmount.present
          ? data.currentAmount.value
          : this.currentAmount,
      period: data.period.present ? data.period.value : this.period,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      status: data.status.present ? data.status.value : this.status,
      creationDate: data.creationDate.present
          ? data.creationDate.value
          : this.creationDate,
      updateDate:
          data.updateDate.present ? data.updateDate.value : this.updateDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpensePlan(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('creationDate: $creationDate, ')
          ..write('updateDate: $updateDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      description,
      category,
      targetAmount,
      currentAmount,
      period,
      startDate,
      endDate,
      status,
      creationDate,
      updateDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpensePlan &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.category == this.category &&
          other.targetAmount == this.targetAmount &&
          other.currentAmount == this.currentAmount &&
          other.period == this.period &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.status == this.status &&
          other.creationDate == this.creationDate &&
          other.updateDate == this.updateDate);
}

class ExpensePlansCompanion extends UpdateCompanion<ExpensePlan> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> category;
  final Value<double> targetAmount;
  final Value<double> currentAmount;
  final Value<String> period;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<String> status;
  final Value<DateTime> creationDate;
  final Value<DateTime> updateDate;
  final Value<int> rowid;
  const ExpensePlansCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.currentAmount = const Value.absent(),
    this.period = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.status = const Value.absent(),
    this.creationDate = const Value.absent(),
    this.updateDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensePlansCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String category,
    required double targetAmount,
    this.currentAmount = const Value.absent(),
    required String period,
    required DateTime startDate,
    required DateTime endDate,
    required String status,
    required DateTime creationDate,
    required DateTime updateDate,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        category = Value(category),
        targetAmount = Value(targetAmount),
        period = Value(period),
        startDate = Value(startDate),
        endDate = Value(endDate),
        status = Value(status),
        creationDate = Value(creationDate),
        updateDate = Value(updateDate);
  static Insertable<ExpensePlan> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? category,
    Expression<double>? targetAmount,
    Expression<double>? currentAmount,
    Expression<String>? period,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? status,
    Expression<DateTime>? creationDate,
    Expression<DateTime>? updateDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (currentAmount != null) 'current_amount': currentAmount,
      if (period != null) 'period': period,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (status != null) 'status': status,
      if (creationDate != null) 'creation_date': creationDate,
      if (updateDate != null) 'update_date': updateDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensePlansCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? category,
      Value<double>? targetAmount,
      Value<double>? currentAmount,
      Value<String>? period,
      Value<DateTime>? startDate,
      Value<DateTime>? endDate,
      Value<String>? status,
      Value<DateTime>? creationDate,
      Value<DateTime>? updateDate,
      Value<int>? rowid}) {
    return ExpensePlansCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      creationDate: creationDate ?? this.creationDate,
      updateDate: updateDate ?? this.updateDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<double>(targetAmount.value);
    }
    if (currentAmount.present) {
      map['current_amount'] = Variable<double>(currentAmount.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (creationDate.present) {
      map['creation_date'] = Variable<DateTime>(creationDate.value);
    }
    if (updateDate.present) {
      map['update_date'] = Variable<DateTime>(updateDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensePlansCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('creationDate: $creationDate, ')
          ..write('updateDate: $updateDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IncomePlansTable extends IncomePlans
    with TableInfo<$IncomePlansTable, IncomePlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncomePlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _incomeTypeMeta =
      const VerificationMeta('incomeType');
  @override
  late final GeneratedColumn<String> incomeType = GeneratedColumn<String>(
      'income_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetAmountMeta =
      const VerificationMeta('targetAmount');
  @override
  late final GeneratedColumn<double> targetAmount = GeneratedColumn<double>(
      'target_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _currentAmountMeta =
      const VerificationMeta('currentAmount');
  @override
  late final GeneratedColumn<double> currentAmount = GeneratedColumn<double>(
      'current_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
      'period', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _creationDateMeta =
      const VerificationMeta('creationDate');
  @override
  late final GeneratedColumn<DateTime> creationDate = GeneratedColumn<DateTime>(
      'creation_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updateDateMeta =
      const VerificationMeta('updateDate');
  @override
  late final GeneratedColumn<DateTime> updateDate = GeneratedColumn<DateTime>(
      'update_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        incomeType,
        targetAmount,
        currentAmount,
        period,
        startDate,
        endDate,
        status,
        creationDate,
        updateDate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'income_plans';
  @override
  VerificationContext validateIntegrity(Insertable<IncomePlan> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('income_type')) {
      context.handle(
          _incomeTypeMeta,
          incomeType.isAcceptableOrUnknown(
              data['income_type']!, _incomeTypeMeta));
    } else if (isInserting) {
      context.missing(_incomeTypeMeta);
    }
    if (data.containsKey('target_amount')) {
      context.handle(
          _targetAmountMeta,
          targetAmount.isAcceptableOrUnknown(
              data['target_amount']!, _targetAmountMeta));
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('current_amount')) {
      context.handle(
          _currentAmountMeta,
          currentAmount.isAcceptableOrUnknown(
              data['current_amount']!, _currentAmountMeta));
    }
    if (data.containsKey('period')) {
      context.handle(_periodMeta,
          period.isAcceptableOrUnknown(data['period']!, _periodMeta));
    } else if (isInserting) {
      context.missing(_periodMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('creation_date')) {
      context.handle(
          _creationDateMeta,
          creationDate.isAcceptableOrUnknown(
              data['creation_date']!, _creationDateMeta));
    } else if (isInserting) {
      context.missing(_creationDateMeta);
    }
    if (data.containsKey('update_date')) {
      context.handle(
          _updateDateMeta,
          updateDate.isAcceptableOrUnknown(
              data['update_date']!, _updateDateMeta));
    } else if (isInserting) {
      context.missing(_updateDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IncomePlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IncomePlan(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      incomeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}income_type'])!,
      targetAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_amount'])!,
      currentAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}current_amount'])!,
      period: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}period'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      creationDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}creation_date'])!,
      updateDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}update_date'])!,
    );
  }

  @override
  $IncomePlansTable createAlias(String alias) {
    return $IncomePlansTable(attachedDatabase, alias);
  }
}

class IncomePlan extends DataClass implements Insertable<IncomePlan> {
  final String id;
  final String name;
  final String? description;
  final String incomeType;
  final double targetAmount;
  final double currentAmount;
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final DateTime creationDate;
  final DateTime updateDate;
  const IncomePlan(
      {required this.id,
      required this.name,
      this.description,
      required this.incomeType,
      required this.targetAmount,
      required this.currentAmount,
      required this.period,
      required this.startDate,
      required this.endDate,
      required this.status,
      required this.creationDate,
      required this.updateDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['income_type'] = Variable<String>(incomeType);
    map['target_amount'] = Variable<double>(targetAmount);
    map['current_amount'] = Variable<double>(currentAmount);
    map['period'] = Variable<String>(period);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['status'] = Variable<String>(status);
    map['creation_date'] = Variable<DateTime>(creationDate);
    map['update_date'] = Variable<DateTime>(updateDate);
    return map;
  }

  IncomePlansCompanion toCompanion(bool nullToAbsent) {
    return IncomePlansCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      incomeType: Value(incomeType),
      targetAmount: Value(targetAmount),
      currentAmount: Value(currentAmount),
      period: Value(period),
      startDate: Value(startDate),
      endDate: Value(endDate),
      status: Value(status),
      creationDate: Value(creationDate),
      updateDate: Value(updateDate),
    );
  }

  factory IncomePlan.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IncomePlan(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      incomeType: serializer.fromJson<String>(json['incomeType']),
      targetAmount: serializer.fromJson<double>(json['targetAmount']),
      currentAmount: serializer.fromJson<double>(json['currentAmount']),
      period: serializer.fromJson<String>(json['period']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      status: serializer.fromJson<String>(json['status']),
      creationDate: serializer.fromJson<DateTime>(json['creationDate']),
      updateDate: serializer.fromJson<DateTime>(json['updateDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'incomeType': serializer.toJson<String>(incomeType),
      'targetAmount': serializer.toJson<double>(targetAmount),
      'currentAmount': serializer.toJson<double>(currentAmount),
      'period': serializer.toJson<String>(period),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'status': serializer.toJson<String>(status),
      'creationDate': serializer.toJson<DateTime>(creationDate),
      'updateDate': serializer.toJson<DateTime>(updateDate),
    };
  }

  IncomePlan copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          String? incomeType,
          double? targetAmount,
          double? currentAmount,
          String? period,
          DateTime? startDate,
          DateTime? endDate,
          String? status,
          DateTime? creationDate,
          DateTime? updateDate}) =>
      IncomePlan(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        incomeType: incomeType ?? this.incomeType,
        targetAmount: targetAmount ?? this.targetAmount,
        currentAmount: currentAmount ?? this.currentAmount,
        period: period ?? this.period,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        status: status ?? this.status,
        creationDate: creationDate ?? this.creationDate,
        updateDate: updateDate ?? this.updateDate,
      );
  IncomePlan copyWithCompanion(IncomePlansCompanion data) {
    return IncomePlan(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      incomeType:
          data.incomeType.present ? data.incomeType.value : this.incomeType,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      currentAmount: data.currentAmount.present
          ? data.currentAmount.value
          : this.currentAmount,
      period: data.period.present ? data.period.value : this.period,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      status: data.status.present ? data.status.value : this.status,
      creationDate: data.creationDate.present
          ? data.creationDate.value
          : this.creationDate,
      updateDate:
          data.updateDate.present ? data.updateDate.value : this.updateDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IncomePlan(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('incomeType: $incomeType, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('creationDate: $creationDate, ')
          ..write('updateDate: $updateDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      description,
      incomeType,
      targetAmount,
      currentAmount,
      period,
      startDate,
      endDate,
      status,
      creationDate,
      updateDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IncomePlan &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.incomeType == this.incomeType &&
          other.targetAmount == this.targetAmount &&
          other.currentAmount == this.currentAmount &&
          other.period == this.period &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.status == this.status &&
          other.creationDate == this.creationDate &&
          other.updateDate == this.updateDate);
}

class IncomePlansCompanion extends UpdateCompanion<IncomePlan> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> incomeType;
  final Value<double> targetAmount;
  final Value<double> currentAmount;
  final Value<String> period;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<String> status;
  final Value<DateTime> creationDate;
  final Value<DateTime> updateDate;
  final Value<int> rowid;
  const IncomePlansCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.incomeType = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.currentAmount = const Value.absent(),
    this.period = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.status = const Value.absent(),
    this.creationDate = const Value.absent(),
    this.updateDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IncomePlansCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String incomeType,
    required double targetAmount,
    this.currentAmount = const Value.absent(),
    required String period,
    required DateTime startDate,
    required DateTime endDate,
    required String status,
    required DateTime creationDate,
    required DateTime updateDate,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        incomeType = Value(incomeType),
        targetAmount = Value(targetAmount),
        period = Value(period),
        startDate = Value(startDate),
        endDate = Value(endDate),
        status = Value(status),
        creationDate = Value(creationDate),
        updateDate = Value(updateDate);
  static Insertable<IncomePlan> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? incomeType,
    Expression<double>? targetAmount,
    Expression<double>? currentAmount,
    Expression<String>? period,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? status,
    Expression<DateTime>? creationDate,
    Expression<DateTime>? updateDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (incomeType != null) 'income_type': incomeType,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (currentAmount != null) 'current_amount': currentAmount,
      if (period != null) 'period': period,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (status != null) 'status': status,
      if (creationDate != null) 'creation_date': creationDate,
      if (updateDate != null) 'update_date': updateDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IncomePlansCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? incomeType,
      Value<double>? targetAmount,
      Value<double>? currentAmount,
      Value<String>? period,
      Value<DateTime>? startDate,
      Value<DateTime>? endDate,
      Value<String>? status,
      Value<DateTime>? creationDate,
      Value<DateTime>? updateDate,
      Value<int>? rowid}) {
    return IncomePlansCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      incomeType: incomeType ?? this.incomeType,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      creationDate: creationDate ?? this.creationDate,
      updateDate: updateDate ?? this.updateDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (incomeType.present) {
      map['income_type'] = Variable<String>(incomeType.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<double>(targetAmount.value);
    }
    if (currentAmount.present) {
      map['current_amount'] = Variable<double>(currentAmount.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (creationDate.present) {
      map['creation_date'] = Variable<DateTime>(creationDate.value);
    }
    if (updateDate.present) {
      map['update_date'] = Variable<DateTime>(updateDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncomePlansCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('incomeType: $incomeType, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('creationDate: $creationDate, ')
          ..write('updateDate: $updateDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AssetsTable assets = $AssetsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $EnvelopeBudgetsTable envelopeBudgets =
      $EnvelopeBudgetsTable(this);
  late final $ZeroBasedBudgetsTable zeroBasedBudgets =
      $ZeroBasedBudgetsTable(this);
  late final $SalaryIncomesTable salaryIncomes = $SalaryIncomesTable(this);
  late final $AssetHistoriesTable assetHistories = $AssetHistoriesTable(this);
  late final $ExpensePlansTable expensePlans = $ExpensePlansTable(this);
  late final $IncomePlansTable incomePlans = $IncomePlansTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        assets,
        transactions,
        accounts,
        envelopeBudgets,
        zeroBasedBudgets,
        salaryIncomes,
        assetHistories,
        expensePlans,
        incomePlans
      ];
}

typedef $$AssetsTableCreateCompanionBuilder = AssetsCompanion Function({
  required String id,
  required String name,
  required double amount,
  required String category,
  required String subCategory,
  required DateTime creationDate,
  required DateTime updateDate,
  Value<DateTime?> purchaseDate,
  Value<String?> depreciationMethod,
  Value<double?> depreciationRate,
  Value<double?> currentValue,
  Value<bool> isIdle,
  Value<double?> idleValue,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$AssetsTableUpdateCompanionBuilder = AssetsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<double> amount,
  Value<String> category,
  Value<String> subCategory,
  Value<DateTime> creationDate,
  Value<DateTime> updateDate,
  Value<DateTime?> purchaseDate,
  Value<String?> depreciationMethod,
  Value<double?> depreciationRate,
  Value<double?> currentValue,
  Value<bool> isIdle,
  Value<double?> idleValue,
  Value<String?> notes,
  Value<int> rowid,
});

class $$AssetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AssetsTable,
    Asset,
    $$AssetsTableFilterComposer,
    $$AssetsTableOrderingComposer,
    $$AssetsTableCreateCompanionBuilder,
    $$AssetsTableUpdateCompanionBuilder> {
  $$AssetsTableTableManager(_$AppDatabase db, $AssetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AssetsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AssetsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> subCategory = const Value.absent(),
            Value<DateTime> creationDate = const Value.absent(),
            Value<DateTime> updateDate = const Value.absent(),
            Value<DateTime?> purchaseDate = const Value.absent(),
            Value<String?> depreciationMethod = const Value.absent(),
            Value<double?> depreciationRate = const Value.absent(),
            Value<double?> currentValue = const Value.absent(),
            Value<bool> isIdle = const Value.absent(),
            Value<double?> idleValue = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssetsCompanion(
            id: id,
            name: name,
            amount: amount,
            category: category,
            subCategory: subCategory,
            creationDate: creationDate,
            updateDate: updateDate,
            purchaseDate: purchaseDate,
            depreciationMethod: depreciationMethod,
            depreciationRate: depreciationRate,
            currentValue: currentValue,
            isIdle: isIdle,
            idleValue: idleValue,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required double amount,
            required String category,
            required String subCategory,
            required DateTime creationDate,
            required DateTime updateDate,
            Value<DateTime?> purchaseDate = const Value.absent(),
            Value<String?> depreciationMethod = const Value.absent(),
            Value<double?> depreciationRate = const Value.absent(),
            Value<double?> currentValue = const Value.absent(),
            Value<bool> isIdle = const Value.absent(),
            Value<double?> idleValue = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssetsCompanion.insert(
            id: id,
            name: name,
            amount: amount,
            category: category,
            subCategory: subCategory,
            creationDate: creationDate,
            updateDate: updateDate,
            purchaseDate: purchaseDate,
            depreciationMethod: depreciationMethod,
            depreciationRate: depreciationRate,
            currentValue: currentValue,
            isIdle: isIdle,
            idleValue: idleValue,
            notes: notes,
            rowid: rowid,
          ),
        ));
}

class $$AssetsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get subCategory => $state.composableBuilder(
      column: $state.table.subCategory,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get creationDate => $state.composableBuilder(
      column: $state.table.creationDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updateDate => $state.composableBuilder(
      column: $state.table.updateDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get purchaseDate => $state.composableBuilder(
      column: $state.table.purchaseDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get depreciationMethod => $state.composableBuilder(
      column: $state.table.depreciationMethod,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get depreciationRate => $state.composableBuilder(
      column: $state.table.depreciationRate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get currentValue => $state.composableBuilder(
      column: $state.table.currentValue,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isIdle => $state.composableBuilder(
      column: $state.table.isIdle,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get idleValue => $state.composableBuilder(
      column: $state.table.idleValue,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$AssetsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get subCategory => $state.composableBuilder(
      column: $state.table.subCategory,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get creationDate => $state.composableBuilder(
      column: $state.table.creationDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updateDate => $state.composableBuilder(
      column: $state.table.updateDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get purchaseDate => $state.composableBuilder(
      column: $state.table.purchaseDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get depreciationMethod => $state.composableBuilder(
      column: $state.table.depreciationMethod,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get depreciationRate => $state.composableBuilder(
      column: $state.table.depreciationRate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get currentValue => $state.composableBuilder(
      column: $state.table.currentValue,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isIdle => $state.composableBuilder(
      column: $state.table.isIdle,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get idleValue => $state.composableBuilder(
      column: $state.table.idleValue,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  required String id,
  required String description,
  required double amount,
  Value<String?> flow,
  Value<String?> type,
  required String category,
  Value<String?> subCategory,
  Value<String?> fromWalletId,
  Value<String?> toWalletId,
  Value<String?> fromAssetId,
  Value<String?> toAssetId,
  Value<String?> fromAccountId,
  Value<String?> toAccountId,
  Value<String?> envelopeBudgetId,
  required DateTime date,
  Value<String?> notes,
  required String tags,
  required String status,
  Value<bool> isRecurring,
  Value<String?> recurringRule,
  Value<String?> parentTransactionId,
  required DateTime creationDate,
  required DateTime updateDate,
  Value<String?> imagePath,
  Value<bool> isAutoGenerated,
  Value<int> rowid,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<String> id,
  Value<String> description,
  Value<double> amount,
  Value<String?> flow,
  Value<String?> type,
  Value<String> category,
  Value<String?> subCategory,
  Value<String?> fromWalletId,
  Value<String?> toWalletId,
  Value<String?> fromAssetId,
  Value<String?> toAssetId,
  Value<String?> fromAccountId,
  Value<String?> toAccountId,
  Value<String?> envelopeBudgetId,
  Value<DateTime> date,
  Value<String?> notes,
  Value<String> tags,
  Value<String> status,
  Value<bool> isRecurring,
  Value<String?> recurringRule,
  Value<String?> parentTransactionId,
  Value<DateTime> creationDate,
  Value<DateTime> updateDate,
  Value<String?> imagePath,
  Value<bool> isAutoGenerated,
  Value<int> rowid,
});

class $$TransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder> {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TransactionsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TransactionsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String?> flow = const Value.absent(),
            Value<String?> type = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String?> subCategory = const Value.absent(),
            Value<String?> fromWalletId = const Value.absent(),
            Value<String?> toWalletId = const Value.absent(),
            Value<String?> fromAssetId = const Value.absent(),
            Value<String?> toAssetId = const Value.absent(),
            Value<String?> fromAccountId = const Value.absent(),
            Value<String?> toAccountId = const Value.absent(),
            Value<String?> envelopeBudgetId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<String?> recurringRule = const Value.absent(),
            Value<String?> parentTransactionId = const Value.absent(),
            Value<DateTime> creationDate = const Value.absent(),
            Value<DateTime> updateDate = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<bool> isAutoGenerated = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion(
            id: id,
            description: description,
            amount: amount,
            flow: flow,
            type: type,
            category: category,
            subCategory: subCategory,
            fromWalletId: fromWalletId,
            toWalletId: toWalletId,
            fromAssetId: fromAssetId,
            toAssetId: toAssetId,
            fromAccountId: fromAccountId,
            toAccountId: toAccountId,
            envelopeBudgetId: envelopeBudgetId,
            date: date,
            notes: notes,
            tags: tags,
            status: status,
            isRecurring: isRecurring,
            recurringRule: recurringRule,
            parentTransactionId: parentTransactionId,
            creationDate: creationDate,
            updateDate: updateDate,
            imagePath: imagePath,
            isAutoGenerated: isAutoGenerated,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String description,
            required double amount,
            Value<String?> flow = const Value.absent(),
            Value<String?> type = const Value.absent(),
            required String category,
            Value<String?> subCategory = const Value.absent(),
            Value<String?> fromWalletId = const Value.absent(),
            Value<String?> toWalletId = const Value.absent(),
            Value<String?> fromAssetId = const Value.absent(),
            Value<String?> toAssetId = const Value.absent(),
            Value<String?> fromAccountId = const Value.absent(),
            Value<String?> toAccountId = const Value.absent(),
            Value<String?> envelopeBudgetId = const Value.absent(),
            required DateTime date,
            Value<String?> notes = const Value.absent(),
            required String tags,
            required String status,
            Value<bool> isRecurring = const Value.absent(),
            Value<String?> recurringRule = const Value.absent(),
            Value<String?> parentTransactionId = const Value.absent(),
            required DateTime creationDate,
            required DateTime updateDate,
            Value<String?> imagePath = const Value.absent(),
            Value<bool> isAutoGenerated = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            id: id,
            description: description,
            amount: amount,
            flow: flow,
            type: type,
            category: category,
            subCategory: subCategory,
            fromWalletId: fromWalletId,
            toWalletId: toWalletId,
            fromAssetId: fromAssetId,
            toAssetId: toAssetId,
            fromAccountId: fromAccountId,
            toAccountId: toAccountId,
            envelopeBudgetId: envelopeBudgetId,
            date: date,
            notes: notes,
            tags: tags,
            status: status,
            isRecurring: isRecurring,
            recurringRule: recurringRule,
            parentTransactionId: parentTransactionId,
            creationDate: creationDate,
            updateDate: updateDate,
            imagePath: imagePath,
            isAutoGenerated: isAutoGenerated,
            rowid: rowid,
          ),
        ));
}

class $$TransactionsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get flow => $state.composableBuilder(
      column: $state.table.flow,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get subCategory => $state.composableBuilder(
      column: $state.table.subCategory,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get fromWalletId => $state.composableBuilder(
      column: $state.table.fromWalletId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get toWalletId => $state.composableBuilder(
      column: $state.table.toWalletId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get fromAssetId => $state.composableBuilder(
      column: $state.table.fromAssetId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get toAssetId => $state.composableBuilder(
      column: $state.table.toAssetId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get fromAccountId => $state.composableBuilder(
      column: $state.table.fromAccountId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get toAccountId => $state.composableBuilder(
      column: $state.table.toAccountId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get envelopeBudgetId => $state.composableBuilder(
      column: $state.table.envelopeBudgetId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get tags => $state.composableBuilder(
      column: $state.table.tags,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isRecurring => $state.composableBuilder(
      column: $state.table.isRecurring,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get recurringRule => $state.composableBuilder(
      column: $state.table.recurringRule,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get parentTransactionId => $state.composableBuilder(
      column: $state.table.parentTransactionId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get creationDate => $state.composableBuilder(
      column: $state.table.creationDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updateDate => $state.composableBuilder(
      column: $state.table.updateDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get imagePath => $state.composableBuilder(
      column: $state.table.imagePath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isAutoGenerated => $state.composableBuilder(
      column: $state.table.isAutoGenerated,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$TransactionsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get amount => $state.composableBuilder(
      column: $state.table.amount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get flow => $state.composableBuilder(
      column: $state.table.flow,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get subCategory => $state.composableBuilder(
      column: $state.table.subCategory,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fromWalletId => $state.composableBuilder(
      column: $state.table.fromWalletId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get toWalletId => $state.composableBuilder(
      column: $state.table.toWalletId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fromAssetId => $state.composableBuilder(
      column: $state.table.fromAssetId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get toAssetId => $state.composableBuilder(
      column: $state.table.toAssetId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fromAccountId => $state.composableBuilder(
      column: $state.table.fromAccountId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get toAccountId => $state.composableBuilder(
      column: $state.table.toAccountId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get envelopeBudgetId => $state.composableBuilder(
      column: $state.table.envelopeBudgetId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get tags => $state.composableBuilder(
      column: $state.table.tags,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isRecurring => $state.composableBuilder(
      column: $state.table.isRecurring,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get recurringRule => $state.composableBuilder(
      column: $state.table.recurringRule,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get parentTransactionId => $state.composableBuilder(
      column: $state.table.parentTransactionId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get creationDate => $state.composableBuilder(
      column: $state.table.creationDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updateDate => $state.composableBuilder(
      column: $state.table.updateDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get imagePath => $state.composableBuilder(
      column: $state.table.imagePath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isAutoGenerated => $state.composableBuilder(
      column: $state.table.isAutoGenerated,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  required String id,
  required String name,
  Value<String?> description,
  required String type,
  required String status,
  required double balance,
  Value<double> initialBalance,
  Value<String> currency,
  Value<String?> bankName,
  Value<String?> accountNumber,
  Value<String?> cardNumber,
  Value<double?> creditLimit,
  Value<double?> interestRate,
  Value<DateTime?> openDate,
  Value<DateTime?> closeDate,
  Value<String?> loanType,
  Value<double?> loanAmount,
  Value<double?> secondInterestRate,
  Value<int?> loanTerm,
  Value<String?> repaymentMethod,
  Value<DateTime?> firstPaymentDate,
  Value<double?> remainingPrincipal,
  Value<double?> monthlyPayment,
  Value<bool> isRecurringPayment,
  Value<String?> iconName,
  Value<String?> color,
  Value<bool> isDefault,
  Value<bool> isHidden,
  required String tags,
  required DateTime creationDate,
  required DateTime updateDate,
  Value<String?> syncProvider,
  Value<String?> syncAccountId,
  Value<DateTime?> lastSyncDate,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String> type,
  Value<String> status,
  Value<double> balance,
  Value<double> initialBalance,
  Value<String> currency,
  Value<String?> bankName,
  Value<String?> accountNumber,
  Value<String?> cardNumber,
  Value<double?> creditLimit,
  Value<double?> interestRate,
  Value<DateTime?> openDate,
  Value<DateTime?> closeDate,
  Value<String?> loanType,
  Value<double?> loanAmount,
  Value<double?> secondInterestRate,
  Value<int?> loanTerm,
  Value<String?> repaymentMethod,
  Value<DateTime?> firstPaymentDate,
  Value<double?> remainingPrincipal,
  Value<double?> monthlyPayment,
  Value<bool> isRecurringPayment,
  Value<String?> iconName,
  Value<String?> color,
  Value<bool> isDefault,
  Value<bool> isHidden,
  Value<String> tags,
  Value<DateTime> creationDate,
  Value<DateTime> updateDate,
  Value<String?> syncProvider,
  Value<String?> syncAccountId,
  Value<DateTime?> lastSyncDate,
  Value<int> rowid,
});

class $$AccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder> {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AccountsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AccountsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<double> balance = const Value.absent(),
            Value<double> initialBalance = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<String?> bankName = const Value.absent(),
            Value<String?> accountNumber = const Value.absent(),
            Value<String?> cardNumber = const Value.absent(),
            Value<double?> creditLimit = const Value.absent(),
            Value<double?> interestRate = const Value.absent(),
            Value<DateTime?> openDate = const Value.absent(),
            Value<DateTime?> closeDate = const Value.absent(),
            Value<String?> loanType = const Value.absent(),
            Value<double?> loanAmount = const Value.absent(),
            Value<double?> secondInterestRate = const Value.absent(),
            Value<int?> loanTerm = const Value.absent(),
            Value<String?> repaymentMethod = const Value.absent(),
            Value<DateTime?> firstPaymentDate = const Value.absent(),
            Value<double?> remainingPrincipal = const Value.absent(),
            Value<double?> monthlyPayment = const Value.absent(),
            Value<bool> isRecurringPayment = const Value.absent(),
            Value<String?> iconName = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isHidden = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<DateTime> creationDate = const Value.absent(),
            Value<DateTime> updateDate = const Value.absent(),
            Value<String?> syncProvider = const Value.absent(),
            Value<String?> syncAccountId = const Value.absent(),
            Value<DateTime?> lastSyncDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion(
            id: id,
            name: name,
            description: description,
            type: type,
            status: status,
            balance: balance,
            initialBalance: initialBalance,
            currency: currency,
            bankName: bankName,
            accountNumber: accountNumber,
            cardNumber: cardNumber,
            creditLimit: creditLimit,
            interestRate: interestRate,
            openDate: openDate,
            closeDate: closeDate,
            loanType: loanType,
            loanAmount: loanAmount,
            secondInterestRate: secondInterestRate,
            loanTerm: loanTerm,
            repaymentMethod: repaymentMethod,
            firstPaymentDate: firstPaymentDate,
            remainingPrincipal: remainingPrincipal,
            monthlyPayment: monthlyPayment,
            isRecurringPayment: isRecurringPayment,
            iconName: iconName,
            color: color,
            isDefault: isDefault,
            isHidden: isHidden,
            tags: tags,
            creationDate: creationDate,
            updateDate: updateDate,
            syncProvider: syncProvider,
            syncAccountId: syncAccountId,
            lastSyncDate: lastSyncDate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            required String type,
            required String status,
            required double balance,
            Value<double> initialBalance = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<String?> bankName = const Value.absent(),
            Value<String?> accountNumber = const Value.absent(),
            Value<String?> cardNumber = const Value.absent(),
            Value<double?> creditLimit = const Value.absent(),
            Value<double?> interestRate = const Value.absent(),
            Value<DateTime?> openDate = const Value.absent(),
            Value<DateTime?> closeDate = const Value.absent(),
            Value<String?> loanType = const Value.absent(),
            Value<double?> loanAmount = const Value.absent(),
            Value<double?> secondInterestRate = const Value.absent(),
            Value<int?> loanTerm = const Value.absent(),
            Value<String?> repaymentMethod = const Value.absent(),
            Value<DateTime?> firstPaymentDate = const Value.absent(),
            Value<double?> remainingPrincipal = const Value.absent(),
            Value<double?> monthlyPayment = const Value.absent(),
            Value<bool> isRecurringPayment = const Value.absent(),
            Value<String?> iconName = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isHidden = const Value.absent(),
            required String tags,
            required DateTime creationDate,
            required DateTime updateDate,
            Value<String?> syncProvider = const Value.absent(),
            Value<String?> syncAccountId = const Value.absent(),
            Value<DateTime?> lastSyncDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion.insert(
            id: id,
            name: name,
            description: description,
            type: type,
            status: status,
            balance: balance,
            initialBalance: initialBalance,
            currency: currency,
            bankName: bankName,
            accountNumber: accountNumber,
            cardNumber: cardNumber,
            creditLimit: creditLimit,
            interestRate: interestRate,
            openDate: openDate,
            closeDate: closeDate,
            loanType: loanType,
            loanAmount: loanAmount,
            secondInterestRate: secondInterestRate,
            loanTerm: loanTerm,
            repaymentMethod: repaymentMethod,
            firstPaymentDate: firstPaymentDate,
            remainingPrincipal: remainingPrincipal,
            monthlyPayment: monthlyPayment,
            isRecurringPayment: isRecurringPayment,
            iconName: iconName,
            color: color,
            isDefault: isDefault,
            isHidden: isHidden,
            tags: tags,
            creationDate: creationDate,
            updateDate: updateDate,
            syncProvider: syncProvider,
            syncAccountId: syncAccountId,
            lastSyncDate: lastSyncDate,
            rowid: rowid,
          ),
        ));
}

class $$AccountsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get balance => $state.composableBuilder(
      column: $state.table.balance,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get initialBalance => $state.composableBuilder(
      column: $state.table.initialBalance,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get currency => $state.composableBuilder(
      column: $state.table.currency,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get bankName => $state.composableBuilder(
      column: $state.table.bankName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get accountNumber => $state.composableBuilder(
      column: $state.table.accountNumber,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get cardNumber => $state.composableBuilder(
      column: $state.table.cardNumber,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get creditLimit => $state.composableBuilder(
      column: $state.table.creditLimit,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get interestRate => $state.composableBuilder(
      column: $state.table.interestRate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get openDate => $state.composableBuilder(
      column: $state.table.openDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get closeDate => $state.composableBuilder(
      column: $state.table.closeDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get loanType => $state.composableBuilder(
      column: $state.table.loanType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get loanAmount => $state.composableBuilder(
      column: $state.table.loanAmount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get secondInterestRate => $state.composableBuilder(
      column: $state.table.secondInterestRate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get loanTerm => $state.composableBuilder(
      column: $state.table.loanTerm,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get repaymentMethod => $state.composableBuilder(
      column: $state.table.repaymentMethod,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get firstPaymentDate => $state.composableBuilder(
      column: $state.table.firstPaymentDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get remainingPrincipal => $state.composableBuilder(
      column: $state.table.remainingPrincipal,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get monthlyPayment => $state.composableBuilder(
      column: $state.table.monthlyPayment,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isRecurringPayment => $state.composableBuilder(
      column: $state.table.isRecurringPayment,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get iconName => $state.composableBuilder(
      column: $state.table.iconName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isDefault => $state.composableBuilder(
      column: $state.table.isDefault,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isHidden => $state.composableBuilder(
      column: $state.table.isHidden,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get tags => $state.composableBuilder(
      column: $state.table.tags,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get creationDate => $state.composableBuilder(
      column: $state.table.creationDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updateDate => $state.composableBuilder(
      column: $state.table.updateDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get syncProvider => $state.composableBuilder(
      column: $state.table.syncProvider,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get syncAccountId => $state.composableBuilder(
      column: $state.table.syncAccountId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastSyncDate => $state.composableBuilder(
      column: $state.table.lastSyncDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$AccountsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get balance => $state.composableBuilder(
      column: $state.table.balance,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get initialBalance => $state.composableBuilder(
      column: $state.table.initialBalance,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get currency => $state.composableBuilder(
      column: $state.table.currency,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get bankName => $state.composableBuilder(
      column: $state.table.bankName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get accountNumber => $state.composableBuilder(
      column: $state.table.accountNumber,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get cardNumber => $state.composableBuilder(
      column: $state.table.cardNumber,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get creditLimit => $state.composableBuilder(
      column: $state.table.creditLimit,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get interestRate => $state.composableBuilder(
      column: $state.table.interestRate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get openDate => $state.composableBuilder(
      column: $state.table.openDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get closeDate => $state.composableBuilder(
      column: $state.table.closeDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get loanType => $state.composableBuilder(
      column: $state.table.loanType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get loanAmount => $state.composableBuilder(
      column: $state.table.loanAmount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get secondInterestRate => $state.composableBuilder(
      column: $state.table.secondInterestRate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get loanTerm => $state.composableBuilder(
      column: $state.table.loanTerm,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get repaymentMethod => $state.composableBuilder(
      column: $state.table.repaymentMethod,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get firstPaymentDate => $state.composableBuilder(
      column: $state.table.firstPaymentDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get remainingPrincipal => $state.composableBuilder(
      column: $state.table.remainingPrincipal,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get monthlyPayment => $state.composableBuilder(
      column: $state.table.monthlyPayment,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isRecurringPayment => $state.composableBuilder(
      column: $state.table.isRecurringPayment,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get iconName => $state.composableBuilder(
      column: $state.table.iconName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isDefault => $state.composableBuilder(
      column: $state.table.isDefault,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isHidden => $state.composableBuilder(
      column: $state.table.isHidden,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get tags => $state.composableBuilder(
      column: $state.table.tags,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get creationDate => $state.composableBuilder(
      column: $state.table.creationDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updateDate => $state.composableBuilder(
      column: $state.table.updateDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get syncProvider => $state.composableBuilder(
      column: $state.table.syncProvider,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get syncAccountId => $state.composableBuilder(
      column: $state.table.syncAccountId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastSyncDate => $state.composableBuilder(
      column: $state.table.lastSyncDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$EnvelopeBudgetsTableCreateCompanionBuilder = EnvelopeBudgetsCompanion
    Function({
  required String id,
  required String name,
  Value<String?> description,
  required String category,
  required double allocatedAmount,
  Value<double> spentAmount,
  required String period,
  required DateTime startDate,
  required DateTime endDate,
  required String status,
  Value<String?> color,
  Value<String?> iconName,
  Value<bool> isEssential,
  Value<double?> warningThreshold,
  Value<double?> limitThreshold,
  required String tags,
  required DateTime creationDate,
  required DateTime updateDate,
  Value<int> rowid,
});
typedef $$EnvelopeBudgetsTableUpdateCompanionBuilder = EnvelopeBudgetsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String> category,
  Value<double> allocatedAmount,
  Value<double> spentAmount,
  Value<String> period,
  Value<DateTime> startDate,
  Value<DateTime> endDate,
  Value<String> status,
  Value<String?> color,
  Value<String?> iconName,
  Value<bool> isEssential,
  Value<double?> warningThreshold,
  Value<double?> limitThreshold,
  Value<String> tags,
  Value<DateTime> creationDate,
  Value<DateTime> updateDate,
  Value<int> rowid,
});

class $$EnvelopeBudgetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EnvelopeBudgetsTable,
    EnvelopeBudget,
    $$EnvelopeBudgetsTableFilterComposer,
    $$EnvelopeBudgetsTableOrderingComposer,
    $$EnvelopeBudgetsTableCreateCompanionBuilder,
    $$EnvelopeBudgetsTableUpdateCompanionBuilder> {
  $$EnvelopeBudgetsTableTableManager(
      _$AppDatabase db, $EnvelopeBudgetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$EnvelopeBudgetsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$EnvelopeBudgetsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<double> allocatedAmount = const Value.absent(),
            Value<double> spentAmount = const Value.absent(),
            Value<String> period = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime> endDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<String?> iconName = const Value.absent(),
            Value<bool> isEssential = const Value.absent(),
            Value<double?> warningThreshold = const Value.absent(),
            Value<double?> limitThreshold = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<DateTime> creationDate = const Value.absent(),
            Value<DateTime> updateDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EnvelopeBudgetsCompanion(
            id: id,
            name: name,
            description: description,
            category: category,
            allocatedAmount: allocatedAmount,
            spentAmount: spentAmount,
            period: period,
            startDate: startDate,
            endDate: endDate,
            status: status,
            color: color,
            iconName: iconName,
            isEssential: isEssential,
            warningThreshold: warningThreshold,
            limitThreshold: limitThreshold,
            tags: tags,
            creationDate: creationDate,
            updateDate: updateDate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            required String category,
            required double allocatedAmount,
            Value<double> spentAmount = const Value.absent(),
            required String period,
            required DateTime startDate,
            required DateTime endDate,
            required String status,
            Value<String?> color = const Value.absent(),
            Value<String?> iconName = const Value.absent(),
            Value<bool> isEssential = const Value.absent(),
            Value<double?> warningThreshold = const Value.absent(),
            Value<double?> limitThreshold = const Value.absent(),
            required String tags,
            required DateTime creationDate,
            required DateTime updateDate,
            Value<int> rowid = const Value.absent(),
          }) =>
              EnvelopeBudgetsCompanion.insert(
            id: id,
            name: name,
            description: description,
            category: category,
            allocatedAmount: allocatedAmount,
            spentAmount: spentAmount,
            period: period,
            startDate: startDate,
            endDate: endDate,
            status: status,
            color: color,
            iconName: iconName,
            isEssential: isEssential,
            warningThreshold: warningThreshold,
            limitThreshold: limitThreshold,
            tags: tags,
            creationDate: creationDate,
            updateDate: updateDate,
            rowid: rowid,
          ),
        ));
}

class $$EnvelopeBudgetsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $EnvelopeBudgetsTable> {
  $$EnvelopeBudgetsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get allocatedAmount => $state.composableBuilder(
      column: $state.table.allocatedAmount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get spentAmount => $state.composableBuilder(
      column: $state.table.spentAmount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get period => $state.composableBuilder(
      column: $state.table.period,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get startDate => $state.composableBuilder(
      column: $state.table.startDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get endDate => $state.composableBuilder(
      column: $state.table.endDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get iconName => $state.composableBuilder(
      column: $state.table.iconName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isEssential => $state.composableBuilder(
      column: $state.table.isEssential,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get warningThreshold => $state.composableBuilder(
      column: $state.table.warningThreshold,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get limitThreshold => $state.composableBuilder(
      column: $state.table.limitThreshold,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get tags => $state.composableBuilder(
      column: $state.table.tags,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get creationDate => $state.composableBuilder(
      column: $state.table.creationDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updateDate => $state.composableBuilder(
      column: $state.table.updateDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$EnvelopeBudgetsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $EnvelopeBudgetsTable> {
  $$EnvelopeBudgetsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get allocatedAmount => $state.composableBuilder(
      column: $state.table.allocatedAmount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get spentAmount => $state.composableBuilder(
      column: $state.table.spentAmount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get period => $state.composableBuilder(
      column: $state.table.period,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get startDate => $state.composableBuilder(
      column: $state.table.startDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get endDate => $state.composableBuilder(
      column: $state.table.endDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get iconName => $state.composableBuilder(
      column: $state.table.iconName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isEssential => $state.composableBuilder(
      column: $state.table.isEssential,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get warningThreshold => $state.composableBuilder(
      column: $state.table.warningThreshold,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get limitThreshold => $state.composableBuilder(
      column: $state.table.limitThreshold,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get tags => $state.composableBuilder(
      column: $state.table.tags,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get creationDate => $state.composableBuilder(
      column: $state.table.creationDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updateDate => $state.composableBuilder(
      column: $state.table.updateDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ZeroBasedBudgetsTableCreateCompanionBuilder
    = ZeroBasedBudgetsCompanion Function({
  required String id,
  required String name,
  Value<String?> description,
  required double totalIncome,
  Value<double> totalAllocated,
  required String envelopes,
  required String period,
  required DateTime startDate,
  required DateTime endDate,
  required String status,
  required DateTime creationDate,
  required DateTime updateDate,
  Value<int> rowid,
});
typedef $$ZeroBasedBudgetsTableUpdateCompanionBuilder
    = ZeroBasedBudgetsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<double> totalIncome,
  Value<double> totalAllocated,
  Value<String> envelopes,
  Value<String> period,
  Value<DateTime> startDate,
  Value<DateTime> endDate,
  Value<String> status,
  Value<DateTime> creationDate,
  Value<DateTime> updateDate,
  Value<int> rowid,
});

class $$ZeroBasedBudgetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ZeroBasedBudgetsTable,
    ZeroBasedBudget,
    $$ZeroBasedBudgetsTableFilterComposer,
    $$ZeroBasedBudgetsTableOrderingComposer,
    $$ZeroBasedBudgetsTableCreateCompanionBuilder,
    $$ZeroBasedBudgetsTableUpdateCompanionBuilder> {
  $$ZeroBasedBudgetsTableTableManager(
      _$AppDatabase db, $ZeroBasedBudgetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ZeroBasedBudgetsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ZeroBasedBudgetsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<double> totalIncome = const Value.absent(),
            Value<double> totalAllocated = const Value.absent(),
            Value<String> envelopes = const Value.absent(),
            Value<String> period = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime> endDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> creationDate = const Value.absent(),
            Value<DateTime> updateDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ZeroBasedBudgetsCompanion(
            id: id,
            name: name,
            description: description,
            totalIncome: totalIncome,
            totalAllocated: totalAllocated,
            envelopes: envelopes,
            period: period,
            startDate: startDate,
            endDate: endDate,
            status: status,
            creationDate: creationDate,
            updateDate: updateDate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            required double totalIncome,
            Value<double> totalAllocated = const Value.absent(),
            required String envelopes,
            required String period,
            required DateTime startDate,
            required DateTime endDate,
            required String status,
            required DateTime creationDate,
            required DateTime updateDate,
            Value<int> rowid = const Value.absent(),
          }) =>
              ZeroBasedBudgetsCompanion.insert(
            id: id,
            name: name,
            description: description,
            totalIncome: totalIncome,
            totalAllocated: totalAllocated,
            envelopes: envelopes,
            period: period,
            startDate: startDate,
            endDate: endDate,
            status: status,
            creationDate: creationDate,
            updateDate: updateDate,
            rowid: rowid,
          ),
        ));
}

class $$ZeroBasedBudgetsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ZeroBasedBudgetsTable> {
  $$ZeroBasedBudgetsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get totalIncome => $state.composableBuilder(
      column: $state.table.totalIncome,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get totalAllocated => $state.composableBuilder(
      column: $state.table.totalAllocated,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get envelopes => $state.composableBuilder(
      column: $state.table.envelopes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get period => $state.composableBuilder(
      column: $state.table.period,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get startDate => $state.composableBuilder(
      column: $state.table.startDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get endDate => $state.composableBuilder(
      column: $state.table.endDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get creationDate => $state.composableBuilder(
      column: $state.table.creationDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updateDate => $state.composableBuilder(
      column: $state.table.updateDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ZeroBasedBudgetsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ZeroBasedBudgetsTable> {
  $$ZeroBasedBudgetsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get totalIncome => $state.composableBuilder(
      column: $state.table.totalIncome,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get totalAllocated => $state.composableBuilder(
      column: $state.table.totalAllocated,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get envelopes => $state.composableBuilder(
      column: $state.table.envelopes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get period => $state.composableBuilder(
      column: $state.table.period,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get startDate => $state.composableBuilder(
      column: $state.table.startDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get endDate => $state.composableBuilder(
      column: $state.table.endDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get creationDate => $state.composableBuilder(
      column: $state.table.creationDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updateDate => $state.composableBuilder(
      column: $state.table.updateDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$SalaryIncomesTableCreateCompanionBuilder = SalaryIncomesCompanion
    Function({
  required String id,
  required String name,
  Value<String?> description,
  required double basicSalary,
  Value<String?> salaryHistory,
  Value<double> housingAllowance,
  Value<double> mealAllowance,
  Value<double> transportationAllowance,
  Value<double> otherAllowance,
  Value<String?> monthlyAllowances,
  required String bonuses,
  Value<double> personalIncomeTax,
  Value<double> socialInsurance,
  Value<double> housingFund,
  Value<double> otherDeductions,
  Value<double> specialDeductionMonthly,
  Value<double> otherTaxDeductions,
  required int salaryDay,
  required String period,
  Value<DateTime?> lastSalaryDate,
  Value<DateTime?> nextSalaryDate,
  required String incomeType,
  required DateTime creationDate,
  required DateTime updateDate,
  Value<int> rowid,
});
typedef $$SalaryIncomesTableUpdateCompanionBuilder = SalaryIncomesCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<double> basicSalary,
  Value<String?> salaryHistory,
  Value<double> housingAllowance,
  Value<double> mealAllowance,
  Value<double> transportationAllowance,
  Value<double> otherAllowance,
  Value<String?> monthlyAllowances,
  Value<String> bonuses,
  Value<double> personalIncomeTax,
  Value<double> socialInsurance,
  Value<double> housingFund,
  Value<double> otherDeductions,
  Value<double> specialDeductionMonthly,
  Value<double> otherTaxDeductions,
  Value<int> salaryDay,
  Value<String> period,
  Value<DateTime?> lastSalaryDate,
  Value<DateTime?> nextSalaryDate,
  Value<String> incomeType,
  Value<DateTime> creationDate,
  Value<DateTime> updateDate,
  Value<int> rowid,
});

class $$SalaryIncomesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SalaryIncomesTable,
    SalaryIncome,
    $$SalaryIncomesTableFilterComposer,
    $$SalaryIncomesTableOrderingComposer,
    $$SalaryIncomesTableCreateCompanionBuilder,
    $$SalaryIncomesTableUpdateCompanionBuilder> {
  $$SalaryIncomesTableTableManager(_$AppDatabase db, $SalaryIncomesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SalaryIncomesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$SalaryIncomesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<double> basicSalary = const Value.absent(),
            Value<String?> salaryHistory = const Value.absent(),
            Value<double> housingAllowance = const Value.absent(),
            Value<double> mealAllowance = const Value.absent(),
            Value<double> transportationAllowance = const Value.absent(),
            Value<double> otherAllowance = const Value.absent(),
            Value<String?> monthlyAllowances = const Value.absent(),
            Value<String> bonuses = const Value.absent(),
            Value<double> personalIncomeTax = const Value.absent(),
            Value<double> socialInsurance = const Value.absent(),
            Value<double> housingFund = const Value.absent(),
            Value<double> otherDeductions = const Value.absent(),
            Value<double> specialDeductionMonthly = const Value.absent(),
            Value<double> otherTaxDeductions = const Value.absent(),
            Value<int> salaryDay = const Value.absent(),
            Value<String> period = const Value.absent(),
            Value<DateTime?> lastSalaryDate = const Value.absent(),
            Value<DateTime?> nextSalaryDate = const Value.absent(),
            Value<String> incomeType = const Value.absent(),
            Value<DateTime> creationDate = const Value.absent(),
            Value<DateTime> updateDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SalaryIncomesCompanion(
            id: id,
            name: name,
            description: description,
            basicSalary: basicSalary,
            salaryHistory: salaryHistory,
            housingAllowance: housingAllowance,
            mealAllowance: mealAllowance,
            transportationAllowance: transportationAllowance,
            otherAllowance: otherAllowance,
            monthlyAllowances: monthlyAllowances,
            bonuses: bonuses,
            personalIncomeTax: personalIncomeTax,
            socialInsurance: socialInsurance,
            housingFund: housingFund,
            otherDeductions: otherDeductions,
            specialDeductionMonthly: specialDeductionMonthly,
            otherTaxDeductions: otherTaxDeductions,
            salaryDay: salaryDay,
            period: period,
            lastSalaryDate: lastSalaryDate,
            nextSalaryDate: nextSalaryDate,
            incomeType: incomeType,
            creationDate: creationDate,
            updateDate: updateDate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            required double basicSalary,
            Value<String?> salaryHistory = const Value.absent(),
            Value<double> housingAllowance = const Value.absent(),
            Value<double> mealAllowance = const Value.absent(),
            Value<double> transportationAllowance = const Value.absent(),
            Value<double> otherAllowance = const Value.absent(),
            Value<String?> monthlyAllowances = const Value.absent(),
            required String bonuses,
            Value<double> personalIncomeTax = const Value.absent(),
            Value<double> socialInsurance = const Value.absent(),
            Value<double> housingFund = const Value.absent(),
            Value<double> otherDeductions = const Value.absent(),
            Value<double> specialDeductionMonthly = const Value.absent(),
            Value<double> otherTaxDeductions = const Value.absent(),
            required int salaryDay,
            required String period,
            Value<DateTime?> lastSalaryDate = const Value.absent(),
            Value<DateTime?> nextSalaryDate = const Value.absent(),
            required String incomeType,
            required DateTime creationDate,
            required DateTime updateDate,
            Value<int> rowid = const Value.absent(),
          }) =>
              SalaryIncomesCompanion.insert(
            id: id,
            name: name,
            description: description,
            basicSalary: basicSalary,
            salaryHistory: salaryHistory,
            housingAllowance: housingAllowance,
            mealAllowance: mealAllowance,
            transportationAllowance: transportationAllowance,
            otherAllowance: otherAllowance,
            monthlyAllowances: monthlyAllowances,
            bonuses: bonuses,
            personalIncomeTax: personalIncomeTax,
            socialInsurance: socialInsurance,
            housingFund: housingFund,
            otherDeductions: otherDeductions,
            specialDeductionMonthly: specialDeductionMonthly,
            otherTaxDeductions: otherTaxDeductions,
            salaryDay: salaryDay,
            period: period,
            lastSalaryDate: lastSalaryDate,
            nextSalaryDate: nextSalaryDate,
            incomeType: incomeType,
            creationDate: creationDate,
            updateDate: updateDate,
            rowid: rowid,
          ),
        ));
}

class $$SalaryIncomesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $SalaryIncomesTable> {
  $$SalaryIncomesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get basicSalary => $state.composableBuilder(
      column: $state.table.basicSalary,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get salaryHistory => $state.composableBuilder(
      column: $state.table.salaryHistory,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get housingAllowance => $state.composableBuilder(
      column: $state.table.housingAllowance,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get mealAllowance => $state.composableBuilder(
      column: $state.table.mealAllowance,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get transportationAllowance => $state.composableBuilder(
      column: $state.table.transportationAllowance,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get otherAllowance => $state.composableBuilder(
      column: $state.table.otherAllowance,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get monthlyAllowances => $state.composableBuilder(
      column: $state.table.monthlyAllowances,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get bonuses => $state.composableBuilder(
      column: $state.table.bonuses,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get personalIncomeTax => $state.composableBuilder(
      column: $state.table.personalIncomeTax,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get socialInsurance => $state.composableBuilder(
      column: $state.table.socialInsurance,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get housingFund => $state.composableBuilder(
      column: $state.table.housingFund,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get otherDeductions => $state.composableBuilder(
      column: $state.table.otherDeductions,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get specialDeductionMonthly => $state.composableBuilder(
      column: $state.table.specialDeductionMonthly,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get otherTaxDeductions => $state.composableBuilder(
      column: $state.table.otherTaxDeductions,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get salaryDay => $state.composableBuilder(
      column: $state.table.salaryDay,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get period => $state.composableBuilder(
      column: $state.table.period,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastSalaryDate => $state.composableBuilder(
      column: $state.table.lastSalaryDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get nextSalaryDate => $state.composableBuilder(
      column: $state.table.nextSalaryDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get incomeType => $state.composableBuilder(
      column: $state.table.incomeType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get creationDate => $state.composableBuilder(
      column: $state.table.creationDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updateDate => $state.composableBuilder(
      column: $state.table.updateDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$SalaryIncomesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $SalaryIncomesTable> {
  $$SalaryIncomesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get basicSalary => $state.composableBuilder(
      column: $state.table.basicSalary,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get salaryHistory => $state.composableBuilder(
      column: $state.table.salaryHistory,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get housingAllowance => $state.composableBuilder(
      column: $state.table.housingAllowance,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get mealAllowance => $state.composableBuilder(
      column: $state.table.mealAllowance,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get transportationAllowance =>
      $state.composableBuilder(
          column: $state.table.transportationAllowance,
          builder: (column, joinBuilders) =>
              ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get otherAllowance => $state.composableBuilder(
      column: $state.table.otherAllowance,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get monthlyAllowances => $state.composableBuilder(
      column: $state.table.monthlyAllowances,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get bonuses => $state.composableBuilder(
      column: $state.table.bonuses,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get personalIncomeTax => $state.composableBuilder(
      column: $state.table.personalIncomeTax,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get socialInsurance => $state.composableBuilder(
      column: $state.table.socialInsurance,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get housingFund => $state.composableBuilder(
      column: $state.table.housingFund,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get otherDeductions => $state.composableBuilder(
      column: $state.table.otherDeductions,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get specialDeductionMonthly =>
      $state.composableBuilder(
          column: $state.table.specialDeductionMonthly,
          builder: (column, joinBuilders) =>
              ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get otherTaxDeductions => $state.composableBuilder(
      column: $state.table.otherTaxDeductions,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get salaryDay => $state.composableBuilder(
      column: $state.table.salaryDay,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get period => $state.composableBuilder(
      column: $state.table.period,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastSalaryDate => $state.composableBuilder(
      column: $state.table.lastSalaryDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get nextSalaryDate => $state.composableBuilder(
      column: $state.table.nextSalaryDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get incomeType => $state.composableBuilder(
      column: $state.table.incomeType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get creationDate => $state.composableBuilder(
      column: $state.table.creationDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updateDate => $state.composableBuilder(
      column: $state.table.updateDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$AssetHistoriesTableCreateCompanionBuilder = AssetHistoriesCompanion
    Function({
  required String id,
  required String assetId,
  required String action,
  required String description,
  Value<String?> previousState,
  Value<String?> newState,
  required DateTime timestamp,
  Value<String?> userId,
  Value<int> rowid,
});
typedef $$AssetHistoriesTableUpdateCompanionBuilder = AssetHistoriesCompanion
    Function({
  Value<String> id,
  Value<String> assetId,
  Value<String> action,
  Value<String> description,
  Value<String?> previousState,
  Value<String?> newState,
  Value<DateTime> timestamp,
  Value<String?> userId,
  Value<int> rowid,
});

class $$AssetHistoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AssetHistoriesTable,
    AssetHistory,
    $$AssetHistoriesTableFilterComposer,
    $$AssetHistoriesTableOrderingComposer,
    $$AssetHistoriesTableCreateCompanionBuilder,
    $$AssetHistoriesTableUpdateCompanionBuilder> {
  $$AssetHistoriesTableTableManager(
      _$AppDatabase db, $AssetHistoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AssetHistoriesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AssetHistoriesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> assetId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String?> previousState = const Value.absent(),
            Value<String?> newState = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssetHistoriesCompanion(
            id: id,
            assetId: assetId,
            action: action,
            description: description,
            previousState: previousState,
            newState: newState,
            timestamp: timestamp,
            userId: userId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String assetId,
            required String action,
            required String description,
            Value<String?> previousState = const Value.absent(),
            Value<String?> newState = const Value.absent(),
            required DateTime timestamp,
            Value<String?> userId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssetHistoriesCompanion.insert(
            id: id,
            assetId: assetId,
            action: action,
            description: description,
            previousState: previousState,
            newState: newState,
            timestamp: timestamp,
            userId: userId,
            rowid: rowid,
          ),
        ));
}

class $$AssetHistoriesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AssetHistoriesTable> {
  $$AssetHistoriesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get assetId => $state.composableBuilder(
      column: $state.table.assetId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get action => $state.composableBuilder(
      column: $state.table.action,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get previousState => $state.composableBuilder(
      column: $state.table.previousState,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get newState => $state.composableBuilder(
      column: $state.table.newState,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$AssetHistoriesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AssetHistoriesTable> {
  $$AssetHistoriesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get assetId => $state.composableBuilder(
      column: $state.table.assetId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get action => $state.composableBuilder(
      column: $state.table.action,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get previousState => $state.composableBuilder(
      column: $state.table.previousState,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get newState => $state.composableBuilder(
      column: $state.table.newState,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ExpensePlansTableCreateCompanionBuilder = ExpensePlansCompanion
    Function({
  required String id,
  required String name,
  Value<String?> description,
  required String category,
  required double targetAmount,
  Value<double> currentAmount,
  required String period,
  required DateTime startDate,
  required DateTime endDate,
  required String status,
  required DateTime creationDate,
  required DateTime updateDate,
  Value<int> rowid,
});
typedef $$ExpensePlansTableUpdateCompanionBuilder = ExpensePlansCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String> category,
  Value<double> targetAmount,
  Value<double> currentAmount,
  Value<String> period,
  Value<DateTime> startDate,
  Value<DateTime> endDate,
  Value<String> status,
  Value<DateTime> creationDate,
  Value<DateTime> updateDate,
  Value<int> rowid,
});

class $$ExpensePlansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExpensePlansTable,
    ExpensePlan,
    $$ExpensePlansTableFilterComposer,
    $$ExpensePlansTableOrderingComposer,
    $$ExpensePlansTableCreateCompanionBuilder,
    $$ExpensePlansTableUpdateCompanionBuilder> {
  $$ExpensePlansTableTableManager(_$AppDatabase db, $ExpensePlansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ExpensePlansTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ExpensePlansTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<double> targetAmount = const Value.absent(),
            Value<double> currentAmount = const Value.absent(),
            Value<String> period = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime> endDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> creationDate = const Value.absent(),
            Value<DateTime> updateDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpensePlansCompanion(
            id: id,
            name: name,
            description: description,
            category: category,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            period: period,
            startDate: startDate,
            endDate: endDate,
            status: status,
            creationDate: creationDate,
            updateDate: updateDate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            required String category,
            required double targetAmount,
            Value<double> currentAmount = const Value.absent(),
            required String period,
            required DateTime startDate,
            required DateTime endDate,
            required String status,
            required DateTime creationDate,
            required DateTime updateDate,
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpensePlansCompanion.insert(
            id: id,
            name: name,
            description: description,
            category: category,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            period: period,
            startDate: startDate,
            endDate: endDate,
            status: status,
            creationDate: creationDate,
            updateDate: updateDate,
            rowid: rowid,
          ),
        ));
}

class $$ExpensePlansTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ExpensePlansTable> {
  $$ExpensePlansTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get targetAmount => $state.composableBuilder(
      column: $state.table.targetAmount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get currentAmount => $state.composableBuilder(
      column: $state.table.currentAmount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get period => $state.composableBuilder(
      column: $state.table.period,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get startDate => $state.composableBuilder(
      column: $state.table.startDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get endDate => $state.composableBuilder(
      column: $state.table.endDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get creationDate => $state.composableBuilder(
      column: $state.table.creationDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updateDate => $state.composableBuilder(
      column: $state.table.updateDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ExpensePlansTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ExpensePlansTable> {
  $$ExpensePlansTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get category => $state.composableBuilder(
      column: $state.table.category,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get targetAmount => $state.composableBuilder(
      column: $state.table.targetAmount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get currentAmount => $state.composableBuilder(
      column: $state.table.currentAmount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get period => $state.composableBuilder(
      column: $state.table.period,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get startDate => $state.composableBuilder(
      column: $state.table.startDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get endDate => $state.composableBuilder(
      column: $state.table.endDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get creationDate => $state.composableBuilder(
      column: $state.table.creationDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updateDate => $state.composableBuilder(
      column: $state.table.updateDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$IncomePlansTableCreateCompanionBuilder = IncomePlansCompanion
    Function({
  required String id,
  required String name,
  Value<String?> description,
  required String incomeType,
  required double targetAmount,
  Value<double> currentAmount,
  required String period,
  required DateTime startDate,
  required DateTime endDate,
  required String status,
  required DateTime creationDate,
  required DateTime updateDate,
  Value<int> rowid,
});
typedef $$IncomePlansTableUpdateCompanionBuilder = IncomePlansCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String> incomeType,
  Value<double> targetAmount,
  Value<double> currentAmount,
  Value<String> period,
  Value<DateTime> startDate,
  Value<DateTime> endDate,
  Value<String> status,
  Value<DateTime> creationDate,
  Value<DateTime> updateDate,
  Value<int> rowid,
});

class $$IncomePlansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $IncomePlansTable,
    IncomePlan,
    $$IncomePlansTableFilterComposer,
    $$IncomePlansTableOrderingComposer,
    $$IncomePlansTableCreateCompanionBuilder,
    $$IncomePlansTableUpdateCompanionBuilder> {
  $$IncomePlansTableTableManager(_$AppDatabase db, $IncomePlansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$IncomePlansTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$IncomePlansTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> incomeType = const Value.absent(),
            Value<double> targetAmount = const Value.absent(),
            Value<double> currentAmount = const Value.absent(),
            Value<String> period = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime> endDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> creationDate = const Value.absent(),
            Value<DateTime> updateDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              IncomePlansCompanion(
            id: id,
            name: name,
            description: description,
            incomeType: incomeType,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            period: period,
            startDate: startDate,
            endDate: endDate,
            status: status,
            creationDate: creationDate,
            updateDate: updateDate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            required String incomeType,
            required double targetAmount,
            Value<double> currentAmount = const Value.absent(),
            required String period,
            required DateTime startDate,
            required DateTime endDate,
            required String status,
            required DateTime creationDate,
            required DateTime updateDate,
            Value<int> rowid = const Value.absent(),
          }) =>
              IncomePlansCompanion.insert(
            id: id,
            name: name,
            description: description,
            incomeType: incomeType,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            period: period,
            startDate: startDate,
            endDate: endDate,
            status: status,
            creationDate: creationDate,
            updateDate: updateDate,
            rowid: rowid,
          ),
        ));
}

class $$IncomePlansTableFilterComposer
    extends FilterComposer<_$AppDatabase, $IncomePlansTable> {
  $$IncomePlansTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get incomeType => $state.composableBuilder(
      column: $state.table.incomeType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get targetAmount => $state.composableBuilder(
      column: $state.table.targetAmount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get currentAmount => $state.composableBuilder(
      column: $state.table.currentAmount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get period => $state.composableBuilder(
      column: $state.table.period,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get startDate => $state.composableBuilder(
      column: $state.table.startDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get endDate => $state.composableBuilder(
      column: $state.table.endDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get creationDate => $state.composableBuilder(
      column: $state.table.creationDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updateDate => $state.composableBuilder(
      column: $state.table.updateDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$IncomePlansTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $IncomePlansTable> {
  $$IncomePlansTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get incomeType => $state.composableBuilder(
      column: $state.table.incomeType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get targetAmount => $state.composableBuilder(
      column: $state.table.targetAmount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get currentAmount => $state.composableBuilder(
      column: $state.table.currentAmount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get period => $state.composableBuilder(
      column: $state.table.period,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get startDate => $state.composableBuilder(
      column: $state.table.startDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get endDate => $state.composableBuilder(
      column: $state.table.endDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get creationDate => $state.composableBuilder(
      column: $state.table.creationDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updateDate => $state.composableBuilder(
      column: $state.table.updateDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db, _db.assets);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$EnvelopeBudgetsTableTableManager get envelopeBudgets =>
      $$EnvelopeBudgetsTableTableManager(_db, _db.envelopeBudgets);
  $$ZeroBasedBudgetsTableTableManager get zeroBasedBudgets =>
      $$ZeroBasedBudgetsTableTableManager(_db, _db.zeroBasedBudgets);
  $$SalaryIncomesTableTableManager get salaryIncomes =>
      $$SalaryIncomesTableTableManager(_db, _db.salaryIncomes);
  $$AssetHistoriesTableTableManager get assetHistories =>
      $$AssetHistoriesTableTableManager(_db, _db.assetHistories);
  $$ExpensePlansTableTableManager get expensePlans =>
      $$ExpensePlansTableTableManager(_db, _db.expensePlans);
  $$IncomePlansTableTableManager get incomePlans =>
      $$IncomePlansTableTableManager(_db, _db.incomePlans);
}
