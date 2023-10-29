import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

import 'subject_event_channel.dart';

/// A specialized event channel that uses [BehaviorSubject] to manage events.
///
/// Extends [SubjectEventChannel] and overrides the [newSubject] method to return
/// a [BehaviorSubject] instance. [BehaviorSubject] retains the latest event and
/// emits it to new subscribers.
class BehaviorEventChannel extends SubjectEventChannel {
  /// Creates a [BehaviorEventChannel] with the specified [name].
  ///
  /// Optionally, a custom [codec] can be provided for encoding/decoding method
  /// calls, and a [binaryMessenger] can be specified for communication.
  BehaviorEventChannel(String name,
      {MethodCodec codec = const StandardMethodCodec(),
      BinaryMessenger? binaryMessenger})
      : super(name, codec, binaryMessenger);

  /// Overrides the [newSubject] method to create a [BehaviorSubject] instance.
  ///
  /// The [maxSize] parameter specifies the maximum size of the subject's buffer.
  /// The [onListen] callback is invoked when a listener subscribes to the stream,
  /// and [onCancel] is called when the last listener unsubscribes. If [sync] is
  /// true, events are broadcast synchronously.
  /// NOTE: [maxSize] parameter has no effects here.
  @override
  Subject<dynamic> newSubject(
      {int? maxSize,
      void Function()? onListen,
      void Function()? onCancel,
      bool sync = false}) {
    // Creates and returns a new BehaviorSubject with the specified parameters.
    return BehaviorSubject(onListen: onListen, onCancel: onCancel, sync: sync);
  }
}
