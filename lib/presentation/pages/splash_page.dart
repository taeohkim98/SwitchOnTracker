// [파일 역할]
// 앱 최초 실행 시 나타나는 스플래시 화면
// - 저장된 설정이 있으면 → 홈 화면으로 이동
// - 없으면 → 온보딩(날짜 설정) 화면으로 이동

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/repositories/program_repository.dart';
import '../../service_locator.dart';
import 'onboarding_page.dart';
import 'home_page.dart';

/// 앱 스플래시 & 라우팅 화면
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAndNavigate();
  }

  /// 저장된 설정 확인 후 적절한 화면으로 이동
  Future<void> _checkAndNavigate() async {
    // 로고가 잠깐 보이도록 약간의 딜레이
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final repo = sl<ProgramRepository>();
    final config = await repo.loadConfig();

    if (!mounted) return;

    if (config == null) {
      // 최초 실행 → 시작일 설정 화면
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
      );
    } else {
      // 기존 사용자 → 홈 화면
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '💪',
              style: TextStyle(fontSize: 72),
            ),
            SizedBox(height: 16),
            Text(
              'Switch-On Diet',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '28일 다이어트 프로그램',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
