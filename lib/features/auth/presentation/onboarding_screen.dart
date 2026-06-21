import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:sacred_app/core/auth/onboarding_prefs.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/shared/widgets/auth_ambient_scaffold.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';

class _OnboardSlideData {
  const _OnboardSlideData({
    required this.badge,
    required this.title,
    required this.body,
    required this.illustration,
    required this.icon,
  });

  final String badge;
  final String title;
  final String body;
  final Widget illustration;
  final IconData icon;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  late final List<_OnboardSlideData> _slides;

  @override
  void initState() {
    super.initState();
    setAuthSystemUI();
    _slides = [
      _OnboardSlideData(
        badge: 'Үйлчилгээ',
        title: 'Монголын\nлам нартай холбогд',
        body: '1000+ итгэмжлэгдсэн лам нар таныг хүлээж байна',
        icon: Icons.self_improvement_rounded,
        illustration: _LottieIllustration(
          asset: 'assets/lottie/meditation.json',
          fallbackIcon: Icons.self_improvement_rounded,
        ),
      ),
      _OnboardSlideData(
        badge: 'Захиалга',
        title: 'Цагаа өөрөө\nтохируул',
        body: 'Ямар ч цагт, ямар ч газраас захиалга өгнө',
        icon: Icons.calendar_month_rounded,
        illustration: _LottieIllustration(
          asset: 'assets/lottie/calendar.json',
          fallbackIcon: Icons.calendar_month_rounded,
        ),
      ),
      _OnboardSlideData(
        badge: 'Видео дуудлага',
        title: 'Нүүр тулан\nярилц',
        body: 'HD видео дуудлагаар ламтайгаа холбогд',
        icon: Icons.videocam_rounded,
        illustration: SvgPicture.asset(
          'assets/icons/onboard_video.svg',
          width: 120,
          colorFilter: const ColorFilter.mode(
            AppColors.orange,
            BlendMode.srcIn,
          ),
        ),
      ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await OnboardingPrefs.markComplete();
    if (!mounted) return;
    context.go('/auth/login');
  }

  void _skip() {
    HapticFeedback.lightImpact();
    _finish();
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 12, 0),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Text(
                        'Gevabal',
                        style: AppText.displaySerif(
                          size: 22,
                          color: AppColors.inkDeep,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _skip,
                        child: Text(
                          'Алгасах',
                          style: AppText.bodySmall.copyWith(
                            color: AppColors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (i) => setState(() => _page = i),
                    itemCount: _slides.length,
                    itemBuilder: (_, i) => _OnboardSlide(slide: _slides[i]),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 24,
                    left: 24,
                    right: 24,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _page == i ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: _page == i
                                  ? AppGradients.primary
                                  : null,
                              color: _page == i
                                  ? null
                                  : AppColors.orangeLight,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _page == 2
                            ? SacredButton(
                                key: const ValueKey('start'),
                                label: 'Эхлэх',
                                sunShadow: true,
                                onTap: _finish,
                              )
                            : SacredButton(
                                key: const ValueKey('next'),
                                label: 'Дараах',
                                sunShadow: true,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _controller.nextPage(
                                    duration: const Duration(milliseconds: 320),
                                    curve: Curves.easeOutCubic,
                                  );
                                },
                              ),
                      ),
                    ],
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

class _OnboardSlide extends StatelessWidget {
  const _OnboardSlide({required this.slide});

  final _OnboardSlideData slide;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 280,
            decoration: BoxDecoration(
              color: AppColors.surfaceEl,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.borderSub),
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.orangePeach.withOpacity(0.5),
                          AppColors.orangePeach.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
                slide.illustration,
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.orange.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(slide.icon, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.orangeLight,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.orange.withOpacity(0.2),
              ),
            ),
            child: Text(
              slide.badge.toUpperCase(),
              style: AppText.caption.copyWith(
                color: AppColors.orange,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: AppText.displaySerif(
              size: 32,
              color: AppColors.inkDeep,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: AppText.body.copyWith(
              color: AppColors.textSec,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LottieIllustration extends StatelessWidget {
  const _LottieIllustration({
    required this.asset,
    required this.fallbackIcon,
  });

  final String asset;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      asset,
      width: 180,
      height: 180,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(
        fallbackIcon,
        size: 88,
        color: AppColors.orange,
      ),
    );
  }
}
