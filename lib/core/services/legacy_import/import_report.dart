class ImportReportModuleStats {
  int total = 0;
  int imported = 0;
  int skipped = 0;
  int failed = 0;

  Map<String, dynamic> toJson() => {
        'total': total,
        'imported': imported,
        'skipped': skipped,
        'failed': failed,
      };
}

class ImportReport {
  final Map<String, ImportReportModuleStats> modules = {
    'assets': ImportReportModuleStats(),
    'accounts': ImportReportModuleStats(),
    'transactions': ImportReportModuleStats(),
    'budgets': ImportReportModuleStats(),
    'salary': ImportReportModuleStats(),
    'history': ImportReportModuleStats(),
  };

  final List<String> warnings = [];
  final List<String> errors = [];

  Map<String, dynamic> toJson() => {
        'modules': modules.map((k, v) => MapEntry(k, v.toJson())),
        'warnings': warnings,
        'errors': errors,
      };
}
