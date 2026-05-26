// [파일 역할]
// 설정 화면의 상태와 로직을 담당하는 Cubit
// - 알림 ON/OFF 토글
// - 데이터 내보내기/가져오기 트리거

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../domain/entities/program_config.dart';
import '../../../domain/repositories/program_repository.dart';
import '../../../domain/repositories/notification_repository.dart';
import '../../../domain/usecases/export_data_usecase.dart';
import '../../../domain/usecases/import_data_usecase.dart';

// ── State ──

@immutable
sealed class SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final ProgramConfig config;
  SettingsLoaded(this.config);
}

class SettingsExporting extends SettingsState {
  final ProgramConfig config;
  SettingsExporting(this.config);
}

class SettingsImporting extends SettingsState {
  final ProgramConfig config;
  SettingsImporting(this.config);
}

/// 내보내기/가져오기 완료 알림용 상태
class SettingsActionResult extends SettingsState {
  final ProgramConfig config;
  final String message;   // 성공/실패 메시지
  final bool isSuccess;
  SettingsActionResult(this.config, this.message, {required this.isSuccess});
}

class SettingsError extends SettingsState {
  final String message;
  SettingsError(this.message);
}

// ── Cubit ──

/// 설정 화면 Cubit
class SettingsCubit extends Cubit<SettingsState> {
  final ProgramRepository _programRepo;
  final NotificationRepository _notifRepo;
  final ExportDataUseCase _exportUseCase;
  final ImportDataUseCase _importUseCase;

  SettingsCubit(
    this._programRepo,
    this._notifRepo,
    this._exportUseCase,
    this._importUseCase,
  ) : super(SettingsLoading());

  /// 현재 설정 로드
  Future<void> load() async {
    try {
      final config = await _programRepo.loadConfig();
      if (config == null) {
        emit(SettingsError('설정 없음'));
        return;
      }
      emit(SettingsLoaded(config));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  /// 알림 ON/OFF 토글
  Future<void> toggleNotifications() async {
    final current = state;
    if (current is! SettingsLoaded) return;

    final newConfig = current.config.withNotifications(
        !current.config.notificationsEnabled);
    await _programRepo.saveConfig(newConfig);

    // 알림 OFF 시 모든 pending 알림 취소
    if (!newConfig.notificationsEnabled) {
      await _notifRepo.cancelAll();
    }

    emit(SettingsLoaded(newConfig));
  }

  /// 데이터 내보내기 (JSON → 클립보드 복사)
  Future<void> exportData() async {
    final current = state;
    if (current is! SettingsLoaded) return;

    emit(SettingsExporting(current.config));
    try {
      await _exportUseCase.execute();
      emit(SettingsActionResult(
        current.config,
        '클립보드에 복사됐습니다!\n메모장·카카오톡 등에 붙여넣기(Paste)하여 보관하세요.',
        isSuccess: true,
      ));
    } catch (e) {
      emit(SettingsActionResult(
        current.config,
        '내보내기 실패: ${e.toString()}',
        isSuccess: false,
      ));
    }
  }

  /// 데이터 가져오기 (휴대폰 교체 시 복원)
  Future<void> importData() async {
    final current = state;
    if (current is! SettingsLoaded) return;

    emit(SettingsImporting(current.config));
    try {
      final result = await _importUseCase.execute();
      switch (result) {
        case ImportResult.success:
          // 가져오기 성공 후 설정 새로고침
          final newConfig = await _programRepo.loadConfig();
          emit(SettingsActionResult(
            newConfig ?? current.config,
            '데이터를 성공적으로 가져왔습니다!\n앱이 이전 폰의 기록으로 복원되었습니다.',
            isSuccess: true,
          ));
        case ImportResult.cancelled:
          emit(SettingsLoaded(current.config));
        case ImportResult.invalidFile:
          emit(SettingsActionResult(
            current.config,
            '올바른 JSON 백업 파일을 선택해 주세요.',
            isSuccess: false,
          ));
        case ImportResult.incompatibleData:
          emit(SettingsActionResult(
            current.config,
            '파일 구조가 맞지 않습니다. Switch-On Diet 백업 파일인지 확인해 주세요.',
            isSuccess: false,
          ));
      }
    } catch (e) {
      emit(SettingsActionResult(
        current.config,
        '가져오기 실패: ${e.toString()}',
        isSuccess: false,
      ));
    }
  }

  /// ActionResult 상태 확인 후 SettingsLoaded로 복귀
  void clearResult() {
    final current = state;
    if (current is SettingsActionResult) {
      emit(SettingsLoaded(current.config));
    }
  }
}
