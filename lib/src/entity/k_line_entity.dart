import '../entity/k_entity.dart';
import '../utils/timestamp_util.dart';

class KLineEntity extends KEntity {
  late double open;
  late double high;
  late double low;
  late double close;
  late double vol;
  late double? amount;
  double? change;
  double? ratio;
  int? time;

  KLineEntity.fromCustom({
    this.amount,
    required this.open,
    required this.close,
    this.change,
    this.ratio,
    required int? time,
    required this.high,
    required this.low,
    required this.vol,
  }) : time = normalizeTimestampMillis(time);

  KLineEntity.fromJson(Map<String, dynamic> json) {
    open = _toDouble(json['open']) ?? 0;
    high = _toDouble(json['high']) ?? 0;
    low = _toDouble(json['low']) ?? 0;
    close = _toDouble(json['close']) ?? 0;
    vol = _toDouble(json['vol']) ?? 0;
    amount = _toDouble(json['amount']);
    // `id` is used by APIs such as Huobi; both fields may be seconds or
    // milliseconds and are normalized to milliseconds internally.
    time = normalizeTimestampMillis(_toInt(json['time']) ?? _toInt(json['id']));
    ratio = _toDouble(json['ratio']);
    change = _toDouble(json['change']);
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['time'] = this.time;
    data['open'] = this.open;
    data['close'] = this.close;
    data['high'] = this.high;
    data['low'] = this.low;
    data['vol'] = this.vol;
    data['amount'] = this.amount;
    data['ratio'] = this.ratio;
    data['change'] = this.change;
    return data;
  }

  @override
  String toString() {
    return 'MarketModel{open: $open, high: $high, low: $low, close: $close, vol: $vol, time: $time, amount: $amount, ratio: $ratio, change: $change}';
  }
}
