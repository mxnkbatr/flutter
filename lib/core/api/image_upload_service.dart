import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/utils/media_url.dart';

String detectImageMime(Uint8List bytes) {
  if (bytes.length >= 3 &&
      bytes[0] == 0xff &&
      bytes[1] == 0xd8 &&
      bytes[2] == 0xff) {
    return 'image/jpeg';
  }
  if (bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4e &&
      bytes[3] == 0x47) {
    return 'image/png';
  }
  if (bytes.length >= 12 &&
      bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x45 &&
      bytes[10] == 0x42 &&
      bytes[11] == 0x50) {
    return 'image/webp';
  }
  return 'image/jpeg';
}

Future<String> uploadImageBytes(
  WidgetRef ref,
  Uint8List bytes, {
  String? mimeType,
  String folder = 'monks',
}) async {
  if (bytes.isEmpty) {
    throw StateError('Зургийн өгөгдөл хоосон байна');
  }
  final mime = mimeType ?? detectImageMime(bytes);
  final base64 = base64Encode(bytes);
  final res = await ref.read(apiClientProvider).post(
        '/upload/image',
        data: {
          'image': 'data:$mime;base64,$base64',
          'folder': folder,
        },
      );
  final data = res.data;
  if (data is! Map<String, dynamic>) {
    throw StateError('Зураг хадгалах хариу буруу байна');
  }
  final url = data['url'] as String? ?? data['path'] as String?;
  if (url == null || url.isEmpty) {
    throw StateError('Зургийн URL олдсонгүй');
  }
  return resolveMediaUrl(url);
}
