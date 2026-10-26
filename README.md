# lib_chart

Flutter K-line & 深度图组件包。基于开源 flutter_kchart 二次开发，使用纯 Canvas 绘制。

## 依赖

```yaml
# 外部 Flutter 应用的 pubspec.yaml
dependencies:
  lib_chart:
    path: ../candle_chart
```

也可以将 `path` 依赖替换为该仓库的 Git 地址。当前仓库本身就是完整的
Flutter package，不需要放在 `packages/` 子目录中。

## Example

仓库内提供了可运行的 [`example`](example) 应用，包含蜡烛图和趋势图切换、
蜡烛图底部网格显隐控制、缩放、拖动以及长按详情演示：

```bash
cd example
flutter run
```

## 快速开始

```dart
import 'package:lib_chart/lib_chart.dart';

// 1. 准备数据
final data = List.generate(100, (i) {
  return KLineEntity.fromCustom(
    open: 50000.0 + i,
    close: 50010.0 + i,
    high: 50050.0 + i,
    low: 49980.0 + i,
    vol: 1000.0 + i * 10,
    time: DateTime.now().millisecondsSinceEpoch - (100 - i) * 3600 * 1000,
  );
});

// 2. 使用
KChartWidget(
  data,
  isTrendLine: false,
  mainState: MainState.MA,
  secondaryState: SecondaryState.MACD,
)
```

## KChartWidget API

### 构造参数

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `datas` | `List<KLineEntity>?` | — | K 线数据 |
| `isTrendLine` | `bool` | — **(必填)** | 是否启用趋势线模式 |
| `mainState` | `MainState` | `MA` | 主图指标 |
| `secondaryState` | `SecondaryState` | `MACD` | 副图指标 |
| `volHidden` | `bool` | `false` | 隐藏成交量 |
| `isLine` | `bool` | `false` | 折线图模式 |
| `hideGrid` | `bool` | `false` | 隐藏网格 |
| `showNowPrice` | `bool` | `true` | 显示当前价格 |
| `showInfoDialog` | `bool` | `true` | 显示长按详情弹窗 |
| `materialInfoDialog` | `bool` | `true` | Material 风格弹窗 |
| `fixedLength` | `int` | `2` | 价格小数位 |
| `xFrontPadding` | `double` | `100` | 左侧留白 |
| `verticalTextAlignment` | `VerticalTextAlignment` | `left` | 价格文字对齐方向 |
| `chartColors` | `ChartColors?` | — | 自定义颜色 |
| `colorConfig` | `ChartColorConfig?` | — | 面向外部应用的精简颜色配置 |
| `chartStyle` | `ChartStyle?` | — | 自定义样式 |
| `enableTheme` | `bool` | `false` | 启用内置明暗主题 |
| `controller` | `KChartController?` | — | 程序化控制 |
| `fullscreenIcon` | `Widget?` | — | 全屏图标覆盖层 |
| `candleCornerRadius` | `double` | `2.0` | 蜡烛实体圆角半径 (px) |

#### 手势配置

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `enablePinchZoom` | `bool` | `true` | 双指缩放 |
| `minScale` / `maxScale` | `double` | `0.1` / `5.0` | 缩放范围 |
| `scaleSensitivity` | `double` | `2.5` | 缩放灵敏度 |
| `enableScaleCenterPoint` | `bool` | `true` | 以双指中心点为锚点 |
| `enableScaleAnimation` | `bool` | `true` | 缩放动画 |
| `scaleAnimationDuration` | `double` | `300.0` | 动画时长 (ms) |
| `enableScrollZoom` | `bool` | `true` | 滚轮缩放 (桌面) |
| `enableBoundaryFeedback` | `bool` | `true` | 边界反馈 |
| `enableScaleHapticFeedback` | `bool` | `true` | 触觉反馈 |
| `onScaleChanged` | `Function(double)?` | — | 缩放变化回调 |
| `flingTime` | `int` | `350` | 惯性动画时长 (ms) |
| `flingRatio` | `double` | `0.9` | 惯性距离系数 |
| `flingCurve` | `Curve` | `easeOutCubic` | 惯性动画曲线 |
| `isOnDrag` | `Function(bool)?` | — | 拖拽状态回调 |

