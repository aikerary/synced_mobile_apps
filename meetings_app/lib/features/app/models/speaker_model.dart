/// Speaker model for the API
class Speaker {
  final int? id;
  final int? entryId; // Entry ID from API database
  final String name;

  Speaker({
    this.id,
    this.entryId,
    required this.name,
  });

  /// Create a Speaker from JSON
  factory Speaker.fromJson(Map<String, dynamic> json) {
    // Parse entry_id (can be String or int from API)
    int? entryId;
    if (json['entry_id'] != null) {
      if (json['entry_id'] is String) {
        entryId = int.tryParse(json['entry_id']);
      } else if (json['entry_id'] is int) {
        entryId = json['entry_id'];
      }
    }
    
    return Speaker(
      id: _parseIntSafely(json['id']),
      entryId: entryId,
      name: json['name'] as String? ?? '',
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

  /// Convert Speaker to JSON
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'name': name,
    };

    if (id != null) {
      data['id'] = id;
    }

    if (entryId != null) {
      data['entry_id'] = entryId;
    }

    return data;
  }

  /// Create a copy of this Speaker with modified fields
  Speaker copyWith({
    int? id,
    int? entryId,
    String? name,
  }) {
    return Speaker(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Speaker && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'Speaker(id: $id, name: $name)';
}
