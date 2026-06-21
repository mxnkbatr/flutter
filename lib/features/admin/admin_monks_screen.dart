import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/admin/models/admin_monk.dart';
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
  bool _reordering = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(adminMonkFilterProvider.notifier).state =
            _filters[_tabController.index];
        setState(() => _reordering = false);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _canReorder {
    final filter = ref.read(adminMonkFilterProvider);
    return filter == 'active' || filter == 'all';
  }

  Future<void> _onReorder(List<AdminMonk> monks, int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final updated = [...monks];
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    try {
      await reorderMonks(ref, updated.map((m) => m.id).toList());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(formatUserError(e))),
        );
      }
    }
  }

  Widget _buildList(List<AdminMonk> monks, String filter) {
    if (monks.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 80),
          Center(child: Text('Лам олдсонгүй', style: AppText.bodySmall)),
        ],
      );
    }

    if (_reordering && _canReorder) {
      return ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: monks.length,
        onReorder: (oldIndex, newIndex) => _onReorder(monks, oldIndex, newIndex),
        itemBuilder: (_, i) => AdminMonkCard(
          key: ValueKey(monks[i].id),
          monk: monks[i],
          showReorderHandle: true,
          reorderIndex: i,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: monks.length,
      itemBuilder: (_, i) => AdminMonkCard(
        key: ValueKey(monks[i].id),
        monk: monks[i],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(adminMonkFilterProvider);
    final monksAsync = ref.watch(adminMonksProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Лам нарын удирдлага'),
        actions: [
          if (_canReorder)
            IconButton(
              tooltip: _reordering ? 'Дуусгах' : 'Дараалал өөрчлөх',
              icon: Icon(_reordering ? Icons.check : Icons.swap_vert),
              onPressed: () => setState(() => _reordering = !_reordering),
            ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_reordering && _canReorder)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.sunLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Ламыг бариад чирж дарааллыг өөрчилнө. Дээрх ✓ дарж хадгална.',
                    style: AppText.caption.copyWith(color: AppColors.inkDeep),
                  ),
                ),
              Expanded(child: _buildList(monks, filter)),
            ],
          ),
        ),
      ),
    );
  }
}
