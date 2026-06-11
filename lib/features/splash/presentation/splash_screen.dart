import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/auth/onboarding_prefs.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _logoVisible = false;
  bool _textVisible = false;
  bool _progressVisible = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _runAnimations();
    _init();
  }

  void _runAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _logoVisible = true);
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _textVisible = true);
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _progressVisible = true);
    });
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted || _navigated) return;

    final auth = ref.read(authStateProvider).valueOrNull;
    if (!mounted) return;
    _navigated = true;

    if (auth?.isAuthenticated == true) {
      final dest = switch (auth!.role) {
        'monk' => '/monk/dashboard',
        'admin' => '/admin/dashboard',
        _ => '/home',
      };
      context.go(dest);
    } else {
      final seenOnboarding = await OnboardingPrefs.isComplete();
      if (!mounted) return;
      context.go(seenOnboarding ? '/auth/login' : '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.inkDeep,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            AnimatedScale(
              scale: _logoVisible ? 1.0 : 0.8,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: _logoVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: SvgPicture.asset(
                  'assets/icons/sacred_logo.svg',
                  width: 80,
                  colorFilter: const ColorFilter.mode(
                    AppColors.goldPrime,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedOpacity(
              opacity: _textVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  const Text('Sacred', style: AppText.brandTitle),
                  const SizedBox(height: 6),
                  Text(
                    'Оюун санааны холбоо',
                    style: AppText.caption.copyWith(color: AppColors.goldMuted),
                  ),
                ],
              ),
            ),
            const Spacer(),
            AnimatedOpacity(
              opacity: _progressVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 48, left: 48, right: 48),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: const LinearProgressIndicator(
                    backgroundColor: AppColors.inkLight,
                    valueColor: AlwaysStoppedAnimation(AppColors.goldPrime),
                    minHeight: 3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
