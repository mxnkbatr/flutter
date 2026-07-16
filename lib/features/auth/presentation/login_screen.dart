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
import 'package:sacred_app/core/utils/auth_phone.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/shared/widgets/auth_ambient_scaffold.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';
import 'package:sacred_app/shared/widgets/sacred_input.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _loginCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _loginError;
  String? _passError;
  String? _formError;

  @override
  void initState() {
    super.initState();
    setAuthSystemUI();
  }

  @override
  void dispose() {
    _loginCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    var ok = true;
    setState(() {
      _loginError = null;
      _passError = null;
      _formError = null;

      final login = _loginCtrl.text.trim();
      if (login.isEmpty) {
        _loginError = 'Утасны дугаар эсвэл и-мэйл оруулна уу';
        ok = false;
      } else if (AuthPhone.looksLikeEmail(login)) {
        if (!login.contains('@') || !login.contains('.')) {
          _loginError = 'Зөв и-мэйл оруулна уу';
          ok = false;
        }
      } else if (!AuthPhone.isValid(login)) {
        _loginError = 'Зөв утасны дугаар оруулна уу';
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
          _loginCtrl.text.trim(),
          _passCtrl.text,
        );

    if (!mounted) return;

    final authAsync = ref.read(authStateProvider);
    setState(() => _loading = false);

    if (authAsync.hasError) {
      setState(() {
        _formError = formatUserError(
          authAsync.error,
          fallback: 'Нэвтрэхэд алдаа гарлаа. Дахин оролдоно уу.',
        );
      });
      return;
    }

    final auth = authAsync.valueOrNull;
    if (auth?.isAuthenticated == true) {
      final dest = switch (auth!.role) {
        'monk' => '/monk/calls',
        'admin' => '/admin/dashboard',
        _ => '/home',
      };
      context.go(dest);
    }
  }

  void _showForgotPassword(BuildContext context) {
    final forgotCtrl = TextEditingController();
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
                    'Бүртгэлтэй утасны дугаар эсвэл и-мэйлээ оруулна уу',
                    style: AppText.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  SacredInput(
                    label: 'Утасны дугаар / И-мэйл',
                    hint: '',
                    controller: forgotCtrl,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.person_outline_rounded,
                    errorText: forgotError,
                  ),
                  const SizedBox(height: 16),
                  SacredButton(
                    label: 'Илгээх',
                    isLoading: sending,
                    onTap: () async {
                      final value = forgotCtrl.text.trim();
                      if (value.isEmpty) {
                        setSheetState(() {
                          forgotError = 'Утасны дугаар эсвэл и-мэйл оруулна уу';
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
                            'Нууц үг сэргээх: support@gevabal.mn хаяг руу холбогдоно уу',
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
    ).whenComplete(forgotCtrl.dispose);
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
                  subtitle: 'Утасны дугаар эсвэл и-мэйлээр нэвтрэнэ үү',
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
                                    : '${DevAuthStore.defaultPhone} эсвэл ${DevAuthStore.defaultEmail} / ${DevAuthStore.defaultPassword}',
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
                        label: 'Утасны дугаар эсвэл и-мэйл',
                        hint: '99112233 эсвэл name@example.com',
                        keyboardType: TextInputType.emailAddress,
                        controller: _loginCtrl,
                        prefixIcon: Icons.phone_outlined,
                        errorText: _loginError,
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
