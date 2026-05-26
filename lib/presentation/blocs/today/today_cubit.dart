// [파일 역할]
// 오늘 화면의 비즈니스 로직을 담당하는 Cubit (BLoC의 단순화 버전)
// - 오늘 데이터 로드
// - 식단 체크/언체크
// - 폭죽 보상 처리

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/meal_type.dart';
import '../../../domain/entities/program_config.dart';
import '../../../domain/repositories/program_repository.dart';
import '../../../domain/usecases/check_meal_usecase.dart';
import 'today_state.dart';

/// 오늘 화면 Cubit
class TodayCubit extends Cubit<TodayState> {
  final ProgramRepository _programRepo;
  final CheckMealUseCase _checkMealUseCase;

  TodayCubit(this._programRepo, this._checkMealUseCase)
      : super(TodayLoading());

  /// 오늘 데이터 로드 (화면 진입 시 또는 import 후 새로고침)
  Future<void> load() async {
    emit(TodayLoading());
    try {
      final config = await _programRepo.loadConfig();

      // 설정 없음 → SplashPage에서 처리하므로 여기서는 에러
      if (config == null) {
        emit(TodayError('설정 없음'));
        return;
      }

      // 시작 전
      if (config.notStartedYet) {
        emit(TodayNotStarted(config.startDate));
        return;
      }

      // 28일 완료
      if (config.isCompleted) {
        emit(TodayProgramCompleted());
        return;
      }

      final day = config.currentDay;
      final record = await _programRepo.loadDayRecord(day);

      emit(TodayLoaded(config: config, dayRecord: record));
    } catch (e) {
      emit(TodayError(e.toString()));
    }
  }

  /// 식단 체크/언체크 토글
  Future<void> toggleMeal(MealType meal) async {
    final current = state;
    if (current is! TodayLoaded) return;

    try {
      final updated = await _checkMealUseCase.execute(
        current.dayRecord.dayNumber,
        meal,
      );

      // 하루 완료 + 폭죽 아직 안 보여줬으면 → 폭죽 표시
      final shouldShowReward =
          updated.isAllChecked && !updated.rewardShown;

      emit(TodayLoaded(
        config: current.config,
        dayRecord: updated,
        showReward: shouldShowReward,
      ));
    } catch (e) {
      emit(TodayError(e.toString()));
    }
  }

  /// 1~3일차에서 4일차로 강제 이동 (금단증상 심할 때 사용)
  /// 시작일을 "오늘 - 3일"로 재설정하여 currentDay가 4가 되게 함
  Future<void> skipToDay4() async {
    final current = state;
    if (current is! TodayLoaded) return;
    if (current.dayRecord.dayNumber > 3) return;

    emit(TodayLoading());
    try {
      final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      final newStartDate = today.subtract(const Duration(days: 3));
      final newConfig = ProgramConfig(
        startDate: newStartDate,
        notificationsEnabled: current.config.notificationsEnabled,
      );
      await _programRepo.saveConfig(newConfig);
      await load();
    } catch (e) {
      emit(TodayError(e.toString()));
    }
  }

  /// 폭죽 애니메이션 표시 완료 처리 (다시 열었을 때 재표시 방지)
  Future<void> markRewardShown() async {
    final current = state;
    if (current is! TodayLoaded) return;

    // DB에 보상 표시 완료 기록
    final updated = current.dayRecord.withRewardShown();
    await _programRepo.saveDayRecord(updated);

    emit(current.copyWith(showReward: false));
  }
}
