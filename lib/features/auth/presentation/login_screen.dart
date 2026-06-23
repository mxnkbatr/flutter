import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/api/api_config.dart';
import 'package:sacred_app/core/auth/dev_auth_store.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/shared/widgets/auth_ambient_scaffold.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';
import 'package:sacred_app/shared/widgets/sacred_divider.dart';
import 'package:sacred_app/shared/widgets/sacred_input.dart';

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
  void initState() {
    super.initState();
    setAuthSystemUI();
  }

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

  void _showForgotPassword(BuildContext context) {
    final forgotEmailCtrl = TextEditingController();
    var sending = false;
    String? forgotError;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceEl,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Нууц үг сэргээх', style: AppText.displaySerif(size: 22)),
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
                      await Future.delayed(const Duration(milliseconds: 400));
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Нууц үг сэргээх: support@gevabal.mn хаяг руу и-мэйл илгээнэ үү',
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
      backgroundColor: AppColors.creamBg,
      body: Stack(
        children: [
          const AuthAmbientBackground(),
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.28,
                child: SafeArea(
                  bottom: false,
                  child: Center(
                    child: const AuthBrandHero(logoHeight: 80, compact: true),
                  ),
                ),
              ),
              Expanded(
                child: AuthFormSheet(
                  title: 'Нэвтрэх',
                  subtitle: 'Өөрийн бүртгэлээр орно уу',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (kDebugMode) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.orangeSoft,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.orange.withOpacity(0.25),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isApiConfigured
                                    ? 'Local API нэвтрэлт'
                                    : 'Dev нэвтрэлт',
                                style: AppText.caption.copyWith(
                                  color: AppColors.orangeDeep,
                                  fontWeight: FontWeight.w700,
                                ),
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
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _showForgotPassword(context),
                          child: Text(
                            'Нууц үг мартсан?',
                            style: AppText.bodySmall.copyWith(
                              color: AppColors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      if (_formError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _formError!,
                            style: AppText.caption.copyWith(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      SacredButton(
                        label: 'Нэвтрэх',
                        isLoading: _loading,
                        onTap: _login,
                        sunShadow: true,
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
                                color: AppColors.orange,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
