import 'dart:math';

import 'package:flutter/material.dart'
    show Color, TextStyle, Rect, Canvas, Size, CustomPainter;

import '../chart_style.dart' show ChartStyle, YAxisScaleMode;
import '../entity/k_line_entity.dart';
import '../k_chart_widget.dart';
import '../utils/date_format_util.dart';
import '../utils/timestamp_util.dart';
import '../utils/wick_clip_util.dart';

export 'package:flutter/material.dart'
    show Color, required, TextStyle, Rect, Canvas, Size, CustomPainter;

abstract class BaseChartPainter extends CustomPainter {
  double maxScrollX = 0.0;
  List<KLineEntity>? datas;
  MainState mainState;
  late final List<MainState> mainStates;

  SecondaryState secondaryState;
  late final List<SecondaryState> secondaryStates;

  bool volHidden;
  bool isTapShowInfoDialog;
  double scaleX = 1.0, scrollX = 0.0, selectX;
  bool isLongPress = false;
  bool isOnTap;
  bool isLine;

  //3块区域大小与位置
  late Rect mMainRect;
  Rect? mVolRect, mSecondaryRect;
  final Map<SecondaryState, Rect> mSecondaryRects = {};
  late double mDisplayHeight, mWidth;
  double mTopPadding = 30.0, mBottomPadding = 20.0, mChildPadding = 12.0;
  int mGridRows = 4, mGridColumns = 4;
  int mStartIndex = 0, mStopIndex = 0;
  double mMainMaxValue = -double.maxFinite, mMainMinValue = double.maxFinite;
  double mWickClipThreshold = 0;
  double mVolMaxValue = -double.maxFinite, mVolMinValue = double.maxFinite;
  double mSecondaryMaxValue = -double.maxFinite,
      mSecondaryMinValue = double.maxFinite;
  final Map<SecondaryState, double> mSecondaryMaxValues = {};
  final Map<SecondaryState, double> mSecondaryMinValues = {};
  double mTranslateX = double.minPositive;
  int mMainMaxIndex = 0, mMainMinIndex = 0;
  double mMainHighMaxValue = -double.maxFinite,
      mMainLowMinValue = double.maxFinite;
  int mItemCount = 0;
  double mDataLen = 0.0; //数据占屏幕总长度
  final ChartStyle chartStyle;
  late double mPointWidth;
  List<String> mFormats = [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn]; //格式化时间
  double xFrontPadding;
  final double singleSecondaryChartHeight;

  BaseChartPainter(
    this.chartStyle, {
    this.datas,
    required this.scaleX,
    required this.scrollX,
    required this.isLongPress,
    required this.selectX,
    required this.xFrontPadding,
    this.isOnTap = false,
    this.mainState = MainState.MA,
    List<MainState>? mainStates,
    this.volHidden = false,
    this.isTapShowInfoDialog = false,
    this.secondaryState = SecondaryState.MACD,
    List<SecondaryState>? secondaryStates,
    this.singleSecondaryChartHeight = 64,
    this.isLine = false,
  }) {
    this.mainStates = (mainStates ?? [mainState])
        .where((state) => state != MainState.NONE)
        .toSet()
        .toList(growable: false);
    this.secondaryStates =
        (secondaryStates ??
                [
                  if (!volHidden) SecondaryState.VOL,
                  if (secondaryState != SecondaryState.NONE) secondaryState,
                ])
            .where((state) => state != SecondaryState.NONE)
            .toSet()
            .toList(growable: false);
    mItemCount = datas?.length ?? 0;
    mPointWidth = max(0.1, this.chartStyle.pointWidth);
    mTopPadding = max(0, this.chartStyle.topPadding);
    mBottomPadding = max(0, this.chartStyle.bottomPadding);
    mChildPadding = max(0, this.chartStyle.childPadding);
    mGridRows = max(1, this.chartStyle.gridRows);
    mGridColumns = max(1, this.chartStyle.gridColumns);
    mDataLen = mItemCount * mPointWidth;
    initFormats();
  }

