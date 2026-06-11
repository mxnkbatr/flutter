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
    return ChatMessage(
      id: json['id'] as String? ?? json['_id'] as String,
      text: json['text'] as String? ?? '',
      isMine: json['isMine'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
    );
  }
}
