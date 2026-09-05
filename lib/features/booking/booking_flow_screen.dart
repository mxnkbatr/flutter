import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/core/utils/formatters.dart';
import 'package:sacred_app/features/booking/providers/booking_draft_provider.dart';
import 'package:sacred_app/features/booking/widgets/date_time_selection_step.dart';
import 'package:sacred_app/features/home/models/monk.dart';
import 'package:sacred_app/features/monk_profile/models/monk_service.dart';
import 'package:sacred_app/features/monk_profile/providers/monk_profile_provider.dart';
import 'package:sacred_app/features/subscription/utils/tier_gating.dart';
import 'package:sacred_app/shared/widgets/premium_layered_scaffold.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';

/// Single-step booking: each monk has one service; user only picks date + time.
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
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeDraft());
  }

  Future<void> _initializeDraft() async {
    if (_initialized) return;
    _initialized = true;

    ref.read(bookingStepProvider.notifier).state = 0;
    ref.read(bookingDraftProvider.notifier).reset(widget.monkId);
    ref.read(bookingDateConfirmedProvider.notifier).state = false;

    Monk monk;
    try {
      monk = await ref.read(monkDetailProvider(widget.monkId).future);
      if (!mounted) return;
      final ok = await TierGating.checkMonkAccess(context, ref, monk);
      if (!mounted) return;
      if (!ok) {
        context.pop();
        return;
      }
    } catch (_) {
      if (mounted) context.pop();
      return;
    }

    if (!monk.canBook) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Энэ лам одоогоор захиалга хүлээн авахгүй байна.'),
            backgroundColor: AppColors.danger,
          ),
        );
        context.pop();
      }
      return;
    }

    List<MonkService> services;
    try {
      services = await ref.read(monkServicesProvider(widget.monkId).future);
    } catch (_) {
      if (mounted) context.pop();
      return;
    }

    if (services.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Энэ лам үйлчилгээ нэмээгүй байна.'),
            backgroundColor: AppColors.danger,
          ),
        );
        context.pop();
      }
      return;
    }

    // One service per monk — always bind the primary (or requested) service.
    MonkService service = services.first;
    if (widget.initialServiceId != null) {
      for (final s in services) {
        if (s.id == widget.initialServiceId) {
          service = s;
          break;
        }
      }
    }
    ref.read(bookingDraftProvider.notifier).setService(service);

    if (widget.initialDate != null) {
      final date = DateTime.tryParse(widget.initialDate!);
      if (date != null) {
        ref.read(bookingDraftProvider.notifier).setDate(date);
        ref.read(bookingDateConfirmedProvider.notifier).state = true;
      }
    }

    if (widget.initialSlot != null && widget.initialSlot!.isNotEmpty) {
      ref
          .read(bookingDraftProvider.notifier)
          .setSlot(Uri.decodeComponent(widget.initialSlot!));
    }
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  Future<void> _pay() async {
    final draft = ref.read(bookingDraftProvider);
    if (!draft.isComplete) return;

    final allowed = await TierGating.checkBookingLimit(context, ref);
    if (!allowed || !mounted) return;

    final monk = await ref.read(monkDetailProvider(widget.monkId).future);
    final monkAccess = await TierGating.checkMonkAccess(context, ref, monk);
    if (!monkAccess || !mounted) return;

    ref.read(bookingSubmittingProvider.notifier).state = true;
    try {
      final result =
          await ref.read(bookingDraftProvider.notifier).createBooking();
      if (!mounted) return;
      context.go(
        '/payment/${result.bookingId}',
        extra: result.qpay,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              formatUserError(e, fallback: 'Захиалга илгээхэд алдаа гарлаа.'),
            ),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      ref.read(bookingSubmittingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final isLoading = ref.watch(bookingSubmittingProvider);
    final canPay =
        draft.date != null && draft.slot != null && draft.service != null;
    final service = draft.service;

    final ctaLabel = draft.date == null
        ? 'Өдөр сонгоно уу'
        : draft.slot == null
            ? 'Цаг сонгоно уу'
            : 'Төлбөр төлөх';

    return PremiumLayeredScaffold(
      title: 'Цаг захиалах',
      subtitle: service == null
          ? 'Өдөр, цагаа сонгоно уу'
          : '${service.displayName} · ${Formatters.currency(service.price)}',
      showBackButton: true,
      canPop: () => context.canPop(),
      headerHeight: 132,
      onBack: () {
        HapticFeedback.lightImpact();
        _leave();
      },
      expandBody: true,
      bottomBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SacredButton(
            label: ctaLabel,
            isLoading: isLoading,
            onTap: canPay
                ? () {
                    HapticFeedback.lightImpact();
                    _pay();
                  }
                : null,
          ),
        ),
      ),
      body: DateTimeSelectionStep(monkId: widget.monkId),
    );
  }
}
