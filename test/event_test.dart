import 'dart:async';
import 'package:guava_event_bus/guava_event_bus.dart';
import 'package:unittest/unittest.dart';
import 'package:behave/behave.dart';
import 'test_data.dart';


void main() {
  testSubscriberRegistration();
  testEventDelivery();
  testDeadEventDelivery();
  testGenericTypeListener();
  testPermissiveListener();
  testExceptionThrowingListener();
}

void testSubscriberRegistration() {
  Feature feature = new Feature("Can subscribe to an Event Bus");

  feature.load(new _Steps());

  feature.scenario("Subscribing to an Event Bus")
    .given("an Event Bus")
    .when("I register an object with @Subscribe methods")
    .then("the registration is successful")
    .test();

  feature.scenario("Subscribing to an Event Bus without annotated methods")
    .given("an Event Bus")
    .when("I register an object with no @Subscribe methods")
    .then("the registration is successful")
    .test();
}

void testEventDelivery() {
  Feature feature = new Feature("Can receive events");

  feature.load(new _Steps());

  feature.scenario("Listening to an Event Bus")
    .given("an Event Bus")
    .and("a registered listener")
    .when("I post an event to the bus")
    .then("the listener receives it")
    .test();

  feature.scenario("Listening to an Event Bus delivering different messages")
    .given("an Event Bus")
    .and("a registered listener")
    .when("I post a different event to the bus")
    .then("the listener does not receive it")
    .test();

  feature.scenario("Unsubscribing from an Event Bus")
    .given("an Event Bus")
    .and("a registered listener")
    .when("I unregister the listener")
    .and("I post an event to the bus")
    .then("the listener does not receive it")
    .test();
}

void testDeadEventDelivery() {
  Feature feature = new Feature("Can receive dead events");

  feature.load(new _Steps());

  feature.scenario("Listening for Dead Events")
    .given("an Event Bus")
    .and("a registered dead event listener")
    .when("I post an event to the bus")
    .then("the dead event listener receives it")
    .test();

  feature.scenario("Listening to an Event Bus delivering different messages")
    .given("an Event Bus")
    .and("a registered dead event listener")
    .when("I post a different event to the bus")
    .then("the dead event listener receives it")
    .test();

  feature.scenario("Unsubscribing from an Event Bus")
    .given("an Event Bus")
    .and("a registered dead event listener")
    .when("I unregister the dead event listener")
    .and("I post an event to the bus")
    .then("the dead event listener does not receive it")
    .test();


  feature.scenario("Listening for Dead Events")
    .given("an Event Bus")
    .and("a registered listener")
    .and("a registered dead event listener")
    .when("I post an event to the bus")
    .then("the dead event listener does not receive it")
    .test();

  feature.scenario("Listening to an Event Bus delivering different messages")
    .given("an Event Bus")
    .and("a registered listener")
    .and("a registered dead event listener")
    .when("I post a different event to the bus")
    .then("the dead event listener receives it")
    .test();

  feature.scenario("Unsubscribing from an Event Bus")
    .given("an Event Bus")
    .and("a registered listener")
    .and("a registered dead event listener")
    .when("I unregister the listener")
    .and("I post an event to the bus")
    .then("the dead event listener receives it")
    .test();
}

void testGenericTypeListener() {
  Feature feature = new Feature("Can receive events based on generic type");

  feature.load(new _Steps());

  feature.scenario("Listening for Events by Generic Type")
    .given("an Event Bus")
    .and("a registered generic listener")
    .when("I post an event to the bus")
    .then("the generic listener receives it")
    .test();

  feature.scenario("Listening to an Event Bus delivering different messages")
    .given("an Event Bus")
    .and("a registered generic listener")
    .when("I post a different event to the bus")
    .then("the generic listener does not receive it")
    .test();

  feature.scenario("Unsubscribing from an Event Bus")
    .given("an Event Bus")
    .and("a registered generic listener")
    .when("I unregister the generic listener")
    .and("I post an event to the bus")
    .then("the generic listener does not receive it")
    .test();
}

void testPermissiveListener() {
  Feature feature = new Feature("Can receive many events based on permissive generic type");

  feature.load(new _Steps());

  feature.scenario("Listening for any Events")
    .given("an Event Bus")
    .and("a registered permissive listener")
    .when("I post an event to the bus")
    .then("the permissive listener receives it")
    .test();

  feature.scenario("Listening to an Event Bus delivering different messages")
    .given("an Event Bus")
    .and("a registered permissive listener")
    .when("I post a different event to the bus")
    .then("the permissive listener receives it")
    .test();

  feature.scenario("Unsubscribing from an Event Bus")
    .given("an Event Bus")
    .and("a registered permissive listener")
    .when("I unregister the permissive listener")
    .and("I post an event to the bus")
    .then("the permissive listener does not receive it")
    .test();
}

void testExceptionThrowingListener() {
  Feature feature = new Feature("Can handle Exceptions");

  feature.load(new _Steps());

  feature.scenario("Listening for Exceptions")
    .given("an Event Bus with an Exception Handler")
    .and("a registered exception throwing listener")
    .when("I post an event to the bus")
    .then("the exception handler receives it")
    .test();
}

class _Steps {

  EventBus getEventBus(Map<String, dynamic> context) =>
    context["bus"] as EventBus;

