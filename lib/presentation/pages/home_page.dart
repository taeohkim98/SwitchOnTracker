// [파일 역할]
// 앱의 메인 화면 — 하단 탭으로 "오늘" / "기록" 두 탭을 전환
// 각 탭은 BLoC Cubit으로 독립적으로 상태 관리

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/diet_plan.dart';
import '../../domain/entities/meal_type.dart';
import '../../domain/repositories/program_repository.dart';
import '../../service_locator.dart';
import '../blocs/today/today_cubit.dart';
import '../blocs/today/today_state.dart';
import '../blocs/history/history_cubit.dart';
import '../widgets/meal_card.dart';
import '../widgets/week_rule_banner.dart';
import '../widgets/day_progress_bar.dart';
import '../widgets/history_calendar.dart';
import '../widgets/completion_overlay.dart';
import 'settings_page.dart';

/// 메인 홈 화면 (탭 포함)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0;  // 0: 오늘, 1: 기록

  /// 꼭 지켜야 할 규칙 BottomSheet 표시
  void _showRulesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _RulesSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => TodayCubit(
            sl<ProgramRepository>(),
            sl(),
          )..load(),
        ),
        BlocProvider(
          create: (_) => HistoryCubit(sl<ProgramRepository>())..load(),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Switch-On Diet',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            // ⓘ 아이콘: 꼭 지켜야 할 규칙 보기
            IconButton(
              icon: const Icon(Icons.info_outline, color: AppColors.textSecondary),
              tooltip: '꼭 지켜야 할 규칙',
              onPressed: () => _showRulesSheet(context),
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: AppColors.textSecondary),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ).then((_) {
                // 설정에서 돌아왔을 때 데이터 새로고침 (import 대응)
                if (mounted) {
                  context.read<TodayCubit>().load();
                  context.read<HistoryCubit>().load();
                }
              }),
            ),
          ],
        ),
        body: IndexedStack(
          index: _tabIndex,
          children: const [
            _TodayTab(),
            _HistoryTab(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tabIndex,
          onDestinationSelected: (i) => setState(() => _tabIndex = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.today_outlined),
              selectedIcon: Icon(Icons.today),
              label: '오늘',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: '기록',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// 오늘 탭
// ─────────────────────────────────────────

/// 오늘의 식단 체크리스트 탭
class _TodayTab extends StatelessWidget {
  const _TodayTab();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodayCubit, TodayState>(
      // listener: 상태 변화에 따른 부수 효과 (오버레이 표시 등)
      listener: (context, state) {
        if (state is TodayLoaded && state.showReward) {
          _showCompletionOverlay(context, state.dayRecord.dayNumber);
        }
      },
      builder: (context, state) {
        return switch (state) {
          TodayLoading()          => const Center(child: CircularProgressIndicator()),
          TodayError(:final message) => _ErrorView(message: message),
          TodayNotStarted(:final startDate) => _NotStartedView(startDate: startDate),
          TodayProgramCompleted() => const _ProgramCompletedView(),
          TodayLoaded(:final config, :final dayRecord) => _buildContent(
              context, config, dayRecord),
        };
      },
    );
  }

  /// 메인 식단 체크리스트 뷰
  Widget _buildContent(BuildContext context, config, dayRecord) {
    final plan = getDayPlan(dayRecord.dayNumber);
    final cubit = context.read<TodayCubit>();

    return RefreshIndicator(
      onRefresh: () => cubit.load(),
      child: ListView(
        children: [
          // ── Day 헤더 ──
          _DayHeader(
            dayNumber: dayRecord.dayNumber,
            date: dayRecord.date,
          ),

          // ── 주차별 주의사항 배너 ──
          WeekRuleBanner(note: plan.weeklyNote),

          // ── 1~3일차: 4일차로 이동 배너 ──
          if (dayRecord.dayNumber <= 3)
            _SkipToDay4Banner(
              onSkip: () => _showSkipConfirmDialog(context, cubit),
            ),

          // ── 진행도 바 ──
          DayProgressBar(checked: dayRecord.checkedCount),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              '식단 체크리스트',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // ── 4개 식단 카드 ──
          for (final type in MealType.values)
            MealCard(
              record: dayRecord.meal(type),
              menuDescription: _menuFor(plan, type),
              onTap: () => cubit.toggleMeal(type),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// 4일차로 이동 확인 다이얼로그
  void _showSkipConfirmDialog(BuildContext context, TodayCubit cubit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('4일차로 넘어가기'),
        content: const Text(
          '1~3일차를 건너뛰고 4일차로 이동합니다.\n'
          '(시작일이 오늘 기준 3일 전으로 자동 조정됩니다)\n\n'
          '계속하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              cubit.skipToDay4();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('4일차로 이동'),
          ),
        ],
      ),
    );
  }

  /// DayPlan에서 해당 식단 메뉴 텍스트 추출
  String _menuFor(DayPlan plan, MealType type) {
    switch (type) {
      case MealType.breakfast: return plan.breakfast;
      case MealType.lunch:     return plan.lunch;
      case MealType.snack:     return plan.snack;
      case MealType.dinner:    return plan.dinner;
    }
  }

  /// 폭죽 오버레이를 전체화면 다이얼로그로 표시
  void _showCompletionOverlay(BuildContext context, int dayNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (_) => CompletionOverlay(
        dayNumber: dayNumber,
        onDismiss: () {
          Navigator.of(context).pop();
          // DB에 보상 표시 완료 기록
          context.read<TodayCubit>().markRewardShown();
        },
      ),
    );
  }
}

/// Day 번호 + 날짜 헤더
class _DayHeader extends StatelessWidget {
  final int dayNumber;
  final DateTime date;

  const _DayHeader({required this.dayNumber, required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Day $dayNumber',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            '$dayNumber / 28일',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// 기록 탭
// ─────────────────────────────────────────

/// 전체 28일 달력 기록 탭
class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        return switch (state) {
          HistoryLoading()  => const Center(child: CircularProgressIndicator()),
          HistoryError(:final message) => _ErrorView(message: message),
          HistoryLoaded(:final config, :final records, :final completedDays) =>
            Column(
              children: [
                // 완료율 요약
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events,
                          color: AppColors.accent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '$completedDays / 28일 완료',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(completedDays / 28 * 100).round()}%',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: HistoryCalendar(
                    records: records,
                    currentDay: config.currentDay,
                  ),
                ),
              ],
            ),
        };
      },
    );
  }
}

