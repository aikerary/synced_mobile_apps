import 'speaker_model.dart';

class Event {
  final int? id;
  final int? entryId; // Entry ID from API database
  final String titulo;
  final String descripcion;
  final String tema;
  final int? ponenteId; // Foreign key to speakers table
  final String? ponenteNombre; // Speaker name directly from event data
  final List<String> invitadosEspeciales; // Guest speakers names directly from event data
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;
  final int maxParticipantes;
  final int suscritos;
  final String imageUrl;

  // Additional fields for UI (not stored in API)
  final Speaker? ponente; // Speaker object for display
  final List<Speaker> speakers; // List of all speakers for this event
  final List<String> trackNames; // Track names for display

  Event({
    this.id,
    this.entryId,
    required this.titulo,
    required this.descripcion,
    required this.tema,
    this.ponenteId,
    this.ponenteNombre,
    this.invitadosEspeciales = const [],
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.maxParticipantes,
    this.suscritos = 0,
    this.imageUrl = 'assets/images/event.jpg',
    this.ponente,
    this.speakers = const [],
    this.trackNames = const [],
  });

  /// Create an Event from API JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    // Parse invitados_especiales array
    List<String> invitados = [];
    if (json['invitados_especiales'] != null) {
      if (json['invitados_especiales'] is List) {
        invitados = (json['invitados_especiales'] as List)
            .map((item) => item.toString())
            .toList();
      }
    }
    
    return Event(
      id: _parseIntSafely(json['id']),
      entryId: _parseIntSafely(json['entry_id']),
      titulo: json['titulo'] as String? ?? 'Sin título',
      descripcion: json['descripcion'] as String? ?? 'Sin descripción',
      tema: json['tema'] as String? ?? 'Sin tema',
      ponenteId: _parseIntSafely(json['ponente_id']),
      ponenteNombre: json['ponente'] as String?,
      invitadosEspeciales: invitados,
      fecha: DateTime.parse(json['fecha'] as String),
      horaInicio: json['hora_inicio'] as String? ?? '',
      horaFin: json['hora_fin'] as String? ?? '',
      maxParticipantes: _parseIntSafely(json['max_participantes']) ?? 0,
      suscritos: _parseIntSafely(json['suscritos']) ?? 0,
      imageUrl: json['imageUrl'] as String? ?? 'assets/images/event.jpg',
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

  /// Convert Event to JSON for API
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'titulo': titulo,
      'descripcion': descripcion,
      'tema': tema,
      'fecha': fecha.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'max_participantes': maxParticipantes,
      'suscritos': suscritos,
      'imageUrl': imageUrl,
    };

    if (id != null) {
      data['id'] = id;
    }

    if (entryId != null) {
      data['entry_id'] = entryId;
    }

    if (ponenteId != null) {
      data['ponente_id'] = ponenteId;
    }

    return data;
  }

  /// Create a copy of this Event with modified fields
  Event copyWith({
    int? id,
    int? entryId,
    String? titulo,
    String? descripcion,
    String? tema,
    int? ponenteId,
    String? ponenteNombre,
    List<String>? invitadosEspeciales,
    DateTime? fecha,
    String? horaInicio,
    String? horaFin,
    int? maxParticipantes,
    int? suscritos,
    String? imageUrl,
    Speaker? ponente,
    List<Speaker>? speakers,
    List<String>? trackNames,
  }) {
    return Event(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      tema: tema ?? this.tema,
      ponenteId: ponenteId ?? this.ponenteId,
      ponenteNombre: ponenteNombre ?? this.ponenteNombre,
      invitadosEspeciales: invitadosEspeciales ?? this.invitadosEspeciales,
      fecha: fecha ?? this.fecha,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      maxParticipantes: maxParticipantes ?? this.maxParticipantes,
      suscritos: suscritos ?? this.suscritos,
      imageUrl: imageUrl ?? this.imageUrl,
      ponente: ponente ?? this.ponente,
      speakers: speakers ?? this.speakers,
      trackNames: trackNames ?? this.trackNames,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Event(id: $id, titulo: $titulo, fecha: $fecha)';
}
