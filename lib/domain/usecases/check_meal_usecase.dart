// [파일 역할]
// 식단 체크/언체크 핵심 비즈니스 로직
// 1. DB에 체크 기록 저장
// 2. 이전 식단의 리마인드 알림 취소
// 3. 이번 식단의 알림 2개 예약
// 4. 하루 완료 시 모든 알림 취소

import '../entities/day_record.dart';
import '../entities/meal_type.dart';
import '../entities/program_config.dart';
import '../repositories/program_repository.dart';
import '../repositories/notification_repository.dart';

/// 식단 체크 유스케이스
class CheckMealUseCase {
  final ProgramRepository _programRepo;
  final NotificationRepository _notifRepo;

  CheckMealUseCase(this._programRepo, this._notifRepo);

  /// [day]: 1~28, [meal]: 체크할 식단 타입
  /// 반환값: 업데이트된 DayRecord (UI 즉시 갱신용)
  Future<DayRecord> execute(int day, MealType meal) async {
    // 1. 현재 기록 불러오기
    final current = await _programRepo.loadDayRecord(day);

    // 2. 이미 체크된 경우 → 체크 취소 처리
    if (current.meal(meal).isChecked) {
      return await _uncheckMeal(day, meal, current);
    }

    // 3. 체크 처리
    return await _checkMeal(day, meal, current);
  }

  /// 식단 체크 처리
  Future<DayRecord> _checkMeal(
      int day, MealType meal, DayRecord current) async {
    // DB 업데이트
    final updated = current.withMealChecked(meal);
    await _programRepo.saveDayRecord(updated);

    // 이전 식단의 리마인드 알림 취소 (이미 다음 식단으로 넘어갔으므로 불필요)
    final prevMeal = meal.previous;
    if (prevMeal != null) {
      await _notifRepo.cancelMealNotifications(day, prevMeal);
    }

    // 알림 예약 (설정이 ON인 경우만)
    final config = await _programRepo.loadConfig();
    if (config?.notificationsEnabled == true) {
      await _notifRepo.scheduleMealNotifications(
        day: day,
        meal: meal,
        checkedAt: DateTime.now(),
      );
    }

    // 하루 전체 완료 여부 확인
    if (updated.isAllChecked) {
      // 당일 모든 pending 알림 취소 (더 이상 리마인드 불필요)
      await _notifRepo.cancelAllForDay(day);
    }

    return updated;
  }

  /// 식단 체크 취소 처리
  Future<DayRecord> _uncheckMeal(
      int day, MealType meal, DayRecord current) async {
    final updated = current.withMealUnchecked(meal);
    await _programRepo.saveDayRecord(updated);

    // 해당 식단의 예약된 알림도 취소 (체크 취소했으니 알림 불필요)
    await _notifRepo.cancelMealNotifications(day, meal);

    return updated;
  }
}
