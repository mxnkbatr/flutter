import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _nameError;
  String? _emailError;
  String? _passError;

  @override
  void initState() {
    super.initState();
    setAuthSystemUI();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    var ok = true;
    setState(() {
      _nameError = null;
      _emailError = null;
      _passError = null;

      if (_nameController.text.trim().isEmpty) {
        _nameError = 'Нэр оруулна уу';
        ok = false;
      }
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        _emailError = 'Имэйл оруулна уу';
        ok = false;
      } else if (!email.contains('@')) {
        _emailError = 'Зөв имэйл оруулна уу';
        ok = false;
      }
      final pass = _passwordController.text;
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

  Future<void> _submit() async {
    if (!_validate()) return;

    await ref.read(authStateProvider.notifier).signup(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: Stack(
        children: [
          const AuthAmbientBackground(),
          Column(
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
                        onPressed: () => context.pop(),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.18,
                child: const Center(
                  child: AuthBrandHero(logoHeight: 72, compact: true),
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
                        label: 'Имэйл',
                        hint: 'name@example.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline_rounded,
                        errorText: _emailError,
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
                          const Text('Бүртгэлтэй юу? ', style: AppText.bodySmall),
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
          ),
        ],
      ),
    );
  }
}
