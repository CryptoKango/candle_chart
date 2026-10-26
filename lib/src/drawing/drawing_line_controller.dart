import 'package:flutter/material.dart';

import '../entity/drawing_tool_entity.dart';
import '../utils/drawing_tool_manager.dart';

enum DrawingLineStyle {
  trendLine,
  extendedTrendLine,
  ray,
  horizontalStraightLine,
  horizontalLineSegment,
  verticalLineSegment,
  parallelLines,
  priceLine,
  threeWaveLine,
  fiveWaveLine,
  rectangle,
  fibonacciRetracement;

  String get label => switch (this) {
    DrawingLineStyle.trendLine => 'Trend',
    DrawingLineStyle.extendedTrendLine => 'Extend',
    DrawingLineStyle.ray => 'Ray',
    DrawingLineStyle.horizontalStraightLine => 'H-Line',
    DrawingLineStyle.horizontalLineSegment => 'H-Seg',
    DrawingLineStyle.verticalLineSegment => 'V-Seg',
    DrawingLineStyle.parallelLines => 'Parallel',
    DrawingLineStyle.priceLine => 'Price',
    DrawingLineStyle.threeWaveLine => '3-Wave',
    DrawingLineStyle.fiveWaveLine => '5-Wave',
    DrawingLineStyle.rectangle => 'Rect',
    DrawingLineStyle.fibonacciRetracement => 'Fib',
  };
}

enum LineColor {
  red,
  orange,
  yellow,
  green,
  blue,
  purple;

  Color get value => switch (this) {
    LineColor.red => const Color(0xFFFD5760),
    LineColor.orange => const Color(0xFFFF7A00),
    LineColor.yellow => const Color(0xFFFFBE40),
    LineColor.green => const Color(0xFF5AD8A6),
    LineColor.blue => const Color(0xFF5B8FF9),
    LineColor.purple => const Color(0xFF9B6DFF),
  };
}

enum LineWeight {
  thin,
  regular,
  medium,
  bold;

  double get value => switch (this) {
    LineWeight.thin => 0.6,
    LineWeight.regular => 1,
    LineWeight.medium => 2,
    LineWeight.bold => 3,
  };
}

enum DotStyle { weight, middle, light, zebra, none }

enum LineAreaColor {
  red,
  orange,
  yellow,
  transparent,
  green,
  blue,
  purple;

  Color get value => switch (this) {
    LineAreaColor.red => const Color(0x33FD5760),
    LineAreaColor.orange => const Color(0x33FF7A00),
    LineAreaColor.yellow => const Color(0x33FFBE40),
    LineAreaColor.transparent => Colors.transparent,
    LineAreaColor.green => const Color(0x335AD8A6),
    LineAreaColor.blue => const Color(0x335B8FF9),
    LineAreaColor.purple => const Color(0x339B6DFF),
  };
}

@immutable
class DrawingLineConfig {
  const DrawingLineConfig({
    this.lineColor = LineColor.orange,
    this.lineWeight = LineWeight.regular,
    this.lineDotStyle = DotStyle.none,
    this.areaColor = LineAreaColor.orange,
    this.isLock = false,
  });

  final LineColor lineColor;
  final LineWeight lineWeight;
  final DotStyle lineDotStyle;
  final LineAreaColor areaColor;
  final bool isLock;

  DrawingLineConfig copyWith({
    LineColor? lineColor,
    LineWeight? lineWeight,
    DotStyle? lineDotStyle,
    LineAreaColor? areaColor,
    bool? isLock,
  }) => DrawingLineConfig(
    lineColor: lineColor ?? this.lineColor,
    lineWeight: lineWeight ?? this.lineWeight,
    lineDotStyle: lineDotStyle ?? this.lineDotStyle,
    areaColor: areaColor ?? this.areaColor,
    isLock: isLock ?? this.isLock,
  );
}

