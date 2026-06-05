import 'package:flutter_test/flutter_test.dart';
import 'package:gushwarah/models/goshwara_case.dart';
import 'package:gushwarah/services/goshwara_calculator_service.dart';

void main() {
  final service = GoshwaraCalculatorService();

  test('each month uses full degree amount with yearly percent increment', () {
    final result = service.calculate(
      GoshwaraCaseInput(
        court: 'Session Court',
        caseNo: '1',
        title: 'Ali -- Amjad',
        caseType: 'Criminal',
        personName: 'Ali',
        degreeAmount: 1000,
        dateFrom: DateTime(2020, 1, 1),
        dateTo: DateTime(2021, 3, 31),
        percentage: 10,
        verificationStatus: 'By Court',
      ),
    );

    expect(result, isNotNull);
    expect(result!.yearGroups.length, 2);

    final year2020 = result.yearGroups.first;
    expect(year2020.year, 2020);
    expect(year2020.months.length, 12);
    expect(year2020.months.first.amount, closeTo(1000, 0.01));
    expect(year2020.yearTotal, closeTo(12000, 0.01));

    final year2021 = result.yearGroups.last;
    expect(year2021.year, 2021);
    expect(year2021.months.length, 3);
    expect(year2021.months.first.amount, closeTo(1100, 0.01));
    expect(year2021.yearTotal, closeTo(3300, 0.01));

    expect(result.grandTotal, closeTo(15300, 0.01));
  });

  test('respects partial months at start and end of range', () {
    final result = service.calculate(
      GoshwaraCaseInput(
        court: 'High Court',
        caseNo: '2',
        title: 'A -- B',
        caseType: 'Civil',
        personName: 'A',
        degreeAmount: 1000,
        dateFrom: DateTime(2020, 3, 15),
        dateTo: DateTime(2020, 5, 10),
        percentage: 0,
        verificationStatus: 'By Degree holder counsel',
      ),
    );

    expect(result, isNotNull);
    expect(result!.yearGroups.length, 1);
    expect(result.yearGroups.first.months.length, 3);
    expect(result.yearGroups.first.months.map((m) => m.monthLabel).toList(), ['Mar', 'Apr', 'May']);
    expect(result.yearGroups.first.yearTotal, closeTo(3000, 0.01));
    expect(result.grandTotal, closeTo(3000, 0.01));
  });
}
