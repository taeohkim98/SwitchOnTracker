// [파일 역할]
// 앱 전체에서 사용하는 상수값들을 모아두는 파일
// 색상, 문자열, 숫자 상수 등 변경 시 이 파일만 수정하면 됨

import 'package:flutter/material.dart';

/// Hive 박스 이름 상수 — DB 접근 시 항상 이 값을 사용
class HiveBoxNames {
  HiveBoxNames._();
  static const String config = 'config_box';  // 앱 설정 저장 박스
  static const String days   = 'days_box';    // 일별 체크 기록 저장 박스
}

/// Hive 키 상수
class HiveKeys {
  HiveKeys._();
  static const String programConfig = 'program_config'; // 시작일, 알림 설정
  static String dayRecord(int day) => 'day_$day';       // 'day_1' ~ 'day_28'
}

/// 로컬 알림 채널 설정
class NotifChannel {
  NotifChannel._();
  static const String id          = 'diet_reminders';
  static const String name        = '식단 알림';
  static const String description = '식단 체크 리마인드 알림';
}

/// 알림 타이밍 (식단 체크 후 경과 시간)
class NotifTiming {
  NotifTiming._();
  /// 1차 알림: 체크 후 5시간 45분
  static const Duration primary  = Duration(hours: 5, minutes: 45);
  /// 2차 리마인드: 체크 후 6시간 30분
  static const Duration reminder = Duration(hours: 6, minutes: 30);
}

/// 앱 전체 색상 팔레트
class AppColors {
  AppColors._();
  static const Color primary       = Color(0xFF4CAF50);   // 메인 초록
  static const Color primaryLight  = Color(0xFFE8F5E9);   // 연한 초록 배경
  static const Color accent        = Color(0xFFFF7043);   // 강조 주황
  static const Color checked       = Color(0xFF4CAF50);   // 체크 완료 색
  static const Color unchecked     = Color(0xFFE0E0E0);   // 미체크 색
  static const Color background    = Color(0xFFF5F5F5);   // 화면 배경
  static const Color cardBg        = Color(0xFFFFFFFF);   // 카드 배경
  static const Color textPrimary   = Color(0xFF212121);   // 주 텍스트
  static const Color textSecondary = Color(0xFF757575);   // 보조 텍스트
}

/// 28일 프로그램 총 일수
const int kTotalDays = 28;

/// 내보내기 파일 이름
const String kExportFileName = 'switch_on_diet_backup.json';

// ============================================================
// ★★★ 꼭 지켜야 할 규칙 내용을 아래에 입력하세요 ★★★
//
// 앱 상단 ⓘ 아이콘을 클릭하면 이 내용이 표시됩니다.
// 줄바꿈은 \n 으로, 각 항목은 자유롭게 작성하세요.
// ============================================================

/// 꼭 지켜야 할 규칙 — ⓘ 아이콘 클릭 시 표시되는 내용
const String kDietRules = '꼭 지켜야 할 규칙\n\n'
    '1. 아침식사는 전날 저녁식사를 마친 시간으로부터 14시간 후에 섭취한다.\n'
    '2. 저녁식사는 취침 2-4시간 전에 끝낸다.\n'
    '3. 수면시간은 하루 7-8시간 유지한다.\n'
    '4. 자정부터 새벽 4시는 반드시 수면시간에 포함되어야 한다\n'
    '5. 규칙적인 운동을 시행 (주4회이상/고강도 인터벌운동 15-30분)\n'
    '6. 오래 앉아있는 것을 피하고 1시간마다 일어나서 가볍게 몸을 움직인다.\n'
    '7. 물은 하루 8컵 이상 충분히 마신다.\n'
    '8. 금기음식: 술 밀가루 당류\n'
    '9. 카페인 음료 X, 2주차부터 오전 아메리카노 섭취 가능\n'
    '10. 영양제 섭취(유산균 비타민 등)\n'
    '11. 2주차: 24시간 간헐적 단식 주 1회 실시\n'
    '12. 3주차: 24시간 간헐적 단식 주 2회 실시. 연속 단식 금지\n'
    '13. 4주차: 24시간 간헐적 단식 주 3회 실시. 연속 단식 금지\n';
