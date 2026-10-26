import 'dart:math';

import 'package:flutter/material.dart';

import '../entity/candle_entity.dart';
import '../k_chart_widget.dart' show CandleType, MainState;
import '../vertical_text_alignment.dart';
import 'base_chart_renderer.dart';

class MainRenderer extends BaseChartRenderer<CandleEntity> {
  late double mCandleWidth;
  late double mCandleLineWidth;
  List<MainState> states;
  bool isLine;

  //绘制的内容区域
  late Rect _contentRect;
  double _contentPadding = 5.0;
  List<int> maDayList;
  final ChartStyle chartStyle;
  final ChartColors chartColors;
  final double mLineStrokeWidth = 1.0;
  double scaleX;
  late Paint mLinePaint;
  final VerticalTextAlignment verticalTextAlignment;
  final CandleType candleType;

  /// 影线截断阈值（ATR × factor）；0 表示不截断。
  final double wickClipThreshold;

  MainRenderer(
    Rect mainRect,
    double maxValue,
    double minValue,
    double topPadding,
    this.states,
    this.isLine,
    int fixedLength,
    this.chartStyle,
    this.chartColors,
    this.scaleX,
    this.verticalTextAlignment, [
    this.maDayList = const [5, 10, 20],
    this.candleType = CandleType.solid,
    this.wickClipThreshold = 0,
  ]) : super(
         chartRect: mainRect,
         maxValue: maxValue,
         minValue: minValue,
         topPadding: topPadding,
         fixedLength: fixedLength,
         gridColor: chartColors.gridColor,
       ) {
    mCandleWidth = this.chartStyle.candleWidth;
    mCandleLineWidth = this.chartStyle.candleLineWidth;
    mLinePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = mLineStrokeWidth
      ..color = this.chartColors.kLineColor;
    final contentTop = min(chartRect.bottom, chartRect.top + _contentPadding);
    final contentBottom = max(contentTop, chartRect.bottom - _contentPadding);
    _contentRect = Rect.fromLTRB(
      chartRect.left,
      contentTop,
      chartRect.right,
      contentBottom,
    );
    scaleY = _contentRect.height <= 0
        ? 0
        : _contentRect.height / (this.maxValue - this.minValue);
  }

