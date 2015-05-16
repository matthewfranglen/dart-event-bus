part of guava_event_bus;

/// Wraps an event that was posted, but which had no subscribers and thus could not be delivered.
///
/// Registering a DeadEvent subscriber is useful for debugging or logging, as
/// it can detect misconfigurations in a system's event distribution.
class DeadEvent {

  final Object event;

  DeadEvent(this.event);

  String toString() => "DeadEvent(${event})";
}

class SubscriberExceptionContext {

  final Object event;
  final EventBus eventBus;
  final Object subscriber;
  final MethodMirror subscriberMethod;

  SubscriberExceptionContext(this.event, this.eventBus, this.subscriber, this.subscriberMethod);
}

class _Subscription {

  final Object observer;
  final TypeMirror type;
  final InstanceMirror _observerMirror;
  final MethodMirror method;

  _Subscription(Object observer, MethodMirror method)
    : this.observer = observer,
      type = method.parameters.first.type,
      _observerMirror = reflect(observer),
      this.method = method;

  void notify(Object event) {
    invoke(_observerMirror, method, [event]);
  }
}

// vim: set ai et sw=2 syntax=dart :
