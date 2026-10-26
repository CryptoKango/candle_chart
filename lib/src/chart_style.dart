import 'package:flutter/material.dart' show Color;

enum ChartTheme { light, dark }

/// 面向外部应用的精简颜色配置。
///
/// 未设置的颜色会从 [KChartWidget] 当前使用的 [ChartColors] 或主题中继承。
/// 涨跌色会同步应用到 K 线、当前价、深度图和详情窗口；如需更细粒度控制，
/// 仍可继续使用完整的 [ChartColors]。
class ChartColorConfig {
  const ChartColorConfig({
    this.baseTheme = ChartTheme.light,
    this.backgroundColor,
    this.backgroundGradient,
    this.textColor,
    this.gridColor,
    this.upColor,
    this.downColor,
    this.lineColor,
    this.lineFillColor,
    this.volumeColor,
    this.movingAverageColors,
    this.nowPrice,
  }) : assert(
         backgroundColor == null || backgroundGradient == null,
         'backgroundColor 和 backgroundGradient 不能同时设置',
       );

  /// 未配置字段所继承的基础主题。
  final ChartTheme baseTheme;

  /// 单色图表背景。
  final Color? backgroundColor;

  /// 渐变图表背景；与 [backgroundColor] 二选一。
  final List<Color>? backgroundGradient;

  /// 坐标、指标和普通说明文字颜色。
  final Color? textColor;

  /// 图表网格颜色。
  final Color? gridColor;

  /// 上涨色，同时作为当前价、买盘和上涨详情颜色的默认值。
  final Color? upColor;

  /// 下跌色，同时作为当前价、卖盘和下跌详情颜色的默认值。
  final Color? downColor;

  /// 趋势折线颜色。
  final Color? lineColor;

  /// 趋势折线填充颜色。
  final Color? lineFillColor;

  /// 成交量及 MACD 柱的强调色。
  final Color? volumeColor;

  /// MA 颜色，依次对应 MA5、MA10、MA30；不足三项时继承主题颜色。
  final List<Color>? movingAverageColors;

  /// 当前价虚线与标签颜色。
  final NowPriceColorConfig? nowPrice;

  /// 将外部配置合并到完整颜色对象中。
  ChartColors applyTo(ChartColors base) {
    Color? movingAverageAt(int index) {
      final colors = movingAverageColors;
      return colors != null && index < colors.length ? colors[index] : null;
    }

    final configuredGradient = backgroundGradient;
    final List<Color>? background;
    if (configuredGradient == null || configuredGradient.isEmpty) {
      background = backgroundColor == null
          ? null
          : List<Color>.unmodifiable([backgroundColor!, backgroundColor!]);
    } else if (configuredGradient.length == 1) {
      background = List<Color>.unmodifiable([
        configuredGradient.single,
        configuredGradient.single,
      ]);
    } else {
      background = List<Color>.unmodifiable(configuredGradient);
    }

    return base.copyWith(
      bgColor: background,
      defaultTextColor: textColor,
      gridColor: gridColor,
      upColor: upColor,
      dnColor: downColor,
      kLineColor: lineColor,
      lineFillColor: lineFillColor,
      volColor: volumeColor,
      macdColor: volumeColor,
      ma5Color: movingAverageAt(0),
      ma10Color: movingAverageAt(1),
      ma30Color: movingAverageAt(2),
      nowPriceUpColor: nowPrice?.upLineColor ?? upColor,
      nowPriceDnColor: nowPrice?.downLineColor ?? downColor,
      nowPriceTextColor: nowPrice?.textColor,
      nowPriceChipBgColor: nowPrice?.backgroundColor,
      nowPriceChipBorderColor: nowPrice?.borderColor,
      depthBuyColor: upColor,
      depthSellColor: downColor,
      infoWindowUpColor: upColor,
      infoWindowDnColor: downColor,
    );
  }
}

/// 当前价格横线和价格标签的外部颜色配置。
class NowPriceColorConfig {
  const NowPriceColorConfig({
    this.textColor,
    this.backgroundColor,
    this.borderColor,
    this.upLineColor,
    this.downLineColor,
  });

  final Color? textColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? upLineColor;
  final Color? downLineColor;
}

