import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/auth/tier_provider.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/monk_dash/providers/monk_profile_edit_provider.dart';
import 'package:sacred_app/features/monk_dash/widgets/availability_toggle.dart';
import 'package:sacred_app/shared/widgets/ios_grouped_section.dart';
import 'package:sacred_app/shared/widgets/profile_image_picker.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';
import 'package:sacred_app/shared/widgets/sacred_input.dart';

const _categoryOptions = ['Ерөөл', 'Зурхай', 'Тахилга', 'Номын тайлбар'];

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  final _nameCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _templeCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _selectedCategories = <String>{};
  List<MonkServiceDraft> _services = [];
  String? _imageUrl;
  bool _saving = false;
  bool _loaded = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _titleCtrl.dispose();
    _templeCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _loadFromProfile(MonkProfileData profile) {
    if (_loaded) return;
    _loaded = true;
    _nameCtrl.text = profile.name;
    _titleCtrl.text = profile.title;
    _templeCtrl.text = profile.temple;
    _bioCtrl.text = profile.bio;
    _imageUrl = profile.image;
    _selectedCategories
      ..clear()
      ..addAll(profile.categories);
    _services = profile.services
        .map(
          (s) => MonkServiceDraft(
            name: s.name,
            description: s.description,
            durationMinutes: s.durationMinutes,
            price: s.price,
            category: s.category,
          ),
        )
        .toList();
    if (_services.isEmpty) {
      _services.add(MonkServiceDraft(name: 'Ерөөл', category: 'Ерөөл', price: 50000));
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      await saveMonkProfile(ref, {
        'name': _nameCtrl.text.trim(),
        'title': _titleCtrl.text.trim(),
        'temple': _templeCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'categories': _selectedCategories.toList(),
        if (_imageUrl != null) 'image': _imageUrl,
      });
      await saveMonkServices(ref, _services.where((s) => s.name.trim().isNotEmpty).toList());
      await ref.read(apiClientProvider).put('/users/profile', data: {
        'name': _nameCtrl.text.trim(),
      });
      await ref.read(authStateProvider.notifier).refreshProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профайл хадгалагдлаа')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Алдаа гарлаа, дахин оролдоно уу')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addService() {
    setState(() => _services.add(MonkServiceDraft()));
  }

  void _removeService(int index) {
    if (_services.length <= 1) return;
    setState(() => _services.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider).valueOrNull;
    final tier = ref.watch(userTierProvider);
    final profileAsync = ref.watch(monkProfileEditProvider);

    return profileAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.goldPrime),
      ),
      error: (e, _) => Center(child: Text(formatUserError(e))),
      data: (profile) {
        _loadFromProfile(profile);
        return ListView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 100,
          ),
          children: [
            Container(
              color: AppColors.inkDeep,
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Column(
                children: [
                  ProfileImagePicker(
                    imageUrl: _imageUrl,
                    label: 'Профайл зураг',
                    onImageChanged: (url) => setState(() => _imageUrl = url),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _nameCtrl.text.isNotEmpty ? _nameCtrl.text : (auth?.userName ?? ''),
                    style: AppText.h2.copyWith(color: AppColors.onDark),
                  ),
                  Text(
                    'Лам · ${tierLabel(tier)}',
                    style: AppText.bodySmall.copyWith(color: AppColors.goldMuted),
                  ),
                  if (profile.email.isNotEmpty)
                    Text(
                      profile.email,
                      style: AppText.caption.copyWith(color: AppColors.goldMuted),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AvailabilityToggle(),
            ),
            const SizedBox(height: 20),
            IosGroupedSection(
              title: 'Профайл мэдээлэл',
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SacredInput(
                        label: 'Нэр',
                        controller: _nameCtrl,
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 12),
                      SacredInput(
                        label: 'Цол',
                        controller: _titleCtrl,
                        prefixIcon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 12),
                      SacredInput(
                        label: 'Хийд / Сүм',
                        controller: _templeCtrl,
                        prefixIcon: Icons.temple_buddhist_outlined,
                      ),
                      const SizedBox(height: 12),
                      SacredInput(
                        label: 'Танилцуулга',
                        controller: _bioCtrl,
                        prefixIcon: Icons.notes_outlined,
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            IosGroupedSection(
              title: 'Үйлчилгээний төрөл',
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categoryOptions.map((cat) {
                      final selected = _selectedCategories.contains(cat);
                      return FilterChip(
                        label: Text(cat),
                        selected: selected,
                        selectedColor: AppColors.sunLight,
                        checkmarkColor: AppColors.sunGold,
                        onSelected: (v) {
                          setState(() {
                            if (v) {
                              _selectedCategories.add(cat);
                            } else {
                              _selectedCategories.remove(cat);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            IosGroupedSection(
              title: 'Үйлчилгээнүүд',
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ..._services.asMap().entries.map((entry) {
                        final i = entry.key;
                        final s = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text('Үйлчилгээ ${i + 1}', style: AppText.body),
                                  const Spacer(),
                                  if (_services.length > 1)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: AppColors.danger,
                                        size: 20,
                                      ),
                                      onPressed: () => _removeService(i),
                                    ),
                                ],
                              ),
                              TextFormField(
                                initialValue: s.name,
                                decoration: const InputDecoration(
                                  labelText: 'Нэр',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (v) => s.name = v,
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                initialValue: s.description,
                                decoration: const InputDecoration(
                                  labelText: 'Тайлбар',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (v) => s.description = v,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: '${s.price}',
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Үнэ (₮)',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (v) =>
                                          s.price = int.tryParse(v) ?? s.price,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: '${s.durationMinutes}',
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Минут',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (v) => s.durationMinutes =
                                          int.tryParse(v) ?? s.durationMinutes,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: s.category.isEmpty ? _categoryOptions.first : s.category,
                                decoration: const InputDecoration(
                                  labelText: 'Ангилал',
                                  border: OutlineInputBorder(),
                                ),
                                items: _categoryOptions
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => s.category = v ?? s.category),
                              ),
                            ],
                          ),
                        );
                      }),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _addService,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Үйлчилгээ нэмэх'),
                        ),
                      ),
                      SacredButton(
                        label: 'Бүгдийг хадгалах',
                        isLoading: _saving,
                        onTap: _saveProfile,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            IosGroupedSection(
              title: 'Тохиргоо',
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.star_outline_rounded,
                    color: AppColors.goldPrime,
                  ),
                  title: const Text('Premium багц'),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSec,
                  ),
                  onTap: () => context.push('/subscription'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            IosGroupedSection(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.danger,
                  ),
                  title: Text(
                    'Гарах',
                    style: AppText.body.copyWith(color: AppColors.danger),
                  ),
                  onTap: () => ref.read(authStateProvider.notifier).logout(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
