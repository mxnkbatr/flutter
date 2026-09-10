import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/features/monk_dash/providers/monk_dashboard_provider.dart';
import 'package:sacred_app/features/monk_dash/tabs/bookings_tab.dart';
import 'package:sacred_app/features/monk_dash/tabs/dashboard_tab.dart';
import 'package:sacred_app/features/monk_dash/tabs/earnings_tab.dart';
import 'package:sacred_app/features/monk_dash/tabs/profile_tab.dart';
import 'package:sacred_app/features/monk_dash/tabs/schedule_tab.dart';
import 'package:sacred_app/features/monk_dash/widgets/availability_toggle.dart';
import 'package:sacred_app/features/monk_dash/widgets/monk_dash_header.dart';
import 'package:sacred_app/features/monk_dash/widgets/monk_tab_bar.dart';

class MonkDashboardScreen extends ConsumerStatefulWidget {
  const MonkDashboardScreen({super.key, this.initialTab = 2});

  final int initialTab;

  @override
  ConsumerState<MonkDashboardScreen> createState() =>
      _MonkDashboardScreenState();
}

class _MonkDashboardScreenState extends ConsumerState<MonkDashboardScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool? _hideEarnings;

  static const _allLabels = [
    'Самбар',
    'Хуваарь',
    'Захиалга',
    'Орлого',
    'Профайл',
  ];

  static const _specialLabels = [
    'Самбар',
    'Хуваарь',
    'Захиалга',
    'Профайл',
  ];

  /// Query tab index → visible tab index when Орлого нуугдсан.
  static int _mapTab(int requested, bool hideEarnings) {
    if (!hideEarnings) return requested.clamp(0, 4);
    // 0 самбар, 1 хуваарь, 2 захиалга, 3 орлого→захиалга, 4 профайл→3
    if (requested == 3) return 2;
    if (requested >= 4) return 3;
    return requested.clamp(0, 3);
  }

  void _ensureController(bool hideEarnings) {
    if (_tabController != null && _hideEarnings == hideEarnings) return;
    final length = hideEarnings ? 4 : 5;
    final index = _mapTab(widget.initialTab, hideEarnings);
    _tabController?.dispose();
    _tabController = TabController(
      length: length,
      vsync: this,
      initialIndex: index.clamp(0, length - 1),
    );
    _hideEarnings = hideEarnings;
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hideEarnings =
        ref.watch(monkDashboardProvider).valueOrNull?.isSpecial ?? false;
    _ensureController(hideEarnings);

    final labels = hideEarnings ? _specialLabels : _allLabels;
    final tabs = hideEarnings
        ? const <Widget>[
            DashboardTab(),
            ScheduleTab(),
            BookingsTab(),
            ProfileTab(),
          ]
        : const <Widget>[
            DashboardTab(),
            ScheduleTab(),
            BookingsTab(),
            EarningsTab(),
            ProfileTab(),
          ];

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: MonkDashHeader(
              trailing: const AvailabilityToggle(compact: true),
            ),
          ),
          MonkTabBar(
            controller: _tabController!,
            labels: labels,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController!,
              children: tabs,
            ),
          ),
        ],
      ),
    );
  }
}