class ChartColors {
  List<Color> bgColor = [const Color(0xff18191d), const Color(0xff18191d)];

  Color kLineColor = const Color(0xff4C86CD);
  Color lineFillColor = const Color(0x554C86CD);
  Color lineFillInsideColor = const Color(0x00000000);
  Color ma5Color = const Color(0xffC9B885);
  Color ma10Color = const Color(0xff6CB0A6);
  Color ma30Color = const Color(0xff9979C6);
  Color upColor = const Color(0xff4DAA90);
  Color dnColor = const Color(0xffC15466);
  Color volColor = const Color(0xff4729AE);

  Color macdColor = const Color(0xff4729AE);
  Color difColor = const Color(0xffC9B885);
  Color deaColor = const Color(0xff6CB0A6);

  Color kColor = const Color(0xffC9B885);
  Color dColor = const Color(0xff6CB0A6);
  Color jColor = const Color(0xff9979C6);
  Color rsiColor = const Color(0xffC9B885);

  Color defaultTextColor = const Color(0xff60738E);

  Color nowPriceUpColor = const Color(0xff4DAA90);
  Color nowPriceDnColor = const Color(0xffC15466);
  Color nowPriceTextColor = const Color(0xffffffff);
  Color nowPriceChipBgColor = const Color(0xFF272729);
  Color nowPriceChipBorderColor = const Color(0xFF151517);

  //深度颜色
  Color depthBuyColor = const Color(0xff60A893);
  Color depthSellColor = const Color(0xffC15866);

  //选中后显示值边框颜色
  Color selectBorderColor = const Color(0xff6C7A86);

  //选中后显示值背景的填充颜色
  Color selectFillColor = const Color(0xff0D1722);

  //分割线颜色
  Color gridColor = const Color(0xff4c5c74);

  Color infoWindowNormalColor = const Color(0xffffffff);
  Color infoWindowTitleColor = const Color(0xffffffff);
  Color infoWindowUpColor = const Color(0xff00ff00);
  Color infoWindowDnColor = const Color(0xffff0000);

  Color hCrossColor = const Color(0xffffffff);
  Color vCrossColor = const Color(0x1Effffff);
  Color crossTextColor = const Color(0xffffffff);

  //当前显示内最大和最小值的颜色
  Color maxColor = const Color(0xffffffff);
  Color minColor = const Color(0xffffffff);

  /// 根据精简的外部配置生成完整颜色对象。
  static ChartColors fromConfig(
    ChartColorConfig config, {
    ChartTheme? baseTheme,
  }) {
    final resolvedTheme = baseTheme ?? config.baseTheme;
    final base = resolvedTheme == ChartTheme.light
        ? ChartColors.light()
        : ChartColors.dark();
    return config.applyTo(base);
  }

  Color getMAColor(int index) {
    switch (index % 3) {
      case 1:
        return ma10Color;
      case 2:
        return ma30Color;
      default:
        return ma5Color;
    }
  }

