import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/auth/onboarding_prefs.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/shared/widgets/auth_ambient_scaffold.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _logoVisible = false;
  bool _textVisible = false;
  bool _progressVisible = false;
  bool _navigated = false;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    setAuthSystemUI();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _runAnimations();
    _init();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _runAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _logoVisible = true);
    });
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _textVisible = true);
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _progressVisible = true);
    });
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 2400));
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
      backgroundColor: AppColors.creamBg,
      body: Stack(
        children: [
          const AuthAmbientBackground(),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                AnimatedScale(
                  scale: _logoVisible ? 1.0 : 0.88,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  child: AnimatedOpacity(
                    opacity: _logoVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 450),
                    child: AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + _pulseCtrl.value * 0.02,
                          child: child,
                        );
                      },
                      child: const AuthBrandHero(logoHeight: 120),
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                AnimatedOpacity(
                  opacity: _progressVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(56, 0, 56, 40),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: const LinearProgressIndicator(
                            backgroundColor: AppColors.orangeLight,
                            valueColor: AlwaysStoppedAnimation(AppColors.orange),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _LoadingDots(visible: _textVisible),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.primary,
            ),
          );
        }),
      ),
    );
  }
}
