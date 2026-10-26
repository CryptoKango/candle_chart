import 'dart:math';

import '../entity/k_line_entity.dart';

/// 单根 K 线的真实波幅（True Range）。
///
/// [prev] 为前一根 K 线；为空时用当前开盘价作为前收（退化为 high-low）。
double trueRange(KLineEntity cur, KLineEntity? prev) {
  final prevClose = prev?.close ?? cur.open;
  return max(
    cur.high - cur.low,
    max((cur.high - prevClose).abs(), (cur.low - prevClose).abs()),
  );
}

/// 可见窗口 [start, stop]（含两端）内的简单平均 ATR。
///
/// [period] 保留用于未来扩展（如 Wilder 平滑），当前实现为窗口内
/// 全部 K 线的简单平均。
double calcAtr(List<KLineEntity> datas, int start, int stop, int period) {
  if (datas.isEmpty || start > stop) return 0;
  var sum = 0.0;
  var count = 0;
  for (var i = start; i <= stop; i++) {
    final prev = i > start ? datas[i - 1] : null;
    sum += trueRange(datas[i], prev);
    count++;
  }
  if (count == 0) return 0;
  return sum / count;
}

/// 按阈值截断影线，返回截断后的 (high, low)。
///
/// 上限 = max(open, close) + threshold；下限 = min(open, close) - threshold。
/// 实体（open/close）本身不做截断。
(double, double) clampWick(
  double high,
  double low,
  double open,
  double close,
  double threshold,
) {
  if (threshold <= 0) return (high, low);
  final upper = max(open, close) + threshold;
  final lower = min(open, close) - threshold;
  return (min(high, upper), max(low, lower));
}
