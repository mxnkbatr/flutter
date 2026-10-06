import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/utils/media_url.dart';

String _audioMimeFromPath(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.m4a') || lower.endsWith('.mp4')) return 'audio/m4a';
  if (lower.endsWith('.mp3')) return 'audio/mp3';
  if (lower.endsWith('.aac')) return 'audio/aac';
  if (lower.endsWith('.wav')) return 'audio/wav';
  if (lower.endsWith('.ogg')) return 'audio/ogg';
  if (lower.endsWith('.webm')) return 'audio/webm';
  if (lower.endsWith('.caf')) return 'audio/caf';
  return 'audio/m4a';
}

Future<String> uploadAudioFile(WidgetRef ref, String filePath) async {
  final file = File(filePath);
  if (!await file.exists()) {
    throw StateError('Дууны файл олдсонгүй');
  }
  final bytes = await file.readAsBytes();
  if (bytes.isEmpty) {
    throw StateError('Дууны өгөгдөл хоосон байна');
  }
  final mime = _audioMimeFromPath(filePath);
  final base64 = base64Encode(bytes);
  final res = await ref.read(apiClientProvider).post(
        '/upload/audio',
        data: {
          'audio': 'data:$mime;base64,$base64',
        },
      );
  final data = res.data;
  if (data is! Map<String, dynamic>) {
    throw StateError('Дуу хадгалах хариу буруу байна');
  }
  final url = data['url'] as String? ?? data['path'] as String?;
  if (url == null || url.isEmpty) {
    throw StateError('Дууны URL олдсонгүй');
  }
  return resolveMediaUrl(url);
}
