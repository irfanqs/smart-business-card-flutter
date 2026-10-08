import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'core.dart';

class ReminderNotifier {
  static final plugin = FlutterLocalNotificationsPlugin();
  static bool initialized = false;

  static int idFor(String relationId) =>
      relationId.codeUnits.fold<int>(0, (a, b) => (a * 31 + b) & 0x7fffffff);

  static Future<void> init() async {
    if (initialized) return;
    tzdata.initializeTimeZones();
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    initialized = true;
  }

  static Future<void> sync(AppStore store) async {
    await init();
    await plugin.cancelAll();
    if (store.account?['notifications_enabled'] == false ||
        store.reminders.isEmpty) return;
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    for (final reminder in store.reminders) {
      final at = DateTime.tryParse(reminder['remind_at']?.toString() ?? '');
      if (at == null || !at.isAfter(DateTime.now())) continue;
      final relation = store.relations
          .where((r) => r['id'] == reminder['relation_id'])
          .firstOrNull;
      await plugin.zonedSchedule(
        idFor(reminder['relation_id'].toString()),
        'Pengingat follow-up',
        relation == null
            ? 'Hubungi relasi Anda'
            : 'Hubungi ${relation['full_name']}',
        tz.TZDateTime.from(at, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'follow_up',
            'Pengingat Relasi',
            channelDescription: 'Pengingat tindak lanjut relasi profesional',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  static Future<void> cancel(String relationId) async {
    await init();
    await plugin.cancel(idFor(relationId));
  }
}