/// Ju.com-style public controller for Wen K-line drawings.
///
/// The current Wen chart renderer still paints through [DrawingToolManager].
/// This controller provides the migrated 12-tool API and state model while
/// adapting into the existing renderer until the data-coordinate renderers are
/// fully replaced.
class DrawingLineController extends ChangeNotifier {
  DrawingToolManager? _manager;
  List<Map<String, dynamic>> _pendingLines = const [];

  bool isDrawing = false;
  bool enableMagnet = false;
  bool enableContinuous = false;
  bool isHidden = false;
  DrawingLineStyle? drawingLineStyle;
  DrawingLineConfig config = const DrawingLineConfig();

  void attachManager(DrawingToolManager manager) {
    if (identical(_manager, manager)) return;
    _manager = manager;
    _manager!.onToolsChanged = notifyListeners;
    if (_pendingLines.isNotEmpty) {
      _manager!.deserializeTools(_pendingLines);
      _pendingLines = const [];
    }
    _syncCurrentStyle();
  }

  int get lineCount => _manager?.tools.length ?? 0;

  List<Map<String, dynamic>> serializeLines() =>
      _manager?.serializeTools() ?? _pendingLines;

  void restoreLines(List<Map<String, dynamic>> lines) {
    _pendingLines = lines;
    _manager?.deserializeTools(lines);
    notifyListeners();
  }

  void updateDrawingStatus(bool value) {
    isDrawing = value;
    if (!value) {
      drawingLineStyle = null;
      _manager?.setCurrentToolType(null);
    }
    notifyListeners();
  }

  void updateEnableMagnet(bool value) {
    enableMagnet = value;
    notifyListeners();
  }

  void updateEnableContinuous(bool value) {
    enableContinuous = value;
    notifyListeners();
  }

  void updateHiddenStatus(bool value) {
    isHidden = value;
    for (final tool in _manager?.tools ?? const <DrawingTool>[]) {
      _manager?.setToolVisibility(tool.id, !value);
    }
    notifyListeners();
  }

  void updateConfig(DrawingLineConfig value) {
    config = value;
    final selected = _manager?.selectedTool;
    if (selected != null) {
      _manager?.updateToolProperties(selected.id, {
        'color': config.lineColor.value,
        'strokeWidth': config.lineWeight.value,
      });
    }
    notifyListeners();
  }

  void updateDrawingLineStyle(DrawingLineStyle? style) {
    isDrawing = style != null;
    drawingLineStyle = style;
    _syncCurrentStyle();
    notifyListeners();
  }

  void deleteSelected() {
    _manager?.deleteSelectedTool();
    notifyListeners();
  }

  void clearAll() {
    _manager?.clearAllTools();
    notifyListeners();
  }

  void notifyToolManagerChanged() {
    notifyListeners();
  }

  void _syncCurrentStyle() {
    _manager?.setCurrentToolType(_toToolType(drawingLineStyle));
  }

  DrawingToolType? _toToolType(DrawingLineStyle? style) => switch (style) {
    null => null,
    DrawingLineStyle.trendLine => DrawingToolType.trendLine,
    DrawingLineStyle.extendedTrendLine => DrawingToolType.extendedTrendLine,
    DrawingLineStyle.ray => DrawingToolType.ray,
    DrawingLineStyle.horizontalStraightLine => DrawingToolType.horizontalLine,
    DrawingLineStyle.horizontalLineSegment => DrawingToolType.horizontalSegment,
    DrawingLineStyle.verticalLineSegment => DrawingToolType.verticalLine,
    DrawingLineStyle.parallelLines => DrawingToolType.parallelLines,
    DrawingLineStyle.priceLine => DrawingToolType.horizontalLine,
    DrawingLineStyle.threeWaveLine => DrawingToolType.threeWaveLine,
    DrawingLineStyle.fiveWaveLine => DrawingToolType.fiveWaveLine,
    DrawingLineStyle.rectangle => DrawingToolType.rectangle,
    DrawingLineStyle.fibonacciRetracement =>
      DrawingToolType.fibonacciRetracement,
  };
}
