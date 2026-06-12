import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sacred_app/core/api/image_upload_service.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class ProfileImagePicker extends ConsumerStatefulWidget {
  const ProfileImagePicker({
    super.key,
    this.imageUrl,
    required this.onImageChanged,
    this.size = 108,
    this.label = 'Зураг сонгох',
  });

  final String? imageUrl;
  final ValueChanged<String> onImageChanged;
  final double size;
  final String label;

  @override
  ConsumerState<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends ConsumerState<ProfileImagePicker> {
  Uint8List? _localPreview;
  bool _uploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    setState(() {
      _localPreview = bytes;
      _uploading = true;
    });

    try {
      final url = await uploadImageBytes(ref, bytes);
      widget.onImageChanged(url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Зураг амжилттай хадгалагдлаа')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Зураг оруулахад алдаа: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasRemote = widget.imageUrl != null && widget.imageUrl!.isNotEmpty;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: widget.size / 2,
              backgroundColor: AppColors.borderSub,
              backgroundImage: _localPreview != null
                  ? MemoryImage(_localPreview!)
                  : hasRemote
                      ? CachedNetworkImageProvider(widget.imageUrl!)
                      : null,
              child: !_uploading &&
                      _localPreview == null &&
                      !hasRemote
                  ? Icon(
                      Icons.person,
                      size: widget.size * 0.45,
                      color: AppColors.textSec,
                    )
                  : null,
            ),
            if (_uploading)
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: const CircularProgressIndicator(
                  color: AppColors.sunGold,
                  strokeWidth: 2,
                ),
              ),
            Positioned(
              right: 4,
              bottom: 4,
              child: Material(
                color: AppColors.sunGold,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _uploading ? null : _pickImage,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.label,
          style: AppText.caption.copyWith(color: AppColors.textSec),
        ),
      ],
    );
  }
}
