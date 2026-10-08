import 'package:flutter/material.dart';

import '../core.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.store,
    required this.onDone,
    this.admin = false,
  });
  final AppStore store;
  final VoidCallback onDone;
  final bool admin;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool register = false, busy = false;
  String? error;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (email.text.trim().isEmpty ||
        validateEmail(email.text) != null ||
        password.text.length < 8) {
      setState(
        () => error = 'Masukkan email yang valid dan sandi minimal 8 karakter.',
      );
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (register) {
        await widget.store.client.auth.signUp(
          email: email.text.trim(),
          password: password.text,
        );
      } else {
        await widget.store.client.auth.signInWithPassword(
          email: email.text.trim(),
          password: password.text,
        );
      }
      await widget.store.refresh();
      widget.onDone();
    } catch (e) {
      if (mounted) setState(() => error = errorText(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            widget.admin
                ? 'Masuk Admin'
                : register
                    ? 'Daftar Akun'
                    : 'Masuk',
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.contact_page_rounded,
                    size: 54,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Smart Business Card',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Kata sandi',
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
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: busy ? null : submit,
                    child: Text(
                      busy
                          ? 'Memproses...'
                          : register
                              ? 'Daftar'
                              : 'Masuk',
                    ),
                  ),
                  if (!widget.admin)
                    TextButton(
                      onPressed: busy
                          ? null
                          : () => setState(() {
                                register = !register;
                                error = null;
                              }),
                      child: Text(
                        register
                            ? 'Sudah punya akun? Masuk'
                            : 'Belum punya akun? Daftar',
                      ),
                    ),
                  if (register)
                    const Text(
                      'Jika lupa sandi setelah keluar, hubungi admin proyek untuk mendapat sandi sementara.',
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({
    super.key,
    required this.store,
    this.requiredChange = false,
    this.onDone,
  });
  final AppStore store;
  final bool requiredChange;
  final VoidCallback? onDone;
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final password = TextEditingController();
  final confirm = TextEditingController();
  bool busy = false;
  String? error;
  @override
  void dispose() {
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (password.text.length < 8 || password.text != confirm.text) {
      setState(
        () => error = 'Sandi minimal 8 karakter dan kedua isian harus sama.',
      );
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.store.changePassword(password.text);
      widget.onDone?.call();
      if (mounted && !widget.requiredChange) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => error = errorText(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Ubah Kata Sandi')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                if (widget.requiredChange)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Sandi sementara harus diganti sebelum menggunakan aplikasi.',
                    ),
                  ),
                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Sandi baru',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirm,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Ulangi sandi baru',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      error!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: busy ? null : save,
                  child: const Text('Simpan Sandi'),
                ),
                if (widget.requiredChange)
                  TextButton(
                    onPressed: () => widget.store.client.auth.signOut(),
                    child: const Text('Keluar'),
                  ),
              ],
            ),
          ),
        ),
      );
}
