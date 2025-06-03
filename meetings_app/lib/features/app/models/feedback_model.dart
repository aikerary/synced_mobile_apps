/// Feedback model for the API
class Feedback {
  final int? id;
  final int? entryId; // Entry ID from API database
  final int eventId;
  final int rating; // 1-5
  final String comment;
  final DateTime? createdAt;

  Feedback({
    this.id,
    this.entryId,
    required this.eventId,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  /// Create a Feedback from JSON
  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: _parseIntSafely(json['id']),
      entryId: _parseIntSafely(json['entry_id']),
      eventId: _parseIntSafely(json['event_id']) ?? 0,
      rating: _parseIntSafely(json['rating']) ?? 1,
      comment: json['comment'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  /// Safely parse int from dynamic value (handles String, int, double, null)
  static int? _parseIntSafely(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Convert Feedback to JSON
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'event_id': eventId,
      'rating': rating,
      'comment': comment,
    };

    if (id != null) {
      data['id'] = id;
    }

    if (entryId != null) {
      data['entry_id'] = entryId;
    }

    if (createdAt != null) {
      data['created_at'] = createdAt!.toIso8601String();
    }

    return data;
  }

  /// Create a copy of this Feedback with modified fields
  Feedback copyWith({
    int? id,
    int? entryId,
    int? eventId,
    int? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return Feedback(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      eventId: eventId ?? this.eventId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Feedback && other.id == id && other.eventId == eventId;
  }

  @override
  int get hashCode => id.hashCode ^ eventId.hashCode;

  @override
  String toString() => 'Feedback(id: $id, eventId: $eventId, rating: $rating)';
}