// ─────────────────────────────────────────
// 공통 상태 위젯
// ─────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<TodayCubit>().load(),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}

/// 프로그램 시작 전 카운트다운 뷰
class _NotStartedView extends StatelessWidget {
  final DateTime startDate;
  const _NotStartedView({required this.startDate});

  @override
  Widget build(BuildContext context) {
    final daysLeft = startDate
        .difference(DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day))
        .inDays;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📅', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'D-$daysLeft',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${startDate.month}월 ${startDate.day}일에 시작합니다!',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 28일 프로그램 완전 완료 뷰
class _ProgramCompletedView extends StatelessWidget {
  const _ProgramCompletedView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🏆', style: TextStyle(fontSize: 72)),
          SizedBox(height: 16),
          Text(
            '28일 프로그램 완료!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '축하합니다! 끝까지 해내셨습니다.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// 1~3일차 4일차 이동 배너
// ─────────────────────────────────────────

/// 1~3일차에만 표시되는 "4일차로 넘어가기" 배너
class _SkipToDay4Banner extends StatelessWidget {
  final VoidCallback onSkip;
  const _SkipToDay4Banner({required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFE65100),
            size: 20,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              '금단증상(두통, 무기력감)이 심하면\n4일차로 바로 넘어갈 수 있습니다.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF4E342E),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFE65100),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '4일차로\n이동',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// 꼭 지켜야 할 규칙 BottomSheet
// ─────────────────────────────────────────

/// ⓘ 아이콘 클릭 시 표시되는 규칙 BottomSheet
class _RulesSheet extends StatelessWidget {
  const _RulesSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, scrollController) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 드래그 핸들
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // 제목
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.rule_rounded, color: AppColors.primary, size: 22),
                SizedBox(width: 8),
                Text(
                  '꼭 지켜야 할 규칙',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 20, indent: 20, endIndent: 20),
          // 규칙 내용 (스크롤 가능)
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: const Text(
                kDietRules,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.9,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
