import 'package:flutter/material.dart';
import '../chart_style.dart';

/// 从外部 theme 映射为 [ChartColors]。
///
/// [lib_chart] 不依赖 [common_ui]，消费方在 feature 包中
/// 传入自己的 theme 颜色即可：
///
/// ```dart
/// KChartWidget(
///   datas: data,
///   chartColors: chartColorsFromTheme(
///     upColor: context.appTheme.colorUp,
///     downColor: context.appTheme.colorDown,
///     textColor: context.appTheme.colorText,
///     gridColor: context.appTheme.colorBorder,
///     bgColor: context.appTheme.colorBackground,
///   ),
/// )
/// ```
ChartColors chartColorsFromTheme({
  Color upColor = const Color(0xff129A48),
  Color downColor = const Color(0xffEA4747),
  Color textColor = const Color(0xff424242),
  Color gridColor = const Color(0xffE0E0E0),
  Color bgColor = const Color(0xffffffff),
  Color? ma5Color,
  Color? ma10Color,
  Color? ma30Color,
  Color? nowPriceChipBgColor,
  Color? nowPriceChipBorderColor,
}) {
  final c = ChartColors.light();
  c.upColor = upColor;
  c.dnColor = downColor;
  c.defaultTextColor = textColor;
  c.gridColor = gridColor;
  c.bgColor = [bgColor, bgColor];

  if (ma5Color != null) c.ma5Color = ma5Color;
  if (ma10Color != null) c.ma10Color = ma10Color;
  if (ma30Color != null) c.ma30Color = ma30Color;
  if (nowPriceChipBgColor != null) c.nowPriceChipBgColor = nowPriceChipBgColor;
  if (nowPriceChipBorderColor != null) {
    c.nowPriceChipBorderColor = nowPriceChipBorderColor;
  }

  return c;
}
