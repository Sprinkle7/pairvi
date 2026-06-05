import 'payment_entry.dart';

class GoshwaraCaseInput {
  const GoshwaraCaseInput({
    required this.court,
    required this.caseNo,
    required this.title,
    required this.caseType,
    required this.personName,
    required this.degreeAmount,
    required this.dateFrom,
    required this.dateTo,
    required this.percentage,
    required this.verificationStatus,
    this.dower,
    this.dowerArticles,
  });

  final String court;
  final String caseNo;
  final String title;
  final String caseType;
  final String personName;
  final double degreeAmount;
  final DateTime dateFrom;
  final DateTime dateTo;
  final double percentage;
  final String verificationStatus;
  final String? dower;
  final String? dowerArticles;

  Map<String, dynamic> toJson() => {
        'court': court,
        'caseNo': caseNo,
        'title': title,
        'caseType': caseType,
        'personName': personName,
        'degreeAmount': degreeAmount,
        'dateFrom': dateFrom.toIso8601String(),
        'dateTo': dateTo.toIso8601String(),
        'percentage': percentage,
        'verificationStatus': verificationStatus,
        'dower': dower,
        'dowerArticles': dowerArticles,
      };

  factory GoshwaraCaseInput.fromJson(Map<String, dynamic> json) => GoshwaraCaseInput(
        court: json['court'] as String,
        caseNo: json['caseNo'] as String,
        title: json['title'] as String,
        caseType: json['caseType'] as String,
        personName: json['personName'] as String,
        degreeAmount: (json['degreeAmount'] as num).toDouble(),
        dateFrom: DateTime.parse(json['dateFrom'] as String),
        dateTo: DateTime.parse(json['dateTo'] as String),
        percentage: (json['percentage'] as num).toDouble(),
        verificationStatus: json['verificationStatus'] as String,
        dower: json['dower'] as String?,
        dowerArticles: json['dowerArticles'] as String?,
      );
}

class MonthlyCalculationRow {
  const MonthlyCalculationRow({
    required this.year,
    required this.month,
    required this.monthLabel,
    required this.amount,
  });

  final int year;
  final int month;
  final String monthLabel;
  final double amount;
}

class YearlyCalculationGroup {
  const YearlyCalculationGroup({
    required this.year,
    required this.months,
    required this.yearTotal,
  });

  final int year;
  final List<MonthlyCalculationRow> months;
  final double yearTotal;

  double get perMonthAmount => months.isEmpty ? 0 : months.first.amount;

  int get monthCount => months.length;

  bool get includesCurrentMonth {
    final now = DateTime.now();
    return months.any((m) => m.year == now.year && m.month == now.month);
  }
}

class GoshwaraCalculationResult {
  const GoshwaraCalculationResult({
    required this.input,
    required this.yearGroups,
    required this.grandTotal,
    this.payments = const [],
  });

  final GoshwaraCaseInput input;
  final List<YearlyCalculationGroup> yearGroups;
  final double grandTotal;
  final List<PaymentEntry> payments;

  double get totalPaid => payments.fold<double>(0, (sum, payment) => sum + payment.amount);

  double get totalRemaining => grandTotal - totalPaid;

  GoshwaraCalculationResult copyWith({List<PaymentEntry>? payments}) {
    return GoshwaraCalculationResult(
      input: input,
      yearGroups: yearGroups,
      grandTotal: grandTotal,
      payments: payments ?? this.payments,
    );
  }

  List<MonthlyCalculationRow> get allMonths =>
      yearGroups.expand((group) => group.months).toList();

  MonthlyCalculationRow? get currentMonth {
    final now = DateTime.now();
    for (final month in allMonths) {
      if (month.year == now.year && month.month == now.month) {
        return month;
      }
    }
    return null;
  }
}
