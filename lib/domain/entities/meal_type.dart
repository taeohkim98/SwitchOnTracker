// [파일 역할]
// 식단 종류(아침/점심/간식/저녁)를 나타내는 열거형
// index 값이 알림 ID 계산에 사용되므로 순서를 변경하지 말 것

/// 식단 종류 열거형
/// index: breakfast=0, lunch=1, snack=2, dinner=3
enum MealType {
  breakfast,  // 아침
  lunch,      // 점심
  snack,      // 간식
  dinner,     // 저녁
}

/// MealType → 한글 이름
extension MealTypeLabel on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast: return '아침';
      case MealType.lunch:     return '점심';
      case MealType.snack:     return '간식';
      case MealType.dinner:    return '저녁';
    }
  }

  /// 각 식단 아이콘 이모지
  String get emoji {
    switch (this) {
      case MealType.breakfast: return '🌅';
      case MealType.lunch:     return '☀️';
      case MealType.snack:     return '🍎';
      case MealType.dinner:    return '🌙';
    }
  }

  /// 다음 식단 (알림 취소 로직에 사용)
  /// dinner 다음은 null (마지막 식단)
  MealType? get next {
    final idx = index + 1;
    if (idx >= MealType.values.length) return null;
    return MealType.values[idx];
  }

  /// 이전 식단 (취소 대상 계산)
  MealType? get previous {
    final idx = index - 1;
    if (idx < 0) return null;
    return MealType.values[idx];
  }
}
