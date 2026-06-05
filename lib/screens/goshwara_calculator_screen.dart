import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';
import '../data/case_types.dart';
import '../data/goshwara_verification_options.dart';
import '../l10n/app_translations.dart';
import '../models/goshwara_case.dart';
import '../models/payment_entry.dart';
import '../models/saved_calculation.dart';
import '../services/calculation_storage_service.dart';
import '../services/export_service.dart';
import '../services/goshwara_calculator_service.dart';
import '../widgets/searchable_case_type_field.dart';
import '../widgets/calculation_results_table.dart';
import '../widgets/paid_amount_section.dart';
import '../widgets/fade_slide_in.dart';

class GoshwaraCalculatorScreen extends StatefulWidget {
  const GoshwaraCalculatorScreen({
    super.key,
    this.initialCalculation,
    this.onCalculationSaved,
  });

  final SavedCalculation? initialCalculation;
  final VoidCallback? onCalculationSaved;

  @override
  State<GoshwaraCalculatorScreen> createState() => _GoshwaraCalculatorScreenState();
}

class _GoshwaraCalculatorScreenState extends State<GoshwaraCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courtController       = TextEditingController();
  final _dowerController       = TextEditingController();
  final _dowerArticlesController = TextEditingController();
  final _caseNoController      = TextEditingController();
  final _person1Controller     = TextEditingController();
  final _person2Controller     = TextEditingController();
  final _personNameController  = TextEditingController();
  final _degreeAmountController = TextEditingController();
  final _percentageController  = TextEditingController();

  final _calculator    = GoshwaraCalculatorService();
  final _exportService = ExportService();
  final _dateFormat    = DateFormat('dd MMM yyyy');

  List<String> _caseTypes = List.from(defaultCaseTypes);
  String? _selectedCaseType;
  String? _selectedVerification = goshwaraVerificationOptions.first;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  List<PaymentEntry> _payments = [];
  GoshwaraCalculationResult? _result;
  bool _isExporting = false;
  String? _editingId;

  @override
  void initState() {
    super.initState();
    if (widget.initialCalculation != null) {
      _loadSavedCalculation(widget.initialCalculation!);
    }
  }

  void _loadSavedCalculation(SavedCalculation saved) {
    final input = saved.input;
    _editingId = saved.id;
    _courtController.text         = input.court;
    _dowerController.text         = input.dower ?? '';
    _dowerArticlesController.text = input.dowerArticles ?? '';
    _caseNoController.text        = input.caseNo;
    _splitTitle(input.title);
    _personNameController.text    = input.personName;
    _degreeAmountController.text  = input.degreeAmount.toString();
    _percentageController.text    = input.percentage.toString();
    _dateFrom             = input.dateFrom;
    _dateTo               = input.dateTo;
    _selectedVerification = input.verificationStatus;
    _payments             = List.from(saved.payments);
    if (!_caseTypes.contains(input.caseType)) {
      _caseTypes = [input.caseType, ..._caseTypes];
    }
    _selectedCaseType = input.caseType;

    final result = _calculator.calculate(input);
    if (result != null) _result = result.copyWith(payments: _payments);
  }

  void _splitTitle(String title) {
    final parts = title.split(' -- ');
    if (parts.length >= 2) {
      _person1Controller.text = parts.first.trim();
      _person2Controller.text = parts.sublist(1).join(' -- ').trim();
    } else {
      _person1Controller.text = title;
      _person2Controller.clear();
    }
  }

  @override
  void dispose() {
    _courtController.dispose();
    _dowerController.dispose();
    _dowerArticlesController.dispose();
    _caseNoController.dispose();
    _person1Controller.dispose();
    _person2Controller.dispose();
    _personNameController.dispose();
    _degreeAmountController.dispose();
    _percentageController.dispose();
    super.dispose();
  }

  String? _optionalText(String value) {
    final t = value.trim();
    return t.isEmpty ? null : t;
  }

  String get _title {
    final p1 = _person1Controller.text.trim();
    final p2 = _person2Controller.text.trim();
    if (p1.isEmpty && p2.isEmpty) return '';
    if (p1.isEmpty) return p2;
    if (p2.isEmpty) return p1;
    return '$p1 -- $p2';
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom ? (_dateFrom ?? DateTime.now()) : (_dateTo ?? _dateFrom ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _dateFrom = picked;
          if (_dateTo != null && _dateTo!.isBefore(picked)) _dateTo = picked;
        } else {
          _dateTo = picked;
        }
      });
    }
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_dateFrom == null || _dateTo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context, 'selectBothDates'))),
      );
      return;
    }

    final input = GoshwaraCaseInput(
      court:              _courtController.text.trim(),
      caseNo:             _caseNoController.text.trim(),
      title:              _title,
      caseType:           _selectedCaseType!,
      personName:         _personNameController.text.trim(),
      degreeAmount:       double.parse(_degreeAmountController.text.trim()),
      dateFrom:           _dateFrom!,
      dateTo:             _dateTo!,
      percentage:         double.parse(_percentageController.text.trim()),
      verificationStatus: _selectedVerification!,
      dower:              _optionalText(_dowerController.text),
      dowerArticles:      _optionalText(_dowerArticlesController.text),
    );

    final result = _calculator.calculate(input);
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context, 'unableToCalculate'))),
      );
      return;
    }

    final saved = SavedCalculation(
      id:      _editingId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      savedAt: DateTime.now(),
      input:   input,
      payments: List.from(_payments),
    );

    CalculationStorageService.instance.save(saved).then((_) {
      if (!mounted) return;
      setState(() {
        _editingId = saved.id;
        _result    = result.copyWith(payments: List.from(_payments));
      });
      widget.onCalculationSaved?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context, 'savedSuccess'))),
      );
    });
  }

  void _onPaymentsChanged(List<PaymentEntry> payments) {
    setState(() {
      _payments = payments;
      if (_result != null) _result = _result!.copyWith(payments: payments);
    });
  }

  void _reset() {
    _formKey.currentState?.reset();
    _courtController.clear();
    _dowerController.clear();
    _dowerArticlesController.clear();
    _caseNoController.clear();
    _person1Controller.clear();
    _person2Controller.clear();
    _personNameController.clear();
    _degreeAmountController.clear();
    _percentageController.clear();
    setState(() {
      _selectedCaseType     = null;
      _selectedVerification = goshwaraVerificationOptions.first;
      _dateFrom             = null;
      _dateTo               = null;
      _payments             = [];
      _result               = null;
      _editingId            = null;
    });
  }

  Future<void> _exportPdf() async {
    if (_result == null) return;
    setState(() => _isExporting = true);
    try {
      await _exportService.exportPdf(_result!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context, 'pdfReady'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeSlideIn(child: _buildHeader(context)),
              const SizedBox(height: 20),
              if (isWide)
                FadeSlideIn(
                  delay: const Duration(milliseconds: 100),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: _buildFormCard(context)),
                      const SizedBox(width: 20),
                      Expanded(flex: 5, child: _buildResultsSection(context)),
                    ],
                  ),
                )
              else ...[
                FadeSlideIn(
                  delay: const Duration(milliseconds: 100),
                  child: _buildFormCard(context),
                ),
                const SizedBox(height: 20),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 180),
                  child: _buildResultsSection(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary, AppTheme.accent],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.calculate_rounded, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context, 'calcTitle'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryTextOf(context),
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                S.of(context, 'calcSubtitle'),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerOf(context)),
        boxShadow: AppTheme.isDark(context) ? null : AppTheme.cardShadow,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section: Court Info
            _SectionHeader(
              icon: Icons.account_balance_rounded,
              title: S.of(context, 'courtInfo'),
              color: AppTheme.primary,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  TextFormField(
                    controller: _courtController,
                    decoration: InputDecoration(
                      labelText: S.of(context, 'inTheCourtOf'),
                      hintText: S.of(context, 'inTheCourtOfHint'),
                      prefixIcon: const Icon(Icons.account_balance_outlined),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? S.of(context, 'required') : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _dowerController,
                    decoration: InputDecoration(
                      labelText: S.of(context, 'dowerOptional'),
                      hintText: S.of(context, 'dowerHint'),
                      prefixIcon: const Icon(Icons.edit_note_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _dowerArticlesController,
                    decoration: InputDecoration(
                      labelText: S.of(context, 'dowerArticlesOptional'),
                      hintText: S.of(context, 'dowerArticlesHint'),
                      prefixIcon: const Icon(Icons.list_alt_outlined),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            // Section: Case Details
            _SectionHeader(
              icon: Icons.folder_copy_rounded,
              title: S.of(context, 'caseDetails'),
              color: AppTheme.accent,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  TextFormField(
                    controller: _caseNoController,
                    decoration: InputDecoration(
                      labelText: S.of(context, 'caseNo'),
                      hintText: S.of(context, 'caseNoHint'),
                      prefixIcon: const Icon(Icons.tag_rounded),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? S.of(context, 'required') : null,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _person1Controller,
                          decoration: InputDecoration(
                            labelText: S.of(context, 'decreeHolder'),
                            hintText: S.of(context, 'decreeHolderHint'),
                            prefixIcon: const Icon(Icons.person_outline_rounded),
                          ),
                          onChanged: (_) => setState(() {}),
                          validator: (v) => v == null || v.trim().isEmpty ? S.of(context, 'required') : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceOf(context),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.dividerOf(context)),
                          ),
                          child: Text(
                            S.of(context, 'vs'),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppTheme.primaryTextOf(context),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _person2Controller,
                          decoration: InputDecoration(
                            labelText: S.of(context, 'judgementDebtor'),
                            hintText: S.of(context, 'judgementDebtorHint'),
                            prefixIcon: const Icon(Icons.person_outline_rounded),
                          ),
                          onChanged: (_) => setState(() {}),
                          validator: (v) => v == null || v.trim().isEmpty ? S.of(context, 'required') : null,
                        ),
                      ),
                    ],
                  ),
                  if (_title.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.title_rounded, size: 14, color: AppTheme.primary.withValues(alpha: 0.7)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _title,
                              style: TextStyle(
                                color: AppTheme.primary.withValues(alpha: 0.8),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  SearchableCaseTypeField(
                    caseTypes: _caseTypes,
                    initialValue: _selectedCaseType,
                    onCustomTypeAdded: (type) {
                      setState(() {
                        if (!_caseTypes.contains(type)) _caseTypes.insert(0, type);
                        _selectedCaseType = type;
                      });
                    },
                    onSaved: (v) => _selectedCaseType = v,
                    validator: (v) => v == null || v.isEmpty ? S.of(context, 'selectCaseType') : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _personNameController,
                    decoration: InputDecoration(
                      labelText: S.of(context, 'personName'),
                      hintText: S.of(context, 'personNameHint'),
                      prefixIcon: const Icon(Icons.badge_outlined),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? S.of(context, 'required') : null,
                  ),
                ],
              ),
            ),

            // Section: Financial Details
            _SectionHeader(
              icon: Icons.payments_rounded,
              title: S.of(context, 'financialDetails'),
              color: AppTheme.gold,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  TextFormField(
                    controller: _degreeAmountController,
                    decoration: InputDecoration(
                      labelText: S.of(context, 'degreeAmount'),
                      hintText: '0.00',
                      prefixIcon: const Icon(Icons.payments_outlined),
                      prefixText: 'PKR ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return S.of(context, 'required');
                      if (double.tryParse(v) == null || double.parse(v) <= 0) {
                        return S.of(context, 'validAmount');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _dateField(
                          label: S.of(context, 'dateFrom'),
                          date: _dateFrom,
                          isFrom: true,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _dateField(
                          label: S.of(context, 'dateTo'),
                          date: _dateTo,
                          isFrom: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _percentageController,
                    decoration: InputDecoration(
                      labelText: S.of(context, 'annualIncrement'),
                      hintText: S.of(context, 'annualIncrementHint'),
                      prefixIcon: const Icon(Icons.trending_up_rounded),
                      suffixText: '%',
                      helperText: S.of(context, 'annualIncrementHelper'),
                      helperStyle: TextStyle(color: Colors.grey.shade500, fontSize: 11.5),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return S.of(context, 'required');
                      if (double.tryParse(v) == null) return S.of(context, 'validPercentage');
                      return null;
                    },
                  ),
                ],
              ),
            ),

            // Section: Payment Entries
            _SectionHeader(
              icon: Icons.receipt_long_rounded,
              title: S.of(context, 'paymentEntries'),
              color: AppTheme.accent,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: PaidAmountSection(
                payments: _payments,
                onPaymentsChanged: _onPaymentsChanged,
              ),
            ),

            // Section: Verification
            _SectionHeader(
              icon: Icons.verified_rounded,
              title: S.of(context, 'verificationStatusSection'),
              color: AppTheme.primary,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: DropdownButtonFormField<String>(
                value: _selectedVerification,
                decoration: InputDecoration(
                  labelText: S.of(context, 'goshwaraVerified'),
                  prefixIcon: const Icon(Icons.verified_outlined),
                ),
                items: goshwaraVerificationOptions
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedVerification = v),
                onSaved: (v) => _selectedVerification = v,
                validator: (v) =>
                    v == null || v.isEmpty ? S.of(context, 'selectVerification') : null,
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: _AnimatedCalculateButton(onPressed: _calculate),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(S.of(context, 'reset')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField({required String label, required DateTime? date, required bool isFrom}) {
    final hasDate = date != null;
    return InkWell(
      onTap: () => _pickDate(isFrom: isFrom),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            Icons.calendar_today_rounded,
            size: 18,
            color: hasDate ? AppTheme.accent : null,
          ),
        ),
        child: Text(
          hasDate ? _dateFormat.format(date!) : S.of(context, 'selectDate'),
          style: TextStyle(
            color: hasDate ? AppTheme.primaryTextOf(context) : Theme.of(context).hintColor,
            fontWeight: hasDate ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection(BuildContext context) {
    if (_result == null) {
      return Container(
        decoration: BoxDecoration(
          color: AppTheme.cardOf(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dividerOf(context)),
        ),
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceOf(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 40,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context, 'resultsPlaceholder'),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              S.of(context, 'resultsPlaceholderHint'),
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CalculationResultsTable(result: _result!),
        const SizedBox(height: 14),
        _buildPaymentSummaryCard(context),
        const SizedBox(height: 14),
        _ExportButton(isExporting: _isExporting, onPressed: _exportPdf),
      ],
    );
  }

  Widget _buildPaymentSummaryCard(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'PKR ', decimalDigits: 2);
    final result = _result!;

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
          _SectionHeader(
            icon: Icons.summarize_rounded,
            title: S.of(context, 'amountSummary'),
            color: AppTheme.primary,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                _summaryRow(context, S.of(context, 'totalAmountDue'), currency.format(result.grandTotal)),
                const SizedBox(height: 8),
                _summaryRow(context, S.of(context, 'totalPaid'), currency.format(result.totalPaid)),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        S.of(context, 'totalRemaining'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        currency.format(result.totalRemaining),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppTheme.mutedTextOf(context), fontSize: 13.5)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
            color: AppTheme.primaryTextOf(context),
          ),
        ),
      ],
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        border: Border(
          top: BorderSide(color: AppTheme.dividerOf(context)),
          bottom: BorderSide(color: color.withValues(alpha: 0.12)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated Calculate Button ─────────────────────────────────────────────────

class _AnimatedCalculateButton extends StatefulWidget {
  const _AnimatedCalculateButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_AnimatedCalculateButton> createState() => _AnimatedCalculateButtonState();
}

class _AnimatedCalculateButtonState extends State<_AnimatedCalculateButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryDark, AppTheme.primary],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _handleTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    S.of(context, 'calculate'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Export PDF Button ─────────────────────────────────────────────────────────

class _ExportButton extends StatelessWidget {
  const _ExportButton({required this.isExporting, required this.onPressed});

  final bool isExporting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.accent, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton.icon(
        onPressed: isExporting ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.accent,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        ),
        icon: isExporting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent),
              )
            : const Icon(Icons.picture_as_pdf_rounded, size: 20),
        label: Text(
          isExporting ? S.of(context, 'generatingPdf') : S.of(context, 'downloadPdf'),
          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
