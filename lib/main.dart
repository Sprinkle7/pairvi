import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_bootstrap.dart';
import 'app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/locale_service.dart';
import 'services/theme_service.dart';
import 'web/website_home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrap.init();
  runApp(const PairviApp());
}

class PairviApp extends StatelessWidget {
  const PairviApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeService = LocaleService.instance;
    final themeService = ThemeService.instance;

    return ListenableBuilder(
      listenable: Listenable.merge([localeService, themeService]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Pairvi',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeService.themeMode,
          locale: localeService.locale,
          supportedLocales: const [Locale('en'), Locale('ur')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            final systemScale = mediaQuery.textScaler.scale(1);
            final textScaler = localeService.isRtl
                ? TextScaler.linear(systemScale * LocaleService.urduTextScaleFactor)
                : mediaQuery.textScaler;

            return Directionality(
              textDirection: localeService.isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: MediaQuery(
                data: mediaQuery.copyWith(textScaler: textScaler),
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          home: kIsWeb ? const WebsiteHomePage() : const SplashScreen(),
        );
      },
    );
  }
}
