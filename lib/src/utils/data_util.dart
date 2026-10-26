import 'dart:math';

import '../entity/index.dart';

class ChartIndicatorParameters {
  const ChartIndicatorParameters({
    this.maPeriods = const [5, 10, 20],
    this.emaPeriods = const [5, 10, 20],
    this.bollPeriod = 20,
    this.bollMultiplier = 2,
    this.sarStep = 0.02,
    this.sarMaximum = 0.2,
    this.macdFast = 12,
    this.macdSlow = 26,
    this.macdSignal = 9,
    this.kdjPeriod = 9,
    this.rsiPeriod = 14,
    this.wrPeriod = 14,
    this.obvMaPeriod = 30,
    this.stochRsiPeriod = 14,
    this.stochRsiSmoothK = 3,
    this.stochRsiSmoothD = 3,
  });

  final List<int> maPeriods;
  final List<int> emaPeriods;
  final int bollPeriod;
  final int bollMultiplier;
  final double sarStep;
  final double sarMaximum;
  final int macdFast;
  final int macdSlow;
  final int macdSignal;
  final int kdjPeriod;
  final int rsiPeriod;
  final int wrPeriod;
  final int obvMaPeriod;
  final int stochRsiPeriod;
  final int stochRsiSmoothK;
  final int stochRsiSmoothD;

  ChartIndicatorParameters copyWith({
    List<int>? maPeriods,
    List<int>? emaPeriods,
    int? bollPeriod,
    int? bollMultiplier,
    double? sarStep,
    double? sarMaximum,
    int? macdFast,
    int? macdSlow,
    int? macdSignal,
    int? kdjPeriod,
    int? rsiPeriod,
    int? wrPeriod,
    int? obvMaPeriod,
    int? stochRsiPeriod,
    int? stochRsiSmoothK,
    int? stochRsiSmoothD,
  }) => ChartIndicatorParameters(
    maPeriods: maPeriods ?? this.maPeriods,
    emaPeriods: emaPeriods ?? this.emaPeriods,
    bollPeriod: bollPeriod ?? this.bollPeriod,
    bollMultiplier: bollMultiplier ?? this.bollMultiplier,
    sarStep: sarStep ?? this.sarStep,
    sarMaximum: sarMaximum ?? this.sarMaximum,
    macdFast: macdFast ?? this.macdFast,
    macdSlow: macdSlow ?? this.macdSlow,
    macdSignal: macdSignal ?? this.macdSignal,
    kdjPeriod: kdjPeriod ?? this.kdjPeriod,
    rsiPeriod: rsiPeriod ?? this.rsiPeriod,
    wrPeriod: wrPeriod ?? this.wrPeriod,
    obvMaPeriod: obvMaPeriod ?? this.obvMaPeriod,
    stochRsiPeriod: stochRsiPeriod ?? this.stochRsiPeriod,
    stochRsiSmoothK: stochRsiSmoothK ?? this.stochRsiSmoothK,
    stochRsiSmoothD: stochRsiSmoothD ?? this.stochRsiSmoothD,
  );
}

class DataUtil {
  static void _requirePositivePeriod(String name, int value) {
    if (value <= 0) {
      throw ArgumentError.value(value, name, 'must be greater than zero');
    }
  }

  static calculate(
    List<KLineEntity> dataList, [
    List<int> maDayList = const [5, 10, 20],
    int n = 20,
    k = 2,
  ]) {
    calculateWithParameters(
      dataList,
      ChartIndicatorParameters(
        maPeriods: maDayList,
        emaPeriods: maDayList,
        bollPeriod: n,
        bollMultiplier: k is int ? k : (k as num).round(),
      ),
    );
  }

  static void calculateWithParameters(
    List<KLineEntity> dataList,
    ChartIndicatorParameters parameters,
  ) {
    _validateParameters(parameters);
    if (dataList.isEmpty) return;
    calcMA(dataList, parameters.maPeriods);
    calcEMA(dataList, parameters.emaPeriods);
    calcBOLL(dataList, parameters.bollPeriod, parameters.bollMultiplier);
    calcSAR(dataList, parameters.sarStep, parameters.sarMaximum);
    calcVolumeMA(dataList);
    calcKDJ(dataList, parameters.kdjPeriod);
    calcMACD(
      dataList,
      parameters.macdFast,
      parameters.macdSlow,
      parameters.macdSignal,
    );
    calcRSI(dataList, parameters.rsiPeriod);
    calcWR(dataList, parameters.wrPeriod);
    calcOBV(dataList, parameters.obvMaPeriod);
    calcStochRSI(
      dataList,
      parameters.stochRsiPeriod,
      parameters.stochRsiSmoothK,
      parameters.stochRsiSmoothD,
    );
    calcCCI(dataList);
  }

