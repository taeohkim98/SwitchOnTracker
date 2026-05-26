// [파일 역할]
// 로컬 파일에서 JSON 데이터를 읽어 DB를 완전히 복원하는 유스케이스
// 휴대폰을 바꿀 때 이 기능으로 이전 폰의 기록을 새 폰으로 이전

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../repositories/program_repository.dart';
import '../repositories/notification_repository.dart';

/// 데이터 가져오기 결과
enum ImportResult {
  success,          // 성공
  cancelled,        // 사용자가 취소
  invalidFile,      // 파일 형식 오류
  incompatibleData, // 데이터 구조 불일치
}

/// 데이터 가져오기 유스케이스
class ImportDataUseCase {
  final ProgramRepository _programRepo;
  final NotificationRepository _notifRepo;

  ImportDataUseCase(this._programRepo, this._notifRepo);

  /// 파일 피커로 JSON 파일 선택 후 데이터 복원
  Future<ImportResult> execute() async {
    // 1. 파일 선택 (JSON 파일만 필터)
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
    );

    // 사용자가 취소한 경우
    if (result == null || result.files.isEmpty) {
      return ImportResult.cancelled;
    }

    // 2. 파일 읽기
    final filePath = result.files.single.path;
    if (filePath == null) return ImportResult.invalidFile;

    String jsonString;
    try {
      jsonString = await File(filePath).readAsString();
    } catch (_) {
      return ImportResult.invalidFile;
    }

    // 3. JSON 파싱
    Map<String, dynamic> parsed;
    try {
      parsed = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      return ImportResult.invalidFile;
    }

    // 4. 파일 구조 검증 ('data' 키가 있어야 함)
    if (!parsed.containsKey('data')) {
      return ImportResult.incompatibleData;
    }

    // 5. 기존 알림 전부 취소 후 데이터 복원
    try {
      await _notifRepo.cancelAll();
      await _programRepo.importAllData(
          parsed['data'] as Map<String, dynamic>);
    } catch (_) {
      return ImportResult.incompatibleData;
    }

    return ImportResult.success;
  }
}
