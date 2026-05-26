// [파일 역할]
// flutter_local_notifications 패키지를 직접 사용하는 알림 데이터 소스
// 알림 예약, 취소 등 플랫폼 알림 API를 래핑

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../core/utils/notif_id_helper.dart';
import '../../domain/entities/meal_type.dart';

/// 로컬 알림 직접 접근 클래스
class NotificationDataSource {
  final FlutterLocalNotificationsPlugin _plugin;

  NotificationDataSource(this._plugin);

  // ── 플랫폼별 알림 세부 설정 ──

  /// Android 알림 세부 설정
  static const _androidDetails = AndroidNotificationDetails(
    'diet_reminders',    // 채널 ID (app_constants.dart와 동일해야 함)
    '식단 알림',
    channelDescription: '식단 체크 리마인드 알림',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  /// iOS 알림 세부 설정
  static const _iosDetails = DarwinNotificationDetails(
    presentAlert: true,  // 포그라운드에서도 알림 배너 표시
    presentBadge: true,
    presentSound: true,
  );

  static const _notifDetails = NotificationDetails(
    android: _androidDetails,
    iOS: _iosDetails,
  );

  // ── 공개 메서드 ──

  /// 알림 권한 요청 (iOS, Android 13+)
  Future<bool> requestPermission() async {
    // iOS
    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Android 13+
    final androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    return (iosGranted ?? true) && (androidGranted ?? true);
  }

  /// 특정 시각에 알림 예약
  /// [id]: buildNotifId()로 생성한 고유 ID
  /// [title], [body]: 알림 내용
  /// [scheduledAt]: 발송 시각
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      // TZDateTime 없이 UTC로 처리 (timezone 패키지 의존 없이 단순화)
      _toTZDateTime(scheduledAt),
      _notifDetails,
      // Android: 정확한 시각에 알림 (배터리 절약 모드 무시)
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // 앱이 꺼져 있을 때도 알림 발송
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 특정 ID의 알림 취소
  Future<void> cancel(int id) => _plugin.cancel(id);

  /// 여러 ID의 알림 일괄 취소
  Future<void> cancelAll(List<int> ids) async {
    for (final id in ids) {
      await _plugin.cancel(id);
    }
  }

  /// 모든 예약된 알림 취소
  Future<void> cancelAllPending() => _plugin.cancelAll();

  /// DateTime → TZDateTime 변환 (기기의 로컬 타임존 기준)
  tz.TZDateTime _toTZDateTime(DateTime dt) {
    return tz.TZDateTime.from(dt, tz.local);
  }
}
