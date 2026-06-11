import 'package:flutter_riverpod/flutter_riverpod.dart';

class IncomingCallState {
  const IncomingCallState({
    required this.callerName,
    required this.callerImage,
    required this.bookingId,
  });

  final String callerName;
  final String callerImage;
  final String bookingId;
}

final incomingCallProvider = StateProvider<IncomingCallState?>((ref) => null);
