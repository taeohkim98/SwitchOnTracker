// [파일 역할]
// 기록(달력) 화면의 데이터를 관리하는 Cubit
// Day 1 ~ 현재까지의 모든 기록을 불러와 달력 UI에 제공

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../domain/entities/day_record.dart';
import '../../../domain/entities/program_config.dart';
import '../../../domain/repositories/program_repository.dart';

// ── State ──

@immutable
sealed class HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final ProgramConfig config;
  final List<DayRecord> records;  // Day 1 ~ 현재까지의 기록 리스트

  HistoryLoaded({required this.config, required this.records});

  /// 완료된 날 수
  int get completedDays => records.where((r) => r.isAllChecked).length;
}

class HistoryError extends HistoryState {
  final String message;
  HistoryError(this.message);
}

// ── Cubit ──

/// 기록 화면 Cubit
class HistoryCubit extends Cubit<HistoryState> {
  final ProgramRepository _programRepo;

  HistoryCubit(this._programRepo) : super(HistoryLoading());

  /// Day 1 ~ 현재까지의 기록 로드
  Future<void> load() async {
    emit(HistoryLoading());
    try {
      final config = await _programRepo.loadConfig();
      if (config == null) {
        emit(HistoryError('설정 없음'));
        return;
      }

      // 현재까지 지난 날짜만 로드
      final currentDay = config.currentDay;
      final records = <DayRecord>[];
      for (var day = 1; day <= currentDay; day++) {
        records.add(await _programRepo.loadDayRecord(day));
      }

      emit(HistoryLoaded(config: config, records: records));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
