import 'package:flutter/material.dart';

import '../l10n/app_translations.dart';

class SearchableCaseTypeField extends FormField<String> {
  SearchableCaseTypeField({
    super.key,
    required List<String> caseTypes,
    required void Function(String) onCustomTypeAdded,
    String? initialValue,
    super.onSaved,
    super.validator,
  }) : super(
          initialValue: initialValue,
          builder: (state) {
            return _SearchableCaseTypeFieldBody(
              caseTypes: caseTypes,
              value: state.value,
              errorText: state.errorText,
              onCustomTypeAdded: onCustomTypeAdded,
              onChanged: state.didChange,
            );
          },
        );
}

class _SearchableCaseTypeFieldBody extends StatelessWidget {
  const _SearchableCaseTypeFieldBody({
    required this.caseTypes,
    required this.value,
    required this.onChanged,
    required this.onCustomTypeAdded,
    this.errorText,
  });

  final List<String> caseTypes;
  final String? value;
  final String? errorText;
  final ValueChanged<String?> onChanged;
  final void Function(String) onCustomTypeAdded;

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _CaseTypePickerSheet(
        caseTypes: caseTypes,
        selected: value,
        onCustomTypeAdded: onCustomTypeAdded,
      ),
    );

    if (selected != null) {
      onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openPicker(context),
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: S.of(context, 'caseType'),
          hintText: S.of(context, 'selectCaseTypeHint'),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          errorText: errorText,
        ),
        child: Text(
          value ?? '',
          style: TextStyle(
            color: value == null ? Theme.of(context).hintColor : null,
          ),
        ),
      ),
    );
  }
}

class _CaseTypePickerSheet extends StatefulWidget {
  const _CaseTypePickerSheet({
    required this.caseTypes,
    required this.onCustomTypeAdded,
    this.selected,
  });

  final List<String> caseTypes;
  final String? selected;
  final void Function(String) onCustomTypeAdded;

  @override
  State<_CaseTypePickerSheet> createState() => _CaseTypePickerSheetState();
}

class _CaseTypePickerSheetState extends State<_CaseTypePickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filtered {
    if (_query.isEmpty) return widget.caseTypes;
    final q = _query.toLowerCase();
    return widget.caseTypes.where((t) => t.toLowerCase().contains(q)).toList();
  }

  Future<void> _openOtherTab() async {
    final customType = await showDialog<String>(
      context: context,
      builder: (ctx) => const _CustomCaseTypeDialog(),
    );

    if (customType != null && customType.isNotEmpty) {
      widget.onCustomTypeAdded(customType);
      if (mounted) Navigator.pop(context, customType);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;

    return SizedBox(
      height: maxHeight,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: S.of(context, 'searchCaseTypes'),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15),
              child: Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
            ),
            title: Text(S.of(context, 'other'), style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(S.of(context, 'enterCustomCaseType')),
            onTap: _openOtherTab,
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final type = _filtered[index];
                final isSelected = type == widget.selected;
                return ListTile(
                  title: Text(type),
                  trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                  selected: isSelected,
                  onTap: () => Navigator.pop(context, type),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomCaseTypeDialog extends StatefulWidget {
  const _CustomCaseTypeDialog();

  @override
  State<_CustomCaseTypeDialog> createState() => _CustomCaseTypeDialogState();
}

class _CustomCaseTypeDialogState extends State<_CustomCaseTypeDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context, 'customCaseType')),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: S.of(context, 'enterCaseType'),
            hintText: S.of(context, 'caseTypeHint'),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return S.of(context, 'enterCaseTypeRequired');
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.of(context, 'cancel')),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _controller.text.trim());
            }
          },
          child: Text(S.of(context, 'save')),
        ),
      ],
    );
  }
}
