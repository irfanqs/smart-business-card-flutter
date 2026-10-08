import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core.dart';
import '../reminder_notifier.dart';
import 'card_screen.dart';
import 'public_screen.dart';

export '../reminder_notifier.dart';

String dateLabel(DateTime date) =>
    DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal());

class RelationsTab extends StatefulWidget {
  const RelationsTab({super.key, required this.store});
  final AppStore store;
  @override
  State<RelationsTab> createState() => _RelationsTabState();
}

class _RelationsTabState extends State<RelationsTab> {
  String search = '', filter = 'Semua';
  @override
  Widget build(BuildContext context) {
    final items = widget.store.relations.where((r) {
      final q = search.toLowerCase();
      return (filter == 'Semua' || r['category'] == filter) &&
          ('${r['full_name']} ${r['company']}'.toLowerCase().contains(q));
    }).toList();
    return RefreshIndicator(
      onRefresh: () => refreshWithFeedback(context, widget.store),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Relasi', style: Theme.of(context).textTheme.headlineSmall),
          Text('Daftar Relasi', style: Theme.of(context).textTheme.titleLarge),
          Text('${widget.store.relations.length} kontak tersimpan'),
          const SizedBox(height: 14),
          TextField(
            onChanged: (v) => setState(() => search = v),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Cari nama atau perusahaan...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final option in ['Semua', ...categories])
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(option),
                      selected: filter == option,
                      onSelected: (_) => setState(() => filter = option),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => RelationFormScreen(store: widget.store),
                    ),
                  ),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Tambah Kontak'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => ScannerScreen(store: widget.store),
                    ),
                  ),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Pindai QR'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Tidak ada relasi yang cocok. Tambahkan kontak atau ubah pencarian.',
                ),
              ),
            ),
          for (final relation in items)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(
                    (relation['full_name']?.toString() ?? '?')
                        .substring(0, 1)
                        .toUpperCase(),
                  ),
                ),
                title: Text(relation['full_name']?.toString() ?? ''),
                subtitle: Text(
                  [
                    relation['job_title'],
                    relation['company'],
                    relation['category'],
                  ]
                      .where((e) => e != null && e.toString().isNotEmpty)
                      .join(' • '),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => RelationDetailScreen(
                      store: widget.store,
                      relation: relation,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key, required this.store});
  final AppStore store;
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool handled = false;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Pindai QR Kartu')),
        body: Column(
          children: [
            Expanded(
              child: MobileScanner(
                onDetect: (capture) {
                  if (handled || capture.barcodes.isEmpty) return;
                  final value = capture.barcodes.first.rawValue;
                  final uri = Uri.tryParse(value ?? '');
                  final base = Uri.tryParse(publicBaseUrl);
                  if (uri == null ||
                      base == null ||
                      uri.host != base.host ||
                      uri.pathSegments.length != 2 ||
                      uri.pathSegments.first != 'p') {
                    handled = true;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('QR tidak dikenali.')),
                    );
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => handled = false);
                    });
                    return;
                  }
                  handled = true;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => PublicScreen(
                        store: widget.store,
                        token: uri.pathSegments[1],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Arahkan kamera ke QR Smart Business Card.'),
            ),
          ],
        ),
      );
}

class RelationFormScreen extends StatefulWidget {
  const RelationFormScreen({
    super.key,
    required this.store,
    this.initial,
    this.sourceToken,
  });
  final AppStore store;
  final Map<String, dynamic>? initial;
  final String? sourceToken;
  @override
  State<RelationFormScreen> createState() => _RelationFormScreenState();
}

class _RelationFormScreenState extends State<RelationFormScreen> {
  final form = GlobalKey<FormState>();
  final fields = <String, TextEditingController>{};
  String? category;
  bool busy = false;
  final labels = const {
    'full_name': 'Nama Lengkap *',
    'job_title': 'Jabatan',
    'company': 'Perusahaan',
    'email': 'Email',
    'phone': 'Nomor Telepon',
    'linkedin': 'LinkedIn URL',
  };
  @override
  void initState() {
    super.initState();
    for (final key in labels.keys)
      fields[key] = TextEditingController(
        text: widget.initial?[key]?.toString() ?? '',
      );
    category = widget.initial?['category']?.toString();
  }

