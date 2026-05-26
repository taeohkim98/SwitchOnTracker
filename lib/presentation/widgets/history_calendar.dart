// [파일 역할]
// 1~28일 기록을 달력/그리드 형태로 표시하는 위젯
// 각 Day 셀: 완료(초록), 일부(노란), 미체크(회색)로 색상 구분
// 셀 탭 시 해당 날의 상세 기록을 바텀시트로 표시

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/diet_plan.dart';
import '../../domain/entities/day_record.dart';
import '../../domain/entities/meal_type.dart';

/// 전체 28일 달력 그리드
class HistoryCalendar extends StatelessWidget {
  final List<DayRecord> records;  // 불러온 기록 (Day 1 ~ 현재)
  final int currentDay;           // 오늘이 몇 일차인지

  const HistoryCalendar({
    super.key,
    required this.records,
    required this.currentDay,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,       // 주 7일 기준
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: kTotalDays,
      itemBuilder: (context, index) {
        final day = index + 1;  // 1-indexed
        // 해당 Day의 기록 찾기 (없으면 미체크 초기 상태)
        final record = records.firstWhere(
          (r) => r.dayNumber == day,
          orElse: () => DayRecord.initial(
            day,
            DateTime.now().subtract(Duration(days: currentDay - day)),
          ),
        );
        final isPast    = day <= currentDay;
        final isToday   = day == currentDay;

        return _DayCell(
          day: day,
          record: record,
          isPast: isPast,
          isToday: isToday,
          onTap: isPast ? () => _showDayDetail(context, day, record) : null,
        );
      },
    );
  }

  /// 바텀시트로 해당 날의 식단 상세 기록 표시
  void _showDayDetail(BuildContext context, int day, DayRecord record) {
    final plan = getDayPlan(day);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DayDetailSheet(day: day, record: record, plan: plan),
    );
  }
}

/// 개별 Day 셀
class _DayCell extends StatelessWidget {
  final int day;
  final DayRecord record;
  final bool isPast;    // 지나간 날인지 (탭 가능 여부)
  final bool isToday;   // 오늘인지 (테두리 강조)
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.record,
    required this.isPast,
    required this.isToday,
    this.onTap,
  });

  /// 완료 상태에 따른 배경 색상
  Color get _bgColor {
    if (!isPast) return const Color(0xFFF5F5F5);      // 미래: 회색
    if (record.isAllChecked) return AppColors.primaryLight; // 완료: 연초록
    if (record.checkedCount > 0) return const Color(0xFFFFF8E1); // 일부: 연노랑
    return const Color(0xFFFBE9E7);                   // 미체크: 연빨강
  }

  /// 완료 상태 이모지
  String get _statusEmoji {
    if (!isPast) return '';
    if (record.isAllChecked) return '✅';
    if (record.checkedCount > 0) return '🟡';
    return '❌';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(10),
          border: isToday
              ? Border.all(color: AppColors.primary, width: 2)  // 오늘은 테두리 강조
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                color: isPast ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            if (isPast)
              Text(
                _statusEmoji,
                style: const TextStyle(fontSize: 14),
              ),
            if (isToday)
              const Text(
                '오늘',
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Day 상세 기록 바텀시트
class _DayDetailSheet extends StatelessWidget {
  final int day;
  final DayRecord record;
  final DayPlan plan;

  const _DayDetailSheet({
    required this.day,
    required this.record,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 핸들 바
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 타이틀
          Text(
            'Day $day 기록',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${record.date.year}.${record.date.month.toString().padLeft(2, '0')}.${record.date.day.toString().padLeft(2, '0')}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // 식단별 완료 여부
          for (final type in MealType.values)
            _MealRow(
              type: type,
              mealRecord: record.meal(type),
              menuDesc: _menuFor(type),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _menuFor(MealType type) {
    switch (type) {
      case MealType.breakfast: return plan.breakfast;
      case MealType.lunch:     return plan.lunch;
      case MealType.snack:     return plan.snack;
      case MealType.dinner:    return plan.dinner;
    }
  }
}

/// 바텀시트 내 식단 행
class _MealRow extends StatelessWidget {
  final MealType type;
  final dynamic mealRecord;
  final String menuDesc;

  const _MealRow({
    required this.type,
    required this.mealRecord,
    required this.menuDesc,
  });

  @override
  Widget build(BuildContext context) {
    final isChecked = mealRecord.isChecked as bool;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(type.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type.label,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                Text(menuDesc,
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          Icon(
            isChecked ? Icons.check_circle : Icons.cancel,
            color: isChecked ? AppColors.primary : Colors.red[200],
            size: 22,
          ),
        ],
      ),
    );
  }
}
