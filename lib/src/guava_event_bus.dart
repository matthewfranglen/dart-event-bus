part of guava_event_bus;

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

  final Map<TypeMirror, List<_Subscription>> _subscriptions;
  final ExceptionHandler _exceptionHandler;

  EventBus()
    : _subscriptions = {},
      _exceptionHandler = null;

  EventBus.withExceptionHandler(ExceptionHandler handler)
    : _subscriptions = {},
      _exceptionHandler = handler;

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
    reflect(observer).type.instanceMembers.values
      .where(DeclarationAnnotationFacade.filterByAnnotation(Subscribe))
      .where(_validateMethodParameters)
      .forEach(_register(observer));
  }

  /// Unregisters all subscriber methods on a registered object.
  ///
  ///     eventBus.unregister(observer);
  void unregister(Object observer) {
    _subscriptions.values.forEach(_unregister(observer));
  }

  /// Posts an event to all registered subscribers.
  ///
  /// This method will return successfully after the event has been posted to
  /// all subscribers, and regardless of any exceptions thrown by subscribers.
  ///
  ///     eventBus.post(new Event());
  void post(Object event) {
    Iterable<_Subscription> subscriptions =
      _subscriptions.keys
        .where(_isAssignable(event))
        .expand(_typeToSubscriptions);

    if (subscriptions.isNotEmpty) {
      subscriptions.forEach(_post(event));
    }
    else if (event is ! DeadEvent) {
      post(new DeadEvent(event));
    }
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

  _SubscribeMethod _register(Object observer) =>
    (MethodMirror method) {
      _Subscription subscription = new _Subscription(observer, method);

      if (!_subscriptions.containsKey(subscription.type)) {
        _subscriptions[subscription.type] = [];
      }
      _subscriptions[subscription.type].add(subscription);
    };

  _UnsubscribeMethod _unregister(Object observer) =>
    (List<_Subscription> subscribers) {
      subscribers.removeWhere(
        (_Subscription subscription) => subscription.observer == observer
      );
    };

  _TypeMirrorFilter _isAssignable(Object event) =>
    (TypeMirror type) => isSubtypeOf(reflectClass(event.runtimeType), type);

  List<_Subscription> _typeToSubscriptions(TypeMirror type) => _subscriptions[type];

  _PostMethod _post(Object event) =>
    (_Subscription subscription) {
      try {
        subscription.notify(event);
      }
      catch (exception, stackTrace) {
        _handleException(event, subscription, exception, stackTrace);
      }
    };

  void _handleException(Object event, _Subscription subscription, var exception, StackTrace stackTrace) {
    if (_exceptionHandler != null) {
      SubscriberExceptionContext context =
        new SubscriberExceptionContext(event, this, subscription.observer, subscription.method);

      _exceptionHandler(exception, stackTrace, context);
    }
  }
}

typedef void ExceptionHandler(var exception, StackTrace stackTrace, SubscriberExceptionContext context);

typedef void _SubscribeMethod(MethodMirror method);
typedef void _UnsubscribeMethod(List<_Subscription> subscribers);
typedef void _PostMethod(_Subscription observer);
typedef bool _TypeMirrorFilter(TypeMirror event);

// vim: set ai et sw=2 syntax=dart :
