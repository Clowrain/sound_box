// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:provider/provider.dart';
import 'package:sound_box/app.dart';
import 'package:sound_box/data/sound_presets.dart';
import 'package:sound_box/features/sounds/sounds_page.dart';
import 'package:sound_box/state/sound_selection_state.dart';

void main() {
  testWidgets('home screen renders hero copy', (tester) async {
    await tester.pumpWidget(
      const SoundBoxApp(),
    );
    expect(find.textContaining('白噪音收音机'), findsWidgets);
  });

  testWidgets('tapping equalizer icon navigates to sounds page', (
    tester,
  ) async {
    await tester.pumpWidget(const SoundBoxApp());
    await tester.tap(find.byIcon(Icons.graphic_eq).first);
    await tester.pumpAndSettle();
    expect(find.text('声音排序和音量设置'), findsOneWidget);
  });

  testWidgets('sounds page renders sound list', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SoundSelectionState(initialOrder: whiteNoiseSounds),
        child: const MaterialApp(home: SoundsPage()),
      ),
    );
    expect(find.text('声音排序和音量设置'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
    expect(find.text('滑滑细雨'), findsOneWidget);
  });
}
