// [파일 역할]
// 설정 화면 — 알림 ON/OFF + 데이터 내보내기/가져오기(폰 교체 대비)
// 가져오기 버튼: 로컬에 저장된 JSON 백업 파일을 불러와 DB 복원

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/repositories/program_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../service_locator.dart';
import '../blocs/settings/settings_cubit.dart';

/// 설정 화면
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(
        sl<ProgramRepository>(),
        sl<NotificationRepository>(),
        sl(),  // ExportDataUseCase
        sl(),  // ImportDataUseCase
      )..load(),
      child: const _SettingsBody(),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: BlocConsumer<SettingsCubit, SettingsState>(
        // 결과 메시지 스낵바 표시
        listener: (context, state) {
          if (state is SettingsActionResult) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: state.isSuccess ? AppColors.primary : Colors.red,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
            // 결과 확인 후 Loaded 상태로 복귀
            context.read<SettingsCubit>().clearResult();
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SettingsError) {
            return Center(child: Text(state.message));
          }

          // config 추출 (모든 비-Loading/Error 상태에서 가능)
          final config = switch (state) {
            SettingsLoaded(:final config)        => config,
            SettingsExporting(:final config)     => config,
            SettingsImporting(:final config)     => config,
            SettingsActionResult(:final config)  => config,
            _ => null,
          };
          if (config == null) return const SizedBox.shrink();

          final isExporting = state is SettingsExporting;
          final isImporting = state is SettingsImporting;

          return ListView(
            children: [
              const SizedBox(height: 8),

              // ── 알림 설정 섹션 ──
              _SectionHeader(title: '알림'),
              _SettingsTile(
                leading: const Icon(Icons.notifications_outlined,
                    color: AppColors.primary),
                title: '식단 알림',
                subtitle: '체크 후 5시간 45분, 6시간 30분에 알림',
                trailing: Switch(
                  value: config.notificationsEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (_) =>
                      context.read<SettingsCubit>().toggleNotifications(),
                ),
              ),

              const SizedBox(height: 8),

              // ── 데이터 관리 섹션 ──
              _SectionHeader(title: '데이터 관리'),

              // 내보내기 버튼
              _SettingsTile(
                leading: const Icon(Icons.upload_outlined,
                    color: AppColors.primary),
                title: '데이터 내보내기',
                subtitle: '기록을 클립보드에 복사 → 메모장에 붙여넣기로 보관',
                trailing: isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right,
                        color: AppColors.textSecondary),
                onTap: isExporting
                    ? null
                    : () => context.read<SettingsCubit>().exportData(),
              ),

              // ── 가져오기 버튼 (핵심: 폰 교체 시 복원) ──
              _SettingsTile(
                leading: const Icon(Icons.download_outlined,
                    color: AppColors.accent),
                title: '데이터 가져오기',
                subtitle: '저장된 백업 파일로 기록 복원 (새 폰에서 사용)',
                trailing: isImporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right,
                        color: AppColors.textSecondary),
                onTap: isImporting
                    ? null
                    : () => _confirmImport(context),
              ),

              const SizedBox(height: 8),

              // ── 프로그램 정보 ──
              _SectionHeader(title: '프로그램 정보'),
              _InfoTile(
                label: '시작일',
                value:
                    '${config.startDate.year}.${config.startDate.month.toString().padLeft(2, '0')}.${config.startDate.day.toString().padLeft(2, '0')}',
              ),
              _InfoTile(
                label: '현재',
                value: 'Day ${config.currentDay} / 28',
              ),

              const SizedBox(height: 32),

              // 사용법 안내
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _UsageGuide(),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 데이터 가져오기 전 경고 다이얼로그
  /// 기존 데이터가 완전히 덮어씌워지므로 확인 필요
  void _confirmImport(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('데이터 가져오기'),
        content: const Text(
          '⚠️ 현재 기기의 모든 기록이 백업 파일의 내용으로\n'
          '완전히 교체됩니다.\n\n'
          '계속 진행하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<SettingsCubit>().importData();
            },
            child: const Text('가져오기'),
          ),
        ],
      ),
    );
  }
}

// ── 설정 화면 공통 위젯들 ──

/// 섹션 구분 헤더
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// 설정 항목 타일
class _SettingsTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// 읽기 전용 정보 타일
class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 14)),
        ],
      ),
    );
  }
}

/// 데이터 이전 사용법 안내 박스
class _UsageGuide extends StatelessWidget {
  const _UsageGuide();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF90CAF9)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📱 폰 교체 시 데이터 이전 방법',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF1565C0),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '① 이전 폰: 설정 → 데이터 내보내기 탭\n'
            '   → JSON이 클립보드에 복사됨\n'
            '   → 메모장 앱에 붙여넣기 후 저장\n\n'
            '② 새 폰으로 전송: 카카오톡·메시지로\n'
            '   메모 내용 전송\n\n'
            '③ 새 폰: 앱 설치 후 설정 → 데이터 가져오기\n'
            '   → JSON 파일 선택\n\n'
            '✅ 완료! 기록이 새 폰에 복원됩니다.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF1565C0),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
