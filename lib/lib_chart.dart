/// lib_chart — 图表组件包
///
/// 包含 K-line 图表、深度图、技术指标等功能。
/// 与 common_ui 相互独立，通过 adapter 桥接主题。
library lib_chart;

// — 主 Widget —
export 'src/k_chart_widget.dart';
export 'src/vertical_text_alignment.dart';
export 'src/depth_chart.dart';

// — 数据模型 —
export 'src/entity/index.dart';

// — 主题 / 样式 —
export 'src/chart_style.dart';
export 'src/chart_translations.dart';

// — 绘制工具 —
export 'src/drawing/drawing_line_controller.dart';
export 'src/utils/drawing_tool_manager.dart';

// — 实用函数 —
export 'src/utils/data_util.dart';
export 'src/utils/number_util.dart';
export 'src/utils/date_format_util.dart';
export 'src/utils/timestamp_util.dart';
export 'src/utils/wick_clip_util.dart';

// — Theme Adapter —
export 'src/adapter/chart_theme_adapter.dart';
