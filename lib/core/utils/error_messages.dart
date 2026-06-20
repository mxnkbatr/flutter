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
      return 'Серверт холбогдож чадсангүй.\nИнтернэт холболтоо шалгана уу.';
    }

    final code = error.response?.statusCode;
    if (code == 401) {
      return 'Нэвтрэлт хүчинтэй биш байна.\nДахин нэвтэрнэ үү.';
    }
    if (code == 403) {
      return 'Энэ үйлдлийг хийх эрхгүй байна.';
    }
    if (code == 404) {
      return 'Мэдээлэл олдсонгүй.';
    }

    final data = error.response?.data;
    if (data is Map) {
      final text = data['error'] ?? data['message'];
      if (text is String && text.isNotEmpty && !_isTechnical(text)) {
        return text;
      }
    }

    return fallback;
  }

  final raw = error.toString();
  if (_isTechnical(raw)) return fallback;
  return raw.replaceFirst('Exception: ', '');
}

bool _isTechnical(String text) {
  return text.contains('DioException') ||
      text.contains('SocketException') ||
      text.contains('HttpException') ||
      text.contains('FormatException');
}
