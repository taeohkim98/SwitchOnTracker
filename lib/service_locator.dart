// [파일 역할]
// 의존성 주입(DI) 설정 파일
// get_it 서비스 로케이터를 통해 앱 전체에서 사용할 객체들을 싱글톤으로 등록
// main.dart에서 앱 시작 시 setupServiceLocator()를 호출해야 함

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'data/datasources/hive_datasource.dart';
import 'data/datasources/notification_datasource.dart';
import 'data/repositories/program_repository_impl.dart';
import 'data/repositories/notification_repository_impl.dart';
import 'domain/repositories/program_repository.dart';
import 'domain/repositories/notification_repository.dart';
import 'domain/usecases/check_meal_usecase.dart';
import 'domain/usecases/export_data_usecase.dart';
import 'domain/usecases/import_data_usecase.dart';

/// 전역 서비스 로케이터 인스턴스
final sl = GetIt.instance;

/// 앱 시작 시 호출: 모든 의존성 등록
Future<void> setupServiceLocator() async {
  // ── 데이터 소스 (싱글톤) ──

  // Hive DB 접근 객체 (초기화 포함)
  final hiveDs = HiveDataSource();
  await hiveDs.init();
  sl.registerSingleton<HiveDataSource>(hiveDs);

  // 로컬 알림 플러그인 (main.dart에서 초기화한 인스턴스 재사용)
  final notifPlugin = FlutterLocalNotificationsPlugin();
  sl.registerSingleton<FlutterLocalNotificationsPlugin>(notifPlugin);
  sl.registerSingleton<NotificationDataSource>(
      NotificationDataSource(notifPlugin));

  // ── 저장소 (싱글톤) ──

  sl.registerSingleton<ProgramRepository>(
      ProgramRepositoryImpl(sl<HiveDataSource>()));

  sl.registerSingleton<NotificationRepository>(
      NotificationRepositoryImpl(sl<NotificationDataSource>()));

  // ── 유스케이스 (factory: 호출마다 새 인스턴스, 의존성은 싱글톤 재사용) ──

  sl.registerFactory(() => CheckMealUseCase(
        sl<ProgramRepository>(),
        sl<NotificationRepository>(),
      ));

  sl.registerFactory(() => ExportDataUseCase(sl<ProgramRepository>()));

  sl.registerFactory(() => ImportDataUseCase(
        sl<ProgramRepository>(),
        sl<NotificationRepository>(),
      ));
}