  static void _validateParameters(ChartIndicatorParameters parameters) {
    for (final period in parameters.maPeriods) {
      _requirePositivePeriod('maPeriods', period);
    }
    for (final period in parameters.emaPeriods) {
      _requirePositivePeriod('emaPeriods', period);
    }
    if (parameters.bollPeriod < 2) {
      throw ArgumentError.value(
        parameters.bollPeriod,
        'bollPeriod',
        'must be at least 2',
      );
    }
    if (parameters.bollMultiplier < 0) {
      throw ArgumentError.value(
        parameters.bollMultiplier,
        'bollMultiplier',
        'must not be negative',
      );
    }
    _requirePositivePeriod('macdFast', parameters.macdFast);
    _requirePositivePeriod('macdSlow', parameters.macdSlow);
    _requirePositivePeriod('macdSignal', parameters.macdSignal);
    _requirePositivePeriod('kdjPeriod', parameters.kdjPeriod);
    _requirePositivePeriod('rsiPeriod', parameters.rsiPeriod);
    _requirePositivePeriod('wrPeriod', parameters.wrPeriod);
    _requirePositivePeriod('obvMaPeriod', parameters.obvMaPeriod);
    _requirePositivePeriod('stochRsiPeriod', parameters.stochRsiPeriod);
    _requirePositivePeriod('stochRsiSmoothK', parameters.stochRsiSmoothK);
    _requirePositivePeriod('stochRsiSmoothD', parameters.stochRsiSmoothD);
    if (!parameters.sarStep.isFinite || parameters.sarStep <= 0) {
      throw ArgumentError.value(
        parameters.sarStep,
        'sarStep',
        'must be finite and greater than zero',
      );
    }
    if (!parameters.sarMaximum.isFinite ||
        parameters.sarMaximum < parameters.sarStep) {
      throw ArgumentError.value(
        parameters.sarMaximum,
        'sarMaximum',
        'must be finite and greater than or equal to sarStep',
      );
    }
  }

  static calcMA(List<KLineEntity> dataList, List<int> maDayList) {
    for (final period in maDayList) {
      _requirePositivePeriod('maDayList', period);
    }
    List<double> ma = List<double>.filled(maDayList.length, 0);

    if (dataList.isNotEmpty) {
      for (int i = 0; i < dataList.length; i++) {
        KLineEntity entity = dataList[i];
        final closePrice = entity.close;
        entity.maValueList = List<double>.filled(maDayList.length, 0);

        for (int j = 0; j < maDayList.length; j++) {
          ma[j] += closePrice;
          if (i == maDayList[j] - 1) {
            entity.maValueList?[j] = ma[j] / maDayList[j];
          } else if (i >= maDayList[j]) {
            ma[j] -= dataList[i - maDayList[j]].close;
            entity.maValueList?[j] = ma[j] / maDayList[j];
          } else {
            entity.maValueList?[j] = 0;
          }
        }
      }
    }
  }

  static void calcEMA(List<KLineEntity> dataList, List<int> emaDayList) {
    for (final period in emaDayList) {
      _requirePositivePeriod('emaDayList', period);
    }
    final ema = List<double>.filled(emaDayList.length, 0);
    for (int i = 0; i < dataList.length; i++) {
      final entity = dataList[i];
      final closePrice = entity.close;
      entity.emaValueList = List<double>.filled(emaDayList.length, 0);

      for (int j = 0; j < emaDayList.length; j++) {
        final day = emaDayList[j];
        if (i == 0) {
          ema[j] = closePrice;
        } else {
          ema[j] = closePrice * 2 / (day + 1) + ema[j] * (day - 1) / (day + 1);
        }
        entity.emaValueList?[j] = i >= day - 1 ? ema[j] : 0;
      }
    }
  }

