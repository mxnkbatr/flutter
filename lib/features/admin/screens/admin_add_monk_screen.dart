import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/providers/monk_categories_provider.dart';
import 'package:sacred_app/features/admin/providers/admin_providers.dart';
import 'package:sacred_app/features/admin/widgets/admin_page_scaffold.dart';
import 'package:sacred_app/shared/widgets/profile_image_picker.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';
import 'package:sacred_app/shared/widgets/sacred_input.dart';

const _fallbackCategories = ['Ерөөл', 'Зурхай', 'Тахилга', 'Номын тайлбар'];

class _ServiceDraft {
  _ServiceDraft({
    this.name = '',
    this.description = '',
    this.durationMinutes = 30,
    this.price = 50000,
    this.category = 'Ерөөл',
  });

  String name;
  String description;
  int durationMinutes;
  int price;
  String category;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'durationMinutes': durationMinutes,
        'price': price,
        'category': category,
      };
}

class AdminAddMonkScreen extends ConsumerStatefulWidget {
  const AdminAddMonkScreen({super.key});

  @override
  ConsumerState<AdminAddMonkScreen> createState() => _AdminAddMonkScreenState();
}

class _AdminAddMonkScreenState extends ConsumerState<AdminAddMonkScreen> {
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _titleCtrl = TextEditingController(text: 'Лам');
  final _templeCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _services = <_ServiceDraft>[
    _ServiceDraft(name: 'Ерөөл', category: 'Ерөөл'),
    _ServiceDraft(
      name: 'Чулуут цаг',
      description: 'Чулуут цагийн үйлчилгээ',
      durationMinutes: 30,
      price: 80000,
      category: 'Тахилга',
    ),
  ];
  final _selectedCategories = <String>{'Ерөөл'};
  String? _imageUrl;
  bool _saving = false;
  String _status = 'active';

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _titleCtrl.dispose();
    _templeCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _addService() {
    setState(() => _services.add(_ServiceDraft()));
  }

  void _removeService(int index) {
    if (_services.length <= 1) return;
    setState(() => _services.removeAt(index));
  }

  String _digitsOnly(String v) => v.replaceAll(RegExp(r'\D'), '');

  Future<void> _submit() async {
    final phone = _digitsOnly(_phoneCtrl.text.trim());
    if (phone.length < 8 ||
        _passwordCtrl.text.length < 8 ||
        _nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Утас (8 орон), нууц үг (8+), нэр заавал'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await createMonk(ref, {
        'phone': phone,
        'password': _passwordCtrl.text,
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
        if (_imageUrl != null) 'image': _imageUrl,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Лам амжилттай бүртгэгдлээ')),
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

  Widget _sectionLabel(String title, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.displaySerif(size: 20)),
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(
              hint,
              style: AppText.caption.copyWith(color: AppColors.textSec, height: 1.35),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryOptions =
        ref.watch(monkCategoriesProvider).valueOrNull ?? _fallbackCategories;

    return AdminPageScaffold(
      title: 'Шинэ лам',
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/admin/dashboard');
        }
      },
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          AdminSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel(
                  'Нэвтрэх эрх',
                  hint: 'Лам утасны дугаараар нэвтэрнэ. Gmail шаардлагагүй.',
                ),
                SacredInput(
                  label: 'Утасны дугаар',
                  controller: _phoneCtrl,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  hint: '99918122',
                ),
                const SizedBox(height: 12),
                SacredInput(
                  label: 'Нууц үг (8+ тэмдэгт)',
                  controller: _passwordCtrl,
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AdminSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('Профайл', hint: 'Хэрэглэгчид харагдах мэдээлэл'),
                Center(
                  child: ProfileImagePicker(
                    imageUrl: _imageUrl,
                    onImageChanged: (url) => setState(() => _imageUrl = url),
                  ),
                ),
                const SizedBox(height: 16),
                SacredInput(
                  label: 'Нэр',
                  controller: _nameCtrl,
                  prefixIcon: Icons.person_outline,
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
                const SizedBox(height: 16),
                Text(
                  'Үйлчилгээний төрөл',
                  style: AppText.body.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categoryOptions.map((cat) {
                    final selected = _selectedCategories.contains(cat);
                    return FilterChip(
                      label: Text(cat),
                      selected: selected,
                      selectedColor: AppColors.orangeLight,
                      checkmarkColor: AppColors.orange,
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
                  decoration: InputDecoration(
                    labelText: 'Төлөв',
                    filled: true,
                    fillColor: AppColors.creamBg.withOpacity(0.6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Идэвхтэй')),
                    DropdownMenuItem(
                      value: 'pending',
                      child: Text('Хүлээгдэж буй'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? 'active'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Үйлчилгээнүүд',
                  style: AppText.displaySerif(size: 20),
                ),
              ),
              TextButton.icon(
                onPressed: _addService,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Нэмэх'),
                style: TextButton.styleFrom(foregroundColor: AppColors.orange),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Үнэ, хугацаа, ангиллыг тодорхойлно',
            style: AppText.caption.copyWith(color: AppColors.textSec),
          ),
          const SizedBox(height: 12),
          ..._services.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value;
            return AdminSurfaceCard(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${i + 1}',
                          style: AppText.caption.copyWith(
                            color: AppColors.orange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Үйлчилгээ',
                        style: AppText.body.copyWith(fontWeight: FontWeight.w600),
                      ),
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
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: s.name,
                    decoration: _fieldDecoration('Нэр'),
                    onChanged: (v) => s.name = v,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: s.description,
                    decoration: _fieldDecoration('Тайлбар'),
                    onChanged: (v) => s.description = v,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: '${s.price}',
                          keyboardType: TextInputType.number,
                          decoration: _fieldDecoration('Үнэ (₮)'),
                          onChanged: (v) =>
                              s.price = int.tryParse(v) ?? s.price,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: '${s.durationMinutes}',
                          keyboardType: TextInputType.number,
                          decoration: _fieldDecoration('Минут'),
                          onChanged: (v) => s.durationMinutes =
                              int.tryParse(v) ?? s.durationMinutes,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: s.category,
                    decoration: _fieldDecoration('Ангилал'),
                    items: categoryOptions
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => s.category = v ?? s.category),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          SacredButton(
            label: 'Лам бүртгэх',
            isLoading: _saving,
            onTap: _submit,
            sunShadow: true,
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.creamBg.withOpacity(0.55),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.orange, width: 1.4),
      ),
    );
  }
}
