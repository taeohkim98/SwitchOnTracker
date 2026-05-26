// [파일 역할]
// NotificationRepository 인터페이스의 실제 구현체
// NotificationDataSource를 통해 알림을 예약/취소
// 식단별 알림 텍스트 결정 로직도 여기에 있음

import '../../core/constants/app_constants.dart';
import '../../core/utils/notif_id_helper.dart';
import '../../domain/entities/meal_type.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_datasource.dart';

/// NotificationRepository 구현체
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDataSource _dataSource;

  NotificationRepositoryImpl(this._dataSource);

  @override
  Future<bool> requestPermission() => _dataSource.requestPermission();

  @override
  Future<void> scheduleMealNotifications({
    required int day,
    required MealType meal,
    required DateTime checkedAt,
  }) async {
    // 기존 알림 먼저 취소 (재체크 시 중복 방지)
    await cancelMealNotifications(day, meal);

    final primaryTime  = checkedAt.add(NotifTiming.primary);
    final reminderTime = checkedAt.add(NotifTiming.reminder);

    // 과거 시각이면 예약하지 않음 (앱 테스트 시 엣지 케이스 방지)
    final now = DateTime.now();

    // 1차 알림 예약
    if (primaryTime.isAfter(now)) {
      await _dataSource.scheduleNotification(
        id: buildNotifId(day, meal, NotifKind.primary),
        title: _primaryTitle(meal),
        body:  _primaryBody(meal),
        scheduledAt: primaryTime,
      );
    }

    // 리마인드 알림 예약
    if (reminderTime.isAfter(now)) {
      await _dataSource.scheduleNotification(
        id: buildNotifId(day, meal, NotifKind.reminder),
        title: _reminderTitle(meal),
        body:  _reminderBody(meal),
        scheduledAt: reminderTime,
      );
    }
  }

  @override
  Future<void> cancelMealNotifications(int day, MealType meal) async {
    await _dataSource.cancelAll(allNotifIdsFor(day, meal));
  }

  @override
  Future<void> cancelAllForDay(int day) async {
    await _dataSource.cancelAll(allNotifIdsForDay(day));
  }

  @override
  Future<void> cancelAll() => _dataSource.cancelAllPending();

  // ── 알림 텍스트 (식단별로 다른 메시지) ──

  /// 1차 알림 제목 (다음 식단 알림)
  String _primaryTitle(MealType meal) {
    switch (meal) {
      case MealType.breakfast: return '점심 시간이에요 🌿';
      case MealType.lunch:     return '간식 시간이에요 🥤';
      case MealType.snack:     return '저녁 준비할 시간이에요 🌙';
      case MealType.dinner:    return '오늘 하루도 수고하셨어요 ✨';
    }
  }

  String _primaryBody(MealType meal) {
    switch (meal) {
      case MealType.breakfast: return 'Switch-On 점심 식단을 챙기세요!';
      case MealType.lunch:     return '단백질 쉐이크 간식 시간입니다.';
      case MealType.snack:     return '저녁 식단 체크해 주세요.';
      case MealType.dinner:    return '오늘 모든 식단을 완료했어요!';
    }
  }

  /// 리마인드 알림 제목
  String _reminderTitle(MealType meal) {
    switch (meal) {
      case MealType.breakfast: return '점심을 아직 안 드셨나요? 😊';
      case MealType.lunch:     return '간식 잊지 마세요! 💪';
      case MealType.snack:     return '저녁도 챙겨드세요! 🍽';
      case MealType.dinner:    return '마지막 저녁이에요! 🌙';
    }
  }

  String _reminderBody(MealType meal) {
    switch (meal) {
      case MealType.breakfast: return '점심 식단을 체크하면 다음 알림을 받을 수 있어요.';
      case MealType.lunch:     return '간식 체크를 잊지 마세요.';
      case MealType.snack:     return '저녁을 드시고 체크해 주세요!';
      case MealType.dinner:    return '오늘의 마지막 식단! 완주해 봐요.';
    }
  }
}
