import 'package:pcplus/observers/subscriber_interface.dart';

abstract class PublisherInterface {
  List<SubscriberInterface> subscribers = [];
  void subscribe(SubscriberInterface subscriber) {
    subscribers.add(subscriber);
  }

  void unsubscribe(SubscriberInterface subscriber) {
    subscribers.remove(subscriber);
  }

  void notifySubscribers() {
    for (SubscriberInterface subscriber in subscribers) {
      subscriber.updateSubscriber();
    }
  }
}