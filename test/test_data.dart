import 'package:event_bus/event_bus.dart';

abstract class Listener {

  List<Object> get events;
}

class MockListener implements Listener {

  List<Object> events;

  MockListener() : events = [];

  @Subscribe()
  void listenForEvent(TestEvent event) {
    events.add(event);
  }
}

class GenericMockListener<T> implements Listener {

  List<T> events;

  GenericMockListener() : events = [];

  @Subscribe()
  void listenForEvent(T event) {
    events.add(event);
  }
}

class InvalidListener {

  InvalidListener();
}

class TestEvent {

  TestEvent();
}

class DifferentEvent {

  DifferentEvent();
}

// vim: set ai et sw=2 syntax=dart :