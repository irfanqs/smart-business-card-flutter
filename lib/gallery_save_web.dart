import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

class GallerySave {
  static Future<void> putQr(Uint8List bytes) async {
    final blob = web.Blob(
      [bytes.toJS].toJS,
      web.BlobPropertyBag(type: 'image/png'),
    );
    final url = web.URL.createObjectURL(blob);
    web.HTMLAnchorElement()
      ..href = url
      ..download = 'smartlink-qr.png'
      ..click();
    web.URL.revokeObjectURL(url);
  }
}
