import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:lib_chart/lib_chart.dart';

void main() {
  test('KLineEntity creates fromCustom', () {
    final entity = KLineEntity.fromCustom(
      open: 100,
      high: 110,
      low: 95,
      close: 105,
      vol: 1000,
      time: 1704067200,
    );

    expect(entity.open, 100);
    expect(entity.close, 105);
    expect(entity.high, 110);
    expect(entity.vol, 1000);
    expect(entity.time, 1704067200000);
  });

  test('KLineEntity parses numeric strings and normalizes timestamps', () {
    final fromSeconds = KLineEntity.fromJson({
      'open': '100.25',
      'high': '102.5',
      'low': '99.75',
      'close': '101.5',
      'vol': '1234.5',
      'time': '1704067200',
    });
    final fromMilliseconds = KLineEntity.fromJson({
      'open': 1,
      'high': 1,
      'low': 1,
      'close': 1,
      'vol': 0,
      'id': 1704067200000,
    });

    expect(fromSeconds.open, 100.25);
    expect(fromSeconds.vol, 1234.5);
    expect(fromSeconds.time, 1704067200000);
    expect(fromMilliseconds.time, 1704067200000);
  });

  test('ChartColors.light() provides defaults', () {
    final colors = ChartColors.light();
    expect(colors.upColor, const Color(0xff129A48));
    expect(colors.dnColor, const Color(0xffEA4747));
  });

  test('ChartColorConfig applies external semantic colors', () {
    const config = ChartColorConfig(
      baseTheme: ChartTheme.dark,
      backgroundColor: Color(0xFF101114),
      textColor: Color(0xFFF5F5F5),
      gridColor: Color(0xFF303238),
      upColor: Color(0xFF2DD4A3),
      downColor: Color(0xFFF05B64),
      movingAverageColors: [Color(0xFFFFCC66), Color(0xFF66CCFF)],
      nowPrice: NowPriceColorConfig(
        textColor: Color(0xFFFFFFFF),
        backgroundColor: Color(0xFF344A43),
        borderColor: Color(0xFF6F817B),
      ),
    );

    final colors = ChartColors.fromConfig(config);

    expect(colors.bgColor, const [Color(0xFF101114), Color(0xFF101114)]);
    expect(colors.defaultTextColor, const Color(0xFFF5F5F5));
    expect(colors.upColor, const Color(0xFF2DD4A3));
    expect(colors.nowPriceUpColor, const Color(0xFF2DD4A3));
    expect(colors.depthBuyColor, const Color(0xFF2DD4A3));
    expect(colors.infoWindowDnColor, const Color(0xFFF05B64));
    expect(colors.ma5Color, const Color(0xFFFFCC66));
    expect(colors.ma10Color, const Color(0xFF66CCFF));
    expect(colors.nowPriceTextColor, const Color(0xFFFFFFFF));
    expect(colors.nowPriceChipBgColor, const Color(0xFF344A43));
  });

  test('ChartColorConfig safely copies and expands background gradients', () {
    final source = <Color>[const Color(0xFF112233)];
    final colors = ChartColors.fromConfig(
      ChartColorConfig(backgroundGradient: source),
    );
    source[0] = const Color(0xFFFFFFFF);

    expect(colors.bgColor, const [Color(0xFF112233), Color(0xFF112233)]);
  });

  test('indicator parameters reject zero and negative periods', () {
    final data = [
      KLineEntity.fromCustom(
        open: 1,
        high: 1,
        low: 1,
        close: 1,
        vol: 0,
        time: 1704067200000,
      ),
    ];

    expect(
      () => DataUtil.calculateWithParameters(
        data,
        const ChartIndicatorParameters(rsiPeriod: 0),
      ),
      throwsArgumentError,
    );
    expect(() => DataUtil.calcBOLL(data, 1, 2), throwsArgumentError);
  });

  test('flat indicator data remains finite', () {
    final data = List.generate(
      40,
      (index) => KLineEntity.fromCustom(
        open: 0,
        high: 0,
        low: 0,
        close: 0,
        vol: 0,
        time: 1704067200000 + index * 60000,
      ),
    );

    DataUtil.calculate(data);

    expect(data.last.k, isNotNull);
    expect(data.last.k!.isFinite, isTrue);
    expect(data.last.r, 0);
    expect(data.last.cci, 0);
    expect(data.last.macd!.isFinite, isTrue);
  });

  test('indicator parameters calculate all migrated indicators', () {
    final data = List.generate(
      80,
      (index) => KLineEntity.fromCustom(
        open: 100 + index.toDouble(),
        high: 102 + index.toDouble(),
        low: 99 + index.toDouble(),
        close: 101 + index.toDouble(),
        vol: 1000 + index.toDouble(),
        time: 1704067200000 + index * 60000,
      ),
    );

    DataUtil.calculateWithParameters(
      data,
      const ChartIndicatorParameters(
        maPeriods: [3, 6, 9],
        emaPeriods: [4, 8, 12],
        bollPeriod: 10,
        macdFast: 8,
        macdSlow: 17,
        macdSignal: 6,
        kdjPeriod: 7,
        rsiPeriod: 9,
        wrPeriod: 10,
        obvMaPeriod: 12,
        stochRsiPeriod: 9,
      ),
    );

    final last = data.last;
    expect(last.maValueList, hasLength(3));
    expect(last.emaValueList, hasLength(3));
    expect(last.up, isNotNull);
    expect(last.sar, isNotNull);
    expect(last.macd, isNotNull);
    expect(last.k, isNotNull);
    expect(last.rsi, isNotNull);
    expect(last.r, isNotNull);
    expect(last.obvMa, isNotNull);
    expect(last.stochRsiK, isNotNull);
  });

  testWidgets(
    'chart renders multiple indicators, watermark, and loading overlay',
    (tester) async {
      final data = List.generate(
        40,
        (index) => KLineEntity.fromCustom(
          open: 100 + index.toDouble(),
          high: 102 + index.toDouble(),
          low: 99 + index.toDouble(),
          close: 101 + index.toDouble(),
          vol: 1000 + index.toDouble(),
          time: 1704067200000 + index * 60000,
        ),
      );
      DataUtil.calculate(data);

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 375,
            height: 402,
            child: KChartWidget(
              data,
              isTrendLine: false,
              mainState: MainState.NONE,
              secondaryState: SecondaryState.NONE,
              mainStates: const [MainState.MA, MainState.EMA, MainState.BOLL],
              secondaryStates: const [SecondaryState.VOL, SecondaryState.MACD],
              watermark: const IgnorePointer(
                child: SizedBox(key: Key('watermark')),
              ),
              loadingOverlay: const SizedBox(key: Key('loading-overlay')),
              singleSecondaryChartHeight: 64,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('watermark')), findsOneWidget);
      expect(find.byKey(const Key('loading-overlay')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('flat zero data renders in a constrained chart', (tester) async {
    final data = List.generate(
      30,
      (index) => KLineEntity.fromCustom(
        open: 0,
        high: 0,
        low: 0,
        close: 0,
        vol: 0,
        time: 1704067200 + index * 60,
      ),
    );
    DataUtil.calculate(data);

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 240,
            height: 48,
            child: KChartWidget(
              data,
              isTrendLine: false,
              fixedLength: 8,
              secondaryStates: const [SecondaryState.VOL, SecondaryState.MACD],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('two chart instances render independently', (tester) async {
    List<KLineEntity> buildData(double price, int count) => List.generate(
      count,
      (index) => KLineEntity.fromCustom(
        open: price,
        high: price,
        low: price,
        close: price,
        vol: 0,
        time: 1704067200000 + index * 60000,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: [
            Expanded(child: KChartWidget(buildData(1, 20), isTrendLine: false)),
            Expanded(
              child: KChartWidget(buildData(1000, 200), isTrendLine: false),
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(KChartWidget), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('disposing during programmatic scale animation is safe', (
    tester,
  ) async {
    final controller = KChartController();
    final data = [
      KLineEntity.fromCustom(
        open: 1,
        high: 2,
        low: 1,
        close: 2,
        vol: 1,
        time: 1704067200000,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: KChartWidget(data, isTrendLine: false, controller: controller),
      ),
    );
    final animation = controller.scaleTo(
      2,
      duration: const Duration(seconds: 1),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(const SizedBox.shrink());
    await animation;

    expect(tester.takeException(), isNull);
  });

  testWidgets('candle tap and long-press movement emit selected data', (
    tester,
  ) async {
    final data = List.generate(
      80,
      (index) => KLineEntity.fromCustom(
        open: index.toDouble(),
        high: index + 1.0,
        low: index.toDouble(),
        close: index + 0.5,
        vol: 1,
        time: 1704067200000 + index * 60000,
      ),
    );
    final tappedIndexes = <int>[];
    final longPressedIndexes = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            key: const Key('chart-host'),
            width: 375,
            height: 402,
            child: KChartWidget(
              data,
              isTrendLine: false,
              onCandleTap: (entity, index) => tappedIndexes.add(index),
              onCandleLongPress: (entity, index) =>
                  longPressedIndexes.add(index),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final rect = tester.getRect(find.byKey(const Key('chart-host')));
    final start = Offset(rect.left + rect.width / 2, rect.top + 100);
    await tester.tapAt(start);
    await tester.pump();

    final gesture = await tester.startGesture(start);
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveBy(const Offset(-60, 0));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(tappedIndexes, hasLength(1));
    expect(tappedIndexes.single, inInclusiveRange(0, data.length - 1));
    expect(longPressedIndexes, isNotEmpty);
    expect(longPressedIndexes.toSet().length, longPressedIndexes.length);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'chart accepts a realtime data revision without replacing its key',
    (tester) async {
      final initial = [
        KLineEntity.fromCustom(
          open: 1,
          high: 1,
          low: 1,
          close: 1,
          vol: 1,
          time: 1704067200000,
        ),
      ];
      final updated = [
        KLineEntity.fromCustom(
          open: 1,
          high: 2,
          low: 1,
          close: 2,
          vol: 2,
          time: 1704067200000,
        ),
      ];

      Widget build(List<KLineEntity> data, int revision) => MaterialApp(
        home: SizedBox(
          width: 375,
          height: 402,
          child: KChartWidget(
            data,
            key: const ValueKey('realtime-chart'),
            dataRevision: revision,
            isTrendLine: false,
          ),
        ),
      );

      await tester.pumpWidget(build(initial, 0));
      await tester.pump();
      await tester.pumpWidget(build(updated, 1));
      await tester.pump();

      final chart = tester.widget<KChartWidget>(find.byType(KChartWidget));
      expect(chart.dataRevision, 1);
      expect(chart.datas?.single.close, 2);
      expect(tester.takeException(), isNull);
    },
  );
}
