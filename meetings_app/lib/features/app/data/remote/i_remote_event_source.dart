// lib/features/app/data/remote/i_remote_event_source.dart

import 'package:meetings_app/features/app/models/event_model.dart';

abstract class IRemoteEventSource {
  Future<List<Event>> getAllEvents();
  Future<Event> getEventById(int id);
  Future<bool> addEvent(Event event);
  Future<bool> updateEvent(Event event);
  Future<bool> deleteEvent(int id);
  Future<DateTime?> getLastUpdated();
}
