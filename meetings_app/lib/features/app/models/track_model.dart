/// Track model for the API
class Track {
  final int? id;
  final String nombre;

  Track({
    this.id,
    required this.nombre,
  });

  /// Create a Track from API JSON
  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as int?,
      nombre: json['nombre'] as String,
    );
  }

  /// Convert Track to JSON for API
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'nombre': nombre,
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  /// Create a copy of this Track with modified fields
  Track copyWith({
    int? id,
    String? nombre,
  }) {
    return Track(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Track && other.id == id && other.nombre == nombre;
  }

  @override
  int get hashCode => id.hashCode ^ nombre.hashCode;

  @override
  String toString() => 'Track(id: $id, nombre: $nombre)';
}
