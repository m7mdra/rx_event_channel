import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

/// An abstract class representing a subject event channel for asynchronous
/// communication between Flutter and platform-specific code.
class SubjectEventChannel implements EventChannel {
  /// Creates a [SubjectEventChannel] with the specified channel [name]
  /// and a [Subject]. Optionally, a custom [codec] can be provided for
  /// encoding/decoding method calls, and a [binaryMessenger] can be specified
  /// for communication. If [binaryMessenger] is not provided, it will attempt
  /// to find an appropriate messenger using [_findBinaryMessenger].
  ///
  /// The [name] is the name of the channel used for communication with the
  /// platform. The [subject] manages the events that are broadcasted.
  /// The [codec] specifies how to encode and decode messages between Dart
  /// and the platform. The [maxSize] is used for buffer limits in some
  /// subject types (e.g., [ReplaySubject]), and [sync] determines whether
  /// the subject is synchronous or asynchronous.
  const SubjectEventChannel(
    this.name,
    this.subject, {
    this.codec = const StandardMethodCodec(),
    this.maxSize,
    BinaryMessenger? binaryMessenger,
  })  : _binaryMessenger = binaryMessenger,
        sync = false;

  /// Creates a [SubjectEventChannel] with a [BehaviorSubject]. The [sync]
  /// parameter determines if the subject should be synchronous or asynchronous.
  ///
  /// This constructor is used for subjects that hold the most recent value
  /// and emit it to new listeners.
  SubjectEventChannel.behavior(
    this.name, {
    this.sync = false,
    this.codec = const StandardMethodCodec(),
    BinaryMessenger? binaryMessenger,
  })  : _binaryMessenger = binaryMessenger,
        subject = BehaviorSubject(sync: sync),
        maxSize = null;

  /// Creates a [SubjectEventChannel] with a [ReplaySubject]. The [sync] parameter
  /// determines if the subject should be synchronous or asynchronous, and
  /// [maxSize] specifies the buffer size for storing old events.
  ///
  /// This constructor is used for subjects that replay a set number of
  /// old values to new listeners.
  SubjectEventChannel.replay(
    this.name, {
    this.sync = false,
    this.maxSize,
    this.codec = const StandardMethodCodec(),
    BinaryMessenger? binaryMessenger,
  })  : _binaryMessenger = binaryMessenger,
        subject = ReplaySubject(maxSize: maxSize, sync: sync);

  /// Creates a [SubjectEventChannel] with a [PublishSubject]. The [sync]
  /// parameter determines if the subject should be synchronous or asynchronous.
  ///
  /// This constructor is used for subjects that broadcast new events to
  /// subscribers without retaining old events.
  SubjectEventChannel.publish(
    this.name, {
    this.sync = false,
    this.codec = const StandardMethodCodec(),
    BinaryMessenger? binaryMessenger,
  })  : _binaryMessenger = binaryMessenger,
        subject = PublishSubject(sync: sync),
        maxSize = null;

  /// The name of the event channel. This is used to identify the channel
  /// for communication with the platform.
  @override
  final String name;

  /// The subject used for managing events. This can be a [BehaviorSubject],
  /// [ReplaySubject], or [PublishSubject], depending on the constructor used.
  final Subject<dynamic> subject;

  /// The maximum number of events to retain for a [ReplaySubject]. If `null`,
  /// no limit is applied.
  final int? maxSize;

  /// Whether the subject is synchronous or asynchronous.
  final bool sync;

  /// The method codec used for encoding/decoding method calls. This codec
  /// ensures that messages are correctly serialized and deserialized between
  /// Dart and the platform.
  @override
  @protected
  final MethodCodec codec;

  /// The binary messenger responsible for sending/receiving messages. This
  /// messenger handles the low-level communication with the platform.
  @override
  @protected
  BinaryMessenger get binaryMessenger =>
      _binaryMessenger ?? _findBinaryMessenger();
  final BinaryMessenger? _binaryMessenger;

  /// Receives a broadcast stream of events from the platform. Optionally,
  /// [arguments] can be passed to the platform method. This method establishes
  /// a communication channel with the platform and returns a stream of events
  /// received from the platform.
  ///
  /// The [onListen] callback is triggered when a listener subscribes to the
  /// stream. It sets up a message handler to receive messages from the platform
  /// and starts listening to the platform method. The [onCancel] callback is
  /// triggered when the last listener unsubscribes and stops listening to the
  /// platform.
  @override
  Stream<dynamic> receiveBroadcastStream([dynamic arguments]) {
    final MethodChannel methodChannel = MethodChannel(name, codec);
    subject.onListen = () async {
      binaryMessenger.setMessageHandler(name, (ByteData? reply) async {
        if (reply == null) {
          subject.close();
        } else {
          try {
            final value = codec.decodeEnvelope(reply);
            subject.add(value);
          } on PlatformException catch (e) {
            subject.addError(e);
          }
        }
        return null;
      });
      try {
        await methodChannel.invokeMethod<void>('listen', arguments);
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'services library',
          context: ErrorDescription(
              'while activating platform stream on channel $name'),
        ));
      }
    };
    subject.onCancel = () async {
      binaryMessenger.setMessageHandler(name, null);
      try {
        await methodChannel.invokeMethod<void>('cancel', arguments);
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'services library',
          context: ErrorDescription(
              'while de-activating platform stream on channel $name'),
        ));
      }
    };

    return subject.stream;
  }

  /// Determines the appropriate [BinaryMessenger] instance based on the runtime
  /// context.
  ///
  /// If the app is running on a platform other than the web and is not in a
  /// background isolate, it returns a custom [BackgroundIsolateBinaryMessenger.instance].
  /// If the app is running in a web environment or in a regular isolate (not in
  /// the background), it returns the default [BinaryMessenger] instance obtained
  /// from [ServicesBinding.instance.defaultBinaryMessenger].
  BinaryMessenger _findBinaryMessenger() {
    return !kIsWeb && ServicesBinding.rootIsolateToken == null
        ? BackgroundIsolateBinaryMessenger.instance
        : ServicesBinding.instance.defaultBinaryMessenger;
  }
}
