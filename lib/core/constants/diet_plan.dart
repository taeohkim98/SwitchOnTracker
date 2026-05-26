// ============================================================
// [파일 역할]
// 28일치 고정 식단 데이터를 저장하는 상수 파일입니다.
//
// ★ 여기가 식단을 입력하는 곳입니다! ★
//
// kDietPlan 리스트에 Day 1 ~ Day 28 순서로
// 각 날의 아침/점심/간식/저녁 메뉴와 특이사항을 입력하세요.
//
// 이 파일은 앱 코드에 하드코딩된 "프로그램 내용"이므로
// 사용자 DB(Hive)에 저장되지 않습니다.
// 사용자의 "체크 여부"는 Hive DB에 별도로 저장됩니다.
// ============================================================

/// 하루치 식단 정보를 담는 데이터 클래스
class DayPlan {
  final int dayNumber;       // 1 ~ 28
  final String breakfast;    // 아침 메뉴 설명
  final String lunch;        // 점심 메뉴 설명
  final String snack;        // 간식 메뉴 설명
  final String dinner;       // 저녁 메뉴 설명
  final String weeklyNote;   // 해당 주차 주의사항 (상단 배너에 표시됨)

  const DayPlan({
    required this.dayNumber,
    required this.breakfast,
    required this.lunch,
    required this.snack,
    required this.dinner,
    required this.weeklyNote,
  });
}

// ============================================================
// ★★★ 아래 리스트에 28일치 식단을 입력하세요 ★★★
//
// 각 DayPlan(...)의 필드를 직접 수정하면 됩니다.
// - breakfast: 아침 메뉴
// - lunch:     점심 메뉴
// - snack:     간식 메뉴
// - dinner:    저녁 메뉴
// - weeklyNote: 해당 날의 주의사항 (1~3일/4일차~ 등)
// ============================================================

