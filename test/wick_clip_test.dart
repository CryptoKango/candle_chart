import 'package:flutter_test/flutter_test.dart';
import 'package:lib_chart/lib_chart.dart';

void main() {
  group('trueRange', () {
    test('with prev close inside range', () {
      final cur = KLineEntity.fromCustom(
        open: 100,
        high: 110,
        low: 95,
        close: 105,
        vol: 0,
        time: 0,
      );
      final prev = KLineEntity.fromCustom(
        open: 101,
        high: 108,
        low: 100,
        close: 102,
        vol: 0,
        time: 0,
      );
      // max(15, |110-102|=8, |95-102|=7) = 15
      expect(trueRange(cur, prev), 15);
    });

    test('gap up beyond high-low', () {
      final cur = KLineEntity.fromCustom(
        open: 200,
        high: 205,
        low: 198,
        close: 203,
        vol: 0,
        time: 0,
      );
      final prev = KLineEntity.fromCustom(
        open: 100,
        high: 102,
        low: 99,
        close: 101,
        vol: 0,
        time: 0,
      );
      // max(7, |205-101|=104, |198-101|=97) = 104
      expect(trueRange(cur, prev), 104);
    });

    test('null prev falls back to high-low', () {
      final cur = KLineEntity.fromCustom(
        open: 100,
        high: 112,
        low: 90,
        close: 98,
        vol: 0,
        time: 0,
      );
      expect(trueRange(cur, null), 22);
    });
  });

  group('calcAtr', () {
    List<KLineEntity> build() => [
      KLineEntity.fromCustom(
        open: 100,
        high: 102,
        low: 99,
        close: 101,
        vol: 0,
        time: 0,
      ),
      KLineEntity.fromCustom(
        open: 101,
        high: 106,
        low: 100,
        close: 105,
        vol: 0,
        time: 0,
      ),
      KLineEntity.fromCustom(
        open: 105,
        high: 107,
        low: 103,
        close: 104,
        vol: 0,
        time: 0,
      ),
    ];

    test('simple average over window', () {
      final datas = build();
      // TR0 = 3 (high-low)
      // TR1 = max(6, |106-101|=5, |100-101|=1) = 6
      // TR2 = max(4, |107-105|=2, |103-105|=2) = 4
      expect(calcAtr(datas, 0, 2, 14), closeTo(13 / 3, 1e-9));
    });

    test('empty window returns 0', () {
      expect(calcAtr([], 0, 0, 14), 0);
    });
  });

  group('clampWick', () {
    test('no clipping when threshold is 0', () {
      final r = clampWick(110, 90, 100, 105, 0);
      expect(r.$1, 110);
      expect(r.$2, 90);
    });

    test('single-side upper clip', () {
      // upper = max(100,105)+5 = 110; high=120 → 110
      final r = clampWick(120, 95, 100, 105, 5);
      expect(r.$1, 110);
      expect(r.$2, 95);
    });

    test('single-side lower clip', () {
      // lower = min(100,105)-5 = 95; low=80 → 95
      final r = clampWick(108, 80, 100, 105, 5);
      expect(r.$1, 108);
      expect(r.$2, 95);
    });

    test('both sides clipped', () {
      final r = clampWick(130, 60, 100, 105, 5);
      expect(r.$1, 110);
      expect(r.$2, 95);
    });

    test('within threshold unchanged', () {
      final r = clampWick(108, 97, 100, 105, 5);
      expect(r.$1, 108);
      expect(r.$2, 97);
    });
  });
}
