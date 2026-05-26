// [파일 역할]
// 하루(Day N) 전체의 체크 기록을 나타내는 도메인 엔티티
// 4개 식단(아침/점심/간식/저녁)의 MealRecord 묶음

import 'meal_type.dart';
import 'meal_record.dart';

/// 하루 전체 식단 체크 기록
class DayRecord {
  final int dayNumber;                     // 1 ~ 28
  final DateTime date;                     // 해당 날짜
  final Map<MealType, MealRecord> meals;   // 4개 식단 체크 상태
  final bool rewardShown;                  // 완료 폭죽 이미 표시했는지 여부

  const DayRecord({
    required this.dayNumber,
    required this.date,
    required this.meals,
    this.rewardShown = false,
  });

  /// 4개 식단 모두 체크되었는지
  bool get isAllChecked => meals.values.every((m) => m.isChecked);

  /// 체크된 식단 개수
  int get checkedCount => meals.values.where((m) => m.isChecked).length;

  /// 특정 식단 체크 상태 반환 (null-safe)
  MealRecord meal(MealType type) =>
      meals[type] ?? MealRecord.initial(type);

  /// 특정 식단을 체크한 새 DayRecord 반환 (불변 패턴)
  DayRecord withMealChecked(MealType type) {
    final updated = Map<MealType, MealRecord>.from(meals);
    updated[type] = updated[type]!.check();
    return DayRecord(
      dayNumber: dayNumber,
      date: date,
      meals: updated,
      rewardShown: rewardShown,
    );
  }

  /// 특정 식단 체크 취소한 새 DayRecord 반환
  DayRecord withMealUnchecked(MealType type) {
    final updated = Map<MealType, MealRecord>.from(meals);
    updated[type] = updated[type]!.uncheck();
    return DayRecord(
      dayNumber: dayNumber,
      date: date,
      meals: updated,
      rewardShown: rewardShown,
    );
  }

  /// 폭죽 표시 완료 처리
  DayRecord withRewardShown() => DayRecord(
        dayNumber: dayNumber,
        date: date,
        meals: meals,
        rewardShown: true,
      );

  // ── JSON 직렬화 (Hive 저장용) ──

  /// DayRecord → JSON Map
  Map<String, dynamic> toJson() => {
        'dayNumber': dayNumber,
        'date': date.toIso8601String(),
        'meals': meals.map(
          (type, record) => MapEntry(type.index.toString(), record.toJson()),
        ),
        'rewardShown': rewardShown,
      };

  /// JSON Map → DayRecord
  factory DayRecord.fromJson(Map<String, dynamic> json) {
    final mealsJson = json['meals'] as Map<String, dynamic>;
    final meals = <MealType, MealRecord>{};
    for (final type in MealType.values) {
      final key = type.index.toString();
      if (mealsJson.containsKey(key)) {
        meals[type] = MealRecord.fromJson(
            mealsJson[key] as Map<String, dynamic>);
      } else {
        meals[type] = MealRecord.initial(type);
      }
    }
    return DayRecord(
      dayNumber: json['dayNumber'] as int,
      date: DateTime.parse(json['date'] as String),
      meals: meals,
      rewardShown: json['rewardShown'] as bool? ?? false,
    );
  }

  /// 새로운 날의 초기 DayRecord 생성 (모두 미체크 상태)
  factory DayRecord.initial(int dayNumber, DateTime date) => DayRecord(
        dayNumber: dayNumber,
        date: date,
        meals: {
          for (final type in MealType.values) type: MealRecord.initial(type),
        },
      );
}