  @override
  void drawText(Canvas canvas, CandleEntity data, double x) {
    if (isLine == true) return;
    final children = <InlineSpan>[];
    for (final state in states) {
      if (state == MainState.MA) {
        children.addAll(_createMATextSpan(data));
      } else if (state == MainState.EMA) {
        children.addAll(_createEMATextSpan(data));
      } else if (state == MainState.BOLL) {
        children.addAll([
          if (data.up != 0)
            TextSpan(
              text: "BOLL:${format(data.mb)}    ",
              style: getTextStyle(this.chartColors.ma5Color),
            ),
          if (data.mb != 0)
            TextSpan(
              text: "UB:${format(data.up)}    ",
              style: getTextStyle(this.chartColors.ma10Color),
            ),
          if (data.dn != 0)
            TextSpan(
              text: "LB:${format(data.dn)}    ",
              style: getTextStyle(this.chartColors.ma30Color),
            ),
        ]);
      } else if (state == MainState.SAR) {
        children.addAll([
          TextSpan(
            text: "SAR:${format(data.sar)}    ",
            style: getTextStyle(this.chartColors.ma10Color),
          ),
        ]);
      }
    }
    if (children.isEmpty) return;
    final span = TextSpan(children: children);
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x, chartRect.top - topPadding));
  }

  List<InlineSpan> _createEMATextSpan(CandleEntity data) {
    List<InlineSpan> result = [];
    for (int i = 0; i < (data.emaValueList?.length ?? 0); i++) {
      if (data.emaValueList?[i] != 0) {
        var item = TextSpan(
          text: "EMA${maDayList[i]}:${format(data.emaValueList![i])}    ",
          style: getTextStyle(this.chartColors.getMAColor(i)),
        );
        result.add(item);
      }
    }
    return result;
  }

  List<InlineSpan> _createMATextSpan(CandleEntity data) {
    List<InlineSpan> result = [];
    for (int i = 0; i < (data.maValueList?.length ?? 0); i++) {
      if (data.maValueList?[i] != 0) {
        var item = TextSpan(
          text: "MA${maDayList[i]}:${format(data.maValueList![i])}    ",
          style: getTextStyle(this.chartColors.getMAColor(i)),
        );
        result.add(item);
      }
    }
    return result;
  }

  @override
  void drawChart(
    CandleEntity lastPoint,
    CandleEntity curPoint,
    double lastX,
    double curX,
    Size size,
    Canvas canvas,
  ) {
    if (isLine) {
      drawPolyline(lastPoint.close, curPoint.close, canvas, lastX, curX);
    } else {
      drawCandle(curPoint, canvas, curX);
      for (final state in states) {
        if (state == MainState.MA) {
          drawMaLine(lastPoint, curPoint, canvas, lastX, curX);
        } else if (state == MainState.EMA) {
          drawEmaLine(lastPoint, curPoint, canvas, lastX, curX);
        } else if (state == MainState.BOLL) {
          drawBollLine(lastPoint, curPoint, canvas, lastX, curX);
        } else if (state == MainState.SAR) {
          drawSarPoint(curPoint, canvas, curX);
        }
      }
    }
  }

  Shader? mLineFillShader;
  Path? mLinePath, mLineFillPath;
  Paint mLineFillPaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  //画折线图
  drawPolyline(
    double lastPrice,
    double curPrice,
    Canvas canvas,
    double lastX,
    double curX,
  ) {
    //    drawLine(lastPrice + 100, curPrice + 100, canvas, lastX, curX, ChartColors.kLineColor);
    mLinePath ??= Path();

    //    if (lastX == curX) {
    //      mLinePath.moveTo(lastX, getY(lastPrice));
    //    } else {
    ////      mLinePath.lineTo(curX, getY(curPrice));
    //      mLinePath.cubicTo(
    //          (lastX + curX) / 2, getY(lastPrice), (lastX + curX) / 2, getY(curPrice), curX, getY(curPrice));
    //    }
    if (lastX == curX) lastX = 0; //起点位置填充
    mLinePath!.moveTo(lastX, getY(lastPrice));
    mLinePath!.cubicTo(
      (lastX + curX) / 2,
      getY(lastPrice),
      (lastX + curX) / 2,
      getY(curPrice),
      curX,
      getY(curPrice),
    );

    //画阴影
    mLineFillShader ??=
        LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          tileMode: TileMode.clamp,
          colors: [
            this.chartColors.lineFillColor,
            this.chartColors.lineFillInsideColor,
          ],
        ).createShader(
          Rect.fromLTRB(
            chartRect.left,
            chartRect.top,
            chartRect.right,
            chartRect.bottom,
          ),
        );
    mLineFillPaint..shader = mLineFillShader;

    mLineFillPath ??= Path();

    mLineFillPath!.moveTo(lastX, chartRect.height + chartRect.top);
    mLineFillPath!.lineTo(lastX, getY(lastPrice));
    mLineFillPath!.cubicTo(
      (lastX + curX) / 2,
      getY(lastPrice),
      (lastX + curX) / 2,
      getY(curPrice),
      curX,
      getY(curPrice),
    );
    mLineFillPath!.lineTo(curX, chartRect.height + chartRect.top);
    mLineFillPath!.close();

    canvas.drawPath(mLineFillPath!, mLineFillPaint);
    mLineFillPath!.reset();

    canvas.drawPath(
      mLinePath!,
      mLinePaint..strokeWidth = (mLineStrokeWidth / scaleX).clamp(0.1, 1.0),
    );
    mLinePath!.reset();
  }

  void drawMaLine(
    CandleEntity lastPoint,
    CandleEntity curPoint,
    Canvas canvas,
    double lastX,
    double curX,
  ) {
    for (int i = 0; i < (curPoint.maValueList?.length ?? 0); i++) {
      if (i == 3) {
        break;
      }
      if (lastPoint.maValueList?[i] != 0) {
        drawLine(
          lastPoint.maValueList?[i],
          curPoint.maValueList?[i],
          canvas,
          lastX,
          curX,
          this.chartColors.getMAColor(i),
        );
      }
    }
  }

  void drawEmaLine(
    CandleEntity lastPoint,
    CandleEntity curPoint,
    Canvas canvas,
    double lastX,
    double curX,
  ) {
    for (int i = 0; i < (curPoint.emaValueList?.length ?? 0); i++) {
      if (i == 3) {
        break;
      }
      if (lastPoint.emaValueList?[i] != 0) {
        drawLine(
          lastPoint.emaValueList?[i],
          curPoint.emaValueList?[i],
          canvas,
          lastX,
          curX,
          this.chartColors.getMAColor(i),
        );
      }
    }
  }

  void drawBollLine(
    CandleEntity lastPoint,
    CandleEntity curPoint,
    Canvas canvas,
    double lastX,
    double curX,
  ) {
    if (lastPoint.up != 0) {
      drawLine(
        lastPoint.up,
        curPoint.up,
        canvas,
        lastX,
        curX,
        this.chartColors.ma10Color,
      );
    }
    if (lastPoint.mb != 0) {
      drawLine(
        lastPoint.mb,
        curPoint.mb,
        canvas,
        lastX,
        curX,
        this.chartColors.ma5Color,
      );
    }
    if (lastPoint.dn != 0) {
      drawLine(
        lastPoint.dn,
        curPoint.dn,
        canvas,
        lastX,
        curX,
        this.chartColors.ma30Color,
      );
    }
  }

  void drawSarPoint(CandleEntity curPoint, Canvas canvas, double curX) {
    final sar = curPoint.sar;
    if (sar == null) return;
    canvas.drawCircle(
      Offset(curX, getY(sar)),
      (1.6 / scaleX).clamp(0.9, 1.8),
      chartPaint..color = this.chartColors.ma10Color,
    );
  }

  void drawCandle(CandleEntity curPoint, Canvas canvas, double curX) {
    var high = curPoint.high;
    var low = curPoint.low;
    var highClipped = false;
    var lowClipped = false;
    if (wickClipThreshold > 0) {
      final upper = max(curPoint.open, curPoint.close) + wickClipThreshold;
      final lower = min(curPoint.open, curPoint.close) - wickClipThreshold;
      if (high > upper) {
        high = upper;
        highClipped = true;
      }
      if (low < lower) {
        low = lower;
        lowClipped = true;
      }
    }
    final highY = getY(high);
    final lowY = getY(low);
    var open = getY(curPoint.open);
    var close = getY(curPoint.close);
    double r = mCandleWidth / 2;
    double lineR = mCandleLineWidth / 2;
    final cornerRadius = chartStyle.candleCornerRadius.clamp(0.0, r);
    if (open >= close) {
      if (open - close < mCandleLineWidth) {
        open = close + mCandleLineWidth;
      }
      chartPaint.color = this.chartColors.upColor;
      final body = RRect.fromRectAndRadius(
        Rect.fromLTRB(curX - r, close, curX + r, open),
        Radius.circular(cornerRadius),
      );
      if (candleType == CandleType.hollowUp) {
        canvas.drawRRect(
          body,
          Paint()
            ..color = chartColors.upColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = (1 / scaleX).clamp(0.5, 1.2),
        );
      } else {
        canvas.drawRRect(body, chartPaint);
      }
      canvas.drawRect(
        Rect.fromLTRB(curX - lineR, highY, curX + lineR, lowY),
        chartPaint,
      );
      if (highClipped) {
        _drawWickClipMark(canvas, curX, highY, r);
      }
      if (lowClipped) {
        _drawWickClipMark(canvas, curX, lowY, r);
      }
    } else if (close > open) {
      if (close - open < mCandleLineWidth) {
        open = close - mCandleLineWidth;
      }
      chartPaint.color = this.chartColors.dnColor;
      final body = RRect.fromRectAndRadius(
        Rect.fromLTRB(curX - r, open, curX + r, close),
        Radius.circular(cornerRadius),
      );
      if (candleType == CandleType.hollowDown) {
        canvas.drawRRect(
          body,
          Paint()
            ..color = chartColors.dnColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = (1 / scaleX).clamp(0.5, 1.2),
        );
      } else {
        canvas.drawRRect(body, chartPaint);
      }
      canvas.drawRect(
        Rect.fromLTRB(curX - lineR, highY, curX + lineR, lowY),
        chartPaint,
      );
      if (highClipped) {
        _drawWickClipMark(canvas, curX, highY, r);
      }
      if (lowClipped) {
        _drawWickClipMark(canvas, curX, lowY, r);
      }
    }
  }

  void _drawWickClipMark(Canvas canvas, double curX, double y, double r) {
    final markPaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = (1 / scaleX).clamp(0.6, 1.0)
      ..color = chartPaint.color;
    canvas.drawLine(Offset(curX - r, y), Offset(curX + r, y), markPaint);
  }

  @override
  void drawVerticalText(canvas, textStyle, int gridRows) {
    double rowSpace = chartRect.height / gridRows;
    for (var i = 0; i <= gridRows; ++i) {
      double value = (gridRows - i) * rowSpace / scaleY + minValue;
      TextSpan span = TextSpan(text: "${format(value)}", style: textStyle);
      TextPainter tp = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      );
      tp.layout();

      double offsetX;
      switch (verticalTextAlignment) {
        case VerticalTextAlignment.left:
          offsetX = 0;
          break;
        case VerticalTextAlignment.right:
          offsetX = chartRect.width - tp.width - 4;
          break;
      }

      if (i == 0) {
        tp.paint(canvas, Offset(offsetX, topPadding));
      } else {
        tp.paint(
          canvas,
          Offset(offsetX, rowSpace * i - tp.height + topPadding),
        );
      }
    }
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
    //    final int gridRows = 4, gridColumns = 4;
    double rowSpace = chartRect.height / gridRows;
    for (int i = 0; i <= gridRows; i++) {
      canvas.drawLine(
        Offset(0, rowSpace * i + topPadding),
        Offset(chartRect.width, rowSpace * i + topPadding),
        gridPaint,
      );
    }
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= gridColumns; i++) {
      canvas.drawLine(
        Offset(columnSpace * i, topPadding / 3),
        Offset(columnSpace * i, chartRect.bottom),
        gridPaint,
      );
    }
  }

  @override
  double getY(double y) {
    final value = (maxValue - y) * scaleY + _contentRect.top;
    return value.clamp(_contentRect.top, _contentRect.bottom);
  }
}