  // copyWith方法，方便基于现有主题创建自定义颜色
  ChartColors copyWith({
    List<Color>? bgColor,
    Color? kLineColor,
    Color? lineFillColor,
    Color? lineFillInsideColor,
    Color? ma5Color,
    Color? ma10Color,
    Color? ma30Color,
    Color? upColor,
    Color? dnColor,
    Color? volColor,
    Color? macdColor,
    Color? difColor,
    Color? deaColor,
    Color? kColor,
    Color? dColor,
    Color? jColor,
    Color? rsiColor,
    Color? defaultTextColor,
    Color? nowPriceUpColor,
    Color? nowPriceDnColor,
    Color? nowPriceTextColor,
    Color? nowPriceChipBgColor,
    Color? nowPriceChipBorderColor,
    Color? depthBuyColor,
    Color? depthSellColor,
    Color? selectBorderColor,
    Color? selectFillColor,
    Color? gridColor,
    Color? infoWindowNormalColor,
    Color? infoWindowTitleColor,
    Color? infoWindowUpColor,
    Color? infoWindowDnColor,
    Color? hCrossColor,
    Color? vCrossColor,
    Color? crossTextColor,
    Color? maxColor,
    Color? minColor,
  }) {
    final newColors = ChartColors();

    newColors.bgColor = bgColor ?? this.bgColor;
    newColors.kLineColor = kLineColor ?? this.kLineColor;
    newColors.lineFillColor = lineFillColor ?? this.lineFillColor;
    newColors.lineFillInsideColor =
        lineFillInsideColor ?? this.lineFillInsideColor;
    newColors.ma5Color = ma5Color ?? this.ma5Color;
    newColors.ma10Color = ma10Color ?? this.ma10Color;
    newColors.ma30Color = ma30Color ?? this.ma30Color;
    newColors.upColor = upColor ?? this.upColor;
    newColors.dnColor = dnColor ?? this.dnColor;
    newColors.volColor = volColor ?? this.volColor;
    newColors.macdColor = macdColor ?? this.macdColor;
    newColors.difColor = difColor ?? this.difColor;
    newColors.deaColor = deaColor ?? this.deaColor;
    newColors.kColor = kColor ?? this.kColor;
    newColors.dColor = dColor ?? this.dColor;
    newColors.jColor = jColor ?? this.jColor;
    newColors.rsiColor = rsiColor ?? this.rsiColor;
    newColors.defaultTextColor = defaultTextColor ?? this.defaultTextColor;
    newColors.nowPriceUpColor = nowPriceUpColor ?? this.nowPriceUpColor;
    newColors.nowPriceDnColor = nowPriceDnColor ?? this.nowPriceDnColor;
    newColors.nowPriceTextColor = nowPriceTextColor ?? this.nowPriceTextColor;
    newColors.nowPriceChipBgColor =
        nowPriceChipBgColor ?? this.nowPriceChipBgColor;
    newColors.nowPriceChipBorderColor =
        nowPriceChipBorderColor ?? this.nowPriceChipBorderColor;
    newColors.depthBuyColor = depthBuyColor ?? this.depthBuyColor;
    newColors.depthSellColor = depthSellColor ?? this.depthSellColor;
    newColors.selectBorderColor = selectBorderColor ?? this.selectBorderColor;
    newColors.selectFillColor = selectFillColor ?? this.selectFillColor;
    newColors.gridColor = gridColor ?? this.gridColor;
    newColors.infoWindowNormalColor =
        infoWindowNormalColor ?? this.infoWindowNormalColor;
    newColors.infoWindowTitleColor =
        infoWindowTitleColor ?? this.infoWindowTitleColor;
    newColors.infoWindowUpColor = infoWindowUpColor ?? this.infoWindowUpColor;
    newColors.infoWindowDnColor = infoWindowDnColor ?? this.infoWindowDnColor;
    newColors.hCrossColor = hCrossColor ?? this.hCrossColor;
    newColors.vCrossColor = vCrossColor ?? this.vCrossColor;
    newColors.crossTextColor = crossTextColor ?? this.crossTextColor;
    newColors.maxColor = maxColor ?? this.maxColor;
    newColors.minColor = minColor ?? this.minColor;

    return newColors;
  }

  // 亮色主题颜色
  static ChartColors light() {
    final colors = ChartColors();
    colors.bgColor = [const Color(0xffffffff), const Color(0xffffffff)];
    colors.kLineColor = const Color(0xff2196F3);
    colors.lineFillColor = const Color(0x552196F3);
    colors.lineFillInsideColor = const Color(0x00000000);
    colors.ma5Color = const Color(0xffFF9800);
    colors.ma10Color = const Color(0xff129A48);

    colors.ma30Color = const Color(0xff9C27B0);
    colors.upColor = const Color(0xff129A48);
    colors.dnColor = const Color(0xffEA4747);
    colors.volColor = const Color(0xff673AB7);

    colors.macdColor = const Color(0xff673AB7);
    colors.difColor = const Color(0xffFF9800);
    colors.deaColor = const Color(0xff129A48);

    colors.kColor = const Color(0xffFF9800);
    colors.dColor = const Color(0xff129A48);
    colors.jColor = const Color(0xff9C27B0);
    colors.rsiColor = const Color(0xffFF9800);

    colors.defaultTextColor = const Color(0xff424242);

    colors.nowPriceUpColor = const Color(0xff129A48);
    colors.nowPriceDnColor = const Color(0xffEA4747);
    colors.nowPriceTextColor = const Color(0xFF151517);
    colors.nowPriceChipBgColor = const Color(0xFFF5F5F5);
    colors.nowPriceChipBorderColor = const Color(0xFFE0E0E0);

    colors.depthBuyColor = const Color(0xff129A48);
    colors.depthSellColor = const Color(0xffEA4747);

    colors.selectBorderColor = const Color(0xffF8F8F8);
    colors.selectFillColor = const Color(0xffF8F8F8);

    colors.gridColor = const Color(0xffE0E0E0);

    colors.infoWindowNormalColor = const Color(0xff000000);
    colors.infoWindowTitleColor = const Color(0xff000000);
    colors.infoWindowUpColor = const Color(0xff129A48);
    colors.infoWindowDnColor = const Color(0xffEA4747);

    colors.hCrossColor = const Color(0xff000000);
    colors.vCrossColor = const Color(0xff000000);
    colors.crossTextColor = const Color(0xff000000);

    colors.maxColor = const Color(0xff000000);
    colors.minColor = const Color(0xff000000);

    return colors;
  }

