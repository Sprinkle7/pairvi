import 'dart:math';

import 'package:intl/intl.dart';

import '../models/goshwara_case.dart';

class GoshwaraCalculatorService {
  final _monthFormat = DateFormat('MMM');

  GoshwaraCalculationResult? calculate(GoshwaraCaseInput input) {
    if (input.degreeAmount <= 0) return null;
    if (input.dateTo.isBefore(input.dateFrom)) return null;

    final startYear = input.dateFrom.year;
    final rate = input.percentage / 100;
    final monthsByYear = <int, List<MonthlyCalculationRow>>{};

    var cursor = DateTime(input.dateFrom.year, input.dateFrom.month);
    final endMonth = DateTime(input.dateTo.year, input.dateTo.month);

    while (!cursor.isAfter(endMonth)) {
      final monthStart = DateTime(cursor.year, cursor.month);
      final monthEnd = DateTime(cursor.year, cursor.month + 1, 0);

      if (!monthEnd.isBefore(input.dateFrom) && !monthStart.isAfter(input.dateTo)) {
        final yearIndex = cursor.year - startYear;
        final monthlyAmount = input.degreeAmount * pow(1 + rate, yearIndex);

        monthsByYear.putIfAbsent(cursor.year, () => []).add(
              MonthlyCalculationRow(
                year: cursor.year,
                month: cursor.month,
                monthLabel: _monthFormat.format(monthStart),
                amount: monthlyAmount,
              ),
            );
      }

      cursor = DateTime(cursor.year, cursor.month + 1);
    }

    if (monthsByYear.isEmpty) return null;

    final yearGroups = monthsByYear.entries.map((entry) {
      final yearTotal = entry.value.fold<double>(0, (sum, row) => sum + row.amount);
      return YearlyCalculationGroup(
        year: entry.key,
        months: entry.value,
        yearTotal: yearTotal,
      );
    }).toList()
      ..sort((a, b) => a.year.compareTo(b.year));

    final grandTotal = yearGroups.fold<double>(0, (sum, group) => sum + group.yearTotal);

    return GoshwaraCalculationResult(
      input: input,
      yearGroups: yearGroups,
      grandTotal: grandTotal,
    );
  }
}
