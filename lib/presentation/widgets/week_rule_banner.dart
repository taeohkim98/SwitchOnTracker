// [파일 역할]
// 현재 일차의 주차별 주의사항을 표시하는 배너 위젯
// diet_plan.dart의 weeklyNote 텍스트를 상단에 강조 표시

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// 주차별 주의사항 배너
class WeekRuleBanner extends StatelessWidget {
  final String note;  // diet_plan.dart의 weeklyNote 값

  const WeekRuleBanner({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),  // 연한 노란색 배경
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFE082), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF5D4037),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
