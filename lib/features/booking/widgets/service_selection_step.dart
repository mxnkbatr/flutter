import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/booking/providers/booking_draft_provider.dart';
import 'package:sacred_app/features/booking/widgets/service_select_card.dart';
import 'package:sacred_app/features/monk_profile/providers/monk_profile_provider.dart';

class ServiceSelectionStep extends ConsumerWidget {
  const ServiceSelectionStep({super.key, required this.monkId});

  final String monkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(monkServicesProvider(monkId));
    final draft = ref.watch(bookingDraftProvider);
    final selectedId = draft.service?.id;

    return servicesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (e, _) => Center(
        child: Text('Алдаа: $e', style: AppText.bodySmall),
      ),
      data: (services) {
        if (services.isEmpty) {
          return const Center(
            child: Text('Үйлчилгээ байхгүй', style: AppText.bodySmall),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: services.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final service = services[index];
            return ServiceSelectCard(
              service: service,
              isSelected: selectedId == service.id,
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(bookingDraftProvider.notifier).setService(service);
              },
            );
          },
        );
      },
    );
  }
}
