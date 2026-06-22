import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/features/monk_dash/tabs/bookings_tab.dart';
import 'package:sacred_app/features/monk_dash/tabs/dashboard_tab.dart';
import 'package:sacred_app/features/monk_dash/tabs/earnings_tab.dart';
import 'package:sacred_app/features/monk_dash/tabs/profile_tab.dart';
import 'package:sacred_app/features/monk_dash/tabs/schedule_tab.dart';
import 'package:sacred_app/features/monk_dash/widgets/availability_toggle.dart';
import 'package:sacred_app/features/monk_dash/widgets/monk_dash_header.dart';
import 'package:sacred_app/features/monk_dash/widgets/monk_tab_bar.dart';

class MonkDashboardScreen extends StatefulWidget {
  const MonkDashboardScreen({super.key, this.initialTab = 2});

  final int initialTab;

  @override
  State<MonkDashboardScreen> createState() => _MonkDashboardScreenState();
}

class _MonkDashboardScreenState extends State<MonkDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabLabels = [
    'Самбар',
    'Хуваарь',
    'Захиалга',
    'Орлого',
    'Профайл',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 4),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            controller: _tabController,
            labels: _tabLabels,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                DashboardTab(),
                ScheduleTab(),
                BookingsTab(),
                EarningsTab(),
                ProfileTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
