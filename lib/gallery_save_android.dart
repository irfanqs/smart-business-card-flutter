import 'dart:typed_data';

import 'package:gal/gal.dart';

class GallerySave {
  static Future<void> putQr(Uint8List bytes) async {
    if (!await Gal.hasAccess(toAlbum: true)) {
      await Gal.requestAccess(toAlbum: true);
    }
    await Gal.putImageBytes(bytes, album: 'Smart Business Card');
  }
}