  // 暗色主题颜色
  static ChartColors dark() {
    final colors = ChartColors();
    colors.bgColor = [const Color(0xff18191d), const Color(0xff18191d)];
    colors.kLineColor = const Color(0xff4C86CD);
    colors.lineFillColor = const Color(0x554C86CD);
    colors.lineFillInsideColor = const Color(0x00000000);
    colors.ma5Color = const Color(0xffC9B885);
    colors.ma10Color = const Color(0xff6CB0A6);
    colors.ma30Color = const Color(0xff9979C6);
    colors.upColor = const Color(0xff129A48);
    colors.dnColor = const Color(0xffEA4747);
    colors.volColor = const Color(0xff4729AE);

    colors.macdColor = const Color(0xff4729AE);
    colors.difColor = const Color(0xffC9B885);
    colors.deaColor = const Color(0xff6CB0A6);

    colors.kColor = const Color(0xffC9B885);
    colors.dColor = const Color(0xff6CB0A6);
    colors.jColor = const Color(0xff9979C6);
    colors.rsiColor = const Color(0xffC9B885);

    colors.defaultTextColor = const Color(0xff60738E);

    colors.nowPriceUpColor = const Color(0xff129A48);
    colors.nowPriceDnColor = const Color(0xffEA4747);
    colors.nowPriceTextColor = const Color(0xFF151517);
    colors.nowPriceChipBgColor = const Color(0xFF272729);
    colors.nowPriceChipBorderColor = const Color(0xFF151517);

    colors.depthBuyColor = const Color(0xff60A893);
    colors.depthSellColor = const Color(0xffC15866);

    colors.selectBorderColor = const Color(0xff6C7A86);
    colors.selectFillColor = const Color(0xff0D1722);

    colors.gridColor = const Color(0xff4c5c74);

    colors.infoWindowNormalColor = const Color(0xffffffff);
    colors.infoWindowTitleColor = const Color(0xffffffff);
    colors.infoWindowUpColor = const Color(0xff00ff00);
    colors.infoWindowDnColor = const Color(0xffff0000);

    colors.hCrossColor = const Color(0xffffffff);
    colors.vCrossColor = const Color(0xffffffff);
    colors.crossTextColor = const Color(0xffffffff);

    colors.maxColor = const Color(0xffffffff);
    colors.minColor = const Color(0xffffffff);

    return colors;
  }
}

/// Y 轴缩放模式。
enum YAxisScaleMode {
  /// 完整显示全部影线（Y 轴包含真实极值）。
  full,

  /// 极端长影线按 ATR 倍数截断显示，Y 轴范围基于截断后的极值。
  wickClipped,
}

class ChartStyle {
  double topPadding = 30.0;
  double bottomPadding = 20.0;
  double childPadding = 12.0;

  //点与点的距离
  double pointWidth = 11.0;

  //蜡烛宽度
  double candleWidth = 8.5;

  //蜡烛中间线的宽度
  double candleLineWidth = 1.5;

  //蜡烛实体圆角半径
  double candleCornerRadius = 2.0;

