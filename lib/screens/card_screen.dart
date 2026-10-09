import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../core.dart';
import '../gallery_save.dart';
import '../theme.dart';
import '../ui.dart';

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

  void _open(BuildContext context, Widget screen) => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => screen),
      );

  @override
  Widget build(BuildContext context) {
    final card = store.card;
    return TabPage(
      header: TabHeader(
        title: 'Kartu Saya',
        name: card?['full_name']?.toString(),
      ),
      onRefresh: () => refreshWithFeedback(context, store),
      children: [
        Text(
          'Kartu Digital Saya',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        if (hasText(card?['company']))
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '${card!['company']} • SmartLink',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: card == null
              ? const StatusBadge(
                  'Belum ada kartu',
                  color: AppColors.textSecondary,
                  background: AppColors.tonal,
                  border: AppColors.outline,
                )
              : card['is_public'] == true
                  ? StatusBadge.live('Profil Publik Aktif • Siap Dibagikan')
                  : const StatusBadge(
                      'Profil Publik Nonaktif',
                      icon: Icons.visibility_off_outlined,
                      color: AppColors.warning,
                      background: AppColors.warningContainer,
                      border: Color(0xFFFDE68A),
                    ),
        ),
        const SizedBox(height: 16),
        if (card == null)
          SurfaceCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const IconBox(Icons.badge_outlined, size: 56),
                const SizedBox(height: 12),
                Text(
                  'Belum ada kartu',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Buat kartu pertama Anda.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          CardPreview(store: store, data: card),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: card == null
              ? null
              : () => _open(context, ShareScreen(store: store)),
          icon: const Icon(Icons.qr_code_scanner, size: 20),
          label: const Text('Tampilkan QR Code'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _open(context, CardEditor(store: store)),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(card == null ? 'Buat Kartu' : 'Edit Kartu'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: card == null
                    ? null
                    : () => _open(context, ShareScreen(store: store)),
                icon: const Icon(Icons.send_outlined, size: 18),
                label: const Text('Bagikan Kartu'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const InfoNote(
          'Kartu digital ini dapat dipindai oleh siapa saja tanpa memerlukan instalasi aplikasi khusus.',
        ),
      ],
    );
  }
}

/// Kartu digital putih seperti di layar "Kartu Saya".
class CardPreview extends StatelessWidget {
  const CardPreview({super.key, required this.store, required this.data});
  final AppStore store;
  final Map<String, dynamic> data;
  @override
  Widget build(BuildContext context) {
    final name = data['full_name']?.toString() ?? '';
    final details = [
      for (final (key, icon) in [
        ('public_email', Icons.mail_outline),
        ('phone', Icons.call_outlined),
        ('linkedin', Icons.share_outlined),
      ])
        if (hasText(data[key])) (icon, data[key].toString()),
    ];
    final updated = DateTime.tryParse(data['updated_at']?.toString() ?? '');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primarySoftBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x141E40AF),
            blurRadius: 30,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          const GlowSpot(
            right: -48,
            top: -48,
            size: 150,
            color: Color(0x1A3B82F6),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.hub_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasText(data['company'])
                                ? data['company'].toString()
                                : 'Kartu Digital',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (hasText(data['industry']))
                            Text(
                              data['industry'].toString().toUpperCase(),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                                color: AppColors.secondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const StatusBadge(
                      'SMARTLINK',
                      icon: Icons.nfc,
                      color: AppColors.primary,
                      border: AppColors.primaryBorder,
                      fontSize: 10,
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(color: AppColors.outlineSoft),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusDot(
                      size: 14,
                      child: ProfilePhoto(
                        store: store,
                        path: data['photo_path']?.toString(),
                        name: name,
                        size: 64,
                        square: true,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name.isEmpty ? 'Nama Lengkap' : name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified_outlined,
                                size: 16,
                                color: AppColors.secondary,
                              ),
                            ],
                          ),
                          if (hasText(joinParts(
                            [data['job_title'], data['company']],
                          )))
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                joinParts([data['job_title'], data['company']]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          if (hasText(joinParts(
                            [data['industry'], data['city']],
                          )))
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 13,
                                    color: AppColors.textTertiary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      joinParts(
                                        [data['industry'], data['city']],
                                        ' | ',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineSoft),
                    ),
                    child: Column(
                      children: [
                        for (final (icon, detail) in details)
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              children: [
                                IconBox(
                                  icon,
                                  size: 28,
                                  radius: 8,
                                  color: const Color(0xFF1D4ED8),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    detail,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textBody,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                if (hasText(data['bio'])) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryContainer,
                          AppColors.indigoContainer.withValues(alpha: 0.5),
                          AppColors.canvas,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primarySoftBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.format_quote,
                          size: 18,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '“${data['bio']}”',
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.6,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                const Divider(color: AppColors.outlineSoft),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        updated == null
                            ? 'SmartLink Card'
                            : 'Diperbarui ${relativeDay(updated.toIso8601String()).toLowerCase()}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    const StatusBadge(
                      'Pratinjau Live',
                      color: AppColors.primary,
                      border: AppColors.primarySoftBorder,
                      radius: 6,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu bergradien ringkas untuk pratinjau di editor.
class GradientCardPreview extends StatelessWidget {
  const GradientCardPreview({
    super.key,
    required this.store,
    required this.data,
    this.photo,
  });
  final AppStore store;
  final Map<String, dynamic> data;
  final Uint8List? photo;

  @override
  Widget build(BuildContext context) {
    final name = data['full_name']?.toString() ?? '';
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppColors.previewGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x662563EB),
            blurRadius: 28,
            spreadRadius: -6,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          const GlowSpot(
            right: -48,
            top: -48,
            size: 176,
            color: Color(0x3360A5FA),
          ),
          Positioned(
            right: 12,
            top: 8,
            child: Text(
              'NFC',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w800,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: DefaultTextStyle.merge(
              style: const TextStyle(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: photo != null
                            ? Image.memory(photo!, fit: BoxFit.cover)
                            : hasText(data['photo_path'])
                                ? ProfilePhoto(
                                    store: store,
                                    path: data['photo_path']?.toString(),
                                    name: name,
                                    size: 52,
                                    square: true,
                                  )
                                : const Icon(
                                    Icons.person_outline,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.isEmpty ? 'Nama Lengkap' : name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              joinParts([data['job_title'], data['company']]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFDBEAFE),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (hasText(joinParts([data['city'], data['industry']]))) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Color(0xFFBFDBFE),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            joinParts([data['city'], data['industry']]),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFDBEAFE),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  Divider(
                    height: 28,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  if (hasText(data['bio']))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        '“${data['bio']}”',
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.6,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFFDBEAFE),
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      const Icon(
                        Icons.alternate_email,
                        size: 14,
                        color: Color(0xFFBFDBFE),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          hasText(data['public_email'])
                              ? data['public_email'].toString()
                              : 'email@domain.com',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.qr_code_2,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'QR',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
    this.square = false,
  });
  final AppStore store;
  final String? path;
  final String name;
  final double size;

  /// Sudut membulat alih-alih lingkaran penuh.
  final bool square;
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
    final fallback = InitialsAvatar(
      name: widget.name,
      size: widget.size,
      square: widget.square,
    );
    if (path == null || path.isEmpty) return fallback;
    return FutureBuilder<String?>(
      future: url,
      builder: (context, snapshot) {
        if (snapshot.data == null) return fallback;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: widget.square ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: widget.square
                ? BorderRadius.circular(widget.size * 0.25)
                : null,
            image: DecorationImage(
              image: NetworkImage(snapshot.data!),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
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
  static const labels = {
    'full_name': 'Nama Lengkap',
    'job_title': 'Jabatan',
    'company': 'Perusahaan',
    'industry': 'Industri',
    'city': 'Kota',
    'public_email': 'Email',
    'phone': 'Nomor Telepon',
    'linkedin': 'LinkedIn URL',
    'bio': 'Bio Singkat',
  };
  static const icons = {
    'public_email': Icons.mail_outline,
    'phone': Icons.call_outlined,
    'linkedin': Icons.link,
  };
  static const hints = {
    'full_name': 'Contoh: Andi Pratama',
    'job_title': 'Contoh: Product Manager',
    'company': 'Contoh: Nusantara Teknologi',
    'industry': 'Contoh: Teknologi Informasi',
    'city': 'Contoh: Jakarta',
    'public_email': 'nama@domain.id',
    'phone': '+62 xxx xxxx xxxx',
    'linkedin': 'https://linkedin.com/in/username',
    'bio': 'Tuliskan ringkasan singkat profil profesional Anda...',
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

  Widget _field(String key) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FieldLabel(
              labels[key]!,
              required: key == 'full_name',
              trailing: key == 'full_name'
                  ? 'Wajib diisi'
                  : key == 'bio'
                      ? '${fields['bio']!.text.length}/160'
                      : null,
            ),
            TextFormField(
              controller: fields[key],
              maxLength: key == 'bio' ? 160 : null,
              maxLines: key == 'bio' ? 3 : 1,
              keyboardType: key == 'public_email'
                  ? TextInputType.emailAddress
                  : key == 'phone'
                      ? TextInputType.phone
                      : TextInputType.text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hints[key],
                counterText: '',
                prefixIcon:
                    icons[key] == null ? null : Icon(icons[key], size: 20),
              ),
              onChanged: (_) => setState(() {}),
              validator: (value) {
                if (key == 'full_name' && (value?.trim().isEmpty ?? true))
                  return 'Nama wajib diisi';
                if (key == 'public_email') return validateEmail(value);
                if (key == 'phone') return validatePhone(value);
                if (key == 'linkedin') return validateLinkedIn(value);
                return null;
              },
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final preview = {
      for (final e in fields.entries) e.key: e.value.text,
      'photo_path': widget.store.card?['photo_path'],
    };
    final creating = widget.store.card == null;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(creating ? 'Buat Kartu Bisnis' : 'Edit Kartu Bisnis'),
            Text(
              creating ? 'Kartu digital baru' : 'Profil Digital Aktif',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.outlineSoft)),
          ),
          child: FilledButton.icon(
            onPressed: busy ? null : save,
            icon: const Icon(Icons.save_outlined, size: 20),
            label: Text(busy ? 'Menyimpan...' : 'Simpan Perubahan Kartu'),
          ),
        ),
      ),
      body: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                PillButton(
                  label: 'Batalkan',
                  icon: Icons.close,
                  filled: true,
                  onTap: () => Navigator.pop(context),
                ),
                const Spacer(),
                StatusBadge(
                  creating ? 'Status: Kartu Baru' : 'Status: Mode Siap Edit',
                  color: const Color(0xFF1D4ED8),
                  border: AppColors.primaryBorder,
                  dot: AppColors.secondary,
                  fontSize: 12,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(24),
              borderColor: AppColors.outlineSoft,
              onTap: pickPhoto,
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [AppColors.secondary, Color(0xFF38BDF8)],
                          ),
                        ),
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: photo != null
                              ? Image.memory(photo!, fit: BoxFit.cover)
                              : hasText(widget.store.card?['photo_path'])
                                  ? ProfilePhoto(
                                      store: widget.store,
                                      path: widget.store.card?['photo_path']
                                          ?.toString(),
                                      name: fields['full_name']!.text,
                                      size: 84,
                                    )
                                  : const Icon(
                                      Icons.account_circle_outlined,
                                      size: 44,
                                      color: AppColors.tertiary,
                                    ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.photo_camera,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ubah Foto Profil',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Rekomendasi rasio 1:1 (JPG/PNG maks. 2MB)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            for (final key in ['full_name', 'job_title', 'company'])
              _field(key),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _field('industry')),
                const SizedBox(width: 12),
                Expanded(child: _field('city')),
              ],
            ),
            for (final key in ['public_email', 'phone', 'linkedin', 'bio'])
              _field(key),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 18,
                  color: AppColors.secondary,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'PREVIEW RINGKAS KARTU',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.textBody,
                    ),
                  ),
                ),
                StatusBadge('Tampilan Publik'),
              ],
            ),
            const SizedBox(height: 12),
            GradientCardPreview(
              store: widget.store,
              data: preview,
              photo: photo,
            ),
            const SizedBox(height: 16),
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
                  ? 'Tautan profil berhasil disalin ke papan klip!'
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

  Widget _corner(Alignment at) {
    const side = BorderSide(color: AppColors.secondary, width: 2);
    return Align(
      alignment: at,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          border: Border(
            top: at.y < 0 ? side : BorderSide.none,
            bottom: at.y > 0 ? side : BorderSide.none,
            left: at.x < 0 ? side : BorderSide.none,
            right: at.x > 0 ? side : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _qr() {
    if (error != null)
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          error!,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13),
        ),
      );
    if (url == null) return const CircularProgressIndicator();
    return Stack(
      alignment: Alignment.center,
      children: [
        QrImageView(
          data: url!,
          size: 196,
          padding: const EdgeInsets.all(6),
          errorCorrectionLevel: QrErrorCorrectLevel.H,
          backgroundColor: Colors.white,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: AppColors.textPrimary,
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: AppColors.textPrimary,
          ),
        ),
        Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: AppShadows.level2,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.share, size: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.store.card;
    return Scaffold(
      appBar: AppBar(title: const Text('Pemindai & Kode QR')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: PillButton(
              label: 'Kembali ke Kartu Saya',
              icon: Icons.arrow_back,
              onTap: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: StatusBadge('MODE BERBAGI INSTAN', icon: Icons.qr_code_2),
          ),
          const SizedBox(height: 8),
          Text(
            'Bagikan Kartu Saya',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 4),
          const Text(
            'Tunjukkan QR Code ini kepada rekan atau mitra bisnis Anda secara langsung.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          SurfaceCard(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(24),
            borderColor: AppColors.outlineSoft,
            shadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 30,
                offset: Offset(0, 8),
              ),
            ],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InitialsAvatar(
                      name: card?['full_name']?.toString(),
                      size: 48,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card?['full_name']?.toString() ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (hasText(card?['job_title']))
                            Text(
                              card!['job_title'].toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 252,
                  height: 252,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.canvas,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: AppColors.primarySoftBorder),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: AppShadows.level1,
                            ),
                            child: _qr(),
                          ),
                        ),
                      ),
                      for (final at in [
                        Alignment.topLeft,
                        Alignment.topRight,
                        Alignment.bottomLeft,
                        Alignment.bottomRight,
                      ])
                        _corner(at),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primarySoftBorder),
                  ),
                  child: const Text(
                    'Pindai QR Code untuk melihat profil publik & menyimpan kontak langsung.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: url == null ? null : () => action('copy'),
            icon: const Icon(Icons.link, size: 20),
            label: const Text('Salin Tautan Profil Publik'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: tintedButton(),
                  onPressed: url == null ? null : () => action('share'),
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Bagikan Pesan'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: tintedButton(),
                  onPressed: url == null ? null : () => action('download'),
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Unduh Gambar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (url != null)
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'URL LANGSUNG',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      StatusBadge.live('Aktif (24 Jam)'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineSoft),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            url!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textBody,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Salin',
                          onPressed: () => action('copy'),
                          icon: const Icon(
                            Icons.content_copy,
                            size: 18,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const InfoNote(
            'Penerima tidak memerlukan aplikasi SmartLink untuk membuka profil ini di browser ponsel mereka. Tautan berlaku 24 jam; membuka halaman ini lagi membuat QR baru.',
          ),
        ],
      ),
    );
  }
}
