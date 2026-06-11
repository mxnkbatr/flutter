import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:sacred_app/core/auth/onboarding_prefs.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';

class _OnboardSlideData {
  const _OnboardSlideData({
    required this.badge,
    required this.title,
    required this.body,
    required this.illustration,
  });

  final String badge;
  final String title;
  final String body;
  final Widget illustration;
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _slides = [
      _OnboardSlideData(
        badge: 'ҮЙЛЧИЛГЭЭ',
        title: 'Монголын\nлам нартай холбогд',
        body: '1000+ итгэмжлэгдсэн лам нар таныг хүлээж байна',
        illustration: _LottieIllustration(
          asset: 'assets/lottie/meditation.json',
          fallbackIcon: Icons.self_improvement_rounded,
        ),
      ),
      _OnboardSlideData(
        badge: 'ЗАХИАЛГА',
        title: 'Цагаа өөрөө\nтохируул',
        body: 'Ямар ч цагт, ямар ч газраас захиалга өгнө',
        illustration: _LottieIllustration(
          asset: 'assets/lottie/calendar.json',
          fallbackIcon: Icons.calendar_month_rounded,
        ),
      ),
      _OnboardSlideData(
        badge: 'ВИДЕО ДУУДЛАГА',
        title: 'Нүүр тулан\nярилц',
        body: 'HD видео дуудлагаар ламтайгаа холбогд',
        illustration: SvgPicture.asset(
          'assets/icons/onboard_video.svg',
          width: 120,
          colorFilter: const ColorFilter.mode(
            AppColors.goldPrime,
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
      backgroundColor: AppColors.inkDeep,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skip,
                child: Text(
                  'Алгасах',
                  style: AppText.body.copyWith(color: AppColors.goldMuted),
                ),
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
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _page == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _page == i
                              ? AppColors.goldPrime
                              : AppColors.inkLight,
                          borderRadius: BorderRadius.circular(4),
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
                            onTap: _finish,
                          )
                        : SacredButton(
                            key: const ValueKey('next'),
                            label: 'Дараах',
                            onTap: () {
                              _controller.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 260,
            decoration: BoxDecoration(
              color: AppColors.inkMid,
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: slide.illustration,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.goldLight.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(slide.badge, style: AppText.goldLabel),
          ),
          const SizedBox(height: 16),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: AppText.h1.copyWith(color: AppColors.onDark),
          ),
          const SizedBox(height: 12),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: AppText.bodySmall.copyWith(color: AppColors.goldMuted),
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
      width: 160,
      height: 160,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(
        fallbackIcon,
        size: 80,
        color: AppColors.goldPrime,
      ),
    );
  }
}
