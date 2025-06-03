import 'package:flutter_test/flutter_test.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/features/app/models/speaker_model.dart';
import 'package:meetings_app/features/app/models/feedback_model.dart';
import 'package:meetings_app/features/app/models/track_model.dart';
import 'package:meetings_app/utils/config/app_config.dart';
import 'package:meetings_app/utils/constants/api_constants.dart';

void main() {
  group('API Integration Tests', () {
    test('AppConfig has valid contract key', () {
      expect(AppConfig.contractKey, isNotEmpty);
      expect(AppConfig.contractKey, isNot('YOUR_CONTRACT_KEY_HERE'));
      expect(AppConfig.baseUrl, contains('unidb.openlab.uninorte.edu.co'));
    });

    test('ApiConstants generates correct URLs', () {
      final eventsUrl = ApiConstants.buildAllDataUrl(ApiConstants.eventsTable);
      expect(eventsUrl, contains('bolt1234'));
      expect(eventsUrl, contains('events'));
      expect(eventsUrl, contains('all'));
    });

    test('Event model can be created from API JSON', () {
      final json = {
        'id': 1,
        'titulo': 'Test Event',
        'descripcion': 'Test Description',
        'tema': 'Test Theme',
        'ponente_id': 1,
        'fecha': '2024-12-25T10:00:00.000Z',
        'hora_inicio': '10:00',
        'hora_fin': '11:00',
        'max_participantes': 100,
        'suscritos': 50,
        'imageUrl': 'test.jpg'
      };

      final event = Event.fromJson(json);

      expect(event.id, 1);
      expect(event.titulo, 'Test Event');
      expect(event.descripcion, 'Test Description');
      expect(event.tema, 'Test Theme');
      expect(event.ponenteId, 1);
      expect(event.maxParticipantes, 100);
      expect(event.suscritos, 50);
    });

    test('Speaker model can be created from API JSON', () {
      final json = {
        'id': 1,
        'name': 'John Doe',
      };

      final speaker = Speaker.fromJson(json);

      expect(speaker.id, 1);
      expect(speaker.name, 'John Doe');
    });

    test('Feedback model can be created from API JSON', () {
      final json = {
        'id': 1,
        'event_id': 1,
        'rating': 5,
        'comment': 'Great event!',
        'created_at': '2024-12-25T10:00:00.000Z'
      };

      final feedback = Feedback.fromJson(json);

      expect(feedback.id, 1);
      expect(feedback.eventId, 1);
      expect(feedback.rating, 5);
      expect(feedback.comment, 'Great event!');
      expect(feedback.createdAt, isNotNull);
    });

    test('Track model can be created from API JSON', () {
      final json = {
        'id': 1,
        'nombre': 'Technology',
      };

      final track = Track.fromJson(json);

      expect(track.id, 1);
      expect(track.nombre, 'Technology');
    });

    test('Event model serializes to JSON correctly', () {
      final event = Event(
        id: 1,
        titulo: 'Test Event',
        descripcion: 'Test Description',
        tema: 'Test Theme',
        ponenteId: 1,
        fecha: DateTime(2024, 12, 25, 10, 0),
        horaInicio: '10:00',
        horaFin: '11:00',
        maxParticipantes: 100,
        suscritos: 50,
        imageUrl: 'test.jpg',
      );

      final json = event.toJson();

      expect(json['id'], 1);
      expect(json['titulo'], 'Test Event');
      expect(json['descripcion'], 'Test Description');
      expect(json['tema'], 'Test Theme');
      expect(json['ponente_id'], 1);
      expect(json['max_participantes'], 100);
      expect(json['suscritos'], 50);
    });

    test('Event model copyWith works correctly', () {
      final originalEvent = Event(
        id: 1,
        titulo: 'Original Title',
        descripcion: 'Original Description',
        tema: 'Original Theme',
        fecha: DateTime(2024, 12, 25),
        horaInicio: '10:00',
        horaFin: '11:00',
        maxParticipantes: 100,
        suscritos: 50,
      );

      final copiedEvent = originalEvent.copyWith(
        titulo: 'New Title',
        suscritos: 75,
      );

      expect(copiedEvent.id, 1);
      expect(copiedEvent.titulo, 'New Title');
      expect(copiedEvent.descripcion, 'Original Description');
      expect(copiedEvent.suscritos, 75);
      expect(copiedEvent.maxParticipantes, 100);
    });
  });
}
