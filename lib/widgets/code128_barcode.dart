import 'package:flutter/material.dart';

class Code128Barcode extends StatelessWidget {
  const Code128Barcode({
    super.key,
    required this.data,
    this.width = 220,
    this.height = 52,
    this.label,
  });

  final String data;
  final double width;
  final double height;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final barcodeData = data.trim();

    return Semantics(
      label: label ?? 'Barcode for $barcodeData',
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(painter: _Code128BarcodePainter(barcodeData)),
      ),
    );
  }
}

class _Code128BarcodePainter extends CustomPainter {
  _Code128BarcodePainter(String data) : _codes = _encode(data), super();

  final List<int> _codes;

  static const int _startCodeB = 104;
  static const int _stopCode = 106;
  static const int _quietZoneModules = 10;

  static const List<String> _patterns = [
    '212222',
    '222122',
    '222221',
    '121223',
    '121322',
    '131222',
    '122213',
    '122312',
    '132212',
    '221213',
    '221312',
    '231212',
    '112232',
    '122132',
    '122231',
    '113222',
    '123122',
    '123221',
    '223211',
    '221132',
    '221231',
    '213212',
    '223112',
    '312131',
    '311222',
    '321122',
    '321221',
    '312212',
    '322112',
    '322211',
    '212123',
    '212321',
    '232121',
    '111323',
    '131123',
    '131321',
    '112313',
    '132113',
    '132311',
    '211313',
    '231113',
    '231311',
    '112133',
    '112331',
    '132131',
    '113123',
    '113321',
    '133121',
    '313121',
    '211331',
    '231131',
    '213113',
    '213311',
    '213131',
    '311123',
    '311321',
    '331121',
    '312113',
    '312311',
    '332111',
    '314111',
    '221411',
    '431111',
    '111224',
    '111422',
    '121124',
    '121421',
    '141122',
    '141221',
    '112214',
    '112412',
    '122114',
    '122411',
    '142112',
    '142211',
    '241211',
    '221114',
    '413111',
    '241112',
    '134111',
    '111242',
    '121142',
    '121241',
    '114212',
    '124112',
    '124211',
    '411212',
    '421112',
    '421211',
    '212141',
    '214121',
    '412121',
    '111143',
    '111341',
    '131141',
    '114113',
    '114311',
    '411113',
    '411311',
    '113141',
    '114131',
    '311141',
    '411131',
    '211412',
    '211214',
    '211232',
    '2331112',
  ];

  static List<int> _encode(String data) {
    final values = data.runes.map(_code128BValue).toList();
    var checksum = _startCodeB;

    for (var index = 0; index < values.length; index++) {
      checksum += values[index] * (index + 1);
    }

    return [_startCodeB, ...values, checksum % 103, _stopCode];
  }

  static int _code128BValue(int rune) {
    if (rune >= 32 && rune <= 126) {
      return rune - 32;
    }

    return 31;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final totalModules =
        _codes
            .map((code) => _patterns[code])
            .expand((pattern) => pattern.runes)
            .fold<int>(0, (sum, rune) => sum + rune - 48) +
        (_quietZoneModules * 2);
    final moduleWidth = size.width / totalModules;
    final paint = Paint()..color = Colors.black;
    var x = _quietZoneModules * moduleWidth;

    for (final code in _codes) {
      var drawBar = true;

      for (final rune in _patterns[code].runes) {
        final runWidth = (rune - 48) * moduleWidth;

        if (drawBar) {
          canvas.drawRect(Rect.fromLTWH(x, 0, runWidth, size.height), paint);
        }

        x += runWidth;
        drawBar = !drawBar;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _Code128BarcodePainter oldDelegate) {
    if (_codes.length != oldDelegate._codes.length) {
      return true;
    }

    for (var index = 0; index < _codes.length; index++) {
      if (_codes[index] != oldDelegate._codes[index]) {
        return true;
      }
    }

    return false;
  }
}
