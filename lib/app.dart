// [파일 역할]
// MaterialApp 루트 위젯 정의
// 테마 적용, 초기 화면(SplashPage) 설정, 한국어 로케일 설정

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/splash_page.dart';

/// 앱 루트 위젯
class SwitchOnDietApp extends StatelessWidget {
  const SwitchOnDietApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Switch-On Diet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // 한국어 날짜 포맷 지원 (DatePicker에서 "월", "일" 등 한글로 표시)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('ko', 'KR'),

      home: const SplashPage(),
    );
  }
}
