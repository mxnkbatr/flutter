class Conversation {
  const Conversation({
    required this.id,
    required this.monkName,
    this.monkImage,
    this.clientName,
    this.lastMessage,
    this.lastMessageAt,
    this.monkId,
  });

  final String id;
  final String monkName;
  final String? monkImage;
  final String? clientName;
  final String? lastMessage;
  final String? lastMessageAt;
  final String? monkId;

  String get displayName {
    if (monkName.isNotEmpty) return monkName;
    if (clientName != null && clientName!.isNotEmpty) return clientName!;
    return 'Чат';
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['_id'];
    return Conversation(
      id: rawId?.toString() ?? '',
      monkName: json['monkName']?.toString() ?? '',
      monkImage: json['monkImage']?.toString(),
      clientName: json['clientName']?.toString(),
      lastMessage: json['lastMessage']?.toString(),
      lastMessageAt: json['lastMessageAt']?.toString(),
      monkId: json['monkId']?.toString(),
    );
  }
}
