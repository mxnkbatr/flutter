import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';

import 'package:sacred_app/core/api/api_config.dart';

const baseUrl = ApiConfig.baseUrl;

bool get isApiConfigured {
  final url = baseUrl.toLowerCase();
  const placeholders = [
    'your_api',
    'your-api',
    'your_api_url',
    'placeholder',
    'example.com',
  ];
  for (final token in placeholders) {
    if (url.contains(token)) return false;
  }
  return true;
}

/// Зөвхөн API тохируулаагүй (placeholder URL) үед бүрэн dev auth.
bool get shouldUseDevAuth {
  if (!kDebugMode) return false;
  return !isApiConfigured;
}

bool isDevAuthToken(String? token) =>
    token != null && token.startsWith('dev_');

final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final authState = ref.read(authStateProvider).valueOrNull;
        if (authState?.token != null) {
          options.headers['Authorization'] = 'Bearer ${authState!.token}';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          final token = ref.read(authStateProvider).valueOrNull?.token;
          if (!isDevAuthToken(token)) {
            ref.read(authStateProvider.notifier).logout();
          }
        }
        handler.next(error);
      },
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(PrettyDioLogger(requestBody: true));
  }

  return dio;
});
