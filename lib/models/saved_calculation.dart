import 'dart:convert';

import 'goshwara_case.dart';
import 'payment_entry.dart';

class SavedCalculation {
  const SavedCalculation({
    required this.id,
    required this.savedAt,
    required this.input,
    required this.payments,
  });

  final String id;
  final DateTime savedAt;
  final GoshwaraCaseInput input;
  final List<PaymentEntry> payments;

  Map<String, dynamic> toJson() => {
        'id': id,
        'savedAt': savedAt.toIso8601String(),
        'input': input.toJson(),
        'payments': payments.map((p) => p.toJson()).toList(),
      };

  factory SavedCalculation.fromJson(Map<String, dynamic> json) => SavedCalculation(
        id: json['id'] as String,
        savedAt: DateTime.parse(json['savedAt'] as String),
        input: GoshwaraCaseInput.fromJson(json['input'] as Map<String, dynamic>),
        payments: (json['payments'] as List<dynamic>)
            .map((e) => PaymentEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  String toJsonString() => jsonEncode(toJson());

  factory SavedCalculation.fromJsonString(String source) =>
      SavedCalculation.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
