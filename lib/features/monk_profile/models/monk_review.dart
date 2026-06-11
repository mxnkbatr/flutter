class MonkReview {
  const MonkReview({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  factory MonkReview.fromJson(Map<String, dynamic> json) {
    return MonkReview(
      id: json['id'] as String? ?? json['_id'] as String,
      userName: json['userName'] as String? ?? json['user'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
