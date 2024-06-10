import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vessel_map/src/widgets/add_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget buildWidgetWithLocalization(Widget widget) {
  return MaterialApp(
    supportedLocales: const [Locale('en')],
    localizationsDelegates: const [AppLocalizations.delegate],
    home: widget,
  );
}

void main() {
  group('AddButton', () {
    testWidgets('AddButton should have an icon', (WidgetTester tester) async {
      final widget = buildWidgetWithLocalization(const AddButton());

      await tester.pumpWidget(widget);

      expect(find.byType(IconButton).first, findsOne);
      final icon = (find.byType(Icon).evaluate().single.widget as Icon).icon;
      expect(icon, equals(Icons.add));
    });
  });
}
