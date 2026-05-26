// [파일 역할]
// 로컬 알림의 고유 ID를 계산하는 유틸리티
// day(1~28) + mealType(0~3) + kind(0~1) 조합으로 절대 겹치지 않는 정수 ID 생성

import '../../../domain/entities/meal_type.dart';

/// 알림 종류 (1차 vs 리마인드)
enum NotifKind {
  primary,   // 1차 알림 (T+5h45m)
  reminder,  // 리마인드 알림 (T+6h30m)
}

/// 알림 ID 생성 공식:
/// day × 100 + mealIndex × 10 + kindIndex
/// 최대값: 28×100 + 3×10 + 1 = 2831 (int 범위 완전 안전)
///
/// 예시:
///   Day 3, breakfast, primary  → 301
///   Day 3, breakfast, reminder → 302  (kindIndex: primary=1, reminder=2)
///   Day 3, lunch,    primary   → 311
int buildNotifId(int day, MealType meal, NotifKind kind) {
  // primary=1, reminder=2 로 인코딩 (0은 쓰지 않아 ID=0 충돌 방지)
  final kindCode = kind == NotifKind.primary ? 1 : 2;
  return day * 100 + meal.index * 10 + kindCode;
}

/// 특정 식단의 primary + reminder 알림 ID를 모두 반환
List<int> allNotifIdsFor(int day, MealType meal) => [
      buildNotifId(day, meal, NotifKind.primary),
      buildNotifId(day, meal, NotifKind.reminder),
    ];

/// 특정 날의 전체 알림 ID 목록 반환 (모든 식단 × 2종류)
List<int> allNotifIdsForDay(int day) {
  return MealType.values
      .expand((meal) => allNotifIdsFor(day, meal))
      .toList();
}
