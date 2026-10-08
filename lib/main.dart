import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core.dart';
import 'reminder_notifier.dart';
import 'screens/admin_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/public_screen.dart';
import 'screens/shell_screen.dart';
import 'theme.dart';
import 'web_url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureWebUrlStrategy();
  if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);
  }
  runApp(const SmartBusinessCardApp());
}

class SmartBusinessCardApp extends StatefulWidget {
  const SmartBusinessCardApp({super.key});
  @override
  State<SmartBusinessCardApp> createState() => _SmartBusinessCardAppState();
}

class _SmartBusinessCardAppState extends State<SmartBusinessCardApp> {
  final navKey = GlobalKey<NavigatorState>();
  AppStore? store;
  StreamSubscription<AuthState>? authSubscription;
  StreamSubscription<Uri>? linkSubscription;
  bool ready = false;
  String? startupError;

  @override
  void initState() {
    super.initState();
    if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
      store = AppStore(Supabase.instance.client);
      authSubscription = store!.client.auth.onAuthStateChange.listen(
        (_) => refresh(),
      );
      refresh();
      if (!kIsWeb) {
        final links = AppLinks();
        linkSubscription = links.uriLinkStream.listen(_openLink);
      }
    }
  }

  Future<void> refresh() async {
    try {
      await store!.refresh();
      startupError = null;
      if (!kIsWeb) {
        try {
          // Pengingat milik akun lain/nonaktif tidak boleh tetap terjadwal.
          if (store!.usable) {
            await ReminderNotifier.sync(store!);
          } else {
            await ReminderNotifier.clear();
          }
        } catch (_) {
          /* Izin notifikasi dapat diatur nanti. */
        }
      }
    } catch (e) {
      startupError = errorText(e);
    }
    if (mounted) setState(() => ready = true);
  }

  void _openLink(Uri uri) {
    if (uri.scheme != 'smartcard' ||
        uri.host != 'save' ||
        uri.pathSegments.isEmpty) return;
    final token = uri.pathSegments.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navKey.currentState?.push(
        MaterialPageRoute<void>(
          builder: (_) => PublicScreen(store: store!, token: token),
        ),
      );
    });
  }

  @override
  void dispose() {
    authSubscription?.cancel();
    linkSubscription?.cancel();
    store?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Business Card',
      navigatorKey: navKey,
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      home: _home(),
    );
  }

  Widget _home() {
    if (store == null) return const ConfigScreen();
    if (!ready)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final parts = Uri.base.pathSegments.where((e) => e.isNotEmpty).toList();
    if (kIsWeb && parts.length == 2 && parts[0] == 'p') {
      return PublicScreen(store: store!, token: parts[1]);
    }
    if (startupError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Koneksi Bermasalah')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(startupError!, textAlign: TextAlign.center),
              TextButton(onPressed: refresh, child: const Text('Coba Lagi')),
              if (store!.signedIn)
                TextButton(
                  onPressed: () => store!.client.auth.signOut(),
                  child: const Text('Keluar'),
                ),
            ],
          ),
        ),
      );
    }
    if (kIsWeb) return AdminScreen(store: store!);
    if (!store!.signedIn) return AuthScreen(store: store!, onDone: refresh);
    if (store!.account?['status'] == 'disabled') {
      return Scaffold(
        appBar: AppBar(title: const Text('Akun nonaktif')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Akun ini dinonaktifkan. Hubungi admin proyek.'),
              TextButton(
                onPressed: () => store!.client.auth.signOut(),
                child: const Text('Keluar'),
              ),
            ],
          ),
        ),
      );
    }
    if (store!.account?['role'] == 'admin') {
      return Scaffold(
        appBar: AppBar(title: const Text('Akun Admin')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Dashboard admin tersedia melalui browser.'),
              TextButton(
                onPressed: () => store!.client.auth.signOut(),
                child: const Text('Keluar'),
              ),
            ],
          ),
        ),
      );
    }
    if (store!.account?['must_change_password'] == true) {
      return ChangePasswordScreen(
        store: store!,
        requiredChange: true,
        onDone: refresh,
      );
    }
    return ShellScreen(store: store!);
  }
}

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Konfigurasi diperlukan')),
        body: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Isi SUPABASE_URL dan SUPABASE_PUBLISHABLE_KEY saat menjalankan aplikasi. Lihat README.md untuk langkah penyiapan.',
            ),
          ),
        ),
      );
}
