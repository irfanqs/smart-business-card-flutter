import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../core.dart';
import '../gallery_save.dart';
import '../theme.dart';

void showError(BuildContext context, Object error) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error is StateError ? error.message.toString() : errorText(error),
        ),
      ),
    );

Future<void> refreshWithFeedback(BuildContext context, AppStore store) async {
  try {
    await store.refresh();
  } catch (e) {
    if (context.mounted) showError(context, e);
  }
}

class CardTab extends StatelessWidget {
  const CardTab({super.key, required this.store});
  final AppStore store;
  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: () => refreshWithFeedback(context, store),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Kartu Saya',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(
              'Kartu Digital Saya',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (store.card == null)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Belum ada kartu. Buat kartu pertama Anda.'),
                ),
              )
            else
              CardPreview(store: store, data: store.card!),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: store.card == null
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => ShareScreen(store: store),
                        ),
                      ),
              icon: const Icon(Icons.qr_code),
              label: const Text('Tampilkan QR Code'),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => CardEditor(store: store),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined),
                    label:
                        Text(store.card == null ? 'Buat Kartu' : 'Edit Kartu'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: store.card == null
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => ShareScreen(store: store),
                              ),
                            ),
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Bagikan Kartu'),
                  ),
                ),
              ],
            ),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Kartu digital dapat dipindai tanpa memasang aplikasi.',
                ),
              ),
            ),
          ],
        ),
      );
}

