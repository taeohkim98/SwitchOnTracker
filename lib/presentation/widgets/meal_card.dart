// [파일 역할]
// 개별 식단(아침/점심/간식/저녁) 하나를 표시하는 카드 위젯
// - 메뉴 이름, 아이콘, 체크박스 표시
// - 탭 시 체크/언체크 토글

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/meal_type.dart';
import '../../domain/entities/meal_record.dart';

/// 단일 식단 카드
class MealCard extends StatelessWidget {
  final MealRecord record;       // 해당 식단의 체크 상태
  final String menuDescription;  // 메뉴 설명 (diet_plan.dart에서 가져온 텍스트)
  final VoidCallback onTap;      // 체크 토글 콜백

  const MealCard({
    super.key,
    required this.record,
    required this.menuDescription,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isChecked = record.isChecked;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isChecked
              ? AppColors.primaryLight  // 체크됨: 연한 초록 배경
              : AppColors.cardBg,       // 미체크: 흰색
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isChecked ? AppColors.checked : AppColors.unchecked,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 식단 아이콘 (이모지)
            Text(
              record.type.emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),

            // 식단 이름 + 메뉴 설명
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.type.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isChecked
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    menuDescription,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isChecked
                          ? AppColors.textPrimary
                          : AppColors.textPrimary,
                      decoration: isChecked
                          ? TextDecoration.lineThrough  // 체크 시 취소선
                          : null,
                      decorationColor: AppColors.textSecondary,
                    ),
                  ),
                  // 체크한 시각 표시
                  if (isChecked && record.checkedAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '${record.checkedAt!.hour.toString().padLeft(2, '0')}:'
                        '${record.checkedAt!.minute.toString().padLeft(2, '0')} 완료',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 체크박스 아이콘
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isChecked
                  ? const Icon(
                      Icons.check_circle,
                      color: AppColors.checked,
                      size: 28,
                      key: ValueKey('checked'),
                    )
                  : const Icon(
                      Icons.radio_button_unchecked,
                      color: AppColors.unchecked,
                      size: 28,
                      key: ValueKey('unchecked'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
