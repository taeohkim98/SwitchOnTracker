// [파일 역할]
// 하루 식단을 모두 완료했을 때 전체화면으로 표시되는 폭죽 축하 위젯
// confetti 패키지를 사용하여 파티클 애니메이션 구현
// 확인 버튼을 누르면 overlay가 사라지고 DB에 "보상 표시 완료" 저장

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// 하루 완료 축하 오버레이
class CompletionOverlay extends StatefulWidget {
  final int dayNumber;         // 완료한 Day 번호
  final VoidCallback onDismiss; // 확인 버튼 콜백

  const CompletionOverlay({
    super.key,
    required this.dayNumber,
    required this.onDismiss,
  });

  @override
  State<CompletionOverlay> createState() => _CompletionOverlayState();
}

class _CompletionOverlayState extends State<CompletionOverlay> {
  late final ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    // 폭죽 컨트롤러: 3초간 지속
    _controller = ConfettiController(duration: const Duration(seconds: 3));
    _controller.play();  // 위젯 생성 즉시 폭죽 발사
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // 반투명 배경
        GestureDetector(
          onTap: () {}, // 배경 탭으로 닫히지 않도록 막음
          child: Container(
            color: Colors.black.withOpacity(0.6),
            width: double.infinity,
            height: double.infinity,
          ),
        ),

        // 폭죽 파티클 (화면 상단 중앙에서 발사)
        ConfettiWidget(
          confettiController: _controller,
          blastDirectionality: BlastDirectionality.explosive,
          numberOfParticles: 30,
          gravity: 0.3,
          emissionFrequency: 0.05,
          colors: const [
            AppColors.primary,
            AppColors.accent,
            Colors.yellow,
            Colors.blue,
            Colors.purple,
          ],
        ),

        // 중앙 카드
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                Text(
                  'Day ${widget.dayNumber} 완료!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '오늘 식단을 모두 지켰습니다!\n내일도 파이팅! 💪',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onDismiss,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
