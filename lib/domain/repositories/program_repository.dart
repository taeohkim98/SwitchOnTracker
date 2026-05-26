// [파일 역할]
// 프로그램 데이터(설정, 일별 기록) 접근에 대한 추상 인터페이스(계약)
// 실제 구현은 data/repositories/program_repository_impl.dart 에 있음
// 이 추상 클래스 덕분에 나중에 저장소를 바꿔도 도메인 코드는 수정 불필요

import '../entities/program_config.dart';
import '../entities/day_record.dart';
import '../entities/meal_type.dart';

/// 프로그램 데이터 저장소 인터페이스
abstract class ProgramRepository {
  // ── 설정 ──

  /// 저장된 프로그램 설정 불러오기 (없으면 null)
  Future<ProgramConfig?> loadConfig();

  /// 프로그램 설정 저장
  Future<void> saveConfig(ProgramConfig config);

  // ── 일별 기록 ──

  /// 특정 Day의 기록 불러오기 (없으면 초기 상태 반환)
  Future<DayRecord> loadDayRecord(int day);

  /// 특정 Day의 기록 저장
  Future<void> saveDayRecord(DayRecord record);

  /// 특정 Day의 특정 식단 체크 토글
  Future<DayRecord> toggleMeal(int day, MealType meal);

  /// 전체 데이터 내보내기용 JSON 생성
  /// { config: {...}, days: { "day_1": {...}, ... } }
  Future<Map<String, dynamic>> exportAllData();

  /// 가져온 JSON 데이터로 전체 복원 (기존 데이터 완전 덮어쓰기)
  Future<void> importAllData(Map<String, dynamic> json);
}
