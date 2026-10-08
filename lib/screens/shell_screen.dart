import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core.dart';
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
            bottomNavigationBar: NavigationBar(
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
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: 'Relasi',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
            ),
          );
        },
      );
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.store, required this.onTab});
  final AppStore store;
  final ValueChanged<int> onTab;
  @override
  Widget build(BuildContext context) {
    final recent = store.relations.take(3).toList();
    final since = DateTime.now().subtract(const Duration(days: 30));
    final newCount = store.relations
        .where(
          (r) => (DateTime.tryParse(r['created_at']?.toString() ?? '') ??
                  DateTime(2000))
              .isAfter(since),
        )
        .length;
    return RefreshIndicator(
      onRefresh: () => refreshWithFeedback(context, store),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Beranda',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton(
                tooltip: 'Pengingat',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => RemindersScreen(store: store),
                  ),
                ),
                icon: const Icon(Icons.notifications_outlined),
              ),
            ],
          ),
          Text(
            'Halo${store.card == null ? '' : ', ${store.card!['full_name']}'} 👋',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Text('Kelola kartu nama & relasi profesional Anda'),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.card == null
                        ? 'Belum ada kartu digital'
                        : 'KARTU DIGITAL AKTIF',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    store.card?['full_name']?.toString() ??
                        'Buat kartu pertama Anda',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    [store.card?['job_title'], store.card?['company']]
                        .where((e) => e != null && e.toString().isNotEmpty)
                        .join(' • '),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => CardEditor(store: store),
                            ),
                          ),
                          child: Text(
                            store.card == null ? 'Buat Kartu' : 'Edit Kartu',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: store.card == null
                              ? null
                              : () => Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) => ShareScreen(store: store),
                                    ),
                                  ),
                          child: const Text('Bagikan Kartu'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            tileColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: const Icon(Icons.qr_code),
            title: const Text('Tampilkan QR Code'),
            subtitle: const Text('Pindai langsung untuk bertukar kontak'),
            trailing: const Icon(Icons.chevron_right),
            onTap: store.card == null
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ShareScreen(store: store),
                      ),
                    ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final stat in [
                ('${store.relations.length}', 'Total Relasi'),
                ('${store.shareCount}', 'Kartu Dibagikan'),
                ('$newCount', 'Relasi Baru'),
              ])
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 4,
                      ),
                      child: Column(
                        children: [
                          Text(
                            stat.$1,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            stat.$2,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Relasi Terbaru',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: () => onTab(2),
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          if (recent.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Belum ada relasi. Tambahkan kontak atau pindai QR kartu.',
                ),
              ),
            ),
          for (final relation in recent)
            Card(
              child: ListTile(
                title: Text(relation['full_name']?.toString() ?? ''),
                subtitle: Text(
                  [relation['job_title'], relation['company']]
                      .where((e) => e != null && e.toString().isNotEmpty)
                      .join(' • '),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        RelationDetailScreen(store: store, relation: relation),
                  ),
                ),
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
  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Profil', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    store.card?['full_name']?.toString() ?? 'Belum ada kartu',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(store.client.auth.currentUser?.email ?? ''),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => AccountScreen(store: store),
                      ),
                    ),
                    child: const Text('Edit Profil Akun'),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 18, bottom: 6),
            child: Text('PENGATURAN KARTU & VISIBILITAS'),
          ),
          SwitchListTile(
            title: const Text('Visibilitas Kartu Publik'),
            subtitle: const Text(
              'Izinkan kartu dipindai dan diakses via tautan publik',
            ),
            value: store.card?['is_public'] == true,
            onChanged: store.card == null
                ? null
                : (value) async {
                    try {
                      await store
                          .saveCard({...store.card!, 'is_public': value});
                    } catch (e) {
                      if (context.mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(errorText(e))));
                    }
                  },
          ),
          const Padding(
            padding: EdgeInsets.only(top: 18, bottom: 6),
            child: Text('PENGATURAN APLIKASI'),
          ),
          SwitchListTile(
            title: const Text('Notifikasi Pengingat'),
            subtitle: const Text('Pengingat jadwal follow-up relasi baru'),
            value: store.account?['notifications_enabled'] != false,
            onChanged: (v) async {
              try {
                await store.notificationsEnabled(v);
                await ReminderNotifier.sync(store);
              } catch (e) {
                if (context.mounted)
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(errorText(e))));
              }
            },
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
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Pusat Bantuan & FAQ'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const InfoScreen(
                  title: 'Pusat Bantuan & FAQ',
                  text:
                      'Buat kartu pada tab Kartu Saya, lalu tampilkan QR untuk membagikannya. Pindai kartu orang lain pada tab Relasi. Jika lupa sandi setelah keluar, hubungi admin proyek.',
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Tentang Aplikasi'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const InfoScreen(
                  title: 'Tentang Aplikasi',
                  text:
                      'Smart Business Card membantu berbagi kartu digital dan menyimpan relasi profesional. Versi tugas perkuliahan.',
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
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
            icon: const Icon(Icons.logout),
            label: const Text('Keluar dari Akun'),
          ),
        ],
      );
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
