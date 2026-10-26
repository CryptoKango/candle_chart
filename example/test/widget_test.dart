import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lib_chart/lib_chart.dart';
import 'package:lib_chart_example/main.dart';

void main() {
  testWidgets('switches between candlestick and trend charts', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const LibChartExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('蜡烛图'), findsOneWidget);
    expect(find.text('趋势图'), findsOneWidget);
    expect(find.text('BTC / USDT'), findsOneWidget);
    expect(find.text('显示网格'), findsOneWidget);
    expect(
      tester.widget<KChartWidget>(find.byType(KChartWidget)).hideGrid,
      false,
    );

    await tester.tap(find.byKey(const ValueKey('grid-visibility-switch')));
    await tester.pumpAndSettle();

    expect(
      tester.widget<KChartWidget>(find.byType(KChartWidget)).hideGrid,
      true,
    );

    await tester.tap(find.text('趋势图'));
    await tester.pumpAndSettle();

    expect(find.text('趋势图'), findsOneWidget);
    expect(find.text('显示网格'), findsNothing);
  });
}
