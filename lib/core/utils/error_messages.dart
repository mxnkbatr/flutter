import 'package:dio/dio.dart';

/// Хэрэглэгчид ойлгомжтой монгол алдааны мессеж буцаана.
String formatUserError(
  Object? error, {
  String fallback = 'Алдаа гарлаа. Дахин оролдоно уу.',
}) {
  if (error == null) return fallback;

  if (error is DioException) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Серверт холбогдож чадсангүй.\nИнтернэт холболтоо шалгаад дахин оролдоно уу.';
    }

    final code = error.response?.statusCode;
    final path = error.requestOptions.path;
    final isAuthCredentialRoute =
        path.contains('/auth/login') || path.contains('/auth/signup');

    if (code == 401) {
      if (isAuthCredentialRoute) {
        return 'Утас/и-мэйл эсвэл нууц үг буруу байна.';
      }
      return 'Нэвтрэлт хүчинтэй биш байна.\nДахин нэвтэрнэ үү.';
    }
    if (code == 403) {
      return 'Энэ үйлдлийг хийх эрхгүй байна.';
    }
    if (code == 404) {
      return 'Мэдээлэл олдсонгүй.';
    }
    if (code == 409) {
      return 'Энэ цаг аль хэдийн захиалагдсан байна.\nӨөр цаг сонгоно уу.';
    }

    final data = error.response?.data;
    if (data is Map) {
      final text = data['error'] ?? data['message'];
      if (text is String && text.isNotEmpty && !_isTechnical(text)) {
        final localized = _localizeKnownApiMessage(text);
        if (localized != null) return localized;
        if (text.contains('Нэхэмжлэлийн мөр') ||
            text.contains('INVOICE_LINE')) {
          return 'QPay тохиргоо дутуу байна.\nАдминтай холбогдоно уу.';
        }
        return text;
      }
    }

    return fallback;
  }

  final raw = error.toString();
  if (raw.contains('invalid API key') ||
      raw.contains('ConnectException') ||
      raw.contains('LiveKit')) {
    return 'Видео холболт амжилтгүй.\nLiveKit серверийн тохиргоог шалгана уу.';
  }
  if (_isTechnical(raw)) return fallback;
  return raw.replaceFirst('Exception: ', '');
}

String? _localizeKnownApiMessage(String text) {
  final lower = text.toLowerCase();
  if (lower.contains('invalid credentials')) {
    return 'Утас/и-мэйл эсвэл нууц үг буруу байна.';
  }
  if (lower.contains('account disabled')) {
    return 'Бүртгэл идэвхгүй байна.';
  }
  return null;
}

bool _isTechnical(String text) {
  return text.contains('DioException') ||
      text.contains('SocketException') ||
      text.contains('HttpException') ||
      text.contains('FormatException') ||
      text.contains('receive timeout') ||
      text.contains('RequestOptions');
}
