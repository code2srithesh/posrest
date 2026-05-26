// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:posrest/services/auth_service.dart';
import 'package:posrest/services/preferences_service.dart';
import 'package:posrest/main.dart';

void main() {
  testWidgets('POSRest Login Screen Smoke Test', (WidgetTester tester) async {
    // Initialize mock SharedPreferences and Services
    SharedPreferences.setMockInitialValues({});
    await AuthService().initialize();
    await PreferencesService().initialize();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 1));

    // Verify that the login screen title and brand exist.
    expect(find.text('POSRest'), findsOneWidget);
    expect(find.text('Luxury Lounge Point of Sale'), findsOneWidget);
  });
}
