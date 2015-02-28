import 'dart:async';
import 'package:event_bus/event_bus.dart';
import 'package:unittest/unittest.dart';
import 'test_data.dart';

final String nl = "\n     ";

void main() {
  group('Given an Event Bus${nl}', () {
    EventBus bus;

    setUp(() {
      bus = new EventBus();
    });
    test('When I register an object with @Subscribe methods${nl} Then the registration is successful',
      () => when(registerListener(bus)).then(isSuccessful)
    );
    test('When I register an object with no @Subscribe methods${nl} Then the registration is successful',
      () => when(registerInvalidListener(bus)).then(isSuccessful)
    );
  });

  group('Given an Event Bus${nl} And a registered listener${nl}', () {
    EventBus bus;
    MockListener listener;

    setUp(() {
      bus = new EventBus();
      listener = new MockListener();
      bus.register(listener);
    });
    test('When I post an event to the bus${nl} Then the listener receives it',
      () => when(postEvent(bus)).then(hasReceivedEvent(listener))
    );
    test('When I post a different event to the bus${nl} Then the listener does not receive it',
      () => when(postDifferentEvent(bus)).then(hasNotReceivedEvent(listener))
    );
    test('When I unregister the listener${nl} And post an event to the bus${nl} Then the listener does not receive it',
      () => when(unregisterAndPostEvent(bus, listener)).then(hasNotReceivedEvent(listener))
    );
  });

  group('Given an Event Bus${nl} And a registered dead event listener${nl}', () {
    EventBus bus;
    DeadEventListener listener;

    setUp(() {
      bus = new EventBus();
      listener = new DeadEventListener();
      bus.register(listener);
    });
    test('When I post an event to the bus${nl} Then the listener receives it',
      () => when(postEvent(bus)).then(hasReceivedEvent(listener))
    );
    test('When I post a different event to the bus${nl} Then the listener receives it',
      () => when(postDifferentEvent(bus)).then(hasReceivedEvent(listener))
    );
    test('When I unregister the listener${nl} And post an event to the bus${nl} Then the listener does not receive it',
      () => when(unregisterAndPostEvent(bus, listener)).then(hasNotReceivedEvent(listener))
    );
  });

  group('Given an Event Bus${nl} And a registered listener${nl} And a dead event listener${nl}', () {
    EventBus bus;
    DeadEventListener listener;

    setUp(() {
      bus = new EventBus();
      listener = new DeadEventListener();
      bus.register(listener);
      bus.register(new MockListener());
    });
    test('When I post an event to the bus${nl} Then the dead event listener does not receive it',
      () => when(postEvent(bus)).then(hasNotReceivedEvent(listener))
    );
    test('When I post a different event to the bus${nl} Then the dead event listener receives it',
      () => when(postDifferentEvent(bus)).then(hasReceivedEvent(listener))
    );
    test('When I unregister the listener${nl} And post an event to the bus${nl} Then the dead event listener does not receive it',
      () => when(unregisterAndPostEvent(bus, listener)).then(hasNotReceivedEvent(listener))
    );
  });

  group('Given an Event Bus${nl} And a registered generic listener${nl}', () {
    EventBus bus;
    GenericMockListener listener;

    setUp(() {
      bus = new EventBus();
      listener = new GenericMockListener<TestEvent>();
      bus.register(listener);
    });
    test('When I post an event to the bus${nl} Then the listener receives it',
      () => when(postEvent(bus)).then(hasReceivedEvent(listener))
    );
    test('When I post a different event to the bus${nl} Then the listener does not receive it',
      () => when(postDifferentEvent(bus)).then(hasNotReceivedEvent(listener))
    );
    test('When I unregister the listener${nl} And post an event to the bus${nl} Then the listener does not receive it',
      () => when(unregisterAndPostEvent(bus, listener)).then(hasNotReceivedEvent(listener))
    );
  });

  group('Given an Event Bus${nl} And a registered permissive listener${nl}', () {
    EventBus bus;
    GenericMockListener listener;

    setUp(() {
      bus = new EventBus();
      listener = new GenericMockListener<Object>();
      bus.register(listener);
    });
    test('When I post an event to the bus${nl} Then the listener receives it',
      () => when(postEvent(bus)).then(hasReceivedEvent(listener))
    );
    test('When I post a different event to the bus${nl} Then the listener receives it',
      () => when(postDifferentEvent(bus)).then(hasReceivedEvent(listener))
    );
    test('When I unregister the listener${nl} And post an event to the bus${nl} Then the listener does not receive it',
      () => when(unregisterAndPostEvent(bus, listener)).then(hasNotReceivedEvent(listener))
    );
  });
}

typedef dynamic Clause();

Future<dynamic> given(Clause clause) => new Future.value(clause());
Future<dynamic> when(Clause clause) => new Future.value(clause());

Clause registerListener(EventBus bus) =>
  () {
    MockListener listener = new MockListener();
    bus.register(listener);
    return listener;
  };

Clause registerInvalidListener(EventBus bus) =>
  () {
    InvalidListener listener = new InvalidListener();
    bus.register(listener);
    return listener;
  };

Clause registerDeadEventListener(EventBus bus) =>
  () {
    DeadEventListener listener = new DeadEventListener();
    bus.register(listener);
    return listener;
  };

Clause postEvent(EventBus bus) =>
  () {
    bus.post(new TestEvent());
  };

Clause postDifferentEvent(EventBus bus) =>
  () {
    bus.post(new DifferentEvent());
  };

Clause unregisterAndPostEvent(EventBus bus, Object listener) =>
  () {
    bus.unregister(listener);
    bus.post(new TestEvent());
  };

void isSuccessful(dynamic value) { }

dynamic hasReceivedEvent(Listener listener) =>
  (v) {
    expect(listener.events, isNotEmpty);
  };

dynamic hasNotReceivedEvent(Listener listener) =>
  (v) {
    expect(listener.events, isEmpty);
  };

// vim: set ai et sw=2 syntax=dart :