#### 翻译

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `translations` | `Map<String, ChartTranslations>` | `kChartTranslations` | 字段名国际化 |
| `timeFormat` | `List<String>` | `YEAR_MONTH_DAY` | 时间格式 |

> 已弃用: `isChinese` — 请用 `translations` 替代。

#### 性能 & 绘图工具

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `enablePerformanceMode` | `bool` | `false` | 性能优化模式 (节流更新) |
| `enableDrawingTools` | `bool` | `false` | 启用绘图工具 |
| `drawingToolManager` | `DrawingToolManager?` | — | 绘图工具管理器 |

### 枚举

```dart
enum MainState { MA, BOLL, NONE }           // 主图指标
enum SecondaryState { MACD, KDJ, RSI, WR, CCI, NONE }  // 副图指标
enum VerticalTextAlignment { left, right }   // 价格文字对齐
```

### KChartController

```dart
final controller = KChartController();

KChartWidget(data, controller: controller, ...);

// 程序化控制
controller.zoomIn();           // 放大
controller.zoomOut();          // 缩小
controller.scaleTo(2.0);       // 缩放到指定比例
controller.resetScale();       // 重置缩放
controller.saveScaleState();   // 保存缩放状态
controller.restoreScaleState(); // 恢复缩放状态
```

## 数据模型

### KLineEntity

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `open` | `double` | ✓ | 开盘价 |
| `high` | `double` | ✓ | 最高价 |
| `low` | `double` | ✓ | 最低价 |
| `close` | `double` | ✓ | 收盘价 |
| `vol` | `double` | ✓ | 成交量 |
| `time` | `int?` | ✓ | Unix 时间戳（推荐毫秒；秒会自动转换） |
| `amount` | `double?` | — | 成交额 |
| `change` | `double?` | — | 涨跌额 |
| `ratio` | `double?` | — | 涨跌幅 |

构造方式：

```dart
// 手动创建
KLineEntity.fromCustom(open: ..., close: ..., high: ..., low: ..., vol: ..., time: ...);

// 从 JSON 创建（字段名: open, close, high, low, vol, time, amount, ratio, change）
KLineEntity.fromJson(jsonMap);
```

## 样式定制

### ChartColors（颜色主题）

通过 `chartColors` 参数传入，支持 30+ 颜色字段细粒度控制：

| 字段 | 默认值 (light) | 默认值 (dark) | 说明 |
|---|---|---|---|
| `upColor` | `#129A48` | `#129A48` | 上涨色 |
| `dnColor` | `#EA4747` | `#EA4747` | 下跌色 |
| `bgColor` | `[#FFF, #FFF]` | `[#18191d, #18191d]` | 渐变背景 |
| `gridColor` | `#E0E0E0` | `#4c5c74` | 网格线 |
| `defaultTextColor` | `#424242` | `#60738E` | 默认文字 |
| `nowPriceUpColor` | `#129A48` | `#129A48` | 当前价线上涨色 |
| `nowPriceDnColor` | `#EA4747` | `#EA4747` | 当前价线下跌色 |
| `nowPriceTextColor` | `#151517` | `#151517` | 当前价格 chip 文字色 |
| `nowPriceChipBgColor` | `#F5F5F5` | `#272729` | 当前价格 chip 背景色 |
| `nowPriceChipBorderColor` | `#E0E0E0` | `#151517` | 当前价格 chip 边框色 |
| `ma5Color` / `ma10Color` / `ma30Color` | ... | ... | 均线色 |
| `macdColor` / `difColor` / `deaColor` | ... | ... | MACD |
| `kColor` / `dColor` / `jColor` | ... | ... | KDJ |
| `rsiColor` | ... | ... | RSI |
| `selectBorderColor` / `selectFillColor` | ... | ... | 选中态 |
| `crossTextColor` / `hCrossColor` / `vCrossColor` | ... | ... | 十字线 |
| `maxColor` / `minColor` | ... | ... | 最大/最小值 |
| `depthBuyColor` / `depthSellColor` | ... | ... | 深度图 |

