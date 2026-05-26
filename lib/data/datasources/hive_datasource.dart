// [파일 역할]
// Hive 로컬 DB에 직접 읽기/쓰기하는 최하위 데이터 접근 계층
// Repository가 이 클래스를 통해 Hive와 통신함
// JSON 문자열로 직렬화하여 Hive String Box에 저장

import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';

/// Hive DB 직접 접근 클래스
class HiveDataSource {
  // 두 개의 Hive Box를 지연 초기화
  late final Box<String> _configBox;
  late final Box<String> _daysBox;

  /// 앱 시작 시 반드시 이 메서드로 Box를 열어야 함
  Future<void> init() async {
    _configBox = await Hive.openBox<String>(HiveBoxNames.config);
    _daysBox   = await Hive.openBox<String>(HiveBoxNames.days);
  }

  // ── 설정 ──

  /// 저장된 프로그램 설정 JSON 문자열 반환 (없으면 null)
  String? readConfig() => _configBox.get(HiveKeys.programConfig);

  /// 프로그램 설정 JSON 문자열 저장
  Future<void> writeConfig(String json) =>
      _configBox.put(HiveKeys.programConfig, json);

  // ── 일별 기록 ──

  /// 특정 Day의 기록 JSON 문자열 반환 (없으면 null)
  String? readDay(int day) => _daysBox.get(HiveKeys.dayRecord(day));

  /// 특정 Day의 기록 JSON 문자열 저장
  Future<void> writeDay(int day, String json) =>
      _daysBox.put(HiveKeys.dayRecord(day), json);

  /// 모든 Day 기록 Map 반환 (내보내기용)
  /// { 'day_1': '{"dayNumber":1,...}', ... }
  Map<String, String> readAllDays() =>
      Map<String, String>.from(_daysBox.toMap().map(
        (k, v) => MapEntry(k.toString(), v.toString()),
      ));

  /// 모든 데이터 삭제 후 새 데이터 일괄 저장 (가져오기용)
  Future<void> replaceAllDays(Map<String, String> data) async {
    await _daysBox.clear();
    await _daysBox.putAll(data);
  }

  /// 전체 데이터 초기화
  Future<void> clearAll() async {
    await _configBox.clear();
    await _daysBox.clear();
  }
}
