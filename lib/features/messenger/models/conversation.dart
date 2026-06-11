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

  String get displayName => monkName.isNotEmpty ? monkName : (clientName ?? '');

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String? ?? json['_id'] as String,
      monkName: json['monkName'] as String? ?? '',
      monkImage: json['monkImage'] as String?,
      clientName: json['clientName'] as String?,
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: json['lastMessageAt'] as String?,
      monkId: json['monkId'] as String?,
    );
  }
}
