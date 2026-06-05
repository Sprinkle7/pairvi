import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../l10n/app_translations.dart';
import '../services/locale_service.dart';
import '../services/theme_service.dart';
import '../widgets/app_footer.dart';
import '../widgets/fade_slide_in.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeService = LocaleService.instance;
    final themeService = ThemeService.instance;

    return ListenableBuilder(
      listenable: Listenable.merge([localeService, themeService]),
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  FadeSlideIn(
                    child: _SettingsCard(
                      title: S.of(context, 'appearance'),
                      child: SegmentedButton<AppThemePreference>(
                        segments: [
                          ButtonSegment(
                            value: AppThemePreference.system,
                            label: Text(S.of(context, 'themeSystem')),
                            icon: const Icon(Icons.brightness_auto_rounded, size: 18),
                          ),
                          ButtonSegment(
                            value: AppThemePreference.light,
                            label: Text(S.of(context, 'themeLight')),
                            icon: const Icon(Icons.light_mode_rounded, size: 18),
                          ),
                          ButtonSegment(
                            value: AppThemePreference.dark,
                            label: Text(S.of(context, 'themeDark')),
                            icon: const Icon(Icons.dark_mode_rounded, size: 18),
                          ),
                        ],
                        selected: {themeService.preference},
                        onSelectionChanged: (selection) {
                          themeService.setPreference(selection.first);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 80),
                    child: _SettingsCard(
                      title: S.of(context, 'language'),
                      child: SegmentedButton<String>(
                        segments: [
                          ButtonSegment(
                            value: 'en',
                            label: Text(S.of(context, 'english')),
                          ),
                          ButtonSegment(
                            value: 'ur',
                            label: Text(S.of(context, 'urdu')),
                          ),
                        ],
                        selected: {localeService.locale.languageCode},
                        onSelectionChanged: (selection) {
                          localeService.setLocale(Locale(selection.first));
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 120),
                    child: _SettingsCard(
                      title: S.of(context, 'about'),
                      children: [
                        _AboutRow(label: S.of(context, 'version'), value: '1.0.0'),
                        const SizedBox(height: 8),
                        _AboutRow(label: S.of(context, 'developedBy'), value: 'Techease Solutions'),
                        const SizedBox(height: 8),
                        _AboutRow(label: S.of(context, 'credit'), value: 'Advocate Islamuddin'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const FadeSlideIn(
                    delay: Duration(milliseconds: 200),
                    child: AppFooter(),
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

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    this.title,
    this.child,
    this.children,
  });

  final String? title;
  final Widget? child;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerOf(context)),
        boxShadow: AppTheme.isDark(context) ? null : AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryTextOf(context),
                  ),
            ),
            const SizedBox(height: 16),
          ],
          if (child != null) child!,
          if (children != null) ...children!,
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: AppTheme.mutedTextOf(context), fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppTheme.primaryTextOf(context),
          ),
        ),
      ],
    );
  }
}
