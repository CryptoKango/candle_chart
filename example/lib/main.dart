import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lib_chart/lib_chart.dart';

void main() {
  runApp(const LibChartExampleApp());
}

class LibChartExampleApp extends StatelessWidget {
  const LibChartExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'lib_chart example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101114),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2DD4A3),
          brightness: Brightness.dark,
          surface: const Color(0xFF181A1F),
        ),
        useMaterial3: true,
      ),
      home: const ChartExamplePage(),
    );
  }
}

enum ChartMode { candle, line }

class ChartExamplePage extends StatefulWidget {
  const ChartExamplePage({super.key});

  @override
  State<ChartExamplePage> createState() => _ChartExamplePageState();
}

class _ChartExamplePageState extends State<ChartExamplePage> {
  final KChartController _controller = KChartController();
  late final List<KLineEntity> _data = _createDemoData();
  ChartMode _mode = ChartMode.candle;
  bool _showGrid = true;

  @override
  Widget build(BuildContext context) {
    final latest = _data.last;
    final change = (latest.close - latest.open) / latest.open * 100;
    final priceColor = change >= 0
        ? const Color(0xFF2DD4A3)
        : const Color(0xFFF05B64);

    return Scaffold(
      appBar: AppBar(
        title: const Text('lib_chart example'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: '缩小',
            onPressed: _controller.zoomOut,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          IconButton(
            tooltip: '放大',
            onPressed: _controller.zoomIn,
            icon: const Icon(Icons.add_circle_outline),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BTC / USDT',
                            style: TextStyle(
                              color: Color(0xFF9297A1),
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            latest.close.toStringAsFixed(2),
                            style: TextStyle(
                              color: priceColor,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: priceColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SegmentedButton<ChartMode>(
                    segments: const [
                      ButtonSegment(
                        value: ChartMode.candle,
                        label: Text('蜡烛图'),
                        icon: Icon(Icons.candlestick_chart, size: 18),
                      ),
                      ButtonSegment(
                        value: ChartMode.line,
                        label: Text('趋势图'),
                        icon: Icon(Icons.show_chart, size: 18),
                      ),
                    ],
                    selected: {_mode},
                    showSelectedIcon: false,
                    onSelectionChanged: (value) {
                      setState(() => _mode = value.first);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ColoredBox(
                        color: const Color(0xFF181A1F),
                        child: KChartWidget(
                          _data,
                          key: ValueKey(_mode),
                          controller: _controller,
                          isTrendLine: false,
                          isLine: _mode == ChartMode.line,
                          mainState: _mode == ChartMode.candle
                              ? MainState.MA
                              : MainState.NONE,
                          secondaryState: _mode == ChartMode.candle
                              ? SecondaryState.MACD
                              : SecondaryState.NONE,
                          volHidden: _mode == ChartMode.line,
                          hideGrid: _mode == ChartMode.candle
                              ? !_showGrid
                              : false,
                          colorConfig: _chartColorConfig,
                          enableTheme: false,
                          showNowPrice: true,
                          isTapShowInfoDialog: true,
                          crosshairMode: CrosshairMode.tapAndLongPress,
                          candleCornerRadius: 2,
                          xFrontPadding: 60,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_mode == ChartMode.candle)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF181A1F),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2A2D34)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.grid_4x4_rounded,
                            size: 18,
                            color: Color(0xFF9297A1),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text('显示网格', style: TextStyle(fontSize: 13)),
                          ),
                          Switch(
                            key: const ValueKey('grid-visibility-switch'),
                            value: _showGrid,
                            onChanged: (value) {
                              setState(() => _showGrid = value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Text(
                    '拖动查看历史 · 双指或滚轮缩放 · 长按查看详情',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF747984), fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const ChartColorConfig _chartColorConfig = ChartColorConfig(
  baseTheme: ChartTheme.dark,
  backgroundColor: Color(0xFF181A1F),
  textColor: Color(0xFF8C909A),
  gridColor: Color(0xFF2A2D34),
  upColor: Color(0xFF2DD4A3),
  downColor: Color(0xFFF05B64),
  lineColor: Color(0xFF5B9CF6),
  volumeColor: Color(0xFF8B7FD6),
  movingAverageColors: [
    Color(0xFFD8C17C),
    Color(0xFF65B7AE),
    Color(0xFF9A7FD1),
  ],
  nowPrice: NowPriceColorConfig(
    textColor: Colors.white,
    backgroundColor: Color(0xFF344A43),
    borderColor: Color(0xFF6F817B),
    upLineColor: Color(0xFF2DD4A3),
    downLineColor: Color(0xFFF05B64),
  ),
);

List<KLineEntity> _createDemoData() {
  final random = Random(42);
  final now = DateTime.now().millisecondsSinceEpoch;
  var price = 64200.0;

  final data = List.generate(160, (index) {
    final open = price;
    final close = max(48000.0, open + (random.nextDouble() - .46) * 850);
    final entity = KLineEntity.fromCustom(
      open: open,
      close: close,
      high: max(open, close) + 80 + random.nextDouble() * 420,
      low: min(open, close) - 80 - random.nextDouble() * 420,
      vol: 500 + random.nextDouble() * 3500,
      time: now - (159 - index) * 3600,
    );
    price = close;
    return entity;
  });

  DataUtil.calculate(data);
  return data;
}
