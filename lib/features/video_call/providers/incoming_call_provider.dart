import 'package:flutter_riverpod/flutter_riverpod.dart';

class IncomingCallState {
  const IncomingCallState({
    required this.callerName,
    required this.callerImage,
    required this.bookingId,
    this.recipientRole = 'client',
    this.isScheduledStart = false,
  });

  final String callerName;
  final String callerImage;
  final String bookingId;
  final String recipientRole;
  final bool isScheduledStart;
}

final incomingCallProvider = StateProvider<IncomingCallState?>((ref) => null);