  static void calcBOLL(List<KLineEntity> dataList, int n, int k) {
    if (n < 2) {
      throw ArgumentError.value(n, 'n', 'must be at least 2');
    }
    if (k < 0) {
      throw ArgumentError.value(k, 'k', 'must not be negative');
    }
    _calcBOLLMA(n, dataList);
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      if (i >= n) {
        double md = 0;
        for (int j = i - n + 1; j <= i; j++) {
          double c = dataList[j].close;
          double m = entity.BOLLMA!;
          double value = c - m;
          md += value * value;
        }
        md = md / (n - 1);
        md = sqrt(md);
        entity.mb = entity.BOLLMA!;
        entity.up = entity.mb! + k * md;
        entity.dn = entity.mb! - k * md;
      }
    }
  }

  static void calcSAR(
    List<KLineEntity> dataList, [
    double step = 0.02,
    double maxAcceleration = 0.2,
  ]) {
    if (!step.isFinite || step <= 0) {
      throw ArgumentError.value(
        step,
        'step',
        'must be finite and greater than zero',
      );
    }
    if (!maxAcceleration.isFinite || maxAcceleration < step) {
      throw ArgumentError.value(
        maxAcceleration,
        'maxAcceleration',
        'must be finite and greater than or equal to step',
      );
    }
    if (dataList.isEmpty) return;
    var isUpTrend = true;
    var acceleration = 0.02;
    var extremePoint = dataList.first.high;
    var sar = dataList.first.low;
    dataList.first.sar = sar;

    for (int i = 1; i < dataList.length; i++) {
      final current = dataList[i];
      final previous = dataList[i - 1];
      sar = sar + acceleration * (extremePoint - sar);

      if (isUpTrend) {
        sar = min(sar, previous.low);
        if (i > 1) sar = min(sar, dataList[i - 2].low);
        if (current.low < sar) {
          isUpTrend = false;
          sar = extremePoint;
          extremePoint = current.low;
          acceleration = step;
        } else if (current.high > extremePoint) {
          extremePoint = current.high;
          acceleration = min(acceleration + step, maxAcceleration);
        }
      } else {
        sar = max(sar, previous.high);
        if (i > 1) sar = max(sar, dataList[i - 2].high);
        if (current.high > sar) {
          isUpTrend = true;
          sar = extremePoint;
          extremePoint = current.high;
          acceleration = step;
        } else if (current.low < extremePoint) {
          extremePoint = current.low;
          acceleration = min(acceleration + step, maxAcceleration);
        }
      }
      current.sar = sar;
    }
  }

  static void _calcBOLLMA(int day, List<KLineEntity> dataList) {
    double ma = 0;
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      ma += entity.close;
      if (i == day - 1) {
        entity.BOLLMA = ma / day;
      } else if (i >= day) {
        ma -= dataList[i - day].close;
        entity.BOLLMA = ma / day;
      } else {
        entity.BOLLMA = null;
      }
    }
  }

  static void calcMACD(
    List<KLineEntity> dataList, [
    int fast = 12,
    int slow = 26,
    int signal = 9,
  ]) {
    _requirePositivePeriod('fast', fast);
    _requirePositivePeriod('slow', slow);
    _requirePositivePeriod('signal', signal);
    double fastEma = 0;
    double slowEma = 0;
    double dif = 0;
    double dea = 0;
    double macd = 0;

    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      final closePrice = entity.close;
      if (i == 0) {
        fastEma = closePrice;
        slowEma = closePrice;
      } else {
        fastEma =
            fastEma * (fast - 1) / (fast + 1) + closePrice * 2 / (fast + 1);
        slowEma =
            slowEma * (slow - 1) / (slow + 1) + closePrice * 2 / (slow + 1);
      }
      dif = fastEma - slowEma;
      dea = dea * (signal - 1) / (signal + 1) + dif * 2 / (signal + 1);
      macd = (dif - dea) * 2;
      entity.dif = dif;
      entity.dea = dea;
      entity.macd = macd;
    }
  }

  static void calcVolumeMA(List<KLineEntity> dataList) {
    double volumeMa5 = 0;
    double volumeMa10 = 0;

    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entry = dataList[i];

      volumeMa5 += entry.vol;
      volumeMa10 += entry.vol;

      if (i == 4) {
        entry.MA5Volume = (volumeMa5 / 5);
      } else if (i > 4) {
        volumeMa5 -= dataList[i - 5].vol;
        entry.MA5Volume = volumeMa5 / 5;
      } else {
        entry.MA5Volume = 0;
      }

      if (i == 9) {
        entry.MA10Volume = volumeMa10 / 10;
      } else if (i > 9) {
        volumeMa10 -= dataList[i - 10].vol;
        entry.MA10Volume = volumeMa10 / 10;
      } else {
        entry.MA10Volume = 0;
      }
    }
  }

  static void calcRSI(List<KLineEntity> dataList, [int period = 14]) {
    _requirePositivePeriod('period', period);
    double? rsi;
    double rsiABSEma = 0;
    double rsiMaxEma = 0;
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      final double closePrice = entity.close;
      if (i == 0) {
        rsi = 0;
        rsiABSEma = 0;
        rsiMaxEma = 0;
      } else {
        double rMax = max(0, closePrice - dataList[i - 1].close.toDouble());
        double rAbs = (closePrice - dataList[i - 1].close.toDouble()).abs();

        rsiMaxEma = (rMax + (period - 1) * rsiMaxEma) / period;
        rsiABSEma = (rAbs + (period - 1) * rsiABSEma) / period;
        rsi = (rsiMaxEma / rsiABSEma) * 100;
      }
      if (i < period - 1) rsi = null;
      if (rsi != null && !rsi.isFinite) rsi = 0;
      entity.rsi = rsi;
    }
  }

  static void calcKDJ(List<KLineEntity> dataList, [int period = 9]) {
    _requirePositivePeriod('period', period);
    if (dataList.isEmpty) return;
    var preK = 50.0;
    var preD = 50.0;
    final tmp = dataList.first;
    tmp.k = preK;
    tmp.d = preD;
    tmp.j = 50.0;
    for (int i = 1; i < dataList.length; i++) {
      final entity = dataList[i];
      final n = max(0, i - period + 1);
      var low = entity.low;
      var high = entity.high;
      for (int j = n; j < i; j++) {
        final t = dataList[j];
        if (t.low < low) {
          low = t.low;
        }
        if (t.high > high) {
          high = t.high;
        }
      }
      final cur = entity.close;
      final range = high - low;
      var rsv = range == 0 ? 0.0 : (cur - low) * 100.0 / range;
      if (!rsv.isFinite) rsv = 0;
      final k = (2 * preK + rsv) / 3.0;
      final d = (2 * preD + k) / 3.0;
      final j = 3 * k - 2 * d;
      preK = k;
      preD = d;
      entity.k = k;
      entity.d = d;
      entity.j = j;
    }
  }

  static void calcWR(List<KLineEntity> dataList, [int period = 14]) {
    _requirePositivePeriod('period', period);
    double r;
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      int startIndex = i - period + 1;
      if (startIndex < 0) {
        startIndex = 0;
      }
      double max14 = -double.maxFinite;
      double min14 = double.maxFinite;
      for (int index = startIndex; index <= i; index++) {
        max14 = max(max14, dataList[index].high);
        min14 = min(min14, dataList[index].low);
      }
      if (i < period - 1) {
        entity.r = -10;
      } else {
        final range = max14 - min14;
        r = range == 0 ? 0 : -100 * (max14 - dataList[i].close) / range;
        entity.r = r.isFinite ? r : 0;
      }
    }
  }

  static void calcOBV(List<KLineEntity> dataList, [int maPeriod = 30]) {
    _requirePositivePeriod('maPeriod', maPeriod);
    var obv = 0.0;
    var maSum = 0.0;
    for (int i = 0; i < dataList.length; i++) {
      final entity = dataList[i];
      if (i == 0) {
        obv = entity.vol;
      } else if (entity.close > dataList[i - 1].close) {
        obv += entity.vol;
      } else if (entity.close < dataList[i - 1].close) {
        obv -= entity.vol;
      }
      entity.obv = obv;
      maSum += obv;
      if (i >= maPeriod) {
        maSum -= dataList[i - maPeriod].obv ?? 0;
        entity.obvMa = maSum / maPeriod;
      } else {
        entity.obvMa = maSum / (i + 1);
      }
    }
  }

  static void calcStochRSI(
    List<KLineEntity> dataList, [
    int period = 14,
    int smoothK = 3,
    int smoothD = 3,
  ]) {
    _requirePositivePeriod('period', period);
    _requirePositivePeriod('smoothK', smoothK);
    _requirePositivePeriod('smoothD', smoothD);
    var k = 50.0;
    var d = 50.0;
    for (int i = 0; i < dataList.length; i++) {
      final entity = dataList[i];
      final rsi = entity.rsi;
      if (rsi == null || i < period - 1) {
        entity.stochRsiK = null;
        entity.stochRsiD = null;
        continue;
      }
      final start = max(0, i - period + 1);
      var minRsi = double.maxFinite;
      var maxRsi = -double.maxFinite;
      for (int j = start; j <= i; j++) {
        final value = dataList[j].rsi;
        if (value == null) continue;
        minRsi = min(minRsi, value);
        maxRsi = max(maxRsi, value);
      }
      final range = maxRsi - minRsi;
      final raw = range == 0 ? 0.0 : ((rsi - minRsi) / range) * 100;
      k = ((smoothK - 1) * k + raw) / smoothK;
      d = ((smoothD - 1) * d + k) / smoothD;
      entity.stochRsiK = k;
      entity.stochRsiD = d;
    }
  }

  static void calcCCI(List<KLineEntity> dataList) {
    final size = dataList.length;
    final count = 14;
    for (int i = 0; i < size; i++) {
      final kline = dataList[i];
      final tp = (kline.high + kline.low + kline.close) / 3;
      final start = max(0, i - count + 1);
      var amount = 0.0;
      var len = 0;
      for (int n = start; n <= i; n++) {
        amount += (dataList[n].high + dataList[n].low + dataList[n].close) / 3;
        len++;
      }
      final ma = amount / len;
      amount = 0.0;
      for (int n = start; n <= i; n++) {
        amount +=
            (ma - (dataList[n].high + dataList[n].low + dataList[n].close) / 3)
                .abs();
      }
      final md = amount / len;
      kline.cci = md == 0 ? 0 : ((tp - ma) / 0.015 / md);
      if (!kline.cci!.isFinite) kline.cci = 0.0;
    }
  }
}