  void makeEventBus(Map<String, dynamic> context, EventBus bus) {
    context["bus"] = bus;
  }

  @Given("a registered dead event listener")
  void registerDeadEventListener(Map<String, dynamic> context) {
    context["dead event listener"] = new DeadEventListener();
    getEventBus(context).register(context["dead event listener"]);
  }

  @Given("a registered exception throwing listener")
  void registerExceptionThrowingListener(Map<String, dynamic> context) {
    context["exception throwing listener"] = new ExceptionThrowingListener<TestEvent>();
    getEventBus(context).register(context["exception throwing listener"]);
  }

  @Given("a registered generic listener")
  void registerGenericMockListener(Map<String, dynamic> context) {
    context["generic listener"] = new GenericMockListener<TestEvent>();
    getEventBus(context).register(context["generic listener"]);
  }

  @Given("a registered listener")
  void registerListener(Map<String, dynamic> context) {
    context["listener"] = new MockListener();
    getEventBus(context).register(context["listener"]);
  }

  @Given("a registered permissive listener")
  void registerPermissiveListener(Map<String, dynamic> context) {
    context["permissive listener"] = new GenericMockListener<Object>();
    getEventBus(context).register(context["permissive listener"]);
  }

  @Given("an Event Bus with an Exception Handler")
  void createExceptionHandlingEventBus(Map<String, dynamic> context) {
    context["exception handler"] = new ExceptionListener();
    makeEventBus(context, new EventBus.withExceptionHandler(context["exception handler"]));
  }

  @Given("an Event Bus")
  void createEventBus(Map<String, dynamic> context) {
    makeEventBus(context, new EventBus());
  }

  @When("I post a different event to the bus")
  void postDifferentEvent(Map<String, dynamic> context) {
    getEventBus(context).post(new DifferentEvent());
  }

  @When("I post an event to the bus")
  void postEvent(Map<String, dynamic> context) {
    getEventBus(context).post(new TestEvent());
  }

  @When("I register an object with @Subscribe methods")
  void registerObjectWithMethods(Map<String, dynamic> context) {
    getEventBus(context).register(new MockListener());
  }

  @When("I register an object with no @Subscribe methods")
  void registerObjectWithNoMethods(Map<String, dynamic> context) {
    getEventBus(context).register(new InvalidListener());
  }

  @When("I unregister the dead event listener")
  void unregisterDeadEventListener(Map<String, dynamic> context) {
    DeadEventListener deadEventListener = context["dead event listener"] as DeadEventListener;
    getEventBus(context).unregister(deadEventListener);
  }

  @When("I unregister the generic listener")
  void unregisterGenericListener(Map<String, dynamic> context) {
    GenericMockListener genericListener = context["generic listener"] as GenericMockListener;
    getEventBus(context).unregister(genericListener);
  }

  @When("I unregister the listener")
  void unregisterListener(Map<String, dynamic> context) {
    MockListener listener = context["listener"] as MockListener;
    getEventBus(context).unregister(listener);
  }

  @When("I unregister the permissive listener")
  void unregisterPermissiveListener(Map<String, dynamic> context) {
    GenericMockListener permissiveListener = context["permissive listener"] as GenericMockListener;
    getEventBus(context).unregister(permissiveListener);
  }

  @Then("the dead event listener does not receive it")
  void testDeadEventListenerDoesNotReceiveEvent(Map<String, dynamic> context) {
    expect((context["dead event listener"] as Listener).events, isEmpty);
  }

  @Then("the dead event listener receives it")
  void testDeadEventListenerDoesReceiveEvent(Map<String, dynamic> context) {
    expect((context["dead event listener"] as Listener).events, isNotEmpty);
  }

  @Then("the exception handler receives it")
  void testExceptionHandlerDoesReceiveEvent(Map<String, dynamic> context) {
    expect((context["exception handler"] as Listener).events, isNotEmpty);
  }

  @Then("the generic listener does not receive it")
  void testGenericListenerDoesNotReceiveEvent(Map<String, dynamic> context) {
    expect((context["generic listener"] as Listener).events, isEmpty);
  }

  @Then("the generic listener receives it")
  void testGenericListenerDoesReceiveEvent(Map<String, dynamic> context) {
    expect((context["generic listener"] as Listener).events, isNotEmpty);
  }

  @Then("the listener does not receive it")
  void testListenerDoesNotReceiveEvent(Map<String, dynamic> context) {
    expect((context["listener"] as Listener).events, isEmpty);
  }

  @Then("the listener receives it")
  void testListenerDoesReceiveEvent(Map<String, dynamic> context) {
    expect((context["listener"] as Listener).events, isNotEmpty);
  }

  @Then("the permissive listener does not receive it")
  void testPermissiveListenerDoesNotReceiveEvent(Map<String, dynamic> context) {
    expect((context["permissive listener"] as Listener).events, isEmpty);
  }

  @Then("the permissive listener receives it")
  void testPermissiveListenerDoesReceiveEvent(Map<String, dynamic> context) {
    expect((context["permissive listener"] as Listener).events, isNotEmpty);
  }

  @Then("the registration is successful")
  void testRegistrationSucceeds(Map<String, dynamic> context, ContextFunction previous) {
    expect(() => previous(context), returnsNormally);
  }
}

// vim: set ai et sw=2 syntax=dart :
