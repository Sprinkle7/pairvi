import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';
import '../l10n/app_translations.dart';
import '../models/saved_calculation.dart';
import '../services/calculation_storage_service.dart';
import '../widgets/fade_slide_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onOpenCalculator,
    required this.onOpenSavedCalculation,
    this.refreshToken = 0,
  });

  final VoidCallback onOpenCalculator;
  final ValueChanged<SavedCalculation> onOpenSavedCalculation;
  final int refreshToken;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<SavedCalculation>> _calculationsFuture;

  @override
  void initState() {
    super.initState();
    _loadCalculations();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) _loadCalculations();
  }

  void _loadCalculations() {
    setState(() {
      _calculationsFuture = CalculationStorageService.instance.getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return FutureBuilder<List<SavedCalculation>>(
      future: _calculationsFuture,
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Hero welcome card ──────────────────────────────────
                  ScaleFadeIn(
                    duration: const Duration(milliseconds: 600),
                    child: _HeroCard(
                      caseCount: items.length,
                      onNewCalculation: widget.onOpenCalculator,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Recent calculations ────────────────────────────────
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 180),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
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
                        Text(
                          S.of(context, 'recentCalculations'),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryTextOf(context),
                              ),
                        ),
                        const Spacer(),
                        if (items.isNotEmpty)
                          Text(
                            '${items.length} cases',
                            style: TextStyle(
                              color: AppTheme.mutedTextOf(context),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Calculations list ──────────────────────────────────
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 260),
                    child: isLoading
                        ? const _LoadingSkeleton()
                        : items.isEmpty
                            ? _EmptyState(onNewCalculation: widget.onOpenCalculator)
                            : _CaseList(
                                items: items,
                                dateFormat: dateFormat,
                                onOpenSavedCalculation: widget.onOpenSavedCalculation,
                              ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Hero Card ─────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.caseCount, required this.onNewCalculation});

  final int caseCount;
  final VoidCallback onNewCalculation;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryDark, AppTheme.primary, Color(0xFF1B5878)],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accent.withValues(alpha: 0.25),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scales of justice icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: const Icon(
                    Icons.balance_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  S.of(context, 'welcomeTitle'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  S.of(context, 'welcomeSubtitle'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                // Divider with gold dot
                Row(
                  children: [
                    Container(width: 20, height: 1, color: AppTheme.gold.withValues(alpha: 0.5)),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.gold.withValues(alpha: 0.8),
                      ),
                    ),
                    Container(width: 20, height: 1, color: AppTheme.gold.withValues(alpha: 0.5)),
                  ],
                ),
                const SizedBox(height: 20),
                // New calculation button
                FilledButton.icon(
                  onPressed: onNewCalculation,
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                  label: Text(S.of(context, 'newCalculation')),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    textStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.items});

  final List<SavedCalculation> items;

  @override
  Widget build(BuildContext context) {
    final totalCases = items.length;
    final recentCount = items
        .where((i) => i.savedAt.isAfter(DateTime.now().subtract(const Duration(days: 30))))
        .length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.folder_copy_outlined,
            label: 'Total Cases',
            value: totalCases.toString(),
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.schedule_rounded,
            label: 'This Month',
            value: recentCount.toString(),
            color: AppTheme.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.account_balance_rounded,
            label: 'Goshwara',
            value: 'PKR',
            color: AppTheme.gold,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerOf(context)),
        boxShadow: AppTheme.isDark(context) ? null : AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: AppTheme.mutedTextOf(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Case List ─────────────────────────────────────────────────────────────────

class _CaseList extends StatelessWidget {
  const _CaseList({
    required this.items,
    required this.dateFormat,
    required this.onOpenSavedCalculation,
  });

  final List<SavedCalculation> items;
  final DateFormat dateFormat;
  final ValueChanged<SavedCalculation> onOpenSavedCalculation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        return FadeSlideIn(
          delay: Duration(milliseconds: 60 * i),
          offset: const Offset(0, 0.04),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CaseCard(
              item: item,
              dateFormat: dateFormat,
              onTap: () => onOpenSavedCalculation(item),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CaseCard extends StatelessWidget {
  const _CaseCard({
    required this.item,
    required this.dateFormat,
    required this.onTap,
  });

  final SavedCalculation item;
  final DateFormat dateFormat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isRecent = item.savedAt.isAfter(DateTime.now().subtract(const Duration(days: 7)));

    return Material(
      color: AppTheme.cardOf(context),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.dividerOf(context)),
          ),
          child: Row(
            children: [
              // Left accent bar
              Container(
                width: 4,
                height: 68,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.primary, AppTheme.accent],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Icon
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceOf(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  size: 20,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.input.caseNo,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppTheme.primaryTextOf(context),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isRecent)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  color: AppTheme.accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.input.title,
                        style: TextStyle(
                          color: AppTheme.mutedTextOf(context),
                          fontSize: 12.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateFormat.format(item.savedAt),
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onNewCalculation});

  final VoidCallback onNewCalculation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.cardOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerOf(context)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceOf(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open_rounded,
              size: 40,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context, 'noSavedCalculations'),
            style: TextStyle(
              color: AppTheme.mutedTextOf(context),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by creating a new calculation',
            style: TextStyle(color: AppTheme.mutedTextOf(context), fontSize: 13),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onNewCalculation,
            icon: const Icon(Icons.add_rounded),
            label: Text(S.of(context, 'newCalculation')),
          ),
        ],
      ),
    );
  }
}

// ── Loading Skeleton ──────────────────────────────────────────────────────────

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            height: 76,
            decoration: BoxDecoration(
              color: AppTheme.dividerOf(context).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }),
    );
  }
}
