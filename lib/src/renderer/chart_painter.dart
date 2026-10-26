import 'dart:async' show StreamSink;

import 'package:flutter/material.dart';
import '../entity/info_window_entity.dart';
import '../entity/k_line_entity.dart';
import '../k_chart_widget.dart' show CandleType, MainState, SecondaryState;
import '../utils/date_format_util.dart';
import '../utils/drawing_tool_manager.dart';
import '../utils/index.dart';
import '../utils/timestamp_util.dart';
import '../vertical_text_alignment.dart';
import 'base_chart_painter.dart';
import 'base_chart_renderer.dart';
import 'main_renderer.dart';
import 'secondary_renderer.dart';
import 'vol_renderer.dart';

class TrendLine {
  final Offset p1;
  final Offset p2;
  final double maxHeight;
  final double scale;

  TrendLine(this.p1, this.p2, this.maxHeight, this.scale);
}

class ChartPainter extends BaseChartPainter {
  final List<TrendLine> lines; //For TrendLine (保留兼容性)
  final bool isTrendLine; //For TrendLine (保留兼容性)
  bool isrecordingCord = false; //For TrendLine (保留兼容性)
  final double selectY; //For TrendLine (保留兼容性)

  // 新增绘图工具支持
  final DrawingToolManager? drawingToolManager;

  late BaseChartRenderer mMainRenderer;
  BaseChartRenderer? mVolRenderer, mSecondaryRenderer;
  final Map<SecondaryState, BaseChartRenderer> mSecondaryRenderers = {};
  StreamSink<InfoWindowEntity?>? sink;
  Color? upColor, dnColor;
  Color? ma5Color, ma10Color, ma30Color;
  Color? volColor;
  Color? macdColor, difColor, deaColor, jColor;
  int fixedLength;
  List<int> maDayList;
  final ChartColors chartColors;
  late Paint selectPointPaint, selectorBorderPaint, nowPricePaint;
  final ChartStyle chartStyle;
  final bool hideGrid;
  final bool showNowPrice;
  final VerticalTextAlignment verticalTextAlignment;
  final CandleType candleType;
  final int dataRevision;
  final int paintRevision;
  late final int _configurationHash;

