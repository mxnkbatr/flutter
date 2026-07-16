import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';

import 'package:sacred_app/core/api/api_config.dart';

String get baseUrl => ApiConfig.baseUrl;

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

/// Render free-tier cold starts often take 30–60s. Allow enough time and
/// retry once on transient timeouts so login does not look "broken".
const Duration kApiConnectTimeout = Duration(seconds: 60);
const Duration kApiReceiveTimeout = Duration(seconds: 90);

bool _isTransientNetworkError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return true;
    default:
      return false;
  }
}

final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: kApiConnectTimeout,
      receiveTimeout: kApiReceiveTimeout,
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
      onError: (error, handler) async {
        final opts = error.requestOptions;
        final retryCount = (opts.extra['retryCount'] as int?) ?? 0;
        final allowRetry = opts.extra['allowRetry'] != false;

        if (allowRetry &&
            retryCount < 1 &&
            _isTransientNetworkError(error) &&
            opts.method.toUpperCase() != 'GET') {
          opts.extra['retryCount'] = retryCount + 1;
          try {
            // Wake a sleeping free-tier instance before the real retry.
            await dio.get(
              '/health',
              options: Options(
                receiveTimeout: kApiReceiveTimeout,
                sendTimeout: kApiConnectTimeout,
                extra: {'allowRetry': false, 'skipAuthLogout': true},
              ),
            );
          } catch (_) {}
          try {
            final response = await dio.fetch(opts);
            return handler.resolve(response);
          } catch (e) {
            if (e is DioException) {
              return handler.next(e);
            }
            return handler.next(error);
          }
        }

        if (error.response?.statusCode == 401) {
          final skipLogout =
              error.requestOptions.extra['skipAuthLogout'] == true;
          final path = error.requestOptions.path;
          final isAuthRoute = path.contains('/auth/login') ||
              path.contains('/auth/signup');

          if (!skipLogout && !isAuthRoute) {
            final auth = ref.read(authStateProvider).valueOrNull;
            final notifier = ref.read(authStateProvider.notifier);

            if (auth?.isAuthenticated == true &&
                !isDevAuthToken(auth!.token) &&
                !notifier.isLoggingOut) {
              final requestAuth =
                  error.requestOptions.headers['Authorization'] as String?;
              final currentAuth = 'Bearer ${auth.token}';
              final isStaleRequest = requestAuth != null &&
                  requestAuth.isNotEmpty &&
                  requestAuth != currentAuth;

              if (!isStaleRequest) {
                notifier.logout();
              }
            }
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
