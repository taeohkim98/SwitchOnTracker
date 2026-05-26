// [파일 역할]
// 오늘 화면(TodayTab)의 UI 상태를 나타내는 클래스들
// TodayCubit이 이 상태들을 emit하고 UI가 감지하여 화면을 업데이트

import 'package:flutter/foundation.dart';
import '../../../domain/entities/day_record.dart';
import '../../../domain/entities/program_config.dart';

/// 오늘 화면 상태 기반 클래스
@immutable
sealed class TodayState {}

/// 데이터 로딩 중
class TodayLoading extends TodayState {}

/// 앱이 시작 전 상태 (시작일이 아직 미래)
class TodayNotStarted extends TodayState {
  final DateTime startDate;
  TodayNotStarted(this.startDate);
}

/// 정상 표시 상태
class TodayLoaded extends TodayState {
  final ProgramConfig config;  // 프로그램 설정 (시작일, 알림 설정)
  final DayRecord dayRecord;   // 오늘의 식단 기록
  final bool showReward;       // 폭죽 애니메이션 표시 여부

  TodayLoaded({
    required this.config,
    required this.dayRecord,
    this.showReward = false,
  });

  /// showReward 값만 바꾼 복사본 (나머지는 동일)
  TodayLoaded copyWith({bool? showReward}) => TodayLoaded(
        config: config,
        dayRecord: dayRecord,
        showReward: showReward ?? this.showReward,
      );
}

/// 28일 프로그램 완전 완료 상태
class TodayProgramCompleted extends TodayState {}

/// 에러 상태
class TodayError extends TodayState {
  final String message;
  TodayError(this.message);
}
