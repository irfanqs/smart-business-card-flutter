import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://vwdbfmhklsvsyigesfvy.supabase.co',
);
const supabaseKey = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
  defaultValue: 'sb_publishable_0SQsGsSkWUce3JOrfCMiPg_lnOSv3zu',
);
const publicBaseUrl = String.fromEnvironment('PUBLIC_BASE_URL');

const categories = ['Partner', 'Klien', 'Prospek', 'Teman Profesional'];

String errorText(Object error) {
  if (error is AuthException) return error.message;
  if (error is PostgrestException) return error.message;
  if (error is StorageException) return error.message;
  if (error is FunctionException && error.status != 0) {
    final details = row(error.details);
    final message = details?['message'] ?? details?['error'];
    if (message != null) return message.toString();
  }
  if (error is StateError) return error.message;
  return 'Terjadi kesalahan. Periksa koneksi internet dan coba lagi.';
}

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())
      ? null
      : 'Format email tidak valid';
}

String? validatePhone(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return RegExp(r'^\+?[0-9\s()\-]{7,20}$').hasMatch(value.trim())
      ? null
      : 'Format nomor telepon tidak valid';
}

String? validateLinkedIn(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final uri = Uri.tryParse(value.trim());
  final host = uri?.host.toLowerCase();
  return uri != null &&
          (uri.scheme == 'https' || uri.scheme == 'http') &&
          (host == 'linkedin.com' || host?.endsWith('.linkedin.com') == true)
      ? null
      : 'Gunakan URL LinkedIn lengkap';
}

Map<String, dynamic>? row(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;
List<Map<String, dynamic>> rows(dynamic value) => value is List
    ? value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : [];

class AppStore extends ChangeNotifier {
  AppStore(this.client);
  final SupabaseClient client;
  Map<String, dynamic>? account;
  Map<String, dynamic>? card;
  List<Map<String, dynamic>> relations = [];
  List<Map<String, dynamic>> reminders = [];
  int shareCount = 0;
  bool loading = false;
  int _generation = 0;

  String get userId => client.auth.currentUser!.id;
  bool get signedIn => client.auth.currentUser != null;
  bool get usable =>
      account?['status'] == 'active' &&
      account?['must_change_password'] != true;

  /// Hanya hasil refresh terbaru yang disimpan. Refresh yang sudah
  /// digantikan (mis. karena logout di tengah jalan) dibuang diam-diam.
  Future<void> refresh() async {
    final generation = ++_generation;
    final uid = client.auth.currentUser?.id;
    if (uid == null) {
      account = null;
      card = null;
      relations = [];
      reminders = [];
      shareCount = 0;
      loading = false;
      notifyListeners();
      return;
    }
    loading = true;
    notifyListeners();
    try {
      final nextAccount = row(
        await client.from('accounts').select().eq('id', uid).single(),
      );
      Map<String, dynamic>? nextCard;
      var nextRelations = <Map<String, dynamic>>[];
      var nextReminders = <Map<String, dynamic>>[];
      var nextShareCount = 0;
      if (nextAccount?['role'] == 'user' &&
          nextAccount?['status'] == 'active' &&
          nextAccount?['must_change_password'] != true) {
        nextCard = row(
          await client.from('cards').select().eq('owner_id', uid).maybeSingle(),
        );
        nextRelations = rows(
          await client
              .from('relations')
              .select()
              .order('created_at', ascending: false),
        );
        nextReminders = rows(
          await client
              .from('reminders')
              .select()
              .gte('remind_at', DateTime.now().toUtc().toIso8601String())
              .order('remind_at'),
        );
        nextShareCount =
            (await client.from('share_events').select('id')).length;
      }
      if (generation != _generation) return;
      account = nextAccount;
      card = nextCard;
      relations = nextRelations;
      reminders = nextReminders;
      shareCount = nextShareCount;
    } catch (_) {
      if (generation != _generation) return;
      rethrow;
    } finally {
      if (generation == _generation) {
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> saveCard(Map<String, dynamic> data) async {
    await client.from('cards').upsert({
      ...data,
      'owner_id': userId,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
    await refresh();
  }

  Future<String> uploadPhoto(Uint8List bytes, String extension) async {
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}.$extension';
    await client.storage.from('card-photos').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: extension == 'png' ? 'image/png' : 'image/jpeg',
          ),
        );
    return path;
  }

  Future<String?> photoUrl(String? path) async {
    if (path == null || path.isEmpty) return null;
    return client.storage.from('card-photos').createSignedUrl(path, 3600);
  }

  Future<String> createShareLink() async {
    if (card == null || card?['is_public'] != true)
      throw StateError('Aktifkan visibilitas kartu terlebih dahulu.');
    if (publicBaseUrl.isEmpty)
      throw StateError('PUBLIC_BASE_URL belum diatur.');
    final random = Random.secure();
    final token = List.generate(
      32,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    await client.from('share_links').insert({
      'token': token,
      'owner_id': userId,
    });
    return '${publicBaseUrl.replaceAll(RegExp(r'/$'), '')}/p/$token';
  }

  Future<Map<String, dynamic>> publicCard(String token) async {
    final response = await client.functions.invoke(
      'public-card',
      body: {'token': token},
    );
    final data = row(response.data);
    if (data?['card'] == null) {
      throw StateError(
        data?['message']?.toString() ?? 'Profil tidak tersedia.',
      );
    }
    return row(data!['card'])!;
  }

  Future<void> recordShare(String kind) async {
    await client.from('share_events').insert({
      'owner_id': userId,
      'kind': kind,
    });
    shareCount++;
    notifyListeners();
  }

  Future<Map<String, dynamic>> saveRelation(
    Map<String, dynamic> data, {
    String? id,
  }) async {
    final body = {
      ...data,
      'owner_id': userId,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    final result = id == null
        ? await client.from('relations').insert(body).select().single()
        : await client
            .from('relations')
            .update(body)
            .eq('id', id)
            .select()
            .single();
    await refresh();
    return row(result)!;
  }

  Future<void> deleteRelation(String id) async {
    await client.from('relations').delete().eq('id', id);
    await refresh();
  }

  Future<List<Map<String, dynamic>>> interactions(String relationId) async =>
      rows(
        await client
            .from('interactions')
            .select()
            .eq('relation_id', relationId)
            .order('happened_at', ascending: false),
      );

  Future<void> saveInteraction(
    String relationId,
    DateTime date,
    String note,
    String location, {
    String? id,
  }) async {
    final body = {
      'owner_id': userId,
      'relation_id': relationId,
      'happened_at': date.toUtc().toIso8601String(),
      'note': note.trim(),
      'location': location.trim(),
    };
    if (id == null) {
      await client.from('interactions').insert(body);
    } else {
      await client.from('interactions').update(body).eq('id', id);
    }
  }

  Future<void> deleteInteraction(String id) async {
    await client.from('interactions').delete().eq('id', id);
  }

  Future<void> saveReminder(String relationId, DateTime at) async {
    await client.from('reminders').upsert({
      'relation_id': relationId,
      'owner_id': userId,
      'remind_at': at.toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
    await refresh();
  }

  Future<void> deleteReminder(String relationId) async {
    await client.from('reminders').delete().eq('relation_id', relationId);
    await refresh();
  }

  Future<void> notificationsEnabled(bool value) async {
    await client
        .from('accounts')
        .update({'notifications_enabled': value}).eq('id', userId);
    account?['notifications_enabled'] = value;
    notifyListeners();
  }

  Future<void> changePassword(String password) async {
    await client.functions.invoke(
      'change-password',
      body: {'password': password},
    );
    await refresh();
  }
}
