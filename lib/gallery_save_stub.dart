import 'dart:typed_data';

class GallerySave {
  static Future<void> putQr(Uint8List bytes) async {
    throw UnsupportedError(
      'Gambar QR hanya dapat disimpan dari aplikasi Android.',
    );
  }
}
