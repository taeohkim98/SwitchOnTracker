// [파일 역할]
// 개별 식단(아침/점심/간식/저녁) 하나의 체크 상태를 나타내는 도메인 엔티티
// Hive에 JSON으로 직렬화되어 저장됨

import 'meal_type.dart';

/// 단일 식단의 체크 기록
class MealRecord {
  final MealType type;         // 식단 종류 (아침/점심/간식/저녁)
  final bool isChecked;        // 사용자가 체크했는지 여부
  final DateTime? checkedAt;   // 체크한 시각 (알림 예약 기준 시각)

  const MealRecord({
    required this.type,
    this.isChecked = false,
    this.checkedAt,
  });

  /// 체크 완료 상태로 복사본 생성 (불변 객체 패턴)
  MealRecord check() => MealRecord(
        type: type,
        isChecked: true,
        checkedAt: DateTime.now(),
      );

  /// 체크 취소 상태로 복사본 생성
  MealRecord uncheck() => MealRecord(
        type: type,
        isChecked: false,
        checkedAt: null,
      );

  // ── JSON 직렬화 (Hive 저장용) ──

  /// MealRecord → JSON Map
  Map<String, dynamic> toJson() => {
        'type': type.index,                          // int로 저장
        'isChecked': isChecked,
        'checkedAt': checkedAt?.toIso8601String(),  // null이면 null 저장
      };

  /// JSON Map → MealRecord
  factory MealRecord.fromJson(Map<String, dynamic> json) => MealRecord(
        type: MealType.values[json['type'] as int],
        isChecked: json['isChecked'] as bool? ?? false,
        checkedAt: json['checkedAt'] != null
            ? DateTime.parse(json['checkedAt'] as String)
            : null,
      );

  /// 해당 식단 타입의 초기(미체크) 레코드 생성
  factory MealRecord.initial(MealType type) => MealRecord(type: type);
}