  /// Y 轴缩放模式：
  /// - [YAxisScaleMode.wickClipped]（默认）：极端长影线按 ATR 倍数截断显示，
  ///   Y 轴范围基于截断后的极值，避免主体与指标被压扁
  /// - [YAxisScaleMode.full]：完整显示全部影线，Y 轴包含真实极值
  YAxisScaleMode yAxisScaleMode = YAxisScaleMode.wickClipped;

  /// 影线截断阈值 = ATR × [wickClipAtrFactor]（仅 wickClipped 模式生效）。
  double wickClipAtrFactor = 2.5;

  /// ATR 计算周期（仅 wickClipped 模式生效）。
  int wickClipAtrPeriod = 14;

  //vol柱子宽度
  double volWidth = 8.5;

  //macd柱子宽度
  double macdWidth = 3.0;

  //垂直交叉线宽度
  double vCrossWidth = 8.5;

  //水平交叉线宽度
  double hCrossWidth = 0.5;

  //现在价格的线条长度
  double nowPriceLineLength = 1;

  //现在价格的线条间隔
  double nowPriceLineSpan = 1;

  //现在价格的线条粗细
  double nowPriceLineWidth = 1;

  int gridRows = 4;
  int gridColumns = 4;

  //下方時間客製化
  List<String>? dateTimeFormat;

  // copyWith方法，方便自定义样式
  ChartStyle copyWith({
    double? topPadding,
    double? bottomPadding,
    double? childPadding,
    double? pointWidth,
    double? candleWidth,
    double? candleLineWidth,
    double? candleCornerRadius,
    YAxisScaleMode? yAxisScaleMode,
    double? wickClipAtrFactor,
    int? wickClipAtrPeriod,
    double? volWidth,
    double? macdWidth,
    double? vCrossWidth,
    double? hCrossWidth,
    double? nowPriceLineLength,
    double? nowPriceLineSpan,
    double? nowPriceLineWidth,
    int? gridRows,
    int? gridColumns,
    List<String>? dateTimeFormat,
  }) {
    final newStyle = ChartStyle();

    newStyle.topPadding = topPadding ?? this.topPadding;
    newStyle.bottomPadding = bottomPadding ?? this.bottomPadding;
    newStyle.childPadding = childPadding ?? this.childPadding;
    newStyle.pointWidth = pointWidth ?? this.pointWidth;
    newStyle.candleWidth = candleWidth ?? this.candleWidth;
    newStyle.candleLineWidth = candleLineWidth ?? this.candleLineWidth;
    newStyle.candleCornerRadius = candleCornerRadius ?? this.candleCornerRadius;
    newStyle.yAxisScaleMode = yAxisScaleMode ?? this.yAxisScaleMode;
    newStyle.wickClipAtrFactor = wickClipAtrFactor ?? this.wickClipAtrFactor;
    newStyle.wickClipAtrPeriod = wickClipAtrPeriod ?? this.wickClipAtrPeriod;
    newStyle.volWidth = volWidth ?? this.volWidth;
    newStyle.macdWidth = macdWidth ?? this.macdWidth;
    newStyle.vCrossWidth = vCrossWidth ?? this.vCrossWidth;
    newStyle.hCrossWidth = hCrossWidth ?? this.hCrossWidth;
    newStyle.nowPriceLineLength = nowPriceLineLength ?? this.nowPriceLineLength;
    newStyle.nowPriceLineSpan = nowPriceLineSpan ?? this.nowPriceLineSpan;
    newStyle.nowPriceLineWidth = nowPriceLineWidth ?? this.nowPriceLineWidth;
    newStyle.gridRows = gridRows ?? this.gridRows;
    newStyle.gridColumns = gridColumns ?? this.gridColumns;
    newStyle.dateTimeFormat = dateTimeFormat ?? this.dateTimeFormat;

    return newStyle;
  }
}

class ChartThemeManager {
  static ChartTheme _currentTheme = ChartTheme.light;

  static ChartTheme get currentTheme => _currentTheme;

  static void setTheme(ChartTheme theme) {
    _currentTheme = theme;
  }

  static ChartColors getColors() {
    switch (_currentTheme) {
      case ChartTheme.light:
        return ChartColors.light();
      case ChartTheme.dark:
        return ChartColors.dark();
    }
  }

  static void toggleTheme() {
    _currentTheme = _currentTheme == ChartTheme.light
        ? ChartTheme.dark
        : ChartTheme.light;
  }
}
