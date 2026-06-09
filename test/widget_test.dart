import 'package:flutter_test/flutter_test.dart';
import 'package:gushwarah/app_bootstrap.dart';
import 'package:gushwarah/main.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    Hive.init('test');
    await AppBootstrap.init();
  });

  testWidgets('App loads dashboard', (WidgetTester tester) async {
   // await tester.pumpWidget(const DaftarApp());

    var reachedHome = false;
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('Welcome to Daftar').evaluate().isNotEmpty) {
        reachedHome = true;
        break;
      }
    }

    expect(reachedHome, isTrue);
    await tester.pump(const Duration(milliseconds: 500));
  });
}
