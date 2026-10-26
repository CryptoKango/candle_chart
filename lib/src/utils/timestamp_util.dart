/// Converts Unix timestamps expressed in seconds or milliseconds to
/// milliseconds.
///
/// Values whose absolute magnitude is below `100000000000` are treated as
/// seconds. This keeps the chart compatible with common exchange APIs while
/// using milliseconds internally.
int? normalizeTimestampMillis(int? timestamp) {
  if (timestamp == null) return null;
  return timestamp.abs() < 100000000000 ? timestamp * 1000 : timestamp;
}
