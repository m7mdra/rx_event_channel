import 'package:rxdart/rxdart.dart';
import 'package:flutter/services.dart';

import 'subject_event_channel.dart';

/// A specialized event channel that uses [ReplaySubject] to manage events.
///
/// Extends [SubjectEventChannel] and overrides the [newSubject] method to return
/// a [ReplaySubject] instance. [ReplaySubject] retains a buffer of events and
/// replays them to new subscribers, limited by the specified buffer size.
class ReplayEventChannel extends SubjectEventChannel {
  /// Creates a [ReplayEventChannel] with the specified [name].
  ///
  /// Optionally, a custom [codec] can be provided for encoding/decoding method
  /// calls, and a [binaryMessenger] can be specified for communication.
  ReplayEventChannel(String name,
      {MethodCodec codec = const StandardMethodCodec(),
        BinaryMessenger? binaryMessenger})
      : super(name, codec, binaryMessenger);

  /// Overrides the [newSubject] method to create a [ReplaySubject] instance.
  ///
  /// The [maxSize] parameter specifies the maximum size of the subject's buffer.
  /// The [onListen] callback is invoked when a listener subscribes to the stream,
  /// and [onCancel] is called when the last listener unsubscribes. If [sync] is
  /// true, events are broadcast synchronously.
  @override
  Subject<dynamic> newSubject(
      {int? maxSize,
        void Function()? onListen,
        void Function()? onCancel,
        bool sync = false}) {
    // Creates and returns a new ReplaySubject with the specified parameters.
    return ReplaySubject(
      maxSize: maxSize,
      onListen: onListen,
      onCancel: onCancel,
      sync: sync,
    );
  }
}
