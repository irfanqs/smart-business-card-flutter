import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core.dart';
import '../theme.dart';
import '../ui.dart';
import 'auth_screen.dart';
import 'card_screen.dart';
import 'relations_screen.dart';

String shortDate(String? value) {
  final date = DateTime.tryParse(value ?? '');
  return date == null ? '' : DateFormat('dd/MM/yyyy').format(date.toLocal());
}

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key, required this.store});
  final AppStore store;
  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int tab = 0;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: widget.store,
        builder: (context, _) {
          final pages = [
            HomeTab(store: widget.store, onTab: (n) => setState(() => tab = n)),
            CardTab(store: widget.store),
            RelationsTab(store: widget.store),
            ProfileTab(store: widget.store),
          ];
          return Scaffold(
            body: SafeArea(child: pages[tab]),
            bottomNavigationBar: DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.outline)),
              ),
              child: NavigationBar(
                selectedIndex: tab,
                onDestinationSelected: (n) => setState(() => tab = n),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Beranda',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.badge_outlined),
                    selectedIcon: Icon(Icons.badge),
                    label: 'Kartu Saya',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.group_outlined),
                    selectedIcon: Icon(Icons.group),
                    label: 'Relasi',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Profil',
                  ),
                ],
              ),
            ),
          );
        },
      );
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.store, required this.onTab});
  final AppStore store;
  final ValueChanged<int> onTab;

  void _open(BuildContext context, Widget screen) => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => screen),
      );

  @override
  Widget build(BuildContext context) {
    final card = store.card;
    final recent = store.relations.take(3).toList();
    final since = DateTime.now().subtract(const Duration(days: 30));
    final newCount = store.relations
        .where(
          (r) => (DateTime.tryParse(r['created_at']?.toString() ?? '') ??
                  DateTime(2000))
              .isAfter(since),
        )
        .length;
    final firstName = (card?['full_name']?.toString() ?? '').split(' ').first;
    return TabPage(
      header: TabHeader(
        title: 'Beranda',
        name: card?['full_name']?.toString(),
      ),
      onRefresh: () => refreshWithFeedback(context, store),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo${firstName.isEmpty ? '' : ', $firstName'} 👋',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Kelola kartu nama & relasi profesional Anda',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.white,
              shape: const CircleBorder(
                side: BorderSide(color: AppColors.outline),
              ),
              child: IconButton(
                tooltip: 'Pengingat',
                onPressed: () => _open(context, RemindersScreen(store: store)),
                icon: Badge(
                  isLabelVisible: store.reminders.isNotEmpty,
                  smallSize: 8,
                  backgroundColor: AppColors.secondary,
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textBody,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _HeroCard(store: store, onOpen: (s) => _open(context, s)),
        const SizedBox(height: 16),
        SurfaceCard(
          padding: const EdgeInsets.all(14),
          onTap: card == null
              ? null
              : () => _open(context, ShareScreen(store: store)),
          child: Row(
            children: [
              const IconBox(Icons.qr_code_2, size: 44),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tampilkan QR Code',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Pindai langsung untuk bertukar kontak',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.canvas,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            for (final (i, stat) in [
              (
                Icons.groups_outlined,
                '${store.relations.length}',
                'Total Relasi'
              ),
              (Icons.send_outlined, '${store.shareCount}', 'Kartu Dibagikan'),
              (Icons.trending_up, '$newCount', 'Relasi Baru'),
            ].indexed) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: SurfaceCard(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 6,
                  ),
                  child: Column(
                    children: [
                      IconBox(
                        stat.$1,
                        size: 28,
                        radius: 8,
                        color: i == 2 ? AppColors.success : AppColors.primary,
                        background: i == 2
                            ? AppColors.successContainer
                            : AppColors.primaryContainer,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        stat.$2,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        stat.$3,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              const Text(
                'Relasi Terbaru',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              if (newCount > 0) StatusBadge('$newCount Baru'),
              const Spacer(),
              TextButton(
                onPressed: () => onTab(2),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Lihat Semua'),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        if (recent.isEmpty)
          const SurfaceCard(
            padding: EdgeInsets.all(20),
            child: Text(
              'Belum ada relasi. Tambahkan kontak atau pindai QR kartu.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          )
        else
          SurfaceCard(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                for (final (i, relation) in recent.indexed) ...[
                  if (i > 0) const Divider(color: AppColors.outlineSoft),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _open(
                      context,
                      RelationDetailScreen(store: store, relation: relation),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          InitialsAvatar(
                            name: relation['full_name']?.toString(),
                            status: relation['source_owner_id'] != null
                                ? AppColors.successDot
                                : const Color(0xFFCBD5E1),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  relation['full_name']?.toString() ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (hasText(joinParts([
                                  relation['job_title'],
                                  relation['company'],
                                ])))
                                  Text(
                                    joinParts(
                                      [
                                        relation['job_title'],
                                        relation['company']
                                      ],
                                      ' di ',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (relation['category'] != null) ...[
                                      StatusBadge.category(
                                        relation['category'].toString(),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Text(
                                      '• ${relativeDay(relation['created_at'])}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.textTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// Kartu digital bergradien di Beranda, lengkap dengan aksi cepat.
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.store, required this.onOpen});
  final AppStore store;
  final ValueChanged<Widget> onOpen;

  @override
  Widget build(BuildContext context) {
    final card = store.card;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppColors.gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x331E3A8A),
            blurRadius: 25,
            spreadRadius: -5,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        children: [
          const GlowSpot(right: -64, top: -64, size: 224),
          const GlowSpot(
            left: -48,
            bottom: -48,
            size: 192,
            color: Color(0x3360A5FA),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GlassPill(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: card == null
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF34D399),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            card == null
                                ? 'Belum Ada Kartu'
                                : 'Kartu Digital Aktif',
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const GlassPill(
                      dark: true,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sensors,
                            size: 15,
                            color: Color(0xFFBFDBFE),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'SmartLink NFC',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFDBEAFE),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ProfilePhoto(
                        store: store,
                        path: card?['photo_path']?.toString(),
                        name: card?['full_name']?.toString() ?? '',
                        size: 60,
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
                                  card?['full_name']?.toString() ??
                                      'Buat kartu pertama Anda',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (card != null) ...[
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.verified,
                                  size: 16,
                                  color: Color(0xFFFCD34D),
                                ),
                              ],
                            ],
                          ),
                          if (hasText(card?['job_title']))
                            Text(
                              card!['job_title'].toString(),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFDBEAFE),
                              ),
                            ),
                          if (hasText(card?['company']))
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.domain,
                                    size: 13,
                                    color: Color(0xFFBFDBFE),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      card!['company'].toString(),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFBFDBFE),
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
                if (hasText(joinParts([card?['industry'], card?['city']]))) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (hasText(card?['industry']))
                        GlassPill(
                          radius: 6,
                          child: Text(
                            card!['industry'].toString(),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      if (hasText(card?['city']))
                        GlassPill(
                          radius: 6,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                card!['city'].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => onOpen(CardEditor(store: store)),
                        icon: const Icon(Icons.edit_outlined, size: 17),
                        label: Text(card == null ? 'Buat Kartu' : 'Edit Kartu'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          disabledBackgroundColor:
                              Colors.white.withValues(alpha: 0.4),
                          textStyle: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: card == null
                            ? null
                            : () => onOpen(ShareScreen(store: store)),
                        icon: const Icon(Icons.share_outlined, size: 17),
                        label: const Text('Bagikan Kartu'),
                      ),
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

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key, required this.store});
  final AppStore store;

  void _open(BuildContext context, Widget screen) => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => screen),
      );

  @override
  Widget build(BuildContext context) {
    final card = store.card;
    final email = store.client.auth.currentUser?.email ?? '';
    return TabPage(
      header: TabHeader(
        title: 'Profil Pengaturan',
        icon: Icons.manage_accounts_outlined,
        name: card?['full_name']?.toString(),
      ),
      children: [
        SurfaceCard(
          padding: const EdgeInsets.all(18),
          borderColor: AppColors.outlineSoft,
          shadow: const [
            BoxShadow(
              color: Color(0x0F2563EB),
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  StatusDot(
                    size: 14,
                    child: ProfilePhoto(
                      store: store,
                      path: card?['photo_path']?.toString(),
                      name: card?['full_name']?.toString() ?? email,
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
                            Expanded(
                              child: Text(
                                card?['full_name']?.toString() ??
                                    'Belum ada kartu',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            StatusBadge(
                              store.account?['status'] == 'active'
                                  ? 'Aktif'
                                  : 'Nonaktif',
                              fontSize: 10,
                            ),
                          ],
                        ),
                        if (hasText(joinParts(
                          [card?['job_title'], card?['company']],
                        )))
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              joinParts([card?['job_title'], card?['company']]),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        if (email.isNotEmpty)
                          Row(
                            children: [
                              const Icon(
                                Icons.mail_outline,
                                size: 14,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  email,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: tintedButton().copyWith(
                  minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
                ),
                onPressed: () => _open(context, AccountScreen(store: store)),
                icon: const Icon(Icons.edit_note, size: 20),
                label: const Text('Edit Profil Akun'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const SectionLabel(
          'Pengaturan Kartu & Visibilitas',
          trailing: StatusBadge('1 Opsi', fontSize: 10, border: null),
        ),
        SettingsGroup(
          children: [
            SettingsTile(
              icon: Icons.visibility_outlined,
              title: 'Visibilitas Kartu Publik',
              subtitle: 'Izinkan kartu dipindai dan diakses via tautan publik',
              trailing: Switch(
                value: card?['is_public'] == true,
                onChanged: card == null
                    ? null
                    : (value) async {
                        try {
                          await store.saveCard({...card, 'is_public': value});
                        } catch (e) {
                          if (context.mounted) showError(context, e);
                        }
                      },
              ),
            ),
          ],
        ),
        const SectionLabel(
          'Pengaturan Aplikasi',
          trailing: Text(
            'Umum',
            style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),
        ),
        SettingsGroup(
          children: [
            SettingsTile(
              icon: Icons.notifications_active_outlined,
              title: 'Notifikasi Pengingat',
              subtitle: 'Pengingat jadwal follow-up relasi baru',
              trailing: Switch(
                value: store.account?['notifications_enabled'] != false,
                onChanged: (v) async {
                  try {
                    await store.notificationsEnabled(v);
                    await ReminderNotifier.sync(store);
                  } catch (e) {
                    if (context.mounted) showError(context, e);
                  }
                },
              ),
            ),
            SettingsTile(
              icon: Icons.lock_outline,
              accent: false,
              title: 'Ubah Kata Sandi',
              subtitle: 'Perbarui sandi untuk masuk ke aplikasi',
              onTap: () => _open(context, ChangePasswordScreen(store: store)),
            ),
            SettingsTile(
              icon: Icons.help_center_outlined,
              accent: false,
              title: 'Pusat Bantuan & FAQ',
              subtitle: 'Panduan dasar alur aplikasi PRM',
              onTap: () => _open(
                context,
                const InfoScreen(
                  title: 'Pusat Bantuan & FAQ',
                  text:
                      'Buat kartu pada tab Kartu Saya, lalu tampilkan QR untuk membagikannya. Pindai kartu orang lain pada tab Relasi. Jika lupa sandi setelah keluar, hubungi admin proyek.',
                ),
              ),
            ),
            SettingsTile(
              icon: Icons.info_outline,
              accent: false,
              title: 'Tentang Aplikasi',
              subtitle: appName,
              trailing: const StatusBadge(
                'V1.0.0 PBL',
                color: AppColors.secondary,
                border: AppColors.primarySoftBorder,
                radius: 8,
              ),
              onTap: () => _open(
                context,
                const InfoScreen(
                  title: 'Tentang Aplikasi',
                  text:
                      '$appName membantu berbagi kartu digital dan menyimpan relasi profesional. Versi tugas perkuliahan.',
                ),
              ),
            ),
          ],
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            backgroundColor: AppColors.errorContainer,
            side: const BorderSide(color: AppColors.errorBorder),
          ),
          onPressed: () async {
            try {
              await ReminderNotifier.clear();
            } catch (_) {
              /* Tetap keluar walau notifikasi gagal dibersihkan. */
            }
            try {
              await store.client.auth.signOut();
            } catch (e) {
              if (context.mounted) showError(context, e);
            }
          },
          icon: const Icon(Icons.logout, size: 20),
          label: const Text('Keluar dari Akun'),
        ),
        const SizedBox(height: 10),
        const Text(
          '$appName • Versi PBL',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key, required this.title, required this.text});
  final String title, text;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Padding(padding: const EdgeInsets.all(24), child: Text(text)),
      );
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, required this.store});
  final AppStore store;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Profil Akun')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              title: const Text('Email akun'),
              subtitle: Text(store.client.auth.currentUser?.email ?? ''),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Edit Kartu Digital'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                    builder: (_) => CardEditor(store: store)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Ubah Kata Sandi'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => ChangePasswordScreen(store: store),
                ),
              ),
            ),
          ],
        ),
      );
}

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key, required this.store});
  final AppStore store;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Pengingat Mendatang')),
        body: store.reminders.isEmpty
            ? const Center(child: Text('Belum ada pengingat mendatang.'))
            : ListView(
                children: [
                  for (final reminder in store.reminders)
                    ListTile(
                      title: Text(
                        store.relations
                                .where(
                                    (r) => r['id'] == reminder['relation_id'])
                                .firstOrNull?['full_name']
                                ?.toString() ??
                            'Relasi',
                      ),
                      subtitle:
                          Text(shortDate(reminder['remind_at']?.toString())),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        final relation = store.relations
                            .where((r) => r['id'] == reminder['relation_id'])
                            .firstOrNull;
                        if (relation != null)
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => RelationDetailScreen(
                                store: store,
                                relation: relation,
                              ),
                            ),
                          );
                      },
                    ),
                ],
              ),
      );
}
