import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core.dart';
import 'auth_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key, required this.store});
  final AppStore store;
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Map<String, dynamic>> users = [];
  String search = '';
  String? error;
  bool loading = false;
  bool loaded = false;

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await widget.store.client.functions.invoke(
        'account-admin',
        body: {'action': 'list'},
      );
      final data = row(response.data);
      if (!mounted) return;
      setState(() {
        users = rows(data?['users']);
        loaded = true;
      });
    } catch (e) {
      if (mounted) setState(() => error = errorText(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> action(Map<String, dynamic> user, String operation) async {
    final isReset = operation == 'reset';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isReset
              ? 'Atur ulang sandi?'
              : operation == 'disable'
                  ? 'Nonaktifkan akun?'
                  : 'Aktifkan akun?',
        ),
        content: Text(
          isReset
              ? 'Sandi sementara untuk ${user['email']} hanya akan ditampilkan sekali setelah dibuat.'
              : 'Ubah status akun ${user['email']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final response = await widget.store.client.functions.invoke(
        'account-admin',
        body: {'action': operation, 'userId': user['id']},
      );
      final data = row(response.data);
      if (isReset && mounted) {
        final password = data?['password']?.toString() ?? '';
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Sandi sementara'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Akun: ${user['email']}'),
                const SizedBox(height: 12),
                SelectableText(password),
                const SizedBox(height: 12),
                const Text(
                  'Salin sekarang. Sandi ini tidak akan ditampilkan lagi. Pengguna wajib mengubahnya setelah masuk.',
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: password)),
                icon: const Icon(Icons.copy),
                label: const Text('Salin'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Selesai'),
              ),
            ],
          ),
        );
      }
      await load();
    } catch (e) {
      if (mounted) setState(() => error = errorText(e));
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: widget.store,
        builder: (context, _) {
          if (!widget.store.signedIn)
            return AuthScreen(
              store: widget.store,
              admin: true,
              onDone: () {
                setState(() => loaded = false);
              },
            );
          if (widget.store.account?['role'] != 'admin' ||
              widget.store.account?['status'] != 'active') {
            return Scaffold(
              appBar: AppBar(title: const Text('Akses ditolak')),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Dashboard ini hanya untuk admin aktif.'),
                    TextButton(
                      onPressed: () => widget.store.client.auth.signOut(),
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!loaded && !loading)
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !loaded && !loading) load();
            });
          final filtered = users
              .where(
                (u) => u['email'].toString().toLowerCase().contains(
                      search.toLowerCase(),
                    ),
              )
              .toList();
          final active = users.where((u) => u['status'] == 'active').length;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Smart Business Card • Admin'),
              actions: [
                IconButton(
                  tooltip: 'Ubah sandi',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => ChangePasswordScreen(store: widget.store),
                    ),
                  ),
                  icon: const Icon(Icons.lock_outline),
                ),
                IconButton(
                  tooltip: 'Keluar',
                  onPressed: () => widget.store.client.auth.signOut(),
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      'Manajemen Akun',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Text(
                        'Kelola status dan sandi sementara akun pengguna.'),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _Stat(label: 'Total Pengguna', value: users.length),
                        _Stat(label: 'Aktif', value: active),
                        _Stat(label: 'Nonaktif', value: users.length - active),
                      ],
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      onChanged: (v) => setState(() => search = v),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Cari email pengguna',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    if (loading) const LinearProgressIndicator(),
                    const SizedBox(height: 14),
                    if (!loading && filtered.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('Tidak ada akun yang cocok.'),
                        ),
                      ),
                    for (final user in filtered)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              SizedBox(
                                width: 260,
                                child: Text(user['email']?.toString() ?? ''),
                              ),
                              SizedBox(
                                width: 120,
                                child: Text(
                                  user['created_at']
                                          ?.toString()
                                          .split('T')
                                          .first ??
                                      '',
                                ),
                              ),
                              Chip(
                                label: Text(
                                  user['status'] == 'active'
                                      ? 'Aktif'
                                      : 'Nonaktif',
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () => action(
                                  user,
                                  user['status'] == 'active'
                                      ? 'disable'
                                      : 'enable',
                                ),
                                child: Text(
                                  user['status'] == 'active'
                                      ? 'Nonaktifkan'
                                      : 'Aktifkan',
                                ),
                              ),
                              FilledButton.tonal(
                                onPressed: () => action(user, 'reset'),
                                child: const Text('Atur Ulang Sandi'),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 210,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                const SizedBox(height: 8),
                Text('$value',
                    style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
          ),
        ),
      );
}
