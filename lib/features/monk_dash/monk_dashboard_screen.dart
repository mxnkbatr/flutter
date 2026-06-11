import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/monk_dash/tabs/bookings_tab.dart';
import 'package:sacred_app/features/monk_dash/tabs/dashboard_tab.dart';
import 'package:sacred_app/features/monk_dash/tabs/earnings_tab.dart';
import 'package:sacred_app/features/monk_dash/tabs/profile_tab.dart';
import 'package:sacred_app/features/monk_dash/tabs/schedule_tab.dart';
import 'package:sacred_app/features/monk_dash/widgets/availability_toggle.dart';
import 'package:sacred_app/features/monk_dash/widgets/monk_dash_header.dart';

class MonkDashboardScreen extends StatefulWidget {
  const MonkDashboardScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<MonkDashboardScreen> createState() => _MonkDashboardScreenState();
}

class _MonkDashboardScreenState extends State<MonkDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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
      backgroundColor: AppColors.surface,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            backgroundColor: AppColors.inkDeep,
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Самбар',
                style: AppText.h3.copyWith(color: AppColors.goldPrime),
              ),
              background: const MonkDashHeader(),
            ),
            actions: const [
              AvailabilityToggle(),
              SizedBox(width: 8),
            ],
          ),
        ],
        body: Column(
          children: [
            Container(
              color: AppColors.inkDeep,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppColors.goldPrime,
                indicatorWeight: 2,
                labelColor: AppColors.goldPrime,
                unselectedLabelColor: AppColors.goldMuted,
                tabs: const [
                  Tab(text: 'Самбар'),
                  Tab(text: 'Хуваарь'),
                  Tab(text: 'Захиалга'),
                  Tab(text: 'Орлого'),
                  Tab(text: 'Профайл'),
                ],
              ),
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
      ),
    );
  }
}
