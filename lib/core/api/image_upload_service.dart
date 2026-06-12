import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';

Future<String> uploadImageBytes(
  WidgetRef ref,
  Uint8List bytes, {
  String mimeType = 'image/jpeg',
}) async {
  final base64 = base64Encode(bytes);
  final res = await ref.read(apiClientProvider).post(
        '/upload/image',
        data: {
          'image': 'data:$mimeType;base64,$base64',
          'folder': 'monks',
        },
      );
  return (res.data as Map<String, dynamic>)['url'] as String;
}
