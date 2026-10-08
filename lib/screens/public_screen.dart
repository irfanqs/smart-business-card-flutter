import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core.dart';
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
              'Pasang APK Smart Business Card, lalu buka tautan ini kembali.',
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

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Detail Kontak Relasi')),
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
                      const Icon(Icons.link_off, size: 48),
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
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: card['photo_url'] == null
                                  ? null
                                  : NetworkImage(card['photo_url'].toString()),
                              child: card['photo_url'] == null
                                  ? Text(
                                      (card['full_name']?.toString() ?? '?')
                                          .substring(0, 1),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              card['full_name']?.toString() ?? '',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              [card['job_title'], card['company']]
                                  .where(
                                    (e) => e != null && e.toString().isNotEmpty,
                                  )
                                  .join(' • '),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              [card['industry'], card['city']]
                                  .where(
                                    (e) => e != null && e.toString().isNotEmpty,
                                  )
                                  .join(' • '),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if ((card['bio']?.toString() ?? '').isNotEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('“${card['bio']}”'),
                        ),
                      ),
                    const SizedBox(height: 14),
                    Text(
                      'INFORMASI KONTAK & TAUTAN',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    if ((card['public_email']?.toString() ?? '').isNotEmpty)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.email_outlined),
                          title: Text(card['public_email'].toString()),
                          trailing: const Text('Kirim Email'),
                          onTap: () => launchUrl(
                            Uri(
                              scheme: 'mailto',
                              path: card['public_email'].toString(),
                            ),
                          ),
                        ),
                      ),
                    if ((card['phone']?.toString() ?? '').isNotEmpty)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.call_outlined),
                          title: Text(card['phone'].toString()),
                          trailing: const Text('Hubungi'),
                          onTap: () => launchUrl(
                            Uri(scheme: 'tel', path: card['phone'].toString()),
                          ),
                        ),
                      ),
                    if ((card['linkedin']?.toString() ?? '').isNotEmpty)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.link),
                          title: Text(card['linkedin'].toString()),
                          trailing: const Text('Buka Profil'),
                          onTap: () => launchUrl(
                            Uri.parse(card['linkedin'].toString()),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () => save(card),
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Simpan ke Relasi'),
                    ),
                    if (kIsWeb)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'Untuk menyimpan relasi, pasang APK Smart Business Card di Android. Profil ini tetap bisa dilihat tanpa akun.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );
}
