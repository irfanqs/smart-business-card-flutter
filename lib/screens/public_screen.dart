import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core.dart';
import '../theme.dart';
import '../ui.dart';
import 'auth_screen.dart';
import 'relations_screen.dart';

String normalizedEmail(dynamic value) =>
    value?.toString().trim().toLowerCase() ?? '';
String normalizedPhone(dynamic value) =>
    value?.toString().replaceAll(RegExp(r'\D'), '') ?? '';

class PublicScreen extends StatefulWidget {
  const PublicScreen({super.key, required this.store, required this.token});
  final AppStore store;
  final String token;
  @override
  State<PublicScreen> createState() => _PublicScreenState();
}

class _PublicScreenState extends State<PublicScreen> {
  late Future<Map<String, dynamic>> future;
  @override
  void initState() {
    super.initState();
    future = widget.store.publicCard(widget.token);
  }

  Future<void> save(Map<String, dynamic> card) async {
    if (kIsWeb) {
      final uri = Uri(
        scheme: 'smartcard',
        host: 'save',
        path: '/${widget.token}',
      );
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
          mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pasang APK $appName, lalu buka tautan ini kembali.',
            ),
          ),
        );
      }
      return;
    }
    if (!widget.store.signedIn) {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => AuthScreen(
            store: widget.store,
            onDone: () => Navigator.pop(context),
          ),
        ),
      );
      if (!widget.store.signedIn) return;
    }
    try {
      final latest = await widget.store.publicCard(widget.token);
      if (latest['owner_id'] == widget.store.userId) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ini kartu Anda sendiri. Buka tab Kartu Saya.'),
            ),
          );
        return;
      }
      final existing = widget.store.relations
          .where((r) => r['source_owner_id'] == latest['owner_id'])
          .firstOrNull;
      if (existing != null) {
        if (mounted)
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) =>
                  RelationDetailScreen(store: widget.store, relation: existing),
            ),
          );
        return;
      }
      final matching = widget.store.relations
          .where(
            (r) =>
                r['source_owner_id'] == null &&
                ((normalizedEmail(latest['public_email']).isNotEmpty &&
                        normalizedEmail(r['email']) ==
                            normalizedEmail(latest['public_email'])) ||
                    (normalizedPhone(latest['phone']).isNotEmpty &&
                        normalizedPhone(r['phone']) ==
                            normalizedPhone(latest['phone']))),
          )
          .firstOrNull;
      if (matching != null && mounted) {
        final merge = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Kontak serupa ditemukan'),
            content: const Text(
              'Hubungkan kartu ini ke kontak manual yang sudah ada? Suntingan dan catatan Anda tetap tersimpan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Buat Baru'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Hubungkan'),
              ),
            ],
          ),
        );
        if (merge == true) {
          await widget.store.saveRelation({
            'full_name': matching['full_name'],
            'job_title': matching['job_title'],
            'company': matching['company'],
            'email': matching['email'],
            'phone': matching['phone'],
            'linkedin': matching['linkedin'],
            'category': matching['category'],
            'source_owner_id': latest['owner_id'],
          }, id: matching['id'].toString());
          if (mounted)
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => RelationDetailScreen(
                  store: widget.store,
                  relation: widget.store.relations.firstWhere(
                    (r) => r['id'] == matching['id'],
                  ),
                ),
              ),
            );
          return;
        }
      }
      if (mounted)
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => RelationFormScreen(
              store: widget.store,
              initial: {
                'full_name': latest['full_name'],
                'job_title': latest['job_title'],
                'company': latest['company'],
                'email': latest['public_email'],
                'phone': latest['phone'],
                'linkedin': latest['linkedin'],
                'source_owner_id': latest['owner_id'],
              },
              sourceToken: widget.token,
            ),
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is StateError ? e.message.toString() : errorText(e),
            ),
          ),
        );
    }
  }

  String get _link =>
      '${publicBaseUrl.replaceAll(RegExp(r'/$'), '')}/p/${widget.token}';

  Widget _hero(Map<String, dynamic> card) {
    final name = card['full_name']?.toString() ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline),
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 184,
            child: Stack(
              children: [
                Container(
                  height: 128,
                  decoration:
                      const BoxDecoration(gradient: AppColors.bannerGradient),
                ),
                const GlowSpot(right: -40, top: -40, size: 176),
                const Positioned(
                  top: 14,
                  right: 14,
                  child: GlassPill(
                    dark: true,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.hub_outlined, size: 13, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'SmartLink Card',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: AppShadows.level3,
                          ),
                          child: card['photo_url'] == null
                              ? InitialsAvatar(name: name, size: 96)
                              : CircleAvatar(
                                  radius: 48,
                                  backgroundColor: AppColors.primaryContainer,
                                  backgroundImage: NetworkImage(
                                    card['photo_url'].toString(),
                                  ),
                                ),
                        ),
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.successDot,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified_outlined,
                      size: 20,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
                if (hasText(joinParts([card['job_title'], card['company']])))
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text.rich(
                      TextSpan(
                        text: hasText(card['job_title'])
                            ? card['job_title'].toString()
                            : '',
                        children: [
                          if (hasText(card['job_title']) &&
                              hasText(card['company']))
                            const TextSpan(text: ' di '),
                          if (hasText(card['company']))
                            TextSpan(
                              text: card['company'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                if (hasText(joinParts([card['industry'], card['city']]))) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (hasText(card['industry']))
                        StatusBadge(
                          card['industry'].toString(),
                          icon: Icons.domain,
                          color: AppColors.textBody,
                          background: AppColors.tonal,
                          border: AppColors.outline,
                          fontSize: 12,
                        ),
                      if (hasText(card['city']))
                        StatusBadge(
                          card['city'].toString(),
                          icon: Icons.location_on_outlined,
                          color: AppColors.textBody,
                          background: AppColors.tonal,
                          border: AppColors.outline,
                          fontSize: 12,
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                const StatusBadge(
                  'Dibagikan via SmartLink Network',
                  icon: Icons.verified_user_outlined,
                  color: Color(0xFF1D4ED8),
                  fontSize: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Profil Publik')),
        body: FutureBuilder<Map<String, dynamic>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done)
              return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError)
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const IconBox(Icons.link_off, size: 56),
                      const SizedBox(height: 12),
                      Text(
                        snapshot.error is StateError
                            ? (snapshot.error as StateError).message.toString()
                            : errorText(snapshot.error!),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () => setState(
                          () => future = widget.store.publicCard(widget.token),
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            final card = snapshot.data!;
            final channels = [
              card['public_email'],
              card['phone'],
              card['linkedin'],
            ].where(hasText).length;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    SurfaceCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          const IconBox(
                            Icons.lock_outline,
                            size: 24,
                            radius: 12,
                            color: AppColors.success,
                            background: AppColors.successContainer,
                            border: Color(0xFFD1FAE5),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              publicBaseUrl.isEmpty
                                  ? 'Profil instan SmartLink'
                                  : _link.replaceFirst(
                                      RegExp('^https?://'), ''),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textBody,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const StatusBadge(
                            'Profil Publik',
                            color: Color(0xFF1D4ED8),
                            dot: AppColors.successDot,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    _hero(card),
                    if (hasText(card['bio']))
                      SurfaceCard(
                        child: Stack(
                          children: [
                            const Positioned(
                              right: -6,
                              bottom: -14,
                              child: Icon(
                                Icons.format_quote,
                                size: 72,
                                color: AppColors.tonal,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.format_quote,
                                      size: 16,
                                      color: AppColors.secondary,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'TENTANG PROFIL',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '“${card['bio']}”',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.6,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.textBody,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    if (channels > 0)
                      SectionLabel(
                        'Informasi Kontak & Tautan',
                        color: const Color(0xFF1E293B),
                        trailing: StatusBadge(
                          '$channels Saluran Aktif',
                          color: AppColors.successStrong,
                          background: AppColors.successContainer,
                          border: const Color(0xFFD1FAE5),
                          dot: AppColors.successDot,
                        ),
                      ),
                    if (hasText(card['public_email']))
                      ContactRow(
                        icon: Icons.mail_outline,
                        label: 'Alamat Surel',
                        value: card['public_email'].toString(),
                        action: 'Kirim Email',
                        onTap: () => launchUrl(
                          Uri(
                            scheme: 'mailto',
                            path: card['public_email'].toString(),
                          ),
                        ),
                      ),
                    if (hasText(card['phone']))
                      ContactRow(
                        icon: Icons.call_outlined,
                        label: 'Nomor Telepon',
                        value: card['phone'].toString(),
                        action: 'Hubungi',
                        tint: Tint.green,
                        onTap: () => launchUrl(
                          Uri(scheme: 'tel', path: card['phone'].toString()),
                        ),
                      ),
                    if (hasText(card['linkedin']))
                      ContactRow(
                        icon: Icons.badge_outlined,
                        label: 'LinkedIn',
                        value: card['linkedin'].toString(),
                        action: 'Buka Profil',
                        actionIcon: Icons.open_in_new,
                        tint: Tint.indigo,
                        onTap: () => launchUrl(
                          Uri.parse(card['linkedin'].toString()),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                    const InfoNote(
                      'Anda sedang mengakses profil instan yang dibagikan melalui Kode QR fisik/digital kartu SmartLink.',
                      icon: Icons.qr_code_scanner,
                      boxed: true,
                    ),
                    if (kIsWeb)
                      const InfoNote(
                        'Untuk menyimpan relasi, pasang APK $appName di Android. Profil ini tetap bisa dilihat tanpa akun.',
                        icon: Icons.android,
                        boxed: true,
                      ),
                    const SizedBox(height: 4),
                    FilledButton.icon(
                      onPressed: () => save(card),
                      icon: const Icon(Icons.person_add_alt_1, size: 20),
                      label: const Text('Simpan ke Relasi'),
                    ),
                    if (publicBaseUrl.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        style: tintedButton(),
                        onPressed: () => SharePlus.instance.share(
                          ShareParams(text: _link),
                        ),
                        icon: const Icon(Icons.share_outlined, size: 18),
                        label: const Text('Bagikan Profil Ini'),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 15,
                          color: AppColors.secondary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          appName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBody,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Data kontak yang Anda simpan adalah salinan independen di daftar relasi Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),
      );
}
