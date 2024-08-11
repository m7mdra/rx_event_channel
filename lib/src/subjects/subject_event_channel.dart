import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

/// An abstract class representing a subject event channel for asynchronous
/// communication between Flutter and platform-specific code.
class SubjectEventChannel implements EventChannel {
  final Subject subject;
  final int? maxSize;
  final bool sync;

  /// Creates a [SubjectEventChannel] with the specified channel [name].
  /// and a [Subject]
  /// Optionally, a custom [codec] can be provided for encoding/decoding method
  /// calls, and a [binaryMessenger] can be specified for communication. If
  /// [binaryMessenger] is not provided, it will attempt to find an appropriate
  /// messenger using [_findBinaryMessenger].
  const SubjectEventChannel(
    this.name,
    this.subject, {
    this.codec = const StandardMethodCodec(),
    this.maxSize,
    BinaryMessenger? binaryMessenger,
  })  : _binaryMessenger = binaryMessenger,
        sync = false;

  SubjectEventChannel.behavior(
    this.name, {
    this.sync = false,
    this.codec = const StandardMethodCodec(),
    BinaryMessenger? binaryMessenger,
  })  : _binaryMessenger = binaryMessenger,
        subject = BehaviorSubject(sync: sync),
        maxSize = null;

  SubjectEventChannel.replay(
    this.name, {
    this.sync = false,
    this.maxSize,
    this.codec = const StandardMethodCodec(),
    BinaryMessenger? binaryMessenger,
  })  : _binaryMessenger = binaryMessenger,
        subject = ReplaySubject(maxSize: maxSize, sync: sync);

  SubjectEventChannel.publish(
    this.name, {
    this.sync = false,
    this.codec = const StandardMethodCodec(),
    BinaryMessenger? binaryMessenger,
  })  : _binaryMessenger = binaryMessenger,
        subject = PublishSubject(sync: sync),
        maxSize = null;

  /// The name of the event channel.
  @override
  final String name;

  /// The method codec used for encoding/decoding method calls.
  @override
  @protected
  final MethodCodec codec;

  /// The binary messenger responsible for sending/receiving messages.
  @override
  @protected
  BinaryMessenger get binaryMessenger =>
      _binaryMessenger ?? _findBinaryMessenger();
  final BinaryMessenger? _binaryMessenger;

  /// Receives a broadcast stream of events from the platform.
  ///
  /// Optionally, [arguments] can be passed to the platform method.
  /// This method establishes a communication channel with the platform and
  /// returns a stream of events received from the platform.
  @override
  Stream<dynamic> receiveBroadcastStream([dynamic arguments]) {
    final MethodChannel methodChannel = MethodChannel(name, codec);
    subject.onListen = () async {
      binaryMessenger.setMessageHandler(name, (ByteData? reply) async {
        if (reply == null) {
          subject.close();
        } else {
          try {
            subject.add(codec.decodeEnvelope(reply));
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

  /// Determines the appropriate [BinaryMessenger] instance based on the runtime context.
  ///
  /// If the app is running on a platform other than the web and is not in a
  /// background isolate, it returns a custom [BackgroundIsolateBinaryMessenger.instance].
  ///
  /// If the app is running in a web environment or in a regular isolate (not in
  /// the background), it returns the default [BinaryMessenger] instance obtained
  /// from [ServicesBinding.instance.defaultBinaryMessenger].
  BinaryMessenger _findBinaryMessenger() {
    return !kIsWeb && ServicesBinding.rootIsolateToken == null
        ? BackgroundIsolateBinaryMessenger.instance
        : ServicesBinding.instance.defaultBinaryMessenger;
  }
}
