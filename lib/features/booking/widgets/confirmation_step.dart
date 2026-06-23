import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sacred_app/core/auth/tier_provider.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/features/booking/providers/booking_draft_provider.dart';
import 'package:sacred_app/features/booking/widgets/detail_row.dart';
import 'package:sacred_app/features/monk_profile/providers/monk_profile_provider.dart';
import 'package:sacred_app/features/subscription/utils/tier_gating.dart';
import 'package:sacred_app/shared/widgets/error_state.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';
import 'package:sacred_app/shared/widgets/sacred_card.dart';

class ConfirmationStep extends ConsumerStatefulWidget {
  const ConfirmationStep({super.key, required this.monkId});

  final String monkId;

  @override
  ConsumerState<ConfirmationStep> createState() => _ConfirmationStepState();
}

class _ConfirmationStepState extends ConsumerState<ConfirmationStep> {
  String _fmt(int n) => n.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );

  String _fmtDate(DateTime date) => DateFormat('yyyy.MM.dd').format(date);

  Future<void> _pay(BuildContext context) async {
    final draft = ref.read(bookingDraftProvider);
    if (!draft.isComplete) return;

    final allowed = await TierGating.checkBookingLimit(context, ref);
    if (!allowed) return;

    final monk = await ref.read(monkDetailProvider(widget.monkId).future);
    final monkAccess = await TierGating.checkMonkAccess(context, ref, monk);
    if (!monkAccess) return;

    ref.read(bookingSubmittingProvider.notifier).state = true;
    try {
      final bookingId =
          await ref.read(bookingDraftProvider.notifier).createBooking();

      if (!context.mounted) return;
      context.go('/payment/$bookingId', extra: 1);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(formatUserError(e, fallback: 'Захиалга илгээхэд алдаа гарлаа.')),
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
    final monkAsync = ref.watch(monkDetailProvider(widget.monkId));
    final isLoading = ref.watch(bookingSubmittingProvider);
    final tier = ref.watch(userTierProvider);
    final discount = tier.discountPercent;
    final discountedPrice = draft.discountedServicePrice(discount);
    final platformFee = draft.platformFeeFor(discount);
    final total = draft.totalAmountFor(discount);

    return monkAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorState(
        error: e,
        fallback: 'Ламын мэдээлэл ачаалахад алдаа гарлаа.',
      ),
      data: (monk) {
        if (!draft.isComplete || draft.service == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Захиалгын мэдээлэл дутуу байна.\nӨмнөх алхам руу буцаж бөглөнө үү.',
                style: AppText.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final service = draft.service!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SacredCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.borderSub,
                      backgroundImage: monk.image != null
                          ? CachedNetworkImageProvider(monk.image!)
                          : null,
                      child: monk.image == null
                          ? const Icon(Icons.person, color: AppColors.goldMuted)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(monk.displayName, style: AppText.h3),
                          if (monk.displayTitle != null)
                            Text(monk.displayTitle!, style: AppText.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SacredCard(
                child: Column(
                  children: [
                    DetailRow(label: 'Үйлчилгээ', value: service.displayName),
                    if (draft.date != null)
                      DetailRow(
                        label: 'Огноо',
                        value: _fmtDate(draft.date!),
                      ),
                    if (draft.slot != null)
                      DetailRow(label: 'Цаг', value: draft.slot!),
                    DetailRow(
                      label: 'Хугацаа',
                      value: '${service.durationMinutes} минут',
                    ),
                    const Divider(),
                    DetailRow(
                      label: 'Үйлчилгээний үнэ',
                      value: '₮${_fmt(service.price)}',
                    ),
                    if (discount > 0) ...[
                      DetailRow(
                        label: 'Хөнгөлөлт ($discount%)',
                        value: '-₮${_fmt(service.price - discountedPrice)}',
                        labelStyle: AppText.bodySmall,
                        valueStyle: AppText.bodySmall.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                      DetailRow(
                        label: 'Хөнгөлсөн үнэ',
                        value: '₮${_fmt(discountedPrice)}',
                        labelStyle: AppText.bodySmall,
                        valueStyle: AppText.bodySmall,
                      ),
                    ],
                    DetailRow(
                      label: 'Платформын хураамж (10%)',
                      value: '₮${_fmt(platformFee)}',
                      labelStyle: AppText.bodySmall,
                      valueStyle: AppText.bodySmall,
                    ),
                    DetailRow(
                      label: 'Нийт дүн',
                      value: '₮${_fmt(total)}',
                      valueStyle:
                          AppText.price.copyWith(color: AppColors.goldPrime),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SacredButton(
                label: 'QPay-ээр төлөх',
                icon: Icons.qr_code_rounded,
                onTap: draft.isComplete && !isLoading
                    ? () {
                        HapticFeedback.lightImpact();
                        _pay(context);
                      }
                    : null,
                isLoading: isLoading,
              ),
            ],
          ),
        );
      },
    );
  }
}
