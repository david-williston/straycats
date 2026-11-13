const _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

/// The geohash of a point, [precision] characters long. At 6 characters a
/// cell is about 1.2 km by 0.6 km: a neighbourhood, never a doorstep.
String encodeGeohash(double lat, double lng, {int precision = 6}) {
  var latMin = -90.0, latMax = 90.0, lngMin = -180.0, lngMax = 180.0;
  final out = StringBuffer();
  var even = true; // bits alternate longitude, latitude
  var bit = 0, ch = 0;
  while (out.length < precision) {
    if (even) {
      final mid = (lngMin + lngMax) / 2;
      if (lng >= mid) {
        ch = (ch << 1) | 1;
        lngMin = mid;
      } else {
        ch = ch << 1;
        lngMax = mid;
      }
    } else {
      final mid = (latMin + latMax) / 2;
      if (lat >= mid) {
        ch = (ch << 1) | 1;
        latMin = mid;
      } else {
        ch = ch << 1;
        latMax = mid;
      }
    }
    even = !even;
    if (++bit == 5) {
      out.write(_base32[ch]);
      bit = 0;
      ch = 0;
    }
  }
  return out.toString();
}

/// The centre of the cell named by [hash]. This is where a place is drawn:
/// the middle of the neighbourhood-sized cell, never the original point.
({double lat, double lng}) decodeGeohashCenter(String hash) {
  var latMin = -90.0, latMax = 90.0, lngMin = -180.0, lngMax = 180.0;
  var even = true;
  for (final c in hash.split('')) {
    final v = _base32.indexOf(c);
    for (var b = 4; b >= 0; b--) {
      final on = (v >> b) & 1 == 1;
      if (even) {
        final mid = (lngMin + lngMax) / 2;
        on ? lngMin = mid : lngMax = mid;
      } else {
        final mid = (latMin + latMax) / 2;
        on ? latMin = mid : latMax = mid;
      }
      even = !even;
    }
  }
  return (lat: (latMin + latMax) / 2, lng: (lngMin + lngMax) / 2);
}