/// 28일 전체 식단 계획
/// index 0 = Day 1, index 27 = Day 28
const List<DayPlan> kDietPlan = [
  // ─────────────────────────────
  // 1주차 (Day 1 ~ 7)
  // 초반 3일: 채소·두부·요거트만 허용
  // ─────────────────────────────

  DayPlan(
    dayNumber: 1,
    breakfast: '단백질 쉐이크',
    // ↓ 여기에 점심 메뉴를 입력하세요
    lunch: '단백질 쉐이크',
    snack: '단백질 쉐이크',
    dinner: '단백질 쉐이크',
    weeklyNote: '1~3일차: 채소, 두부, 요거트만 허용합니다.\n단백질 쉐이크를 기본으로 섭취하세요.\n금단증상(두통, 무기력감 나타날 시 4일차로바로 넘어가기)',
  ),

  DayPlan(
    dayNumber: 2,
    breakfast: '단백질 쉐이크',
    lunch: '단백질 쉐이크',
    snack: '단백질 쉐이크',
    dinner: '단백질 쉐이크',
    weeklyNote: '1~3일차: 채소, 두부, 요거트만 허용합니다.\n단백질 쉐이크를 기본으로 섭취하세요.\n금단증상(두통, 무기력감 나타날 시 4일차로바로 넘어가기)',
  ),

  DayPlan(
    dayNumber: 3,
    breakfast: '단백질 쉐이크',
    lunch: '단백질 쉐이크',
    snack: '단백질 쉐이크',
    dinner: '단백질 쉐이크',
    weeklyNote: '1~3일차: 채소, 두부, 요거트만 허용합니다.\n내일부터 식단이 확장됩니다!\n금단증상(두통, 무기력감 나타날 시 4일차로바로 넘어가기)',
  ),

  DayPlan(
    dayNumber: 4,
    breakfast: '단백질 쉐이크',
    // ↓ 4일차부터 계란·생선·고기 등 허용
    lunch: '밥 + 채소 + 단백질',
    snack: '단백질 쉐이크',
    dinner: '단백질 쉐이크',
    weeklyNote: '4일차부터: 계란, 생선, 살코기 등 단백질 식품이 허용됩니다.\n채소, 두부, 플레인요거트, 해조류, 버섯,',
  ),

  DayPlan(
    dayNumber: 5,
    breakfast: '단백질 쉐이크',
    lunch: '밥 + 채소 + 단백질',
    snack: '단백질 쉐이크',
    dinner: '단백질 쉐이크',
    weeklyNote: '4일차부터: 계란, 생선, 살코기 등 단백질 식품이 허용됩니다.\n채소, 두부, 플레인요거트, 해조류, 버섯,',
  ),

  DayPlan(
    dayNumber: 6,
    breakfast: '단백질 쉐이크',
    lunch: '밥 + 채소 + 단백질',
    snack: '단백질 쉐이크',
    dinner: '단백질 쉐이크',
    weeklyNote: '4일차부터: 계란, 생선, 살코기 등 단백질 식품이 허용됩니다.\n채소, 두부, 플레인요거트, 해조류, 버섯,',
  ),

  DayPlan(
    dayNumber: 7,
    breakfast: '단백질 쉐이크',
    lunch: '밥 + 채소 + 단백질',
    snack: '단백질 쉐이크',
    dinner: '단백질 쉐이크',
    weeklyNote: '1주차 마지막 날! 잘 하고 계세요 💪',
  ),

  // ─────────────────────────────
  // 2주차 (Day 8 ~ 14)
  // ↓ 아래 필드들을 프로그램 내용에 맞게 수정하세요
  // ─────────────────────────────

  DayPlan(
    dayNumber: 8,
    breakfast: '단백질 쉐이크',
    lunch: '밥 + 채소 + 단백질',       // ← 여기를 수정하세요
    snack: '단백질 쉐이크',
    dinner: '채소 + 단백질',
    weeklyNote: '2주차: 간헐적 단식 주 1회\n금기: 설탕, 밀가루, 과일\n허용:채소, 두부, 플레인요거트, 해조류, 달걀, 생선, 살코기, 콩류, 견과류 한줌',
  ),

  DayPlan(
    dayNumber: 9,
    breakfast: '단백질 쉐이크',
    lunch: '밥 + 채소 + 단백질',
    snack: '단백질 쉐이크',
    dinner: '단백질 쉐이크',
    weeklyNote: '2주차: 간헐적 단식 주 1회\n금기: 설탕, 밀가루, 과일\n허용:채소, 두부, 플레인요거트, 해조류, 달걀, 생선, 살코기, 콩류, 견과류 한줌',
  ),

  DayPlan(
    dayNumber: 10,
    breakfast: '단백질 쉐이크',
    lunch: '밥 + 채소 + 단백질',
    snack: '단백질 쉐이크',
    dinner: '단식',
    weeklyNote: '2주차: 간헐적 단식 주 1회\n금기: 설탕, 밀가루, 과일\n허용:채소, 두부, 플레인요거트, 해조류, 달걀, 생선, 살코기, 콩류, 견과류 한줌\n내일은 단식입니다!',
  ),

  DayPlan(
    dayNumber: 11,
    breakfast: '단식',
    lunch: '단식',
    snack: '단식',
    dinner: '채소 + 단백질',
    weeklyNote: '2주차 첫번째 단식일: 단식하시느라 수고하셨습니다. 꾸준히 이어가세요!',
  ),

  DayPlan(
    dayNumber: 12,
    breakfast: '단백질 쉐이크',
    lunch: '밥 + 채소 + 단백질',
    snack: '단백질 쉐이크',
    dinner: '채소 + 단백질',
    weeklyNote: '2주차: 간헐적 단식 주 1회\n금기: 설탕, 밀가루, 과일\n허용:채소, 두부, 플레인요거트, 해조류, 달걀, 생선, 살코기, 콩류, 견과류 한줌\n내일은 단식입니다!',
  ),

  DayPlan(
    dayNumber: 13,
    breakfast: '단백질 쉐이크',
    lunch: '밥 + 채소 + 단백질',
    snack: '단백질 쉐이크',
    dinner: '채소 + 단백질',
    weeklyNote: '2주차: 간헐적 단식 주 1회\n금기: 설탕, 밀가루, 과일\n허용:채소, 두부, 플레인요거트, 해조류, 달걀, 생선, 살코기, 콩류, 견과류 한줌\n내일은 단식입니다!',
  ),

  DayPlan(
    dayNumber: 14,
    breakfast: '단백질 쉐이크',
    lunch: '밥 + 채소 + 단백질',
    snack: '단백질 쉐이크',
    dinner: '채소 + 단백질',
    weeklyNote: '2주 완료! 절반 왔습니다 🎉',
  ),

  // ─────────────────────────────
  // 3주차 (Day 15 ~ 21)
  // ─────────────────────────────

  DayPlan(
    dayNumber: 15,
    breakfast: '단백질 쉐이크',
    lunch: '밥 + 채소 + 단백질',
    snack: '단백질 쉐이크',
    dinner: '단식',
    weeklyNote: '3주차: 후반전 시작! 포기하지 마세요.\n금기: 설탕, 밀가루, 과일.\n허용: 채소, 두부, 플레인요거트, 해조류, 버섯, 달걀, 생선, 살코기, 콩류, 견과류, 단호박, 토마토, 베리류 과일, 바나나 하루 1개, 고구마 하루 1개, 방울토마토, 저지방 소고기\n내일은 단식일입니다. 화이팅!',
  ),

  DayPlan(
    dayNumber: 16,
    breakfast: '단식',
    lunch: '단식',
    snack: '단식',
    dinner: '채소 + 단백질',
    weeklyNote: '3주차 금기: 설탕, 밀가루, 과일.\n허용: 채소, 두부, 플레인요거트, 해조류, 버섯, 달걀, 생선, 살코기, 콩류, 견과류, 단호박, 토마토, 베리류 과일, 바나나 하루 1개, 고구마 하루 1개, 방울토마토, 저지방 소고기',
  ),

  DayPlan(
    dayNumber: 17,
    breakfast: '단백질 쉐이크',
    lunch: '밥 + 채소 + 단백질',
    snack: '단백질 쉐이크',
    dinner: '단식',
    weeklyNote: '3주차 금기: 설탕, 밀가루, 과일.\n허용: 채소, 두부, 플레인요거트, 해조류, 버섯, 달걀, 생선, 살코기, 콩류, 견과류, 단호박, 토마토, 베리류 과일, 바나나 하루 1개, 고구마 하루 1개, 방울토마토, 저지방 소고기\n내일은 단식일입니다. 화이팅!',
  ),

  DayPlan(
    dayNumber: 18,
    breakfast: '단식',
    lunch: '단식',
    snack: '단식',
    dinner: '채소 + 단백질',
    weeklyNote: '3주차 금기: 설탕, 밀가루, 과일.\n허용: 채소, 두부, 플레인요거트, 해조류, 버섯, 달걀, 생선, 살코기, 콩류, 견과류, 단호박, 토마토, 베리류 과일, 바나나 하루 1개, 고구마 하루 1개, 방울토마토, 저지방 소고기',
  ),

  DayPlan(
    dayNumber: 19,
    breakfast: '단백질 쉐이크',
    lunch: '밥 + 채소 + 단백질',
    snack: '단백질 쉐이크',
    dinner: '채소 + 단백질',
    weeklyNote: '3주차 금기: 설탕, 밀가루, 과일.\n허용: 채소, 두부, 플레인요거트, 해조류, 버섯, 달걀, 생선, 살코기, 콩류, 견과류, 단호박, 토마토, 베리류 과일, 바나나 하루 1개, 고구마 하루 1개, 방울토마토, 저지방 소고기',
  ),

  DayPlan(
    dayNumber: 20,
    breakfast: '단백질 쉐이크',
    lunch: '밥 + 채소 + 단백질',
    snack: '단백질 쉐이크',
    dinner: '채소 + 단백질',
    weeklyNote: '3주차 금기: 설탕, 밀가루, 과일.\n허용: 채소, 두부, 플레인요거트, 해조류, 버섯, 달걀, 생선, 살코기, 콩류, 견과류, 단호박, 토마토, 베리류 과일, 바나나 하루 1개, 고구마 하루 1개, 방울토마토, 저지방 소고기',
  ),

  DayPlan(
    dayNumber: 21,
    breakfast: '단백질 쉐이크',
    lunch: '밥 + 채소 + 단백질',
    snack: '단백질 쉐이크',
    dinner: '채소 + 단백질',
    weeklyNote: '3주 완료! 마지막 주가 남았습니다.',
  ),

  // ─────────────────────────────
  // 4주차 (Day 22 ~ 28)
  // ─────────────────────────────

  DayPlan(
    dayNumber: 22,
    breakfast: '단백질 쉐이크',
    lunch: '일반식',
    snack: '단백질 쉐이크',
    dinner: '단식',
    weeklyNote: '마지막 4주차. 끝까지 화이팅!\n금기: 설탕, 밀가루, 과일.\n허용: 채소, 두부, 플레인요거트, 해조류, 버섯, 달걀, 생선, 살코기, 콩류, 견과류, 단호박, 토마토, 베리류 과일, 바나나 하루 1개, 고구마 하루 1개, 방울토마토, 저지방 소고기',
  ),

  DayPlan(
    dayNumber: 23,
    breakfast: '단식',
    lunch: '단식',
    snack: '단식',
    dinner: '밥 + 채소 + 단백질',
    weeklyNote: '4주차 금기: 설탕, 밀가루, 과일.\n허용: 채소, 두부, 플레인요거트, 해조류, 버섯, 달걀, 생선, 살코기, 콩류, 견과류, 단호박, 토마토, 베리류 과일, 바나나 하루 1개, 고구마 하루 1개, 방울토마토, 저지방 소고기',
  ),

  DayPlan(
    dayNumber: 24,
    breakfast: '단백질 쉐이크',
    lunch: '일반식',
    snack: '단백질 쉐이크',
    dinner: '단식',
    weeklyNote: '4주차 금기: 설탕, 밀가루, 과일.\n허용: 채소, 두부, 플레인요거트, 해조류, 버섯, 달걀, 생선, 살코기, 콩류, 견과류, 단호박, 토마토, 베리류 과일, 바나나 하루 1개, 고구마 하루 1개, 방울토마토, 저지방 소고기',
  ),

  DayPlan(
    dayNumber: 25,
    breakfast: '단식',
    lunch: '단식',
    snack: '단식',
    dinner: '밥 + 채소 + 단백질',
    weeklyNote: '4주차 금기: 설탕, 밀가루, 과일.\n허용: 채소, 두부, 플레인요거트, 해조류, 버섯, 달걀, 생선, 살코기, 콩류, 견과류, 단호박, 토마토, 베리류 과일, 바나나 하루 1개, 고구마 하루 1개, 방울토마토, 저지방 소고기',
  ),

  DayPlan(
    dayNumber: 26,
    breakfast: '단백질 쉐이크',
    lunch: '일반식',
    snack: '단백질 쉐이크',
    dinner: '단식',
    weeklyNote: '4주차 금기: 설탕, 밀가루, 과일.\n허용: 채소, 두부, 플레인요거트, 해조류, 버섯, 달걀, 생선, 살코기, 콩류, 견과류, 단호박, 토마토, 베리류 과일, 바나나 하루 1개, 고구마 하루 1개, 방울토마토, 저지방 소고기',
  ),

  DayPlan(
    dayNumber: 27,
    breakfast: '단식',
    lunch: '단식',
    snack: '단식',
    dinner: '밥 + 채소 + 단백질',
    weeklyNote: '내일이 마지막 날! 거의 다 왔어요!',
  ),

  DayPlan(
    dayNumber: 28,
    breakfast: '단백질 쉐이크',
    lunch: '일반식',
    snack: '단백질 쉐이크',
    dinner: '밥 + 채소 + 단백질',
    weeklyNote: '🎊 오늘이 마지막 날입니다! 완주하세요!\n수고 많으셨습니다!',
  ),
];

/// dayNumber(1~28)로 해당 날의 식단 계획을 가져오는 함수
/// dayNumber가 범위를 벗어나면 Day 28 기준 반환
DayPlan getDayPlan(int dayNumber) {
  final index = (dayNumber - 1).clamp(0, kDietPlan.length - 1);
  return kDietPlan[index];
}
