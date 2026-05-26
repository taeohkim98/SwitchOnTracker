// [파일 역할]
// 사용자 데이터를 JSON 텍스트로 내보내는 유스케이스
// path_provider/파일 저장 없이 순수 텍스트 공유로 처리 (iOS 호환)

import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../repositories/program_repository.dart';

/// 데이터 내보내기 유스케이스
class ExportDataUseCase {
  final ProgramRepository _programRepo;

  ExportDataUseCase(this._programRepo);

  /// 전체 데이터를 JSON 텍스트로 내보내기
  /// share_plus / path_provider 없이 클립보드로 복사
  Future<String> execute() async {
    // 1. 전체 데이터 수집
    final allData = await _programRepo.exportAllData();

    // 2. 메타데이터 추가
    final exportPayload = {
      'appVersion': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'data': allData,
    };

    // 3. JSON 문자열 변환
    final jsonString = const JsonEncoder.withIndent('  ').convert(exportPayload);

    // 4. 클립보드에 복사 (순수 Flutter — 플러그인 불필요)
    await Clipboard.setData(ClipboardData(text: jsonString));

    return jsonString;
  }
}
