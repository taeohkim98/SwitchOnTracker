// [파일 역할]
// ProgramRepository 인터페이스의 실제 구현체
// HiveDataSource를 통해 JSON 직렬화/역직렬화 후 Hive에 저장
// Export/Import 로직도 여기에 구현

import 'dart:convert';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/program_config.dart';
import '../../domain/entities/day_record.dart';
import '../../domain/entities/meal_type.dart';
import '../../domain/repositories/program_repository.dart';
import '../datasources/hive_datasource.dart';

/// ProgramRepository 구현체
class ProgramRepositoryImpl implements ProgramRepository {
  final HiveDataSource _hive;

  ProgramRepositoryImpl(this._hive);

  // ── 설정 ──

  @override
  Future<ProgramConfig?> loadConfig() async {
    final json = _hive.readConfig();
    if (json == null) return null;
    try {
      return ProgramConfig.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null; // 파싱 실패 시 null 반환 → 온보딩으로 이동
    }
  }

  @override
  Future<void> saveConfig(ProgramConfig config) async {
    await _hive.writeConfig(jsonEncode(config.toJson()));
  }

  // ── 일별 기록 ──

  @override
  Future<DayRecord> loadDayRecord(int day) async {
    final json = _hive.readDay(day);
    if (json == null) {
      // 기록 없으면 해당 날짜의 초기 상태 반환
      final config = await loadConfig();
      final date = config != null
          ? config.startDate.add(Duration(days: day - 1))
          : DateTime.now();
      return DayRecord.initial(day, date);
    }
    try {
      return DayRecord.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      final config = await loadConfig();
      final date = config != null
          ? config.startDate.add(Duration(days: day - 1))
          : DateTime.now();
      return DayRecord.initial(day, date);
    }
  }

  @override
  Future<void> saveDayRecord(DayRecord record) async {
    await _hive.writeDay(record.dayNumber, jsonEncode(record.toJson()));
  }

  @override
  Future<DayRecord> toggleMeal(int day, MealType meal) async {
    final current = await loadDayRecord(day);
    final updated = current.meal(meal).isChecked
        ? current.withMealUnchecked(meal)
        : current.withMealChecked(meal);
    await saveDayRecord(updated);
    return updated;
  }

  // ── 내보내기 / 가져오기 ──

  @override
  Future<Map<String, dynamic>> exportAllData() async {
    final config = await loadConfig();
    final rawDays = _hive.readAllDays();

    // days 데이터를 JSON 객체로 변환 (문자열 → Map)
    final daysMap = <String, dynamic>{};
    for (final entry in rawDays.entries) {
      try {
        daysMap[entry.key] = jsonDecode(entry.value);
      } catch (_) {
        // 파싱 실패한 레코드는 스킵
      }
    }

    return {
      'config': config?.toJson(),
      'days': daysMap,
    };
  }

  @override
  Future<void> importAllData(Map<String, dynamic> json) async {
    // 설정 복원
    if (json['config'] != null) {
      final config = ProgramConfig.fromJson(
          json['config'] as Map<String, dynamic>);
      await saveConfig(config);
    }

    // 일별 기록 복원
    final daysJson = json['days'] as Map<String, dynamic>?;
    if (daysJson != null) {
      final stringMap = <String, String>{};
      for (final entry in daysJson.entries) {
        stringMap[entry.key] = jsonEncode(entry.value);
      }
      await _hive.replaceAllDays(stringMap);
    }
  }
}