  @override
  void dispose() {
    for (final c in fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      if (widget.sourceToken != null)
        await widget.store.publicCard(widget.sourceToken!);
      final data = {
        for (final e in fields.entries) e.key: e.value.text.trim(),
        'category': category,
        'source_owner_id': widget.initial?['source_owner_id'],
      };
      await widget.store.saveRelation(
        data,
        id: widget.initial?['id']?.toString(),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            widget.initial?['id'] == null
                ? 'Simpan sebagai Relasi'
                : 'Edit Relasi',
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton(
              onPressed: busy ? null : save,
              child: Text(busy ? 'Menyimpan...' : 'Simpan Relasi'),
            ),
          ),
        ),
        body: Form(
          key: form,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final e in labels.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: TextFormField(
                    controller: fields[e.key],
                    decoration: InputDecoration(
                      labelText: e.value,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (e.key == 'full_name' && (v?.trim().isEmpty ?? true))
                        return 'Nama wajib diisi';
                      if (e.key == 'email') return validateEmail(v);
                      if (e.key == 'phone') return validatePhone(v);
                      if (e.key == 'linkedin') return validateLinkedIn(v);
                      return null;
                    },
                  ),
                ),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(
                  labelText: 'Kategori / Nama Grup',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: '',
                    child: Text('Belum dipilih'),
                  ),
                  for (final c in categories)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (v) => setState(() => category = v == '' ? null : v),
              ),
            ],
          ),
        ),
      );
}

class RelationDetailScreen extends StatefulWidget {
  const RelationDetailScreen({
    super.key,
    required this.store,
    required this.relation,
  });
  final AppStore store;
  final Map<String, dynamic> relation;
  @override
  State<RelationDetailScreen> createState() => _RelationDetailScreenState();
}

class _RelationDetailScreenState extends State<RelationDetailScreen> {
  late Future<List<Map<String, dynamic>>> notes;
  @override
  void initState() {
    super.initState();
    notes = widget.store.interactions(widget.relation['id'].toString());
  }

  void reload() => setState(
        () =>
            notes = widget.store.interactions(widget.relation['id'].toString()),
      );
  Future<void> deleteRelation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus relasi?'),
        content: const Text(
          'Kontak, catatan, dan pengingat relasi ini akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ReminderNotifier.cancel(widget.relation['id'].toString());
      await widget.store.deleteRelation(widget.relation['id'].toString());
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.store.relations
            .where((e) => e['id'] == widget.relation['id'])
            .firstOrNull ??
        widget.relation;
    final reminder = widget.store.reminders
        .where((e) => e['relation_id'] == r['id'])
        .firstOrNull;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kontak Relasi'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'edit')
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        RelationFormScreen(store: widget.store, initial: r),
                  ),
                ).then((_) => setState(() {}));
              if (v == 'delete') deleteRelation();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit Kontak')),
              PopupMenuItem(value: 'delete', child: Text('Hapus Kontak')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r['full_name']?.toString() ?? '',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    [r['job_title'], r['company']]
                        .where((e) => e != null && e.toString().isNotEmpty)
                        .join(' • '),
                  ),
                  if (r['category'] != null)
                    Chip(label: Text(r['category'].toString())),
                ],
              ),
            ),
          ),
          if ((r['phone']?.toString() ?? '').isNotEmpty)
            ListTile(
              leading: const Icon(Icons.call),
              title: Text(r['phone'].toString()),
              onTap: () =>
                  launchUrl(Uri(scheme: 'tel', path: r['phone'].toString())),
            ),
          if ((r['email']?.toString() ?? '').isNotEmpty)
            ListTile(
              leading: const Icon(Icons.mail),
              title: Text(r['email'].toString()),
              onTap: () =>
                  launchUrl(Uri(scheme: 'mailto', path: r['email'].toString())),
            ),
          if ((r['linkedin']?.toString() ?? '').isNotEmpty)
            ListTile(
              leading: const Icon(Icons.link),
              title: Text(r['linkedin'].toString()),
              onTap: () => launchUrl(
                Uri.parse(r['linkedin'].toString()),
                mode: LaunchMode.externalApplication,
              ),
            ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Riwayat Interaksi',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => InteractionFormScreen(
                      store: widget.store,
                      relationId: r['id'].toString(),
                    ),
                  ),
                ).then((_) => reload()),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Catatan'),
              ),
            ],
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: notes,
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(errorText(snapshot.error!)),
                );
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              if (snapshot.data!.isEmpty)
                return const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text('Belum ada catatan interaksi.'),
                );
              return Column(
                children: [
                  for (final note in snapshot.data!)
                    Card(
                      child: ListTile(
                        title: Text(note['note']?.toString() ?? ''),
                        subtitle: Text(
                          '${dateLabel(DateTime.parse(note['happened_at'].toString()))}${(note['location']?.toString() ?? '').isEmpty ? '' : ' • ${note['location']}'}',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) async {
                            try {
                              if (v == 'edit')
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => InteractionFormScreen(
                                      store: widget.store,
                                      relationId: r['id'].toString(),
                                      initial: note,
                                    ),
                                  ),
                                );
                              if (v == 'delete')
                                await widget.store.deleteInteraction(
                                  note['id'].toString(),
                                );
                              reload();
                            } catch (e) {
                              if (mounted) showError(context, e);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Hapus'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pengingat Follow-up',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => ReminderFormScreen(
                      store: widget.store,
                      relationId: r['id'].toString(),
                      existing: reminder,
                    ),
                  ),
                ).then((_) => setState(() {})),
                child: Text(reminder == null ? 'Atur' : 'Ubah'),
              ),
            ],
          ),
          Text(
            reminder == null
                ? 'Belum ada pengingat.'
                : dateLabel(DateTime.parse(reminder['remind_at'].toString())),
          ),
          if (reminder != null)
            TextButton(
              onPressed: () async {
                try {
                  await widget.store.deleteReminder(r['id'].toString());
                  await ReminderNotifier.cancel(r['id'].toString());
                  if (mounted) setState(() {});
                } catch (e) {
                  if (mounted) showError(context, e);
                }
              },
              child: const Text('Hapus Pengingat'),
            ),
        ],
      ),
    );
  }
}

