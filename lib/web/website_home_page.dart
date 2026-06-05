import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../l10n/app_translations.dart';
import '../screens/goshwara_calculator_screen.dart';
import '../services/locale_service.dart';

class WebsiteHomePage extends StatefulWidget {
  const WebsiteHomePage({super.key});

  @override
  State<WebsiteHomePage> createState() => _WebsiteHomePageState();
}

class _WebsiteHomePageState extends State<WebsiteHomePage> {
  final _topKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _calculatorKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeService = LocaleService.instance;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            title: Text(S.of(context, 'appName'), style: const TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              _NavButton(label: S.of(context, 'navHome'), onTap: () => _scrollTo(_topKey)),
              _NavButton(label: S.of(context, 'navCalculator'), onTap: () => _scrollTo(_calculatorKey)),
              _NavButton(label: S.of(context, 'navAbout'), onTap: () => _scrollTo(_aboutKey)),
              PopupMenuButton<String>(
                icon: const Icon(Icons.language, color: Colors.white),
                onSelected: (code) => localeService.setLocale(Locale(code)),
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'en', child: Text(S.of(context, 'english'))),
                  PopupMenuItem(value: 'ur', child: Text(S.of(context, 'urdu'))),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              key: _topKey,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 72),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.85), AppTheme.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context, 'websiteHeroTitle'),
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        S.of(context, 'websiteHeroSubtitle'),
                        style: theme.textTheme.titleLarge?.copyWith(color: Colors.white.withValues(alpha: 0.92)),
                      ),
                      const SizedBox(height: 28),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        ),
                        onPressed: () => _scrollTo(_calculatorKey),
                        child: Text(S.of(context, 'openCalculator')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 56),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    children: [
                      Text(
                        S.of(context, 'websiteFeaturesTitle'),
                        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 32),
                      Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        alignment: WrapAlignment.center,
                        children: [
                          _FeatureCard(
                            title: S.of(context, 'websiteFeature1Title'),
                            body: S.of(context, 'websiteFeature1Body'),
                            icon: Icons.calculate,
                          ),
                          _FeatureCard(
                            title: S.of(context, 'websiteFeature2Title'),
                            body: S.of(context, 'websiteFeature2Body'),
                            icon: Icons.picture_as_pdf,
                          ),
                          _FeatureCard(
                            title: S.of(context, 'websiteFeature3Title'),
                            body: S.of(context, 'websiteFeature3Body'),
                            icon: Icons.cloud_off,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              key: _aboutKey,
              color: AppTheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 56),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      Text(
                        S.of(context, 'websiteAboutTitle'),
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        S.of(context, 'websiteAboutBody'),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              key: _calculatorKey,
              padding: const EdgeInsets.fromLTRB(32, 56, 32, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      Text(
                        S.of(context, 'websiteCalculatorTitle'),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const GoshwaraCalculatorScreen(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.primary,
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  S.of(context, 'websiteFooter'),
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.title, required this.body, required this.icon});

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 36, color: AppTheme.accent),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(body, style: TextStyle(color: Colors.grey.shade600, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }
}
