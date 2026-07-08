import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sacred_app/core/api/image_upload_service.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/utils/app_feedback.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/core/utils/media_url.dart';

class ProfileImagePicker extends ConsumerStatefulWidget {
  const ProfileImagePicker({
    super.key,
    this.imageUrl,
    required this.onImageChanged,
    this.size = 108,
    this.label = 'Зураг сонгох',
    this.folder = 'monks',
  });

  final String? imageUrl;
  final ValueChanged<String> onImageChanged;
  final double size;
  final String label;
  final String folder;

  @override
  ConsumerState<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends ConsumerState<ProfileImagePicker> {
  Uint8List? _localPreview;
  bool _uploading = false;

  String? get _resolvedRemote {
    final url = widget.imageUrl;
    if (url == null || url.isEmpty) return null;
    return resolveMediaUrl(url);
  }

  @override
  void didUpdateWidget(ProfileImagePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl && !_uploading) {
      _localPreview = null;
    }
  }

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
      final url = await uploadImageBytes(
        ref,
        bytes,
        folder: widget.folder,
      );
      widget.onImageChanged(url);
      if (mounted) {
        showAppSnackBar(
          context,
          const SnackBar(
            content: Text('Зураг амжилттай орууллаа. Хадгалах товч дарна уу.'),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _localPreview = null);
        showAppSnackBar(
          context,
          SnackBar(
            content: Text(formatUserError(e, fallback: 'Зураг оруулахад алдаа гарлаа')),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final remote = _resolvedRemote;
    final hasRemote = remote != null && remote.isNotEmpty;

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
                      ? CachedNetworkImageProvider(remote)
                      : null,
              child: !_uploading && _localPreview == null && !hasRemote
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
