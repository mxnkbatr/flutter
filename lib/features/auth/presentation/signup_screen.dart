import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/utils/auth_phone.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/constants/app_branding.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/shared/widgets/auth_ambient_scaffold.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';
import 'package:sacred_app/shared/widgets/sacred_input.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _nameError;
  String? _phoneError;
  String? _passError;

  @override
  void initState() {
    super.initState();
    setAuthSystemUI();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    var ok = true;
    setState(() {
      _nameError = null;
      _phoneError = null;
      _passError = null;

      if (_nameController.text.trim().isEmpty) {
        _nameError = 'Нэр оруулна уу';
        ok = false;
      }

      final phone = _phoneController.text.trim();
      if (phone.isEmpty) {
        _phoneError = 'Утасны дугаар оруулна уу';
        ok = false;
      } else if (!AuthPhone.isValid(phone)) {
        _phoneError = 'Зөв утасны дугаар оруулна уу (жишээ: 99112233)';
        ok = false;
      }

      final pass = _passwordController.text;
      if (pass.isEmpty) {
        _passError = 'Нууц үг оруулна уу';
        ok = false;
      } else if (pass.length < 8) {
        _passError = 'Хамгийн багадаа 8 тэмдэгт';
        ok = false;
      }
    });
    return ok;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    await ref.read(authStateProvider.notifier).signup(
          name: _nameController.text.trim(),
          phone: AuthPhone.normalize(_phoneController.text.trim()),
          password: _passwordController.text,
        );

    if (!mounted) return;
    final authAsync = ref.read(authStateProvider);
    if (authAsync.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(formatUserError(authAsync.error)),
          backgroundColor: AppColors.danger,
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const AuthAmbientBackground(),
          LayoutBuilder(
            builder: (context, constraints) {
              final avail = constraints.maxHeight;
              final compact = avail < MediaQuery.sizeOf(context).height * 0.72;
              final heroHeight = compact
                  ? (avail < 480 ? 0.0 : 56.0)
                  : (avail * 0.14).clamp(72.0, 140.0);

              return Column(
                children: [
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                              color: AppColors.inkDeep,
                            ),
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/auth/login');
                              }
                            },
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                  if (heroHeight > 0)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      height: heroHeight,
                      alignment: Alignment.center,
                      child: ClipRect(
                        child: AuthBrandHero(
                          logoHeight: compact ? 48 : 72,
                          compact: true,
                          logoOnly: compact,
                        ),
                      ),
                    ),
                  Expanded(
                    child: AuthFormSheet(
                      title: 'Бүртгүүлэх',
                      subtitle: '${AppBranding.name} платформд нэгдэх',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SacredInput(
                            label: 'Нэр',
                            hint: 'Таны нэр',
                            controller: _nameController,
                            prefixIcon: Icons.person_outline_rounded,
                            errorText: _nameError,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          SacredInput(
                            label: 'Утасны дугаар',
                            hint: '99112233',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_outlined,
                            errorText: _phoneError,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          SacredInput(
                            label: 'Нууц үг',
                            hint: '••••••••',
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            prefixIcon: Icons.lock_outline_rounded,
                            errorText: _passError,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                                color: AppColors.textSec,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          SacredButton(
                            label: 'Бүртгүүлэх',
                            isLoading: isLoading,
                            onTap: _submit,
                            sunShadow: true,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Бүртгэлтэй юу? ',
                                style: AppText.bodySmall,
                              ),
                              GestureDetector(
                                onTap: () => context.go('/auth/login'),
                                child: Text(
                                  'Нэвтрэх',
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
              );
            },
          ),
        ],
      ),
    );
  }
}
