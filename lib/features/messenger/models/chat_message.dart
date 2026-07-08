class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.isMine,
    this.createdAt,
  });

  final String id;
  final String text;
  final bool isMine;
  final String? createdAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['_id'];
    return ChatMessage(
      id: rawId?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      isMine: json['isMine'] as bool? ?? false,
      createdAt: json['createdAt']?.toString(),
    );
  }
}
