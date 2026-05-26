// [파일 역할]
// 로컬 알림 예약/취소에 대한 추상 인터페이스
// 실제 구현은 data/repositories/notification_repository_impl.dart 에 있음

import '../entities/meal_type.dart';

/// 로컬 알림 저장소 인터페이스
abstract class NotificationRepository {
  /// 알림 권한 요청 (앱 최초 실행 시 호출)
  Future<bool> requestPermission();

  /// 특정 식단의 1차 + 리마인드 알림 예약
  /// [checkedAt]: 사용자가 체크한 시각 (기준 시각)
  Future<void> scheduleMealNotifications({
    required int day,
    required MealType meal,
    required DateTime checkedAt,
  });

  /// 특정 식단의 모든 알림 취소 (1차 + 리마인드)
  Future<void> cancelMealNotifications(int day, MealType meal);

  /// 특정 Day의 모든 알림 취소 (하루 완료 시 사용)
  Future<void> cancelAllForDay(int day);

  /// 모든 알림 취소 (알림 OFF 시 사용)
  Future<void> cancelAll();
}
