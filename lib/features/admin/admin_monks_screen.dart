import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/admin/providers/admin_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/features/admin/widgets/admin_monk_card.dart';

class AdminMonksScreen extends ConsumerStatefulWidget {
  const AdminMonksScreen({super.key});

  @override
  ConsumerState<AdminMonksScreen> createState() => _AdminMonksScreenState();
}

class _AdminMonksScreenState extends ConsumerState<AdminMonksScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  static const _filters = ['all', 'pending', 'active', 'blocked'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(adminMonkFilterProvider.notifier).state =
            _filters[_tabController.index];
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(adminMonkFilterProvider);
    final monksAsync = ref.watch(adminMonksProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Лам нарын удирдлага'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/admin/monks/add'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.goldPrime,
          labelColor: AppColors.goldPrime,
          unselectedLabelColor: AppColors.goldMuted,
          tabs: const [
            Tab(text: 'Бүгд'),
            Tab(text: 'Хүлээгдэж буй'),
            Tab(text: 'Идэвхтэй'),
            Tab(text: 'Хаагдсан'),
          ],
        ),
      ),
      body: monksAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.goldPrime),
        ),
        error: (e, _) => Center(child: Text(formatUserError(e))),
        data: (monks) => RefreshIndicator(
          color: AppColors.goldPrime,
          onRefresh: () => ref.refresh(adminMonksProvider(filter).future),
          child: monks.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 80),
                    Center(child: Text('Лам олдсонгүй', style: AppText.bodySmall)),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: monks.length,
                  itemBuilder: (_, i) => AdminMonkCard(monk: monks[i]),
                ),
        ),
      ),
    );
  }
}
