import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touchstone/core/app/app.dart';
import 'package:touchstone/core/theme/app_colors.dart';

void main() {
  testWidgets('MyApp uses the snowflake light theme', (tester) async {
    await tester.pumpWidget(const MyApp());

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

    // getSnowflakeThemeData wires appColors.background into the AppBar theme;
    // asserting on it proves the theme came from snowflake, not fromSeed.
    expect(app.theme!.appBarTheme.backgroundColor, lightColors.background);
    expect(app.theme!.appBarTheme.foregroundColor, lightColors.onBackground);
  });
}
