import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/shop/models/product.dart';
import 'package:sacred_app/features/shop/providers/shop_providers.dart';
import 'package:sacred_app/shared/widgets/profile_image_picker.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';
import 'package:sacred_app/shared/widgets/sacred_card.dart';
import 'package:sacred_app/shared/widgets/sacred_input.dart';

const _cats = ['Ном', 'Эрдэнэ', 'Тос', 'Бусад'];

class AdminProductsScreen extends ConsumerWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(adminProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Бараа удирдлага'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showProductSheet(context, ref, null),
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.goldPrime),
        ),
        error: (e, _) => Center(child: Text('Алдаа: $e')),
        data: (products) => RefreshIndicator(
          color: AppColors.goldPrime,
          onRefresh: () => ref.refresh(adminProductsProvider.future),
          child: products.isEmpty
              ? const Center(child: Text('Бараа байхгүй'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (_, i) => _ProductAdminCard(
                    product: products[i],
                    onEdit: () => _showProductSheet(context, ref, products[i]),
                    onDelete: () => _confirmDelete(context, ref, products[i]),
                  ),
                ),
        ),
      ),
    );
  }

  void _showProductSheet(BuildContext context, WidgetRef ref, Product? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ProductFormSheet(existing: existing),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Бараа устгах уу?'),
        content: Text(product.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Болих'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Устгах'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await adminDeleteProduct(ref, product.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} устгагдлаа'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }
}

class _ProductAdminCard extends StatelessWidget {
  const _ProductAdminCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _fmt(int n) =>
      n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SacredCard(
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 56,
                height: 56,
                child: product.image.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.image,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: AppColors.goldLight,
                        child: const Icon(
                          Icons.storefront_outlined,
                          color: AppColors.goldMuted,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppText.body.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(product.category, style: AppText.caption),
                  Row(
                    children: [
                      Text(
                        '₮${_fmt(product.price)}',
                        style: AppText.bodySmall.copyWith(
                          color: AppColors.saffronDeep,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Үлдэгдэл: ${product.stock}',
                        style: AppText.caption.copyWith(
                          color: product.stock <= 0
                              ? AppColors.danger
                              : AppColors.textSec,
                        ),
                      ),
                      if (!product.isActive) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Идэвхгүй',
                          style: AppText.caption.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: AppColors.goldPrime,
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.danger,
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductFormSheet extends ConsumerStatefulWidget {
  const _ProductFormSheet({this.existing});
  final Product? existing;

  @override
  ConsumerState<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends ConsumerState<_ProductFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _stockCtrl;
  late String _category;
  String? _imageUrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl = TextEditingController(text: p != null ? '${p.price}' : '');
    _stockCtrl = TextEditingController(text: p != null ? '${p.stock}' : '0');
    _category = p?.category ?? 'Бусад';
    _imageUrl = p?.image.isNotEmpty == true ? p!.image : null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _priceCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нэр болон үнэ заавал')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final data = {
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': int.tryParse(_priceCtrl.text.trim()) ?? 0,
        'stock': int.tryParse(_stockCtrl.text.trim()) ?? 0,
        'category': _category,
        if (_imageUrl != null) 'image': _imageUrl,
      };
      if (widget.existing != null) {
        await adminUpdateProduct(ref, widget.existing!.id, data);
      } else {
        await adminCreateProduct(ref, data);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existing != null ? 'Бараа шинэчлэгдлээ' : 'Бараа нэмэгдлээ',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Алдаа: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 12,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              widget.existing != null ? 'Бараа засах' : 'Шинэ бараа нэмэх',
              style: AppText.h3,
            ),
            const SizedBox(height: 20),
            Center(
              child: ProfileImagePicker(
                imageUrl: _imageUrl,
                size: 90,
                label: 'Барааны зураг',
                onImageChanged: (url) => setState(() => _imageUrl = url),
              ),
            ),
            const SizedBox(height: 16),
            SacredInput(
              label: 'Барааны нэр',
              controller: _nameCtrl,
              prefixIcon: Icons.storefront_outlined,
            ),
            const SizedBox(height: 12),
            SacredInput(
              label: 'Тайлбар',
              controller: _descCtrl,
              prefixIcon: Icons.notes_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SacredInput(
                    label: 'Үнэ (₮)',
                    controller: _priceCtrl,
                    prefixIcon: Icons.monetization_on_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SacredInput(
                    label: 'Үлдэгдэл тоо',
                    controller: _stockCtrl,
                    prefixIcon: Icons.inventory_2_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: InputDecoration(
                labelText: 'Ангилал',
                prefixIcon: const Icon(Icons.category_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.goldPrime, width: 1.5),
                ),
              ),
              items: _cats
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: 20),
            SacredButton(
              label: widget.existing != null ? 'Хадгалах' : 'Бараа нэмэх',
              isLoading: _saving,
              onTap: _save,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
