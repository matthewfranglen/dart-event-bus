Guava Event Bus
===============

This library provides a Google Guava style Event Bus.

EventBus allows publish-subscribe-style communication between components without requiring the components to explicitly register with one another (and thus be aware of each other). It is designed exclusively to replace traditional in-process event distribution using explicit registration. It is not a general-purpose publish-subscribe system, nor is it intended for interprocess communication.

Synopsis
--------

    // Class is typically registered by the container.
    class EventBusChangeRecorder {
      @subscribe void recordCustomerChange(ChangeEvent e) {
        recordChange(e.getChange());
      }
    }

    // somewhere during initialization
    eventBus.register(new EventBusChangeRecorder());

    // much later
    public void changeCustomer() {
      ChangeEvent event = getChangeEvent();
      eventBus.post(event);
    }

You can create the event bus with a callback to receive details about exceptions which are thrown by subscribers.

    ExceptionHandler handler = (var exception, StackTrace stackTrace, SubscriberExceptionContext context) {
      print(context.event);
    };

    eventBus = new EventBus.withExceptionHandler(handler);

The exception handler is a typedef, and as such is expected to be a function. To use a class instead just implement the _call_ method:

    class CustomExceptionHandler {
      void call(var exception, StackTrace stackTrace, SubscriberExceptionContext context) {
        print(context.event);
      }
    }

    eventBus = new EventBus.withExceptionHandler(new CustomExceptionHandler());

For Listeners
-------------

To listen for a specific flavor of event (say, a CustomerChangeEvent) with EventBus: create a method that accepts CustomerChangeEvent as its sole argument, and mark it with the Subscribe annotation.

To register your listener methods with the event producers with EventBus: pass your object to the EventBus.register(Object) method on an EventBus. You'll need to make sure that your object shares an EventBus instance with the event producers.

To listen for a common event supertype (such as EventObject or Object) with EventBus: events are automatically dispatched to listeners of any supertype, allowing listeners for interface types or "wildcard listeners" for Object.

To listen for and detect events that were dispatched without listeners with EventBus: subscribe to DeadEvent. The EventBus will notify you of any events that were posted but not delivered. (Handy for debugging.)

For Producers
-------------

To keep track of listeners to your events with EventBus: EventBus does this for you.

To dispatch an event to listeners with EventBus: pass the event object to an EventBus's EventBus.post(Object) method.
