import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

import 'subject_event_channel.dart';

/// A specialized event channel that uses [PublishSubject] to manage events.
///
/// Extends [SubjectEventChannel] and overrides the [newSubject] method to return
/// a [PublishSubject] instance. [PublishSubject] does not retain the latest event
/// and only emits events to active subscribers.
class PublishEventChannel extends SubjectEventChannel {
  /// Creates a [PublishEventChannel] with the specified [name].
  ///
  /// Optionally, a custom [codec] can be provided for encoding/decoding method
  /// calls, and a [binaryMessenger] can be specified for communication.
  PublishEventChannel(String name,
      {MethodCodec codec = const StandardMethodCodec(),
        BinaryMessenger? binaryMessenger})
      : super(name, codec, binaryMessenger);

  /// Overrides the [newSubject] method to create a [PublishSubject] instance.
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
    // Creates and returns a new PublishSubject with the specified parameters.
    return PublishSubject(onListen: onListen, onCancel: onCancel, sync: sync);
  }
}
