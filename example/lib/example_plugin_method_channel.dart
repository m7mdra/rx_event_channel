import 'package:flutter/foundation.dart';
import 'package:rx_event_channel/rx_event_channel.dart';

import 'example_plugin_platform_interface.dart';

/// An implementation of [ExamplePluginPlatform] that uses method channels.
class MethodChannelExamplePlugin extends ExamplePluginPlatform {
  @visibleForTesting
  final SubjectEventChannel behaviorEventChannel =
      SubjectEventChannel.behavior('example.channel1');
  @visibleForTesting
  final SubjectEventChannel replayEventChannel =
      SubjectEventChannel.replay('example.channel2');
  @visibleForTesting
  final SubjectEventChannel publishEventChannel =
      SubjectEventChannel.publish('example.channel3');

  @override
  Stream<int> valuesBehaviorSubject() {
    return behaviorEventChannel.receiveBroadcastStream().cast();
  }

  @override
  Stream<int> valuesPublishSubject() {
    return publishEventChannel.receiveBroadcastStream().cast();
  }

  @override
  Stream<int> valuesReplaySubject() {
    return replayEventChannel.receiveBroadcastStream().cast();
  }
}
