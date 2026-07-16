/// Phone / login-id helpers for Mongolian (+ optional intl) numbers.
class AuthPhone {
  AuthPhone._();

  /// Digits only; strips leading 976 country code when present.
  static String normalize(String? input) {
    if (input == null || input.isEmpty) return '';
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('976') && digits.length > 8) {
      digits = digits.substring(3);
    }
    return digits;
  }

  /// 8-digit MN mobile, or 10–15 digit international.
  static bool isValid(String? input) {
    final phone = normalize(input);
    if (phone.length == 8) return true;
    return phone.length >= 10 && phone.length <= 15;
  }

  static bool looksLikeEmail(String input) => input.trim().contains('@');
}