class InteractionFormScreen extends StatefulWidget {
  const InteractionFormScreen({
    super.key,
    required this.store,
    required this.relationId,
    this.initial,
  });
  final AppStore store;
  final String relationId;
  final Map<String, dynamic>? initial;
  @override
  State<InteractionFormScreen> createState() => _InteractionFormScreenState();
}

class _InteractionFormScreenState extends State<InteractionFormScreen> {
  bool busy = false;
  late final note = TextEditingController(
    text: widget.initial?['note']?.toString() ?? '',
  );
  late final location = TextEditingController(
    text: widget.initial?['location']?.toString() ?? '',
  );
  late DateTime at =
      DateTime.tryParse(widget.initial?['happened_at']?.toString() ?? '')
              ?.toLocal() ??
          DateTime.now();
  @override
  void dispose() {
    note.dispose();
    location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Catatan Interaksi')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              title: const Text('Tanggal Pertemuan'),
              subtitle: Text(dateLabel(at)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: at,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (d != null)
                  setState(
                    () => at =
                        DateTime(d.year, d.month, d.day, at.hour, at.minute),
                  );
              },
            ),
            TextField(
              controller: location,
              decoration: const InputDecoration(
                labelText: 'Lokasi (opsional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: note,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Catatan Pribadi *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: busy
                  ? null
                  : () async {
                      if (note.text.trim().isEmpty) {
                        showError(context, StateError('Catatan wajib diisi.'));
                        return;
                      }
                      setState(() => busy = true);
                      try {
                        await widget.store.saveInteraction(
                          widget.relationId,
                          at,
                          note.text,
                          location.text,
                          id: widget.initial?['id']?.toString(),
                        );
                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                        if (context.mounted) showError(context, e);
                      } finally {
                        if (mounted) setState(() => busy = false);
                      }
                    },
              child: Text(busy ? 'Menyimpan...' : 'Simpan Catatan'),
            ),
          ],
        ),
      );
}

class ReminderFormScreen extends StatefulWidget {
  const ReminderFormScreen({
    super.key,
    required this.store,
    required this.relationId,
    this.existing,
  });
  final AppStore store;
  final String relationId;
  final Map<String, dynamic>? existing;
  @override
  State<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends State<ReminderFormScreen> {
  late DateTime at =
      DateTime.tryParse(widget.existing?['remind_at']?.toString() ?? '')
              ?.toLocal() ??
          DateTime.now().add(const Duration(days: 1));
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Atur Pengingat')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              title: const Text('Tanggal'),
              subtitle: Text(dateLabel(at)),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: at,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (d != null)
                  setState(
                    () => at =
                        DateTime(d.year, d.month, d.day, at.hour, at.minute),
                  );
              },
            ),
            ListTile(
              title: const Text('Waktu'),
              subtitle: Text(DateFormat('HH:mm').format(at)),
              onTap: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(at),
                );
                if (t != null)
                  setState(
                    () => at =
                        DateTime(at.year, at.month, at.day, t.hour, t.minute),
                  );
              },
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () async {
                if (!at.isAfter(DateTime.now())) {
                  showError(context, StateError('Pilih waktu di masa depan.'));
                  return;
                }
                try {
                  await widget.store.saveReminder(widget.relationId, at);
                  await ReminderNotifier.sync(widget.store);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) showError(context, e);
                }
              },
              child: const Text('Simpan Pengingat'),
            ),
            const Text(
              'Notifikasi dijadwalkan pada perangkat Android ini. Jika izin notifikasi belum diberikan, aktifkan melalui pengaturan perangkat.',
            ),
          ],
        ),
      );
}