工厂方法：

```dart
ChartColors.light();  // 亮色主题
ChartColors.dark();   // 暗色主题
```

用 `copyWith` 基于已有主题做部分覆盖：

```dart
ChartColors.light().copyWith(upColor: Colors.blue, dnColor: Colors.red);
```

### 外部颜色配置（推荐）

外部应用可直接向 `KChartWidget` 传入精简的 `ChartColorConfig`。未配置项会从
`baseTheme` 指定的亮色或暗色主题继承：

```dart
KChartWidget(
  data,
  isTrendLine: false,
  colorConfig: const ChartColorConfig(
    baseTheme: ChartTheme.dark,
    backgroundColor: Color(0xFF181A1F),
    textColor: Color(0xFFF5F5F5),
    gridColor: Color(0xFF2A2D34),
    upColor: Color(0xFF2DD4A3),
    downColor: Color(0xFFF05B64),
    nowPrice: NowPriceColorConfig(
      textColor: Colors.white,
      backgroundColor: Color(0xFF344A43),
      borderColor: Color(0xFF6F817B),
      upLineColor: Color(0xFF2DD4A3),
      downLineColor: Color(0xFFF05B64),
    ),
  ),
)
```

当 `colorConfig` 与 `chartColors` 同时传入时，`colorConfig` 作为外部覆盖层，
未设置的颜色继续继承 `chartColors`。

### ChartStyle（尺寸样式）

| 字段 | 默认值 | 说明 |
|---|---|---|
| `topPadding` / `bottomPadding` / `childPadding` | `30` / `20` / `12` | 间距 |
| `pointWidth` | `11.0` | 数据点间距 |
| `candleWidth` | `8.5` | 蜡烛宽度 |
| `candleLineWidth` | `1.5` | 蜡烛影线宽度 |
| `candleCornerRadius` | `2.0` | 蜡烛实体圆角半径 |
| `volWidth` | `8.5` | 成交量柱宽度 |
| `macdWidth` | `3.0` | MACD 柱宽度 |
| `gridRows` / `gridColumns` | `4` / `4` | 网格行列数 |
| `nowPriceLineLength` / `nowPriceLineSpan` / `nowPriceLineWidth` | `1` / `1` / `1` | 当前价虚线属性 |

### Theme Adapter（外部主题桥接）

`lib_chart` 与 UI 主题系统相互独立。通过 `chartColorsFromTheme()` 将外部主题颜色映射为 `ChartColors`：

```dart
import 'package:lib_chart/lib_chart.dart';

KChartWidget(
  data,
  chartColors: chartColorsFromTheme(
    upColor: context.walletTheme.tokenUpColor,
    downColor: context.walletTheme.tokenDownColor,
    textColor: const Color(0xFF8E8E92),
    gridColor: const Color(0xFFEAEAED),
    bgColor: context.walletTheme.cardBackground,
    nowPriceChipBgColor: const Color(0xFF272729),
    nowPriceChipBorderColor: const Color(0xFF151517),
  ),
)
```

完整参数：`upColor`, `downColor`, `textColor`, `gridColor`, `bgColor`, `ma5Color`, `ma10Color`, `ma30Color`, `nowPriceChipBgColor`, `nowPriceChipBorderColor`。

## 手势操作

| 手势 | 效果 |
|---|---|
| **单指拖动** | 横向平移查看历史数据 |
| **双指捏合** | 缩放 K 线密度（由 `enablePinchZoom` 控制） |
| **长按** | 显示十字线 + 详情弹窗 |
| **点击** | 选中 K 线（`isTapShowInfoDialog: true`） |
| **滚轮** (桌面) | 缩放（由 `enableScrollZoom` 控制） |

手势通过 `onScale*` 统一处理，单指平移 + 双指缩放互不冲突。

## 技术指标

### 主图 (`MainState`)