  ChartPainter(
    this.chartStyle,
    this.chartColors, {
    required this.lines, //For TrendLine (保留兼容性)
    required this.isTrendLine, //For TrendLine (保留兼容性)
    required this.selectY, //For TrendLine (保留兼容性)
    this.drawingToolManager, // 新增绘图工具管理器
    required datas,
    required scaleX,
    required scrollX,
    required isLongPass,
    required selectX,
    required xFrontPadding,
    isOnTap,
    isTapShowInfoDialog,
    required this.verticalTextAlignment,
    mainState,
    List<MainState>? mainStates,
    volHidden,
    secondaryState,
    List<SecondaryState>? secondaryStates,
    double singleSecondaryChartHeight = 64,
    this.candleType = CandleType.solid,
    this.sink,
    bool isLine = false,
    this.hideGrid = false,
    this.showNowPrice = true,
    this.fixedLength = 2,
    this.maDayList = const [5, 10, 20],
    this.dataRevision = 0,
    this.paintRevision = 0,
  }) : super(
         chartStyle,
         datas: datas,
         scaleX: scaleX,
         scrollX: scrollX,
         isLongPress: isLongPass,
         isOnTap: isOnTap,
         isTapShowInfoDialog: isTapShowInfoDialog,
         selectX: selectX,
         mainState: mainState,
         mainStates: mainStates,
         volHidden: volHidden,
         secondaryState: secondaryState,
         secondaryStates: secondaryStates,
         singleSecondaryChartHeight: singleSecondaryChartHeight,
         xFrontPadding: xFrontPadding,
         isLine: isLine,
       ) {
    _configurationHash = Object.hashAll([
      hideGrid,
      showNowPrice,
      verticalTextAlignment,
      candleType,
      isTrendLine,
      isLine,
      isTapShowInfoDialog,
      this.mainState,
      ...this.mainStates,
      this.secondaryState,
      ...this.secondaryStates,
      fixedLength,
      ...maDayList,
      chartStyle.topPadding,
      chartStyle.bottomPadding,
      chartStyle.childPadding,
      chartStyle.pointWidth,
      chartStyle.candleWidth,
      chartStyle.candleLineWidth,
      chartStyle.candleCornerRadius,
      chartStyle.yAxisScaleMode,
      chartStyle.wickClipAtrFactor,
      chartStyle.wickClipAtrPeriod,
      chartStyle.volWidth,
      chartStyle.macdWidth,
      chartStyle.vCrossWidth,
      chartStyle.hCrossWidth,
      chartStyle.nowPriceLineLength,
      chartStyle.nowPriceLineSpan,
      chartStyle.nowPriceLineWidth,
      chartStyle.gridRows,
      chartStyle.gridColumns,
      ...?chartStyle.dateTimeFormat,
      ...chartColors.bgColor,
      chartColors.kLineColor,
      chartColors.lineFillColor,
      chartColors.lineFillInsideColor,
      chartColors.ma5Color,
      chartColors.ma10Color,
      chartColors.ma30Color,
      chartColors.upColor,
      chartColors.dnColor,
      chartColors.volColor,
      chartColors.macdColor,
      chartColors.difColor,
      chartColors.deaColor,
      chartColors.kColor,
      chartColors.dColor,
      chartColors.jColor,
      chartColors.rsiColor,
      chartColors.defaultTextColor,
      chartColors.nowPriceUpColor,
      chartColors.nowPriceDnColor,
      chartColors.nowPriceTextColor,
      chartColors.nowPriceChipBgColor,
      chartColors.nowPriceChipBorderColor,
      chartColors.selectBorderColor,
      chartColors.selectFillColor,
      chartColors.gridColor,
      chartColors.hCrossColor,
      chartColors.vCrossColor,
      chartColors.crossTextColor,
      chartColors.maxColor,
      chartColors.minColor,
    ]);
    selectPointPaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 0.5
      ..color = chartColors.selectFillColor;
    selectorBorderPaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke
      ..color = chartColors.selectBorderColor;
    nowPricePaint = Paint()
      ..strokeWidth = chartStyle.nowPriceLineWidth
      ..isAntiAlias = true;
  }

  @override
  void initChartRenderer() {
    fixedLength = fixedLength.clamp(0, 20);
    mMainRenderer = MainRenderer(
      mMainRect,
      mMainMaxValue,
      mMainMinValue,
      mTopPadding,
      mainStates,
      isLine,
      fixedLength,
      chartStyle,
      chartColors,
      scaleX,
      verticalTextAlignment,
      maDayList,
      candleType,
      mWickClipThreshold,
    );
    mSecondaryRenderers.clear();
    for (final state in secondaryStates) {
      final rect = mSecondaryRects[state];
      if (rect == null) continue;
      late final BaseChartRenderer renderer;
      if (state == SecondaryState.VOL) {
        renderer = VolRenderer(
          rect,
          mVolMaxValue,
          mVolMinValue,
          mChildPadding,
          fixedLength,
          chartStyle,
          chartColors,
        );
      } else {
        renderer = SecondaryRenderer(
          rect,
          mSecondaryMaxValues[state] ?? 0,
          mSecondaryMinValues[state] ?? 0,
          mChildPadding,
          state,
          fixedLength,
          chartStyle,
          chartColors,
        );
      }
      mSecondaryRenderers[state] = renderer;
    }
    mVolRenderer = mSecondaryRenderers[SecondaryState.VOL];
    mSecondaryRenderer = mSecondaryRenderers[secondaryState];
  }

  @override
  void drawBg(Canvas canvas, Size size) {
    Paint mBgPaint = Paint();
    Gradient mBgGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: chartColors.bgColor,
    );
    Rect mainRect = Rect.fromLTRB(
      0,
      0,
      mMainRect.width,
      mMainRect.height + mTopPadding,
    );
    canvas.drawRect(
      mainRect,
      mBgPaint..shader = mBgGradient.createShader(mainRect),
    );

