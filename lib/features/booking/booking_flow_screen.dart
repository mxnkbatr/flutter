import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/features/booking/providers/booking_draft_provider.dart';
import 'package:sacred_app/features/booking/widgets/confirmation_step.dart';
import 'package:sacred_app/features/booking/widgets/date_time_selection_step.dart';
import 'package:sacred_app/features/booking/widgets/service_selection_step.dart';
import 'package:sacred_app/features/booking/widgets/step_indicator.dart';
import 'package:sacred_app/features/monk_profile/providers/monk_profile_provider.dart';
import 'package:sacred_app/features/subscription/utils/tier_gating.dart';
import 'package:sacred_app/shared/widgets/premium_layered_scaffold.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';

const _stepLabels = ['Үйлчилгээ', 'Цаг', 'Баталгаа'];

class BookingFlowScreen extends ConsumerStatefulWidget {
  const BookingFlowScreen({
    super.key,
    required this.monkId,
    this.initialServiceId,
    this.initialDate,
    this.initialSlot,
  });

  final String monkId;
  final String? initialServiceId;
  final String? initialDate;
  final String? initialSlot;

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  late final PageController _pageController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeDraft());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializeDraft() async {
    if (_initialized) return;
    _initialized = true;

    ref.read(bookingStepProvider.notifier).state = 0;
    ref.read(bookingDraftProvider.notifier).reset(widget.monkId);

    try {
      final monk = await ref.read(monkDetailProvider(widget.monkId).future);
      if (mounted) {
        final ok = await TierGating.checkMonkAccess(context, ref, monk);
        if (!ok) {
          context.pop();
          return;
        }
      }
    } catch (_) {
      if (mounted) context.pop();
      return;
    }

    if (widget.initialServiceId != null) {
      final services =
          await ref.read(monkServicesProvider(widget.monkId).future);
      for (final service in services) {
        if (service.id == widget.initialServiceId) {
          ref.read(bookingDraftProvider.notifier).setService(service);
          break;
        }
      }
    }

    if (widget.initialDate != null) {
      final date = DateTime.tryParse(widget.initialDate!);
      if (date != null) {
        ref.read(bookingDraftProvider.notifier).setDate(date);
      }
    }

    if (widget.initialSlot != null && widget.initialSlot!.isNotEmpty) {
      ref
          .read(bookingDraftProvider.notifier)
          .setSlot(Uri.decodeComponent(widget.initialSlot!));
    }

    var startStep = 0;
    final draft = ref.read(bookingDraftProvider);
    if (draft.service != null) startStep = 1;
    if (draft.service != null && draft.date != null && draft.slot != null) {
      startStep = 2;
    } else if (draft.service != null && draft.date != null) {
      startStep = 1;
    }

    if (startStep > 0) {
      ref.read(bookingStepProvider.notifier).state = startStep;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(startStep);
        }
      });
    }
  }

  void _goToStep(int step) {
    ref.read(bookingStepProvider.notifier).state = step;
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(bookingStepProvider);
    final draft = ref.watch(bookingDraftProvider);
    final isLastStep = step == 2;
    final canGoNext = switch (step) {
      0 => draft.canProceedStep1,
      1 => draft.canProceedStep2,
      _ => false,
    };

    return PremiumLayeredScaffold(
      title: 'Захиалах',
      showBackButton: true,
      headerHeight: 196,
      onBack: () {
        HapticFeedback.lightImpact();
        if (step > 0) {
          _goToStep(step - 1);
        } else {
          context.pop();
        }
      },
      headerBottom: StepIndicator(
        current: step,
        total: 3,
        labels: _stepLabels,
      ),
      expandBody: true,
      bottomBar: isLastStep
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: SacredButton(
                  label: step == 1 ? 'Үргэлжлүүлэх' : 'Дараах',
                  onTap: canGoNext
                      ? () {
                          HapticFeedback.lightImpact();
                          _goToStep(step + 1);
                        }
                      : null,
                ),
              ),
            ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ServiceSelectionStep(monkId: widget.monkId),
          DateTimeSelectionStep(monkId: widget.monkId),
          ConfirmationStep(monkId: widget.monkId),
        ],
      ),
    );
  }
}