  void initFormats() {
    if (this.chartStyle.dateTimeFormat != null) {
      mFormats = this.chartStyle.dateTimeFormat!;
      return;
    }

    if (mItemCount < 2) {
      mFormats = [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn];
      return;
    }

    int firstTime = normalizeTimestampMillis(datas!.first.time) ?? 0;
    int secondTime = normalizeTimestampMillis(datas![1].time) ?? 0;
    int time = secondTime - firstTime;
    time ~/= 1000;
    //月线
    if (time >= 24 * 60 * 60 * 28)
      mFormats = [yy, '-', mm];
    //日线等
    else if (time >= 24 * 60 * 60)
      mFormats = [yy, '-', mm, '-', dd];
    //小时线等
    else
      mFormats = [mm, '-', dd, ' ', HH, ':', nn];
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height));
    mDisplayHeight = max(0.0, size.height - mTopPadding - mBottomPadding);
    mWidth = size.width;
    initRect(size);
    calculateValue();
    initChartRenderer();

    canvas.save();
    canvas.scale(1, 1);
    drawBg(canvas, size);
    drawGrid(canvas);
    if (datas != null && datas!.isNotEmpty) {
      drawChart(canvas, size);
      drawVerticalText(canvas);
      drawDate(canvas, size);

      drawText(canvas, datas!.last, 5);
      drawMaxAndMin(canvas);
      drawNowPrice(canvas);

      if (isLongPress == true || (isTapShowInfoDialog && isOnTap)) {
        drawCrossLineText(canvas, size);
      }
    }
    canvas.restore();
  }

  void initChartRenderer();

  //画背景
  void drawBg(Canvas canvas, Size size);

  //画网格
  void drawGrid(canvas);

  //画图表
  void drawChart(Canvas canvas, Size size);

  //画右边值
  void drawVerticalText(canvas);

  //画时间
  void drawDate(Canvas canvas, Size size);

  //画值
  void drawText(Canvas canvas, KLineEntity data, double x);

  //画最大最小值
  void drawMaxAndMin(Canvas canvas);

  //画当前价格
  void drawNowPrice(Canvas canvas);

  //画交叉线
  void drawCrossLine(Canvas canvas, Size size);

  //交叉线值
  void drawCrossLineText(Canvas canvas, Size size);

  void initRect(Size size) {
    mSecondaryRects.clear();
    final panelCount = secondaryStates.length;
    final totalGaps = panelCount * mChildPadding;
    final availablePanelHeight = panelCount == 0
        ? 0.0
        : min(
            singleSecondaryChartHeight,
            max(0.0, mDisplayHeight - 80 - totalGaps) / panelCount,
          );
    final secondaryHeight = availablePanelHeight * panelCount;
    final desiredMainHeight = max(
      0.0,
      mDisplayHeight - secondaryHeight - totalGaps,
    );
    final mainHeight = mDisplayHeight >= 80
        ? desiredMainHeight.clamp(80.0, mDisplayHeight)
        : desiredMainHeight;

    mMainRect = Rect.fromLTRB(0, mTopPadding, mWidth, mTopPadding + mainHeight);

    var top = mMainRect.bottom;
    for (final state in secondaryStates) {
      top += mChildPadding;
      final rect = Rect.fromLTWH(0, top, mWidth, availablePanelHeight);
      mSecondaryRects[state] = rect;
      top = rect.bottom;
    }
    mVolRect = mSecondaryRects[SecondaryState.VOL];
    mSecondaryRect = null;
    for (final state in secondaryStates) {
      if (state != SecondaryState.VOL) {
        mSecondaryRect = mSecondaryRects[state];
        break;
      }
    }
  }

  calculateValue() {
    if (datas == null) return;
    if (datas!.isEmpty) return;
    maxScrollX = getMinTranslateX().abs();
    setTranslateXFromScrollX(scrollX);
    mStartIndex = indexOfTranslateX(xToTranslateX(0));
    mStopIndex = indexOfTranslateX(xToTranslateX(mWidth));
    mWickClipThreshold = 0;
    if (chartStyle.yAxisScaleMode == YAxisScaleMode.wickClipped &&
        chartStyle.wickClipAtrFactor > 0) {
      final atr = calcAtr(
        datas!,
        mStartIndex,
        mStopIndex,
        chartStyle.wickClipAtrPeriod,
      );
      if (atr > 0) {
        mWickClipThreshold = atr * chartStyle.wickClipAtrFactor;
      }
    }
    for (int i = mStartIndex; i <= mStopIndex; i++) {
      var item = datas![i];
      getMainMaxMinValue(item, i);
      getVolMaxMinValue(item);
      for (final state in secondaryStates) {
        getSecondaryMaxMinValue(item, state);
      }
    }
  }

  void getMainMaxMinValue(KLineEntity item, int i) {
    var high = item.high;
    var low = item.low;
    if (mWickClipThreshold > 0) {
      (high, low) = clampWick(
        high,
        low,
        item.open,
        item.close,
        mWickClipThreshold,
      );
    }
    var maxPrice = high;
    var minPrice = low;
    for (final state in mainStates) {
      if (state == MainState.MA) {
        maxPrice = max(maxPrice, _findMaxMA(item.maValueList ?? [0]));
        minPrice = min(minPrice, _findMinMA(item.maValueList ?? [0]));
      } else if (state == MainState.EMA) {
        maxPrice = max(maxPrice, _findMaxMA(item.emaValueList ?? [0]));
        minPrice = min(minPrice, _findMinMA(item.emaValueList ?? [0]));
      } else if (state == MainState.BOLL) {
        maxPrice = max(item.up ?? 0, maxPrice);
        minPrice = min(item.dn ?? 0, minPrice);
      } else if (state == MainState.SAR) {
        maxPrice = max(item.sar ?? item.high, maxPrice);
        minPrice = min(item.sar ?? item.low, minPrice);
      }
    }
    // 指标线夹取到截断后的影线范围，避免超出绘图区。
    if (mWickClipThreshold > 0) {
      maxPrice = maxPrice.clamp(low, high);
      minPrice = minPrice.clamp(low, high);
    }
    mMainMaxValue = max(mMainMaxValue, maxPrice);
    mMainMinValue = min(mMainMinValue, minPrice);

    if (mMainHighMaxValue < item.high) {
      mMainHighMaxValue = item.high;
      mMainMaxIndex = i;
    }
    if (mMainLowMinValue > item.low) {
      mMainLowMinValue = item.low;
      mMainMinIndex = i;
    }

    if (isLine == true) {
      mMainMaxValue = max(mMainMaxValue, item.close);
      mMainMinValue = min(mMainMinValue, item.close);
    }
  }

  double _findMaxMA(List<double> a) {
    double result = -double.maxFinite;
    for (double i in a) {
      result = max(result, i);
    }
    return result;
  }

  double _findMinMA(List<double> a) {
    double result = double.maxFinite;
    for (double i in a) {
      result = min(result, i == 0 ? double.maxFinite : i);
    }
    return result;
  }

  void getVolMaxMinValue(KLineEntity item) {
    mVolMaxValue = max(
      mVolMaxValue,
      max(item.vol, max(item.MA5Volume ?? 0, item.MA10Volume ?? 0)),
    );
    mVolMinValue = min(
      mVolMinValue,
      min(item.vol, min(item.MA5Volume ?? 0, item.MA10Volume ?? 0)),
    );
  }

  void getSecondaryMaxMinValue(KLineEntity item, SecondaryState state) {
    if (state == SecondaryState.VOL) return;
    var maxValue = mSecondaryMaxValues[state] ?? -double.maxFinite;
    var minValue = mSecondaryMinValues[state] ?? double.maxFinite;
    if (state == SecondaryState.MACD) {
      if (item.macd != null) {
        maxValue = max(maxValue, max(item.macd!, max(item.dif!, item.dea!)));
        minValue = min(minValue, min(item.macd!, min(item.dif!, item.dea!)));
      }
    } else if (state == SecondaryState.KDJ) {
      if (item.d != null) {
        maxValue = max(maxValue, max(item.k!, max(item.d!, item.j!)));
        minValue = min(minValue, min(item.k!, min(item.d!, item.j!)));
      }
    } else if (state == SecondaryState.RSI) {
      if (item.rsi != null) {
        maxValue = max(maxValue, item.rsi!);
        minValue = min(minValue, item.rsi!);
      }
    } else if (state == SecondaryState.WR) {
      maxValue = 0;
      minValue = -100;
    } else if (state == SecondaryState.OBV) {
      if (item.obv != null) {
        maxValue = max(maxValue, max(item.obv!, item.obvMa ?? item.obv!));
        minValue = min(minValue, min(item.obv!, item.obvMa ?? item.obv!));
      }
    } else if (state == SecondaryState.StochRSI) {
      maxValue = 100;
      minValue = 0;
    } else if (state == SecondaryState.CCI) {
      if (item.cci != null) {
        maxValue = max(maxValue, item.cci!);
        minValue = min(minValue, item.cci!);
      }
    } else {
      maxValue = 0;
      minValue = 0;
    }
    mSecondaryMaxValues[state] = maxValue;
    mSecondaryMinValues[state] = minValue;
    if (state == secondaryState) {
      mSecondaryMaxValue = maxValue;
      mSecondaryMinValue = minValue;
    }
  }

  double xToTranslateX(double x) => -mTranslateX + x / scaleX;

  int indexOfTranslateX(double translateX) =>
      _indexOfTranslateX(translateX, 0, mItemCount - 1);

  ///二分查找当前值的index
  int _indexOfTranslateX(double translateX, int start, int end) {
    if (end == start || end == -1) {
      return start;
    }
    if (end - start == 1) {
      double startValue = getX(start);
      double endValue = getX(end);
      return (translateX - startValue).abs() < (translateX - endValue).abs()
          ? start
          : end;
    }
    int mid = start + (end - start) ~/ 2;
    double midValue = getX(mid);
    if (translateX < midValue) {
      return _indexOfTranslateX(translateX, start, mid);
    } else if (translateX > midValue) {
      return _indexOfTranslateX(translateX, mid, end);
    } else {
      return mid;
    }
  }

  ///根据索引索取x坐标
  ///+ mPointWidth / 2防止第一根和最后一根k线显示不���
  ///@param position 索引值
  double getX(int position) => position * mPointWidth + mPointWidth / 2;

  KLineEntity getItem(int position) {
    return datas![position];
    // if (datas != null) {
    //   return datas[position];
    // } else {
    //   return null;
    // }
  }

  ///scrollX 转换为 TranslateX
  void setTranslateXFromScrollX(double scrollX) =>
      mTranslateX = scrollX + getMinTranslateX();

  ///获取平移的最小值
  double getMinTranslateX() {
    var x = -mDataLen + mWidth / scaleX - mPointWidth / 2 - xFrontPadding;
    return x >= 0 ? 0.0 : x;
  }

  ///计算长按后x的值，转换为index
  int calculateSelectedX(double selectX) {
    int mSelectedIndex = indexOfTranslateX(xToTranslateX(selectX));
    if (mSelectedIndex < mStartIndex) {
      mSelectedIndex = mStartIndex;
    }
    if (mSelectedIndex > mStopIndex) {
      mSelectedIndex = mStopIndex;
    }
    return mSelectedIndex;
  }

  ///translateX转化为view中的x
  double translateXtoX(double translateX) =>
      (translateX + mTranslateX) * scaleX;

  TextStyle getTextStyle(Color color) {
    return TextStyle(fontSize: 10.0, color: color);
  }

  @override
  bool shouldRepaint(BaseChartPainter oldDelegate) {
    return true;
    //    return oldDelegate.datas != datas ||
    //        oldDelegate.datas?.length != datas?.length ||
    //        oldDelegate.scaleX != scaleX ||
    //        oldDelegate.scrollX != scrollX ||
    //        oldDelegate.isLongPress != isLongPress ||
    //        oldDelegate.selectX != selectX ||
    //        oldDelegate.isLine != isLine ||
    //        oldDelegate.mainState != mainState ||
    //        oldDelegate.secondaryState != secondaryState;
  }
}
