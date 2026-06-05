import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';
import '../l10n/app_translations.dart';
import '../models/goshwara_case.dart';

class CalculationResultsTable extends StatelessWidget {
  const CalculationResultsTable({super.key, required this.result});

  final GoshwaraCalculationResult result;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'PKR ', decimalDigits: 2);
    final hasCurrentYear = result.yearGroups.any((g) => g.includesCurrentMonth);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerOf(context)),
        boxShadow: AppTheme.isDark(context) ? null : AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.04),
              border: Border(
                bottom: BorderSide(color: AppTheme.primary.withValues(alpha: 0.12)),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppTheme.primary, AppTheme.accent],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.table_chart_rounded, size: 16, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  S.of(context, 'yearWiseSummary'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: AppTheme.primary,
                  ),
                ),
                if (hasCurrentYear) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppTheme.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          S.of(context, 'currentYearHighlighted'),
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      headingRowHeight: 42,
                      dataRowMinHeight: 44,
                      dataRowMaxHeight: 52,
                      horizontalMargin: 8,
                      columnSpacing: 24,
                      headingRowColor: WidgetStateProperty.all(AppTheme.surfaceOf(context)),
                      headingTextStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        color: AppTheme.primaryTextOf(context),
                        letterSpacing: 0.3,
                      ),
                      dataTextStyle: TextStyle(
                        fontSize: 13.5,
                        color: AppTheme.primaryTextOf(context),
                      ),
                      dividerThickness: 0,
                      columns: [
                        DataColumn(label: Text(S.of(context, 'year'))),
                        DataColumn(label: Text(S.of(context, 'perMonth')), numeric: true),
                        DataColumn(label: Text(S.of(context, 'months')), numeric: true),
                        DataColumn(label: Text(S.of(context, 'totalAmount')), numeric: true),
                      ],
                      rows: [
                        ...result.yearGroups.map((group) {
                          final isCurrent = group.includesCurrentMonth;
                          return DataRow(
                            color: WidgetStateProperty.all(
                              isCurrent
                                  ? AppTheme.accent.withValues(alpha: 0.08)
                                  : Colors.transparent,
                            ),
                            cells: [
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      group.year.toString(),
                                      style: TextStyle(
                                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                    if (isCurrent) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accent,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          S.of(context, 'now'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              DataCell(Text(
                                currency.format(group.perMonthAmount),
                                style: TextStyle(
                                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                                ),
                              )),
                              DataCell(Text(
                                group.monthCount.toString(),
                                style: TextStyle(
                                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                                ),
                              )),
                              DataCell(Text(
                                currency.format(group.yearTotal),
                                style: TextStyle(
                                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                                ),
                              )),
                            ],
                          );
                        }),
                        DataRow(
                          color: WidgetStateProperty.all(
                            AppTheme.primary.withValues(alpha: 0.07),
                          ),
                          cells: [
                            DataCell(
                              Text(
                                S.of(context, 'grandTotal'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryTextOf(context),
                                ),
                              ),
                            ),
                            const DataCell(Text('')),
                            DataCell(
                              Text(
                                result.allMonths.length.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryTextOf(context),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                currency.format(result.grandTotal),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primary,
                                  fontSize: 14.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
