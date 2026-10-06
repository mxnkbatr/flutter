class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.isMine,
    this.type = 'text',
    this.mediaUrl,
    this.durationSeconds = 0,
    this.createdAt,
  });

  final String id;
  final String text;
  final bool isMine;
  /// text | audio
  final String type;
  final String? mediaUrl;
  final int durationSeconds;
  final String? createdAt;

  bool get isAudio => type == 'audio' && (mediaUrl?.isNotEmpty ?? false);

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['_id'];
    final type = json['type']?.toString() ?? 'text';
    return ChatMessage(
      id: rawId?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      isMine: json['isMine'] as bool? ?? false,
      type: type == 'audio' ? 'audio' : 'text',
      mediaUrl: json['mediaUrl']?.toString(),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt']?.toString(),
    );
  }
}
