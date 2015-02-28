part of event_bus;

class _Subscription {

  final Object observer;
  final TypeMirror type;
  final InstanceMirror _observerMirror;
  final MethodMirror _method;

  _Subscription(Object observer, MethodMirror method)
    : this.observer = observer,
      type = method.parameters.first.type,
      _observerMirror = reflect(observer),
      _method = method;

  void notify(Object event) {
    invoke(_observerMirror, _method, [event]);
  }
}

// vim: set ai et sw=2 syntax=dart :