| 值 | 说明 |
|---|---|
| `MA` | 移动平均线 (MA5/MA10/MA30) |
| `BOLL` | 布林带 |
| `NONE` | 无 |

`maDayList` 参数自定义 MA 周期组合，默认 `[5, 10, 20]`。

### 副图 (`SecondaryState`)

| 值 | 说明 |
|---|---|
| `MACD` | MACD (DIF/DEA/柱状图) |
| `KDJ` | KDJ |
| `RSI` | RSI |
| `WR` | Williams %R |
| `CCI` | CCI |
| `NONE` | 无 |

## 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:lib_chart/lib_chart.dart';

class KlinePage extends StatelessWidget {
  const KlinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = _sampleData();
    return SizedBox(
      height: 340,
      child: KChartWidget(
        data,
        isTrendLine: false,
        mainState: MainState.MA,
        secondaryState: SecondaryState.MACD,
        verticalTextAlignment: VerticalTextAlignment.right,
        candleCornerRadius: 4.0,
        chartColors: ChartColors.dark().copyWith(
          upColor: const Color(0xFF4DAA90),
          dnColor: const Color(0xFFC15466),
        ),
        chartStyle: ChartStyle()
          ..candleWidth = 10.0
          ..candleCornerRadius = 3.0,
        enablePinchZoom: true,
        scaleSensitivity: 2.5,
        controller: KChartController(),
        fullscreenIcon: IconButton(
          icon: const Icon(Icons.fullscreen),
          onPressed: () {},
        ),
      ),
    );
  }

  List<KLineEntity> _sampleData() {
    final now = DateTime.now().millisecondsSinceEpoch;
    double price = 50000;
    return List.generate(100, (i) {
      price += (i % 2 == 0 ? 1 : -1) * (i % 50).toDouble();
      return KLineEntity.fromCustom(
        open: price,
        close: price + (i % 5 - 2).toDouble(),
        high: price + (i % 10 + 5).toDouble(),
        low: price - (i % 10 + 5).toDouble(),
        vol: (1000 + i * 10).toDouble(),
        time: now - (100 - i) * 3600,
      );
    });
  }
}
```

## DepthChart 深度图

```dart
DepthChart(
  bids,         // List<DepthEntity> 买单
  asks,         // List<DepthEntity> 卖单
  chartColors,  // ChartColors
  fixedLength: 2,
  buyPathColor: Colors.green,
  sellPathColor: Colors.red,
)
```

## 输出

- `lib_chart.dart` — 所有公开 API 的 barrel 文件
- `VerticalTextAlignment` 需从 `package:lib_chart/lib_chart.dart` 直接导入（不可通过其他文件间接引用），否则 switch 会报 "Not a constant expression"

## 常见问题

**Q: 双指缩放没反应？**

A: 确保 `enablePinchZoom: true`。在模拟器上用按住 Option/Alt 键模拟双指。桌面端可用滚轮缩放（`enableScrollZoom: true`）。

**Q: 如何调整蜡烛圆角？**

```dart
KChartWidget(
  data,
  candleCornerRadius: 4.0,  // 0 = 直角
  chartStyle: ChartStyle()..candleCornerRadius = 3.0,  // 或通过 style
)
```

**Q: 价格 chip 背景/边框如何自定义？**

```dart
chartColorsFromTheme(
  nowPriceChipBgColor: Colors.black,
  nowPriceChipBorderColor: Colors.grey,
)
// 或直接传 chartColors 覆盖
chartColors: ChartColors.dark().copyWith(
  nowPriceChipBgColor: Color(0xFF272729),
  nowPriceChipBorderColor: Color(0xFF151517),
)
```

**Q: 如何支持 JSON 数据？**

```dart
final list = (json['data'] as List)
    .map((e) => KLineEntity.fromJson(e))
    .toList();
```

**Q: 性能优化？**

设置 `enablePerformanceMode: true` 启用以 60fps 节流的更新策略。配合 `minScale`/`maxScale` 限制缩放范围也可以减少计算量。
