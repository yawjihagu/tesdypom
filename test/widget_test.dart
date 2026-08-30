import 'package:flutter_test/flutter_test.dart';

import 'package:pomodoro_flutter/pomodoro_page.dart';

void main() {
  testWidgets('Pomodoro app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const PomodoroApp());

    expect(find.text('FOCUS'), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);
    expect(find.textContaining('today'), findsWidgets);
  });
}