    for (final rect in mSecondaryRects.values) {
      final panelRect = Rect.fromLTRB(
        0,
        rect.top - mChildPadding,
        rect.width,
        rect.bottom,
      );
      canvas.drawRect(
        panelRect,
        mBgPaint..shader = mBgGradient.createShader(panelRect),
      );
    }
    Rect dateRect = Rect.fromLTRB(
      0,
      size.height - mBottomPadding,
      size.width,
      size.height,
    );
    canvas.drawRect(
      dateRect,
      mBgPaint..shader = mBgGradient.createShader(dateRect),
    );
  }

  @override
  void drawGrid(canvas) {
    if (!hideGrid) {
      mMainRenderer.drawGrid(canvas, mGridRows, mGridColumns);
      for (final renderer in mSecondaryRenderers.values) {
        renderer.drawGrid(canvas, mGridRows, mGridColumns);
      }
    }
  }

  @override
  void drawChart(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(mTranslateX * scaleX, 0.0);
    canvas.scale(scaleX, 1.0);
    for (int i = mStartIndex; datas != null && i <= mStopIndex; i++) {
      KLineEntity? curPoint = datas?[i];
      if (curPoint == null) continue;
      KLineEntity lastPoint = i == 0 ? curPoint : datas![i - 1];
      double curX = getX(i);
      double lastX = i == 0 ? curX : getX(i - 1);

      mMainRenderer.drawChart(lastPoint, curPoint, lastX, curX, size, canvas);
      for (final renderer in mSecondaryRenderers.values) {
        renderer.drawChart(lastPoint, curPoint, lastX, curX, size, canvas);
      }
    }

    if ((isLongPress == true || (isTapShowInfoDialog && isOnTap)) &&
        isTrendLine == false) {
      drawCrossLine(canvas, size);
    }
    if (isTrendLine == true) drawTrendLines(canvas, size);
    canvas.restore();

    // 在恢复canvas状态后绘制绘图工具，避免受到缩放和平移影响
    if (drawingToolManager != null) {
      // 创建正确的坐标转换函数
      double getXForDrawing(double x) {
        // x 应该是屏幕坐标，直接返回
        return x;
      }

      double getYForDrawing(double y) {
        // y 是屏幕坐标，直接返回
        return y;
      }

      drawingToolManager!.drawTools(
        canvas,
        size,
        1.0,
        0.0,
        getXForDrawing,
        getYForDrawing,
      );
    }
  }

  @override
  void drawVerticalText(canvas) {
    var textStyle = getTextStyle(this.chartColors.defaultTextColor);
    if (!hideGrid) {
      mMainRenderer.drawVerticalText(canvas, textStyle, mGridRows);
    }
    for (final renderer in mSecondaryRenderers.values) {
      renderer.drawVerticalText(canvas, textStyle, mGridRows);
    }
  }

  @override
  void drawDate(Canvas canvas, Size size) {
    if (datas == null) return;

    double columnSpace = size.width / mGridColumns;
    double startX = getX(mStartIndex) - mPointWidth / 2;
    double stopX = getX(mStopIndex) + mPointWidth / 2;
    double x = 0.0;
    double y = 0.0;
    for (var i = 0; i <= mGridColumns; ++i) {
      double translateX = xToTranslateX(columnSpace * i);

      if (translateX >= startX && translateX <= stopX) {
        int index = indexOfTranslateX(translateX);

        if (datas?[index] == null) continue;
        TextPainter tp = getTextPainter(getDate(datas![index].time), null);
        y = size.height - (mBottomPadding - tp.height) / 2 - tp.height;
        x = columnSpace * i - tp.width / 2;
        // Prevent date text out of canvas
        if (x < 0) x = 0;
        if (x > size.width - tp.width) x = size.width - tp.width;
        tp.paint(canvas, Offset(x, y));
      }
    }

    //    double translateX = xToTranslateX(0);
    //    if (translateX >= startX && translateX <= stopX) {
    //      TextPainter tp = getTextPainter(getDate(datas[mStartIndex].id));
    //      tp.paint(canvas, Offset(0, y));
    //    }
    //    translateX = xToTranslateX(size.width);
    //    if (translateX >= startX && translateX <= stopX) {
    //      TextPainter tp = getTextPainter(getDate(datas[mStopIndex].id));
    //      tp.paint(canvas, Offset(size.width - tp.width, y));
    //    }
  }

  @override
  void drawCrossLineText(Canvas canvas, Size size) {
    var index = calculateSelectedX(selectX);
    KLineEntity point = getItem(index);

    TextPainter tp = getTextPainter(point.close, chartColors.crossTextColor);
    double textHeight = tp.height;
    double textWidth = tp.width;

    double w1 = 5;
    double w2 = 3;
    double r = textHeight / 2 + w2;
    double y = getMainY(point.close);
    double x;
    bool isLeft = false;
    if (translateXtoX(getX(index)) < mWidth / 2) {
      isLeft = false;
      x = 1;
      Path path = new Path();
      path.moveTo(x, y - r);
      path.lineTo(x, y + r);
      path.lineTo(textWidth + 2 * w1, y + r);
      path.lineTo(textWidth + 2 * w1 + w2, y);
      path.lineTo(textWidth + 2 * w1, y - r);
      path.close();
      canvas.drawPath(path, selectPointPaint);
      canvas.drawPath(path, selectorBorderPaint);
      tp.paint(canvas, Offset(x + w1, y - textHeight / 2));
    } else {
      isLeft = true;
      x = mWidth - textWidth - 1 - 2 * w1 - w2;
      Path path = new Path();
      path.moveTo(x, y);
      path.lineTo(x + w2, y + r);
      path.lineTo(mWidth - 2, y + r);
      path.lineTo(mWidth - 2, y - r);
      path.lineTo(x + w2, y - r);
      path.close();
      canvas.drawPath(path, selectPointPaint);
      canvas.drawPath(path, selectorBorderPaint);
      tp.paint(canvas, Offset(x + w1 + w2, y - textHeight / 2));
    }

    TextPainter dateTp = getTextPainter(
      getDate(point.time),
      chartColors.crossTextColor,
    );
    textWidth = dateTp.width;
    r = textHeight / 2;
    x = translateXtoX(getX(index));
    y = size.height - mBottomPadding;

    if (x < textWidth + 2 * w1) {
      x = 1 + textWidth / 2 + w1;
    } else if (mWidth - x < textWidth + 2 * w1) {
      x = mWidth - 1 - textWidth / 2 - w1;
    }
    double baseLine = textHeight / 2;
    canvas.drawRect(
      Rect.fromLTRB(
        x - textWidth / 2 - w1,
        y,
        x + textWidth / 2 + w1,
        y + baseLine + r,
      ),
      selectPointPaint,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        x - textWidth / 2 - w1,
        y,
        x + textWidth / 2 + w1,
        y + baseLine + r,
      ),
      selectorBorderPaint,
    );

    dateTp.paint(canvas, Offset(x - textWidth / 2, y));
    //长按显示这条数据详情
    sink?.add(InfoWindowEntity(point, isLeft: isLeft));
  }

  @override
  void drawText(Canvas canvas, KLineEntity data, double x) {
    //长按显示按中的数据
    if (isLongPress || (isTapShowInfoDialog && isOnTap)) {
      var index = calculateSelectedX(selectX);
      data = getItem(index);
    }
    //松开显示最后一条数据
    mMainRenderer.drawText(canvas, data, x);
    for (final renderer in mSecondaryRenderers.values) {
      renderer.drawText(canvas, data, x);
    }
  }

  @override
  void drawMaxAndMin(Canvas canvas) {
    if (isLine == true) return;
    double lineSize = 20;
    double lineToTextOffset = 5;

    Paint linePaint = Paint()
      ..strokeWidth = 1
      ..color = chartColors.minColor;

    //绘制最大值和最小值
    double x = translateXtoX(getX(mMainMinIndex));
    double y = getMainY(mMainLowMinValue);
    if (x < mWidth / 2) {
      //画右边
      TextPainter tp = getTextPainter(
        mMainLowMinValue.toStringAsFixed(fixedLength),
        chartColors.minColor,
      );

      canvas.drawLine(Offset(x, y), Offset(x + lineSize, y), linePaint);

      tp.paint(
        canvas,
        Offset(x + lineSize + lineToTextOffset, y - tp.height / 2),
      );
    } else {
      TextPainter tp = getTextPainter(
        mMainLowMinValue.toStringAsFixed(fixedLength),
        chartColors.minColor,
      );

      canvas.drawLine(Offset(x, y), Offset(x - lineSize, y), linePaint);

      tp.paint(
        canvas,
        Offset(x - tp.width - lineSize - lineToTextOffset, y - tp.height / 2),
      );
    }
    x = translateXtoX(getX(mMainMaxIndex));
    y = getMainY(mMainHighMaxValue);
    if (x < mWidth / 2) {
      //画右边
      TextPainter tp = getTextPainter(
        mMainHighMaxValue.toStringAsFixed(fixedLength),
        chartColors.maxColor,
      );

      canvas.drawLine(Offset(x, y), Offset(x + lineSize, y), linePaint);

      tp.paint(
        canvas,
        Offset(x + lineSize + lineToTextOffset, y - tp.height / 2),
      );
    } else {
      TextPainter tp = getTextPainter(
        mMainHighMaxValue.toStringAsFixed(fixedLength),
        chartColors.maxColor,
      );

      canvas.drawLine(Offset(x, y), Offset(x - lineSize, y), linePaint);

      tp.paint(
        canvas,
        Offset(x - tp.width - lineSize - lineToTextOffset, y - tp.height / 2),
      );
    }
  }

  @override
  void drawNowPrice(Canvas canvas) {
    if (!this.showNowPrice) return;
    if (datas == null) return;

    double value = datas!.last.close;
    double y = getMainY(value);

    if (y > getMainY(mMainLowMinValue)) {
      y = getMainY(mMainLowMinValue);
    }
    if (y < getMainY(mMainHighMaxValue)) {
      y = getMainY(mMainHighMaxValue);
    }

    final lineColor = value >= datas!.last.open
        ? chartColors.nowPriceUpColor
        : chartColors.nowPriceDnColor;
    nowPricePaint.color = lineColor;

    double startX = 0;
    final max = -mTranslateX + mWidth / scaleX;
    final space = chartStyle.nowPriceLineSpan + chartStyle.nowPriceLineLength;
    while (startX < max) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + chartStyle.nowPriceLineLength, y),
        nowPricePaint,
      );
      startX += space;
    }

    final tp = TextPainter(
      text: TextSpan(
        text: value.toStringAsFixed(fixedLength),
        style: TextStyle(
          fontSize: 10.0,
          color: chartColors.nowPriceTextColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    const double chipHeight = 18.0;
    const double pl = 4.0;
    const double pr = 6.0;
    final double chipWidth = tp.width + pl + pr;
    final double chipY = y - chipHeight / 2;

    final Rect chipRect;
    final double textX;
    switch (verticalTextAlignment) {
      case VerticalTextAlignment.left:
        chipRect = Rect.fromLTWH(0, chipY, chipWidth, chipHeight);
        textX = pl;
        break;
      case VerticalTextAlignment.right:
        chipRect = Rect.fromLTWH(
          mWidth - chipWidth,
          chipY,
          chipWidth,
          chipHeight,
        );
        textX = mWidth - tp.width - pr;
        break;
    }

    final RRect chipRRect = RRect.fromRectAndRadius(
      chipRect,
      Radius.circular(chipHeight / 2),
    );

    final chipBgPaint = Paint()
      ..color = chartColors.nowPriceChipBgColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(chipRRect, chipBgPaint);

    final chipBorderPaint = Paint()
      ..color = chartColors.nowPriceChipBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawRRect(chipRRect, chipBorderPaint);

    final double textTop = chipY + (chipHeight - tp.height) / 2;
    tp.paint(canvas, Offset(textX, textTop));
  }

  //For TrendLine
  void drawTrendLines(Canvas canvas, Size size) {
    var index = calculateSelectedX(selectX);
    Paint paintY = Paint()
      ..color = Colors.orange
      ..strokeWidth = 1
      ..isAntiAlias = true;
    double x = getX(index);

    double y = selectY;
    // getMainY(point.close);

    // k线图竖线
    canvas.drawLine(
      Offset(x, mTopPadding),
      Offset(x, size.height - mBottomPadding),
      paintY,
    );
    Paint paintX = Paint()
      ..color = Colors.orangeAccent
      ..strokeWidth = 1
      ..isAntiAlias = true;
    Paint paint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(-mTranslateX, y),
      Offset(-mTranslateX + mWidth / scaleX, y),
      paintX,
    );
    if (scaleX >= 1) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          height: 15.0 * scaleX,
          width: 15.0,
        ),
        paint,
      );
    } else {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          height: 10.0,
          width: 10.0 / scaleX,
        ),
        paint,
      );
    }
    if (lines.length >= 1) {
      lines.forEach((element) {
        var y1 = -((element.p1.dy - 35) / element.scale) + element.maxHeight;
        var y2 = -((element.p2.dy - 35) / element.scale) + element.maxHeight;
        var a =
            (mMainRenderer.maxValue - y1) * mMainRenderer.scaleY +
            mMainRenderer.chartRect.top;
        var b =
            (mMainRenderer.maxValue - y2) * mMainRenderer.scaleY +
            mMainRenderer.chartRect.top;
        var p1 = Offset(element.p1.dx, a);
        var p2 = Offset(element.p2.dx, b);
        canvas.drawLine(
          p1,
          element.p2 == Offset(-1, -1) ? Offset(x, y) : p2,
          Paint()
            ..color = Colors.yellow
            ..strokeWidth = 2,
        );
      });
    }
  }

  ///画交叉线
  void drawCrossLine(Canvas canvas, Size size) {
    var index = calculateSelectedX(selectX);
    KLineEntity point = getItem(index);

    // 创建虚线画笔 - 竖线使用与横线相同的颜色
    Paint paintY = Paint()
      ..color = this
          .chartColors
          .hCrossColor // 使用与横线相同的颜色
      ..strokeWidth = this
          .chartStyle
          .hCrossWidth // 使用与横线相同的宽度
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double x = getX(index);
    double y = getMainY(point.close);

    // k线图竖线 - 使用虚线
    _drawDashedLine(
      canvas,
      Offset(x, mTopPadding),
      Offset(x, size.height - mBottomPadding),
      paintY,
    );

    Paint paintX = Paint()
      ..color = this.chartColors.hCrossColor
      ..strokeWidth = this.chartStyle.hCrossWidth
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // k线图横线 - 使用虚线
    _drawDashedLine(
      canvas,
      Offset(-mTranslateX, y),
      Offset(-mTranslateX + mWidth / scaleX, y),
      paintX,
    );

    if (scaleX >= 1) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), height: 2.0 * scaleX, width: 2.0),
        paintX,
      );
    } else {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), height: 2.0, width: 2.0 / scaleX),
        paintX,
      );
    }
  }

  /// 绘制虚线
  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const double dashLength = 3.0; // 增加虚线长度
    const double dashSpace = 3.0; // 增加间距

    final double distance = (end - start).distance;
    final Offset direction = (end - start) / distance;

    double currentDistance = 0.0;
    bool drawDash = true;

    while (currentDistance < distance) {
      final double segmentLength = drawDash ? dashLength : dashSpace;
      final double nextDistance = (currentDistance + segmentLength).clamp(
        0.0,
        distance,
      );

      if (drawDash) {
        final Offset segmentStart = start + direction * currentDistance;
        final Offset segmentEnd = start + direction * nextDistance;
        canvas.drawLine(segmentStart, segmentEnd, paint);
      }

      currentDistance = nextDistance;
      drawDash = !drawDash;
    }
  }

  TextPainter getTextPainter(text, color) {
    if (color == null) {
      color = this.chartColors.defaultTextColor;
    }
    TextSpan span = TextSpan(text: "$text", style: getTextStyle(color));
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    return tp;
  }

  String getDate(int? date) => dateFormat(
    DateTime.fromMillisecondsSinceEpoch(
      normalizeTimestampMillis(date) ?? DateTime.now().millisecondsSinceEpoch,
    ),
    mFormats,
  );

  double getMainY(double y) => mMainRenderer.getY(y);

  double getTrendLineX() => getX(calculateSelectedX(selectX));

  double get trendLineMaxValue => mMainRenderer.maxValue;

  double get trendLineScale => mMainRenderer.scaleY;

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) {
    return oldDelegate.paintRevision != paintRevision ||
        oldDelegate.dataRevision != dataRevision ||
        !identical(oldDelegate.datas, datas) ||
        oldDelegate._configurationHash != _configurationHash;
  }

  /// 点是否在SecondaryRect中
  bool isInSecondaryRect(Offset point) {
    return mSecondaryRects.values.any((rect) => rect.contains(point));
  }

  /// 点是否在MainRect中
  bool isInMainRect(Offset point) {
    return mMainRect.contains(point);
  }
}
