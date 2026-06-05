import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';
import '../l10n/app_translations.dart';
import '../models/payment_entry.dart';

class PaidAmountSection extends StatefulWidget {
  const PaidAmountSection({
    super.key,
    required this.payments,
    required this.onPaymentsChanged,
  });

  final List<PaymentEntry> payments;
  final ValueChanged<List<PaymentEntry>> onPaymentsChanged;

  @override
  State<PaidAmountSection> createState() => _PaidAmountSectionState();
}

class _PaidAmountSectionState extends State<PaidAmountSection> {
  final _amountController = TextEditingController();
  final _orderSheetController = TextEditingController();
  final _dateFormat = DateFormat('dd MMM yyyy');
  DateTime? _paymentDate;

  @override
  void dispose() {
    _amountController.dispose();
    _orderSheetController.dispose();
    super.dispose();
  }

  Future<void> _pickPaymentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _paymentDate = picked);
  }

  void _addPayment() {
    final amountText = _amountController.text.trim();
    final orderSheet = _orderSheetController.text.trim();

    if (amountText.isEmpty || double.tryParse(amountText) == null || double.parse(amountText) <= 0) {
      _showMessage(S.of(context, 'validPaymentAmount'));
      return;
    }
    if (orderSheet.isEmpty) {
      _showMessage(S.of(context, 'orderSheetRequired'));
      return;
    }

    final updated = [
      ...widget.payments,
      PaymentEntry(
        date: _paymentDate,
        amount: double.parse(amountText),
        orderSheetNo: orderSheet,
      ),
    ]..sort(_comparePayments);

    widget.onPaymentsChanged(updated);
    _amountController.clear();
    _orderSheetController.clear();
    setState(() => _paymentDate = null);
  }

  void _removePayment(int index) {
    final updated = List<PaymentEntry>.from(widget.payments)..removeAt(index);
    widget.onPaymentsChanged(updated);
  }

  int _comparePayments(PaymentEntry a, PaymentEntry b) {
    if (a.date == null && b.date == null) return 0;
    if (a.date == null) return 1;
    if (b.date == null) return -1;
    return a.date!.compareTo(b.date!);
  }

  String _formatDate(DateTime? date) =>
      date != null ? _dateFormat.format(date) : S.of(context, 'noDate');

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'PKR ', decimalDigits: 2);
    final totalPaid = widget.payments.fold<double>(0, (s, p) => s + p.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: _pickPaymentDate,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: S.of(context, 'paymentDateOptional'),
              prefixIcon: Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: _paymentDate != null ? AppTheme.accent : null,
              ),
              suffixIcon: _paymentDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () => setState(() => _paymentDate = null),
                    )
                  : null,
            ),
            child: Text(
              _paymentDate != null
                  ? _dateFormat.format(_paymentDate!)
                  : S.of(context, 'selectDateOptional'),
              style: TextStyle(
                color: _paymentDate == null ? Theme.of(context).hintColor : AppTheme.primaryTextOf(context),
                fontWeight: _paymentDate != null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _amountController,
          decoration: InputDecoration(
            labelText: S.of(context, 'amountPaid'),
            hintText: '0.00',
            prefixIcon: const Icon(Icons.payments_outlined),
            prefixText: 'PKR ',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _orderSheetController,
          decoration: InputDecoration(
            labelText: S.of(context, 'orderSheetNo'),
            hintText: S.of(context, 'orderSheetHint'),
            prefixIcon: const Icon(Icons.description_outlined),
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: _addPayment,
          icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
          label: Text(S.of(context, 'addPaymentEntry')),
        ),
        if (widget.payments.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                '${S.of(context, 'entries')} (${widget.payments.length})',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: AppTheme.primaryTextOf(context),
                ),
              ),
              const Spacer(),
              Text(
                '${S.of(context, 'total')}: ${currency.format(totalPaid)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: AppTheme.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...widget.payments.asMap().entries.map((entry) {
            final payment = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceOf(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.dividerOf(context)),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    size: 18,
                    color: AppTheme.accent,
                  ),
                ),
                title: Text(
                  currency.format(payment.amount),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.primaryTextOf(context),
                  ),
                ),
                subtitle: Text(
                  '${_formatDate(payment.date)}  •  OS: ${payment.orderSheetNo}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  color: Colors.red.shade400,
                  onPressed: () => _removePayment(entry.key),
                  tooltip: S.of(context, 'remove'),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }),
        ],
      ],
    );
  }
}
