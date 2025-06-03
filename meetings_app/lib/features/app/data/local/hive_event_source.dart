import 'package:hive/hive.dart';
import 'package:loggy/loggy.dart';
import '../../models/event_model.dart';
import 'i_local_event_source.dart';

class HiveEventSource implements ILocalEventSource {
  static const String _eventBoxName = 'events';
  static const String _metadataBoxName = 'eventsMetadata';
  static const String _lastUpdatedKey = 'lastUpdated';

  Future<Box<Event>> get _eventBox async =>
      await Hive.openBox<Event>(_eventBoxName);

  Future<Box<dynamic>> get _metadataBox async =>
      await Hive.openBox(_metadataBoxName);

  @override
  Future<List<Event>> getAllEvents() async {
    try {
      final box = await _eventBox;
      return box.values.toList();
    } catch (e) {
      logError('Error fetching events from Hive: $e');
      return [];
    }
  }

  @override
  Future<Event?> getEventById(int id) async {
    try {
      final box = await _eventBox;
      return box.get(id);
    } catch (e) {
      logError('Error fetching event from Hive: $e');
      return null;
    }
  }

  @override
  Future<bool> addEvent(Event event) async {
    try {
      final box = await _eventBox;
      await box.put(event.id, event);
      return true;
    } catch (e) {
      logError('Error adding event to Hive: $e');
      return false;
    }
  }

  @override
  Future<bool> updateEvent(Event event) async {
    try {
      final box = await _eventBox;
      await box.put(event.id, event);
      return true;
    } catch (e) {
      logError('Error updating event in Hive: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteEvent(int id) async {
    try {
      final box = await _eventBox;
      await box.delete(id);
      return true;
    } catch (e) {
      logError('Error deleting event from Hive: $e');
      return false;
    }
  }

  @override
  Future<void> saveAllEvents(List<Event> events) async {
    try {
      final box = await _eventBox;
      final eventMap = {for (var event in events) event.id: event};
      await box.putAll(eventMap);
    } catch (e) {
      logError('Error saving all events to Hive: $e');
      throw e;
    }
  }

  @override
  Future<DateTime?> getLastUpdated() async {
    try {
      final box = await _metadataBox;
      final timestamp = box.get(_lastUpdatedKey);
      return timestamp != null ? DateTime.parse(timestamp) : null;
    } catch (e) {
      logError('Error getting last updated timestamp from Hive: $e');
      return null;
    }
  }

  @override
  Future<void> setLastUpdated(DateTime dateTime) async {
    try {
      final box = await _metadataBox;
      await box.put(_lastUpdatedKey, dateTime.toIso8601String());
    } catch (e) {
      logError('Error setting last updated timestamp in Hive: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      final box = await _eventBox;
      await box.clear();
    } catch (e) {
      logError('Error clearing events from Hive: $e');
    }
  }
}
