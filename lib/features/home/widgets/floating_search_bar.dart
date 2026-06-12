import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/home/providers/monks_provider.dart';

class FloatingSearchBar extends ConsumerStatefulWidget {
  const FloatingSearchBar({super.key});

  @override
  ConsumerState<FloatingSearchBar> createState() => _FloatingSearchBarState();
}

class _FloatingSearchBarState extends ConsumerState<FloatingSearchBar> {
  final _controller = TextEditingController();
  bool _expanded = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceEl,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.inkDeep.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppGradients.sun,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.search_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              onTap: () => setState(() => _expanded = true),
              onChanged: (v) =>
                  ref.read(monkSearchQueryProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Лам хайх...',
                hintStyle: AppText.bodySmall.copyWith(color: AppColors.textHint),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ),
          if (_expanded && _controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                _controller.clear();
                ref.read(monkSearchQueryProvider.notifier).state = '';
                setState(() => _expanded = false);
              },
            ),
        ],
      ),
    );
  }
}
