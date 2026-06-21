import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/admin/models/admin_monk_detail.dart';
import 'package:sacred_app/features/admin/providers/admin_providers.dart';
import 'package:sacred_app/shared/widgets/profile_image_picker.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';
import 'package:sacred_app/shared/widgets/sacred_input.dart';

const _categoryOptions = ['Ерөөл', 'Зурхай', 'Тахилга', 'Номын тайлбар'];

class AdminEditMonkScreen extends ConsumerStatefulWidget {
  const AdminEditMonkScreen({super.key, required this.monkId});

  final String monkId;

  @override
  ConsumerState<AdminEditMonkScreen> createState() =>
      _AdminEditMonkScreenState();
}

class _AdminEditMonkScreenState extends ConsumerState<AdminEditMonkScreen> {
  final _nameCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _templeCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _selectedCategories = <String>{};
  List<AdminMonkServiceItem> _services = [];
  String? _imageUrl;
  String _status = 'active';
  String _email = '';
  bool _isSpecial = false;
  bool _loaded = false;
  bool _saving = false;
  bool _deleting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _titleCtrl.dispose();
    _templeCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _load(AdminMonkDetail detail) {
    if (_loaded) return;
    _loaded = true;
    _nameCtrl.text = detail.name;
    _titleCtrl.text = detail.title;
    _templeCtrl.text = detail.temple;
    _bioCtrl.text = detail.bio;
    _email = detail.email;
    _imageUrl = detail.image;
    _status = detail.status;
    _isSpecial = detail.isSpecial;
    _selectedCategories
      ..clear()
      ..addAll(detail.categories);
    _services = detail.services
        .map(
          (s) => AdminMonkServiceItem(
            name: s.name,
            description: s.description,
            durationMinutes: s.durationMinutes,
            price: s.price,
            category: s.category,
          ),
        )
        .toList();
    if (_services.isEmpty) {
      _services.add(AdminMonkServiceItem(name: 'Ерөөл', category: 'Ерөөл', price: 50000));
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нэр заавал')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await updateMonk(ref, widget.monkId, {
        'name': _nameCtrl.text.trim(),
        'title': _titleCtrl.text.trim(),
        'temple': _templeCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'categories': _selectedCategories.toList(),
        'services': _services
            .where((s) => s.name.trim().isNotEmpty)
            .map((s) => s.toJson())
            .toList(),
        'status': _status,
        'isSpecial': _isSpecial,
        if (_imageUrl != null) 'image': _imageUrl,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Хадгалагдлаа')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(formatUserError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ламын бүртгэл устгах уу?'),
        content: Text(
          '${_nameCtrl.text.trim()} ламын бүртгэл, нэвтрэх эрх болон холбогдох мэдээлэл бүрмөсөн устгагдана.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Үгүй'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Устгах',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await deleteMonk(ref, widget.monkId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ламын бүртгэл устгагдлаа')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(formatUserError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  void _addService() {
    setState(() => _services.add(AdminMonkServiceItem()));
  }

  void _removeService(int index) {
    if (_services.length <= 1) return;
    setState(() => _services.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(adminMonkDetailProvider(widget.monkId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Лам засах'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            onPressed: _deleting ? null : _delete,
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.goldPrime),
        ),
        error: (e, _) => Center(child: Text(formatUserError(e))),
        data: (detail) {
          _load(detail);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: ProfileImagePicker(
                  imageUrl: _imageUrl,
                  onImageChanged: (url) => setState(() => _imageUrl = url),
                ),
              ),
              if (detail.email.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceEl,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 18,
                        color: AppColors.textSec,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('И-мэйл', style: AppText.caption),
                          Text(
                            detail.email,
                            style: AppText.body.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SacredInput(label: 'Нэр', controller: _nameCtrl, prefixIcon: Icons.person),
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
              const SizedBox(height: 16),
              const Text('Үйлчилгээний төрөл', style: AppText.body),
              const SizedBox(height: 8),
              Wrap(
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Төлөв',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Идэвхтэй')),
                  DropdownMenuItem(value: 'pending', child: Text('Хүлээгдэж буй')),
                  DropdownMenuItem(value: 'blocked', child: Text('Хаагдсан')),
                ],
                onChanged: (v) => setState(() => _status = v ?? _status),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Онцгой лам'),
                subtitle: const Text(
                  'Premium гишүүдэд нээлттэй, нүүр хуудсанд онцолж харагдана',
                  style: TextStyle(fontSize: 12),
                ),
                value: _isSpecial,
                activeColor: AppColors.goldPrime,
                onChanged: (v) => setState(() => _isSpecial = v),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text('Үйлчилгээнүүд', style: AppText.h3),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _addService,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Нэмэх'),
                  ),
                ],
              ),
              ..._services.asMap().entries.map((entry) {
                final i = entry.key;
                final s = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
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
                          value: s.category.isEmpty
                              ? _categoryOptions.first
                              : s.category,
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
                  ),
                );
              }),
              const SizedBox(height: 24),
              SacredButton(
                label: 'Хадгалах',
                isLoading: _saving,
                onTap: _save,
              ),
              const SizedBox(height: 12),
              SacredButton(
                label: 'Бүртгэл устгах',
                isLoading: _deleting,
                onTap: _delete,
                prominent: false,
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}
