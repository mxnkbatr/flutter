import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/api/api_config.dart';
import 'package:sacred_app/core/auth/dev_auth_store.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';
import 'package:sacred_app/shared/widgets/sacred_divider.dart';
import 'package:sacred_app/shared/widgets/sacred_input.dart';
import 'package:sacred_app/shared/widgets/sacred_outline_btn.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _emailError;
  String? _passError;
  String? _formError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    var ok = true;
    setState(() {
      _emailError = null;
      _passError = null;
      _formError = null;

      final email = _emailCtrl.text.trim();
      if (email.isEmpty) {
        _emailError = 'И-мэйл оруулна уу';
        ok = false;
      } else if (!email.contains('@')) {
        _emailError = 'Зөв и-мэйл оруулна уу';
        ok = false;
      }

      final pass = _passCtrl.text;
      if (pass.isEmpty) {
        _passError = 'Нууц үг оруулна уу';
        ok = false;
      } else if (pass.length < 6) {
        _passError = 'Хамгийн багадаа 6 тэмдэгт';
        ok = false;
      }
    });
    return ok;
  }

  Future<void> _login() async {
    if (!_validate()) return;

    setState(() {
      _loading = true;
      _formError = null;
    });

    await ref.read(authStateProvider.notifier).login(
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );

    if (!mounted) return;

    final authAsync = ref.read(authStateProvider);
    setState(() => _loading = false);

    if (authAsync.hasError) {
      setState(() {
        _formError = _formatAuthError(authAsync.error);
      });
      return;
    }

    final auth = authAsync.valueOrNull;
    if (auth?.isAuthenticated == true) {
      final dest = switch (auth!.role) {
        'monk' => '/monk/dashboard',
        'admin' => '/admin/dashboard',
        _ => '/home',
      };
      context.go(dest);
    }
  }

  String _formatAuthError(Object? error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        return shouldUseDevAuth
            ? 'Серверт холбогдож чадсангүй. Dev нэвтрэлт ашиглана уу.'
            : 'Серверт холбогдож чадсангүй. Backend асаасан эсэхээ шалгана уу.';
      }
      final msg = error.response?.data;
      if (msg is Map) {
        final text = msg['error'] ?? msg['message'];
        if (text != null) return text.toString();
      }
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<void> _googleLogin() async {
    setState(() => _formError = 'Google нэвтрэлт удахгүй нээгдэнэ');
  }

  void _showForgotPassword(BuildContext context) {
    final forgotEmailCtrl = TextEditingController();
    var sending = false;
    String? forgotError;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceEl,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Нууц үг сэргээх', style: AppText.h2),
                  const SizedBox(height: 8),
                  Text(
                    'Бүртгэлтэй и-мэйл хаягаа оруулна уу',
                    style: AppText.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  SacredInput(
                    label: 'И-мэйл',
                    hint: 'name@example.com',
                    controller: forgotEmailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline_rounded,
                    errorText: forgotError,
                  ),
                  const SizedBox(height: 16),
                  SacredButton(
                    label: 'Илгээх',
                    isLoading: sending,
                    onTap: () async {
                      final email = forgotEmailCtrl.text.trim();
                      if (email.isEmpty || !email.contains('@')) {
                        setSheetState(() {
                          forgotError = 'Зөв и-мэйл оруулна уу';
                        });
                        return;
                      }
                      setSheetState(() {
                        sending = true;
                        forgotError = null;
                      });
                      await Future.delayed(const Duration(milliseconds: 800));
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Сэргээх холбоос $email руу илгээгдлээ',
                            style: AppText.bodySmall.copyWith(
                              color: AppColors.onDark,
                            ),
                          ),
                          backgroundColor: AppColors.inkDeep,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(forgotEmailCtrl.dispose);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.inkDeep,
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.32,
            child: SafeArea(
              bottom: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/sacred_logo.svg',
                      width: 48,
                      colorFilter: const ColorFilter.mode(
                        AppColors.goldPrime,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Тавтай морил',
                      style: AppText.h1.copyWith(color: AppColors.onDark),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Оюун санааны замдаа эргэж ир',
                      style: AppText.bodySmall.copyWith(
                        color: AppColors.goldMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (kDebugMode) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.goldLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.goldPrime.withOpacity(0.4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isApiConfigured
                                  ? 'Local API нэвтрэлт'
                                  : 'Dev нэвтрэлт',
                              style: AppText.goldLabel,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isApiConfigured
                                  ? '${ApiConfig.seedClientEmail} / ${ApiConfig.seedClientPassword}'
                                  : '${DevAuthStore.defaultEmail} / ${DevAuthStore.defaultPassword}',
                              style: AppText.caption.copyWith(
                                color: AppColors.inkDeep,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    SacredInput(
                      label: 'И-мэйл',
                      hint: 'name@example.com',
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailCtrl,
                      prefixIcon: Icons.mail_outline_rounded,
                      errorText: _emailError,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    SacredInput(
                      label: 'Нууц үг',
                      hint: '••••••••',
                      obscureText: _obscure,
                      controller: _passCtrl,
                      prefixIcon: Icons.lock_outline_rounded,
                      errorText: _passError,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: AppColors.textSec,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _showForgotPassword(context),
                        child: Text(
                          'Нууц үг мартсан?',
                          style: AppText.bodySmall.copyWith(
                            color: AppColors.goldPrime,
                          ),
                        ),
                      ),
                    ),
                    if (_formError != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formError!,
                        style: AppText.caption.copyWith(color: AppColors.danger),
                      ),
                    ],
                    const SizedBox(height: 8),
                    SacredButton(
                      label: 'Нэвтрэх',
                      isLoading: _loading,
                      onTap: _login,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Expanded(child: SacredDivider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('эсвэл', style: AppText.caption),
                        ),
                        const Expanded(child: SacredDivider()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SacredOutlineBtn(
                      label: 'Google-ээр нэвтрэх',
                      prefixWidget: SvgPicture.asset(
                        'assets/icons/google.svg',
                        width: 20,
                      ),
                      onTap: _googleLogin,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Бүртгэл байхгүй юу? ', style: AppText.bodySmall),
                        GestureDetector(
                          onTap: () => context.go('/auth/signup'),
                          child: Text(
                            'Бүртгүүлэх',
                            style: AppText.bodySmall.copyWith(
                              color: AppColors.goldPrime,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
