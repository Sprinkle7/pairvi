class PaymentEntry {
  const PaymentEntry({
    this.date,
    required this.amount,
    required this.orderSheetNo,
  });

  final DateTime? date;
  final double amount;
  final String orderSheetNo;

  Map<String, dynamic> toJson() => {
        'date': date?.toIso8601String(),
        'amount': amount,
        'orderSheetNo': orderSheetNo,
      };

  factory PaymentEntry.fromJson(Map<String, dynamic> json) => PaymentEntry(
        date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
        amount: (json['amount'] as num).toDouble(),
        orderSheetNo: json['orderSheetNo'] as String,
      );
}