class CardPreview extends StatelessWidget {
  const CardPreview({super.key, required this.store, required this.data});
  final AppStore store;
  final Map<String, dynamic> data;
  @override
  Widget build(BuildContext context) {
    const muted = TextStyle(color: Colors.white70);
    final details = [
      for (final key in ['public_email', 'phone', 'linkedin'])
        if ((data[key]?.toString() ?? '').isNotEmpty) data[key].toString(),
    ];
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProfilePhoto(
                  store: store,
                  path: data['photo_path']?.toString(),
                  name: data['full_name']?.toString() ?? '',
                  size: 62,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['full_name']?.toString() ?? '',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        [data['job_title'], data['company']]
                            .where((e) => e != null && e.toString().isNotEmpty)
                            .join(' • '),
                      ),
                      Text(
                        [data['industry'], data['city']]
                            .where((e) => e != null && e.toString().isNotEmpty)
                            .join(' • '),
                        style: muted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (details.isNotEmpty) ...[
              const Divider(height: 28, color: Colors.white24),
              for (final detail in details)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(detail),
                ),
            ],
            if ((data['bio']?.toString() ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '“${data['bio']}”',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ProfilePhoto extends StatefulWidget {
  const ProfilePhoto({
    super.key,
    required this.store,
    required this.path,
    required this.name,
    this.size = 52,
  });
  final AppStore store;
  final String? path;
  final String name;
  final double size;
  @override
  State<ProfilePhoto> createState() => _ProfilePhotoState();
}

class _ProfilePhotoState extends State<ProfilePhoto> {
  Future<String?>? url;

  @override
  void initState() {
    super.initState();
    url = widget.store.photoUrl(widget.path);
  }

  @override
  void didUpdateWidget(ProfilePhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) url = widget.store.photoUrl(widget.path);
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.path;
    final name = widget.name;
    if (path == null || path.isEmpty)
      return CircleAvatar(
        radius: widget.size / 2,
        child: Text(name.isEmpty ? '?' : name.substring(0, 1).toUpperCase()),
      );
    return FutureBuilder<String?>(
      future: url,
      builder: (context, snapshot) => CircleAvatar(
        radius: widget.size / 2,
        backgroundImage:
            snapshot.data == null ? null : NetworkImage(snapshot.data!),
        child: snapshot.data == null ? const Icon(Icons.person_outline) : null,
      ),
    );
  }
}

class CardEditor extends StatefulWidget {
  const CardEditor({super.key, required this.store});
  final AppStore store;
  @override
  State<CardEditor> createState() => _CardEditorState();
}

class _CardEditorState extends State<CardEditor> {
  final form = GlobalKey<FormState>();
  final fields = <String, TextEditingController>{};
  Uint8List? photo;
  String? extension;
  bool busy = false;
  final labels = const {
    'full_name': 'Nama Lengkap *',
    'job_title': 'Jabatan',
    'company': 'Perusahaan',
    'industry': 'Industri',
    'city': 'Kota',
    'public_email': 'Email',
    'phone': 'Nomor Telepon',
    'linkedin': 'LinkedIn URL',
    'bio': 'Bio Singkat',
  };
  @override
  void initState() {
    super.initState();
    for (final key in labels.keys)
      fields[key] = TextEditingController(
        text: widget.store.card?[key]?.toString() ?? '',
      );
  }

  @override
  void dispose() {
    for (final c in fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> pickPhoto() async {
    final XFile? file;
    final Uint8List bytes;
    try {
      file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file == null) return;
      bytes = await file.readAsBytes();
    } catch (e) {
      if (mounted)
        showError(context,
            StateError('Foto tidak dapat dibuka. Periksa izin galeri.'));
      return;
    }
    if (!mounted) return;
    final ext = file.name.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png'].contains(ext) ||
        bytes.length > 2 * 1024 * 1024) {
      showError(context, StateError('Pilih foto JPG/PNG maksimal 2 MB.'));
      return;
    }
    setState(() {
      photo = bytes;
      extension = ext == 'png' ? 'png' : 'jpg';
    });
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      String? photoPath = widget.store.card?['photo_path']?.toString();
      if (photo != null)
        photoPath = await widget.store.uploadPhoto(photo!, extension!);
      final body = {
        for (final entry in fields.entries) entry.key: entry.value.text.trim(),
        'photo_path': photoPath,
        'is_public': widget.store.card?['is_public'] ?? true,
      };
      await widget.store.saveCard(body);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = {
      for (final e in fields.entries) e.key: e.value.text,
      'photo_path': widget.store.card?['photo_path'],
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Kartu Bisnis')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: busy ? null : save,
            icon: const Icon(Icons.save_outlined),
            label: Text(busy ? 'Menyimpan...' : 'Simpan Perubahan Kartu'),
          ),
        ),
      ),
      body: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            InkWell(
              onTap: pickPhoto,
              child: Container(
                height: 140,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: photo == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, size: 34),
                          Text('Unggah Foto Profil (300×300)'),
                          Text('JPG/PNG maks. 2MB'),
                        ],
                      )
                    : Image.memory(photo!, height: 125, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 18),
            for (final entry in labels.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: TextFormField(
                  controller: fields[entry.key],
                  maxLength: entry.key == 'bio' ? 160 : null,
                  maxLines: entry.key == 'bio' ? 3 : 1,
                  keyboardType: entry.key == 'public_email'
                      ? TextInputType.emailAddress
                      : entry.key == 'phone'
                          ? TextInputType.phone
                          : TextInputType.text,
                  decoration: InputDecoration(
                    labelText: entry.value,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    if (entry.key == 'full_name' &&
                        (value?.trim().isEmpty ?? true))
                      return 'Nama wajib diisi';
                    if (entry.key == 'public_email')
                      return validateEmail(value);
                    if (entry.key == 'phone') return validatePhone(value);
                    if (entry.key == 'linkedin') return validateLinkedIn(value);
                    return null;
                  },
                ),
              ),
            const Text('PREVIEW RINGKAS KARTU'),
            CardPreview(store: widget.store, data: preview),
          ],
        ),
      ),
    );
  }
}

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key, required this.store});
  final AppStore store;
  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  String? url;
  String? error;
  @override
  void initState() {
    super.initState();
    generate();
  }

  Future<void> generate() async {
    try {
      final link = await widget.store.createShareLink();
      if (mounted) setState(() => url = link);
    } catch (e) {
      if (mounted)
        setState(
          () => error = e is StateError ? e.message.toString() : errorText(e),
        );
    }
  }

  Future<void> action(String kind) async {
    try {
      if (kind == 'copy') await Clipboard.setData(ClipboardData(text: url!));
      if (kind == 'share')
        await SharePlus.instance.share(ShareParams(text: url!));
      if (kind == 'download') {
        final bytes = await QrPainter(
          data: url!,
          version: QrVersions.auto,
        ).toImageData(1024);
        if (bytes == null) throw StateError('Gambar QR gagal dibuat.');
        await GallerySave.putQr(bytes.buffer.asUint8List());
      }
      await widget.store.recordShare(kind);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              kind == 'copy'
                  ? 'Tautan disalin.'
                  : kind == 'download'
                      ? 'QR tersimpan di galeri.'
                      : 'Menu berbagi dibuka.',
            ),
          ),
        );
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Pemindai Kartu & QR')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('MODE BERBAGI INSTAN'),
            const SizedBox(height: 6),
            Text(
              'Bagikan Kartu Saya',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Text(
              'Tunjukkan QR Code ini kepada rekan atau mitra bisnis Anda secara langsung.',
            ),
            const SizedBox(height: 22),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      widget.store.card?['full_name']?.toString() ?? '',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(widget.store.card?['job_title']?.toString() ?? ''),
                    const SizedBox(height: 15),
                    if (error != null)
                      Text(error!, textAlign: TextAlign.center)
                    else if (url == null)
                      const CircularProgressIndicator()
                    else
                      QrImageView(
                        data: url!,
                        size: 230,
                        backgroundColor: Colors.white,
                      ),
                    const SizedBox(height: 10),
                    const Text(
                      'Pindai QR Code untuk melihat profil publik & menyimpan kontak.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: url == null ? null : () => action('copy'),
              icon: const Icon(Icons.link),
              label: const Text('Salin Tautan Profil Publik'),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: url == null ? null : () => action('share'),
                    icon: const Icon(Icons.share),
                    label: const Text('Bagikan Pesan'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: url == null ? null : () => action('download'),
                    icon: const Icon(Icons.download),
                    label: const Text('Unduh Gambar'),
                  ),
                ),
              ],
            ),
            if (url != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(url!),
                ),
              ),
            const Text(
              'Tautan berlaku 24 jam. Membuka halaman ini lagi membuat QR baru.',
            ),
          ],
        ),
      );
}
