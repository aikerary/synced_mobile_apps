class EventComment {
  final String id;
  final int eventId;
  final String content;
  final int rating;
  final DateTime datePosted;
  final bool isAnonymous;
  final String? userId; // Can be null for anonymous comments

  EventComment({
    required this.id,
    required this.eventId,
    required this.content,
    required this.rating,
    required this.datePosted,
    this.isAnonymous = false,
    this.userId,
  });

  factory EventComment.fromJson(Map<String, dynamic> json) {
    return EventComment(
      id: json['id'],
      eventId: json['eventId'],
      content: json['content'],
      rating: json['rating'] ?? 0,
      datePosted: DateTime.parse(json['datePosted']),
      isAnonymous: json['isAnonymous'] ?? false,
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'content': content,
      'rating': rating,
      'datePosted': datePosted.toIso8601String(),
      'isAnonymous': isAnonymous,
      'userId': userId,
    };
  }
}
