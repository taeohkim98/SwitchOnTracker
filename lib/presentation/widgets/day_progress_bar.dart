// [파일 역할]
// 오늘 4개 식단 중 몇 개 완료했는지 진행도를 표시하는 위젯
// 하단에 "N/4 완료" 텍스트와 프로그레스 바 표시

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// 식단 진행도 표시 바
class DayProgressBar extends StatelessWidget {
  final int checked;  // 체크된 식단 수 (0~4)
  final int total;    // 전체 식단 수 (항상 4)

  const DayProgressBar({
    super.key,
    required this.checked,
    this.total = 4,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? checked / total : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '오늘 진행도',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$checked / $total 완료',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: checked == total
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.unchecked,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
