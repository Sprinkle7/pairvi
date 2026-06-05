import 'services/calculation_storage_service.dart';
import 'services/locale_service.dart';
import 'services/theme_service.dart';

class AppBootstrap {
  static Future<void> init() async {
    await CalculationStorageService.instance.init();
    await LocaleService.instance.load();
    await ThemeService.instance.load();
  }
}
