part of guava_event_bus;

/// Subscribe annotates a method that can receive EventBus Events.
///
/// The method must take a single parameter.
/// The method parameter type is used to determine the events to receive.
/// If the posted event is assignable to the type then the method will be called.
///
///     @subscribe
///     void notify(Event event) {}
///
///     @subscribe
///     void notifyOnSubtype(EventSubtype event) {}
class Subscribe {
  const Subscribe();
}

const Subscribe subscribe = const Subscribe();

// vim: set ai et sw=2 syntax=dart :
