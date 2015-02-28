part of event_bus;

/// EventBus allows publish-subscribe-style communication between components
/// without requiring the components to explicitly register with one another
/// (and thus be aware of each other).
///
/// It is designed exclusively to replace traditional in-process event
/// distribution using explicit registration. It is not a general-purpose
/// publish-subscribe system, nor is it intended for interprocess
/// communication.
///
///     class EventBusSubscriber {
///       @Subscribe()
///       void notify(Event event) {}
///     }
///     ...
///     eventBus.register(new EventBusSubscriber());
///     ...
///     eventBus.post(new Event());
class EventBus {

  final Map<TypeMirror, List<_NotifyListener>> _listeners;

  EventBus() : _listeners = {};

  /// Registers all [Subscriber] methods on [observer] to receive events.
  ///
  /// Any methods on the [observer] that are annotated with [Subscriber] and
  /// take a single parameter will receive any events posted to the [EventBus]
  /// which can be assigned to that parameter.
  ///
  ///     class EventBusSubscriber {
  ///       @Subscribe()
  ///       void notify(Event event) {}
  ///     }
  ///     ...
  ///     eventBus.register(new EventBusSubscriber());
  void register(Object observer) {
    InstanceMirror observerMirror = reflect(observer);

    observerMirror.type.instanceMembers.values
      .where(DeclarationAnnotationFacade.filterByAnnotation(Subscribe))
      .where(_validateMethodParameters)
      .forEach((MethodMirror method) {
        _subscribe(observerMirror, method);
      });
  }

  /// Posts an event to all registered subscribers.
  ///
  /// This method will return successfully after the event has been posted to
  /// all subscribers, and regardless of any exceptions thrown by subscribers.
  ///
  ///     eventBus.post(new Event());
  void post(Object event) {
    _listeners.keys
      .where(_isAssignable(event))
      .expand((TypeMirror type) => _listeners[type])
      .forEach((_NotifyListener notify) {
        try {
          notify(event);
        }
        catch (exception) {}
      });
  }

  bool _validateMethodParameters(MethodMirror method) {
    if (method.parameters.isEmpty) {
      print("Rejecting @Subscribe on ${method.simpleName}: No parameters available");
      return false;
    }
    else if (method.parameters.length > 1) {
      print("Rejecting @Subscribe on ${method.simpleName}: Too many parameters available");
      return false;
    }
    return true;
  }

  TypeMirror _getEventParameterType(MethodMirror method) =>
    method.parameters.first.type;

  void _subscribe(InstanceMirror observer, MethodMirror method) {
    TypeMirror type = _getEventParameterType(method);

    if (!_listeners.containsKey(type)) {
      _listeners[type] = [];
    }
    _listeners[type].add((Object event) {
      observer.invoke(method.simpleName, [event]);
    });
  }

  _TypeMirrorFilter _isAssignable(Object event) =>
    (TypeMirror type) => isSubtypeOf(reflectClass(event.runtimeType), type);
}

typedef void _NotifyListener(Object event);
typedef bool _TypeMirrorFilter(TypeMirror event);

// vim: set ai et sw=2 syntax=dart :
