// [파일 역할]
// 프로그램 전체 설정을 나타내는 도메인 엔티티
// - 시작 날짜 (Day 1이 언제인지)
// - 알림 ON/OFF 여부

import '../../core/constants/app_constants.dart';

/// 앱 전체 프로그램 설정
class ProgramConfig {
  final DateTime startDate;          // 프로그램 시작일 (Day 1 = 이 날짜)
  final bool notificationsEnabled;   // 알림 활성화 여부

  const ProgramConfig({
    required this.startDate,
    this.notificationsEnabled = true,
  });

  /// 오늘이 몇 일차인지 계산 (1~28 범위로 제한)
  int get currentDay {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final diff = today.difference(start).inDays + 1;
    return diff.clamp(1, kTotalDays);
  }

  /// 오늘 날짜가 시작일 이전인지
  bool get notStartedYet {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    return today.isBefore(start);
  }

  /// 28일 프로그램이 완전히 끝났는지
  bool get isCompleted {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    return today.difference(start).inDays >= kTotalDays;
  }

  /// 알림 설정 변경된 복사본 반환
  ProgramConfig withNotifications(bool enabled) => ProgramConfig(
        startDate: startDate,
        notificationsEnabled: enabled,
      );

  // ── JSON 직렬화 ──

  Map<String, dynamic> toJson() => {
        'startDate': startDate.toIso8601String(),
        'notificationsEnabled': notificationsEnabled,
      };

  factory ProgramConfig.fromJson(Map<String, dynamic> json) => ProgramConfig(
        startDate: DateTime.parse(json['startDate'] as String),
        notificationsEnabled:
            json['notificationsEnabled'] as bool? ?? true,
      );
}
