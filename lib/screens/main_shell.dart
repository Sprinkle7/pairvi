import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../l10n/app_translations.dart';
import '../models/saved_calculation.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_logo.dart';
import 'goshwara_calculator_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

enum AppSection { home, goshwara, settings }

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  AppSection _selectedSection = AppSection.home;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  SavedCalculation? _calculatorInitial;
  int _homeRefreshToken = 0;

  static const _railDestinations = [
    (AppSection.home,     Icons.home_outlined,       Icons.home,       'home'),
    (AppSection.goshwara, Icons.calculate_outlined,  Icons.calculate,  'calculator'),
    (AppSection.settings, Icons.settings_outlined,   Icons.settings,   'settings'),
  ];

  void _navigateTo(AppSection section) {
    setState(() {
      _selectedSection = section;
    });
    _scaffoldKey.currentState?.closeDrawer();
  }

  void _openNewCalculator() {
    setState(() {
      _calculatorInitial = null;
      _selectedSection = AppSection.goshwara;
    });
  }

  void _openSavedCalculation(SavedCalculation saved) {
    setState(() {
      _calculatorInitial = saved;
      _selectedSection = AppSection.goshwara;
    });
  }

  void _onCalculationSaved() {
    setState(() => _homeRefreshToken++);
  }

  Widget _buildBody(BuildContext context) {
    return switch (_selectedSection) {
      AppSection.home => HomeScreen(
          refreshToken: _homeRefreshToken,
          onOpenCalculator: _openNewCalculator,
          onOpenSavedCalculation: _openSavedCalculation,
        ),
      AppSection.goshwara => GoshwaraCalculatorScreen(
          key: ValueKey(_calculatorInitial?.id ?? 'new'),
          initialCalculation: _calculatorInitial,
          onCalculationSaved: _onCalculationSaved,
        ),
      AppSection.settings => const SettingsScreen(),
    };
  }

  String _pageTitle(BuildContext context) => switch (_selectedSection) {
        AppSection.home     => S.of(context, 'dashboard'),
        AppSection.goshwara => S.of(context, 'goshwara'),
        AppSection.settings => S.of(context, 'settings'),
      };

  int get _bottomNavIndex => switch (_selectedSection) {
        AppSection.home     => 0,
        AppSection.goshwara => 1,
        AppSection.settings => 2,
      };

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useRail = width >= 900;

    return Scaffold(
      key: _scaffoldKey,
      appBar: _GradientAppBar(
        title: Row(
          children: [
            if (!useRail) ...[
              const AppLogo(size: 30, borderRadius: 8),
              const SizedBox(width: 12),
            ],
            Text(_pageTitle(context)),
          ],
        ),
        leading: useRail
            ? null
            : IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
      ),
      drawer: useRail ? null : _AppDrawer(selected: _selectedSection, onSelect: _navigateTo),
      body: Row(
        children: [
          if (useRail)
            _StyledNavigationRail(
              extended: width >= 1100,
              selectedIndex: _bottomNavIndex,
              onDestinationSelected: (i) => _navigateTo(_railDestinations[i].$1),
              destinations: _railDestinations,
            ),
          if (useRail)
            Container(width: 1, color: AppTheme.dividerOf(context)),
          Expanded(
            child: AnimatedSectionSwitcher(
              transitionKey: _selectedSection,
              child: _buildBody(context),
            ),
          ),
        ],
      ),
      bottomNavigationBar: useRail
          ? null
          : NavigationBar(
              selectedIndex: _bottomNavIndex,
              onDestinationSelected: (i) => _navigateTo(_railDestinations[i].$1),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home_rounded),
                  label: S.of(context, 'home'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.calculate_outlined),
                  selectedIcon: const Icon(Icons.calculate_rounded),
                  label: S.of(context, 'calculator'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings_rounded),
                  label: S.of(context, 'settings'),
                ),
              ],
            ),
    );
  }
}

// ── Gradient AppBar ───────────────────────────────────────────────────────────

class _GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _GradientAppBar({this.title, this.leading});

  final Widget? title;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(62);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: title,
      leading: leading,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
      ),
    );
  }
}

// ── Navigation Rail ───────────────────────────────────────────────────────────

class _StyledNavigationRail extends StatelessWidget {
  const _StyledNavigationRail({
    required this.extended,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final bool extended;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<(AppSection, IconData, IconData, String)> destinations;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.cardOf(context),
      child: Column(
        children: [
          Expanded(
            child: NavigationRail(
              extended: extended,
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              backgroundColor: Colors.transparent,
              leading: extended
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Row(
                        children: [
                          const AppLogo(size: 36, borderRadius: 10, showShadow: true),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              S.of(context, 'appName'),
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                letterSpacing: 0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(height: 12),
              labelType: extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
              destinations: destinations.map((d) {
                return NavigationRailDestination(
                  icon: Icon(d.$2),
                  selectedIcon: Icon(d.$3),
                  label: Text(S.of(context, d.$4)),
                );
              }).toList(),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 8, 16),
            child: AppFooter(),
          ),
        ],
      ),
    );
  }
}

// ── App Drawer ────────────────────────────────────────────────────────────────

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.selected, required this.onSelect});

  final AppSection selected;
  final ValueChanged<AppSection> onSelect;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.cardOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header with gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
            decoration: const BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AppLogo(size: 48, borderRadius: 14, showShadow: true),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context, 'appName'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        S.of(context, 'appTagline'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Navigation items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                _DrawerTile(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: S.of(context, 'home'),
                  selected: selected == AppSection.home,
                  onTap: () => onSelect(AppSection.home),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppTheme.gold,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        S.of(context, 'goshwara').toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade500,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                _DrawerTile(
                  icon: Icons.calculate_outlined,
                  selectedIcon: Icons.calculate_rounded,
                  label: S.of(context, 'calculator'),
                  selected: selected == AppSection.goshwara,
                  onTap: () => onSelect(AppSection.goshwara),
                ),
                const SizedBox(height: 4),
                const Divider(height: 24),
                _DrawerTile(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings_rounded,
                  label: S.of(context, 'settings'),
                  selected: selected == AppSection.settings,
                  onTap: () => onSelect(AppSection.settings),
                ),
              ],
            ),
          ),

          const Spacer(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: AppFooter(),
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primary.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          selected ? selectedIcon : icon,
          color: selected ? AppTheme.primary : AppTheme.mutedTextOf(context),
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppTheme.primary : AppTheme.mutedTextOf(context),
            fontSize: 14.5,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dense: true,
        onTap: onTap,
        trailing: selected
            ? Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            : null,
      ),
    );
  }
}
