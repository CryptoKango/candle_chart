import 'cci_entity.dart';
import 'kdj_entity.dart';
import 'rsi_entity.dart';
import 'rw_entity.dart';
import 'stoch_rsi_entity.dart';

mixin MACDEntity
    on KDJEntity, RSIEntity, WREntity, OBVEntity, StochRSIEntity, CCIEntity {
  double? dea;
  double? dif;
  double? macd;
}
