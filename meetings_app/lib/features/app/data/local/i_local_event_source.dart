import '../../models/event_model.dart';

abstract class ILocalEventSource {
  Future<List<Event>> getAllEvents();
  Future<Event?> getEventById(int id);
  Future<bool> addEvent(Event event);
  Future<bool> updateEvent(Event event);
  Future<bool> deleteEvent(int id);
  Future<void> saveAllEvents(List<Event> events);
  Future<DateTime?> getLastUpdated();
  Future<void> setLastUpdated(DateTime dateTime);
  Future<void> clear();
}
