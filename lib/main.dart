// [파일 역할]
// 앱 진입점 (entry point)
// 앱 실행 전 필요한 모든 초기화를 순서대로 처리:
// 1. Flutter 엔진 초기화
// 2. Hive 로컬 DB 초기화 및 박스 열기
// 3. 로컬 알림 플러그인 초기화 및 Android 채널 생성
// 4. 의존성 주입(DI) 설정
// 5. 앱 실행

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'app.dart';
import 'service_locator.dart';
import 'core/constants/app_constants.dart';

void main() async {
  // Flutter 엔진과 플랫폼 채널 바인딩 초기화
  // (async main에서 플랫폼 API 호출 전 반드시 필요)
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. timezone 초기화 (zonedSchedule에 필요) ──
  tz.initializeTimeZones();

  // ── 2. Hive 초기화 ──
  // 앱 문서 디렉토리에 Hive DB 파일 생성
  await Hive.initFlutter();
  // Hive는 String 타입 Box를 기본 지원하므로 별도 어댑터 불필요

  // ── 3. 로컬 알림 초기화 ──
  await _initNotifications();

  // ── 4. 의존성 주입 설정 ──
  await setupServiceLocator();

  // ── 5. 앱 실행 ──
  runApp(const SwitchOnDietApp());
}

/// 로컬 알림 플러그인 초기화
Future<void> _initNotifications() async {
  final plugin = FlutterLocalNotificationsPlugin();

  // Android 설정: 앱 아이콘을 알림 아이콘으로 사용
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS 설정: 앱 실행 시 권한 자동 요청하지 않음 (OnboardingPage에서 요청)
  const iosInit = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  const initSettings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );

  await plugin.initialize(initSettings);

  // Android 8.0+ 필수: 알림 채널 생성
  const channel = AndroidNotificationChannel(
    NotifChannel.id,
    NotifChannel.name,
    description: NotifChannel.description,
    importance: Importance.high,
  );

  await plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}
