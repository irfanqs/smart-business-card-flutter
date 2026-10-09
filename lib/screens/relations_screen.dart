import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core.dart';
import '../reminder_notifier.dart';
import '../theme.dart';
import '../ui.dart';
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
  static const sorts = ['Terbaru Ditambahkan', 'Nama A–Z'];
  String search = '', filter = 'Semua', sort = sorts.first;

  void open(Widget screen) => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => screen),
      );

  @override
  Widget build(BuildContext context) {
    final all = widget.store.relations;
    final items = all.where((r) {
      final q = search.toLowerCase();
      return (filter == 'Semua' || r['category'] == filter) &&
          ('${r['full_name']} ${r['company']} ${r['job_title']}'
              .toLowerCase()
              .contains(q));
    }).toList();
    if (sort == sorts.last) {
      items.sort(
        (a, b) => (a['full_name']?.toString() ?? '')
            .toLowerCase()
            .compareTo((b['full_name']?.toString() ?? '').toLowerCase()),
      );
    } else {
      items.sort(
        (a, b) => (b['created_at']?.toString() ?? '')
            .compareTo(a['created_at']?.toString() ?? ''),
      );
    }
    int count(String option) => option == 'Semua'
        ? all.length
        : all.where((r) => r['category'] == option).length;
    return TabPage(
      header: TabHeader(
        title: 'Relasi',
        name: widget.store.card?['full_name']?.toString(),
      ),
      onRefresh: () => refreshWithFeedback(context, widget.store),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Daftar Relasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            StatusBadge(
              '${all.length} Kontak Tersimpan',
              color: AppColors.primary,
              background: const Color(0xFFE2E7FF),
              border: const Color(0x66B8C4FF),
              fontSize: 12,
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Manajemen Personal Relationship Management (PRM) & Pertemuan',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 14),
        TextField(
          onChanged: (v) => setState(() => search = v),
          style: const TextStyle(fontSize: 13),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search, color: AppColors.secondary),
            hintText: 'Cari nama, perusahaan, atau jabatan...',
            hintStyle: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: AppColors.textTertiary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              for (final option in ['Semua', ...categories])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: filter == option
                        ? AppColors.primary
                        : const Color(0xFFEAEDFF),
                    shape: const StadiumBorder(),
                    elevation: filter == option ? 2 : 0,
                    shadowColor: AppColors.primary.withValues(alpha: 0.3),
                    child: InkWell(
                      customBorder: const StadiumBorder(),
                      onTap: () => setState(() => filter = option),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        child: Text(
                          '$option (${count(option)})',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: filter == option
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: filter == option
                                ? Colors.white
                                : const Color(0xFF444653),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => open(RelationFormScreen(store: widget.store)),
              icon: const Icon(Icons.person_add_alt_1, size: 16),
              label: const Text('Tambah'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              style: tintedButton().copyWith(
                minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 12),
                ),
                textStyle: const WidgetStatePropertyAll(
                  TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              onPressed: () => open(ScannerScreen(store: widget.store)),
              icon: const Icon(Icons.qr_code_scanner, size: 16),
              label: const Text('Pindai QR'),
            ),
            const Spacer(),
            PopupMenuButton<String>(
              initialValue: sort,
              onSelected: (v) => setState(() => sort = v),
              itemBuilder: (_) => [
                for (final s in sorts) PopupMenuItem(value: s, child: Text(s)),
              ],
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 96),
                      child: Text(
                        sort,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.expand_more,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (items.isEmpty)
          const SurfaceCard(
            padding: EdgeInsets.all(24),
            child: Text(
              'Tidak ada relasi yang cocok. Tambahkan kontak atau ubah pencarian.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        for (final relation in items)
          _RelationCard(
            store: widget.store,
            relation: relation,
            onOpen: open,
          ),
        if (all.isNotEmpty)
          const InfoNote(
            'Data relasi disimpan terpisah dari kontak telepon. Kontak tidak berubah walau pemilik kartu mengubah kartunya.',
            title: 'Penyimpanan PRM Terproteksi',
            icon: Icons.shield_outlined,
            boxed: true,
          ),
      ],
    );
  }
}

class _RelationCard extends StatelessWidget {
  const _RelationCard({
    required this.store,
    required this.relation,
    required this.onOpen,
  });
  final AppStore store;
  final Map<String, dynamic> relation;
  final ValueChanged<Widget> onOpen;

  @override
  Widget build(BuildContext context) {
    final reminder = store.reminders
        .where((e) => e['relation_id'] == relation['id'])
        .firstOrNull;
    final detail = RelationDetailScreen(store: store, relation: relation);
    return SurfaceCard(
      radius: 12,
      padding: const EdgeInsets.all(14),
      borderColor: const Color(0xFFE2E7FF),
      onTap: () => onOpen(detail),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InitialsAvatar(name: relation['full_name']?.toString()),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          relation['full_name']?.toString() ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (relation['category'] != null)
                          StatusBadge.category(
                            relation['category'].toString(),
                          ),
                      ],
                    ),
                    if (hasText(joinParts(
                      [relation['job_title'], relation['company']],
                    )))
                      Text(
                        joinParts([relation['job_title'], relation['company']]),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF444653),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (reminder != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFF2F3FF),
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(8),
                ),
                border: Border(
                  left: BorderSide(color: AppColors.secondary, width: 2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.alarm,
                    size: 14,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Follow-up ${dateLabel(DateTime.parse(reminder['remind_at'].toString()))}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF444653),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.history, size: 12, color: Color(0xFF757684)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  dateOnly(relation['created_at']),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF757684),
                  ),
                ),
              ),
              if (hasText(relation['phone']))
                _QuickAction(
                  icon: Icons.call_outlined,
                  tooltip: 'Telepon',
                  onTap: () => launchUrl(
                    Uri(scheme: 'tel', path: relation['phone'].toString()),
                  ),
                ),
              if (hasText(relation['email']))
                _QuickAction(
                  icon: Icons.mail_outline,
                  tooltip: 'Email',
                  onTap: () => launchUrl(
                    Uri(scheme: 'mailto', path: relation['email'].toString()),
                  ),
                ),
              _QuickAction(
                icon: Icons.arrow_forward,
                tooltip: 'Detail',
                filled: true,
                onTap: () => onOpen(detail),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String dateOnly(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  return date == null ? '-' : DateFormat('dd/MM/yyyy').format(date.toLocal());
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.filled = false,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Material(
          color: filled ? AppColors.primary : const Color(0xFFEAEDFF),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Tooltip(
              message: tooltip,
              child: SizedBox(
                width: 36,
                height: 36,
                child: Icon(
                  icon,
                  size: 18,
                  color: filled ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      );
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
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: const Row(
                children: [
                  IconBox(Icons.qr_code_scanner),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Arahkan kamera ke QR $appName.'),
                  ),
                ],
              ),
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
  final place = TextEditingController();
  final note = TextEditingController();
  DateTime metAt = DateTime.now();
  String? category;
  bool busy = false;
  static const labels = {
    'full_name': 'Nama Lengkap',
    'job_title': 'Jabatan',
    'company': 'Perusahaan',
    'email': 'Email',
    'phone': 'Nomor Telepon',
    'linkedin': 'LinkedIn URL',
  };
  static const icons = {
    'email': Icons.mail_outline,
    'phone': Icons.call_outlined,
    'linkedin': Icons.link,
  };

  bool get creating => widget.initial?['id'] == null;
  bool get fromCard => widget.sourceToken != null;

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
    place.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    if (creating && place.text.trim().isNotEmpty && note.text.trim().isEmpty) {
      showError(
        context,
        StateError('Isi catatan pribadi untuk menyimpan lokasi pertemuan.'),
      );
      return;
    }
    setState(() => busy = true);
    try {
      if (widget.sourceToken != null)
        await widget.store.publicCard(widget.sourceToken!);
      final data = {
        for (final e in fields.entries) e.key: e.value.text.trim(),
        'category': category,
        'source_owner_id': widget.initial?['source_owner_id'],
      };
      final saved = await widget.store.saveRelation(
        data,
        id: widget.initial?['id']?.toString(),
      );
      if (creating && note.text.trim().isNotEmpty)
        await widget.store.saveInteraction(
          saved['id'].toString(),
          metAt,
          note.text,
          place.text,
        );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Relasi berhasil disimpan!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget _summary() => SurfaceCard(
        borderColor: AppColors.outlineSoft,
        shadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: InitialsAvatar(
                name: fields['full_name']!.text,
                size: 52,
                status: AppColors.successDot,
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
                          fields['full_name']!.text,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
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
                  if (hasText(joinParts([
                    fields['job_title']!.text,
                    fields['company']!.text,
                  ])))
                    Text(
                      joinParts(
                        [fields['job_title']!.text, fields['company']!.text],
                      ),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  if (hasText(fields['email']!.text))
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.mail_outline,
                            size: 14,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              fields['email']!.text,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondary,
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
      );

  Widget _categoryOption(String c) {
    final selected = category == c;
    return Material(
      color: selected
          ? AppColors.primaryContainer.withValues(alpha: 0.6)
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? AppColors.secondary : AppColors.outline,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => category = selected ? null : c),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.secondary : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? AppColors.secondary
                        : const Color(0xFFCBD5E1),
                    width: 2,
                  ),
                ),
                child: selected
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  c,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color:
                        selected ? const Color(0xFF1E3A8A) : AppColors.textBody,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactFields() => Column(
        children: [
          for (final e in labels.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FieldLabel(e.value, required: e.key == 'full_name'),
                  TextFormField(
                    controller: fields[e.key],
                    keyboardType: e.key == 'email'
                        ? TextInputType.emailAddress
                        : e.key == 'phone'
                            ? TextInputType.phone
                            : TextInputType.text,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: icons[e.key] == null
                          ? null
                          : Icon(icons[e.key], size: 20),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      if (e.key == 'full_name' && (v?.trim().isEmpty ?? true))
                        return 'Nama wajib diisi';
                      if (e.key == 'email') return validateEmail(v);
                      if (e.key == 'phone') return validatePhone(v);
                      if (e.key == 'linkedin') return validateLinkedIn(v);
                      return null;
                    },
                  ),
                ],
              ),
            ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final tonalInput = InputDecoration(
      filled: true,
      fillColor: AppColors.canvas,
      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(creating ? 'Simpan sebagai Relasi' : 'Edit Relasi'),
      ),
      body: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF475569),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.chevron_left, size: 22),
                  label: const Text(
                    'Batal',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                const Spacer(),
                StatusBadge(
                  fromCard ? 'DARI KARTU SMARTLINK' : 'KONTAK MANUAL',
                  color: AppColors.textSecondary,
                  background: AppColors.tonal,
                  border: null,
                  radius: 6,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (fromCard) _summary(),
            SurfaceCard(
              borderColor: AppColors.outlineSoft,
              shadow: const [
                BoxShadow(
                  color: Color(0x0A0F172A),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FieldLabel(
                    'Kategori / Nama Grup',
                    trailing: 'Pilih salah satu',
                  ),
                  const SizedBox(height: 4),
                  for (var i = 0; i < categories.length; i += 2) ...[
                    if (i > 0) const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _categoryOption(categories[i])),
                        const SizedBox(width: 10),
                        Expanded(
                          child: i + 1 < categories.length
                              ? _categoryOption(categories[i + 1])
                              : const SizedBox(),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 18),
                  if (fromCard)
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: const EdgeInsets.only(top: 6),
                        leading: const Icon(
                          Icons.contact_page_outlined,
                          size: 18,
                          color: AppColors.secondary,
                        ),
                        title: const Text(
                          'Ubah Data Kontak',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textBody,
                          ),
                        ),
                        children: [_contactFields()],
                      ),
                    )
                  else
                    _contactFields(),
                  if (creating) ...[
                    const SizedBox(height: 4),
                    const FieldLabel(
                      'Tanggal & Lokasi Pertemuan',
                      icon: Icons.calendar_month_outlined,
                    ),
                    Row(
                      children: [
                        Material(
                          color: AppColors.canvas,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.outline),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: metAt,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (d != null)
                                setState(
                                  () => metAt = DateTime(
                                    d.year,
                                    d.month,
                                    d.day,
                                    metAt.hour,
                                    metAt.minute,
                                  ),
                                );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              child: Text(
                                DateFormat('dd/MM/yyyy').format(metAt),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: place,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: tonalInput.copyWith(
                              hintText: 'cth: Tech Conference Jakarta',
                              prefixIcon: const Icon(
                                Icons.pin_drop_outlined,
                                size: 20,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const FieldLabel(
                      'Catatan Pribadi',
                      icon: Icons.lock_outline,
                      trailing: 'Hanya Anda yang melihat',
                    ),
                    TextField(
                      controller: note,
                      maxLines: 3,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: tonalInput.copyWith(
                        hintText:
                            'cth: Diskusi potensi kolaborasi, follow up minggu depan.',
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const InfoNote(
                    'Kontak akan tersimpan di database SmartLink PRM tanpa mengubah kontak buku telepon bawaan perangkat.',
                    title: 'Penyimpanan Aman & Terpisah',
                    icon: Icons.verified_user_outlined,
                    boxed: true,
                  ),
                  const SizedBox(height: 4),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 52),
                    ),
                    onPressed: busy ? null : save,
                    icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                    label: Text(busy ? 'Menyimpan...' : 'Simpan Relasi'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
          SurfaceCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                InitialsAvatar(name: r['full_name']?.toString(), size: 60),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r['full_name']?.toString() ?? '',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        joinParts([r['job_title'], r['company']]),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (r['category'] != null) ...[
                        const SizedBox(height: 8),
                        StatusBadge.category(r['category'].toString()),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (joinParts([r['phone'], r['email'], r['linkedin']]).isNotEmpty)
            const SectionLabel('Informasi Kontak & Tautan'),
          if ((r['email']?.toString() ?? '').isNotEmpty)
            ContactRow(
              icon: Icons.mail_outline,
              label: 'Alamat Surel',
              value: r['email'].toString(),
              action: 'Kirim Email',
              onTap: () =>
                  launchUrl(Uri(scheme: 'mailto', path: r['email'].toString())),
            ),
          if ((r['phone']?.toString() ?? '').isNotEmpty)
            ContactRow(
              icon: Icons.call_outlined,
              label: 'Nomor Telepon',
              value: r['phone'].toString(),
              action: 'Hubungi',
              onTap: () =>
                  launchUrl(Uri(scheme: 'tel', path: r['phone'].toString())),
            ),
          if ((r['linkedin']?.toString() ?? '').isNotEmpty)
            ContactRow(
              icon: Icons.badge_outlined,
              label: 'LinkedIn',
              value: r['linkedin'].toString(),
              action: 'Buka Profil',
              actionIcon: Icons.open_in_new,
              onTap: () => launchUrl(
                Uri.parse(r['linkedin'].toString()),
                mode: LaunchMode.externalApplication,
              ),
            ),
          const SizedBox(height: 12),
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
                    SurfaceCard(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      radius: 12,
                      child: ListTile(
                        leading: const IconBox(Icons.sticky_note_2_outlined),
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
          SurfaceCard(
            radius: 12,
            child: Row(
              children: [
                IconBox(
                  Icons.alarm,
                  color: reminder == null
                      ? AppColors.textSecondary
                      : AppColors.error,
                  background: reminder == null
                      ? AppColors.tonal
                      : AppColors.errorContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    reminder == null
                        ? 'Belum ada pengingat.'
                        : dateLabel(
                            DateTime.parse(reminder['remind_at'].toString()),
                          ),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (reminder != null)
                  const StatusBadge(
                    'Follow-up',
                    color: AppColors.error,
                    background: AppColors.errorContainer,
                  ),
              ],
            ),
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
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: note,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Catatan Pribadi *',
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
