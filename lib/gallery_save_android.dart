import 'dart:typed_data';

import 'package:gal/gal.dart';

class GallerySave {
  static Future<void> putQr(Uint8List bytes) =>
      Gal.putImageBytes(bytes, album: 'Smart Business Card');
}
