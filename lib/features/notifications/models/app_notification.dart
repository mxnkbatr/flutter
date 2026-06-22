enum AppNotificationType {
  booking,
  message,
  promo,
  legal,
  system,
  call,
}

AppNotificationType notificationTypeFromString(String? value) {
  switch (value) {
    case 'message':
      return AppNotificationType.message;
    case 'promo':
      return AppNotificationType.promo;
    case 'legal':
      return AppNotificationType.legal;
    case 'call':
      return AppNotificationType.call;
    case 'system':
      return AppNotificationType.system;
    default:
      return AppNotificationType.booking;
  }
}

String notificationTypeToString(AppNotificationType type) {
  switch (type) {
    case AppNotificationType.message:
      return 'message';
    case AppNotificationType.promo:
      return 'promo';
    case AppNotificationType.legal:
      return 'legal';
    case AppNotificationType.call:
      return 'call';
    case AppNotificationType.system:
      return 'system';
    case AppNotificationType.booking:
      return 'booking';
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.category = '',
    this.actionPath = '',
    this.refId = '',
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final AppNotificationType type;
  final String category;
  final String actionPath;
  final String refId;
  final DateTime createdAt;
  final bool isRead;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: notificationTypeFromString(json['type'] as String?),
      category: json['category'] as String? ?? '',
      actionPath: json['actionPath'] as String? ?? '',
      refId: json['refId'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      category: category,
      actionPath: actionPath,
      refId: refId,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
