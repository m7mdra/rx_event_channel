import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

/// An abstract class representing a subject event channel for asynchronous
/// communication between Flutter and platform-specific code.
abstract class SubjectEventChannel implements EventChannel {
  /// Creates a [SubjectEventChannel] with the specified channel [name].
  ///
  /// Optionally, a custom [codec] can be provided for encoding/decoding method
  /// calls, and a [binaryMessenger] can be specified for communication. If
  /// [binaryMessenger] is not provided, it will attempt to find an appropriate
  /// messenger using [_findBinaryMessenger].
  const SubjectEventChannel(this.name,
      [this.codec = const StandardMethodCodec(),
      BinaryMessenger? binaryMessenger])
      : _binaryMessenger = binaryMessenger;

  /// The name of the event channel.
  @override
  final String name;

  /// The method codec used for encoding/decoding method calls.
  @override
  final MethodCodec codec;

  /// The binary messenger responsible for sending/receiving messages.
  @override
  BinaryMessenger get binaryMessenger =>
      _binaryMessenger ?? _findBinaryMessenger();
  final BinaryMessenger? _binaryMessenger;

  /// Creates a new subject to manage events received from the platform.
  ///
  /// The [maxSize] parameter specifies the maximum size of the subject's buffer.
  /// This parameter only applies when using a [ReplaySubject]. If [maxSize] is
  /// provided and a [ReplaySubject] is created, it limits the number of previous
  /// events that are replayed to new subscribers.
  ///
  /// The [onListen] callback is invoked when a listener subscribes to the stream,
  /// and [onCancel] is called when the last listener unsubscribes. If [sync] is
  /// true, events are broadcast synchronously.
  Subject<dynamic> newSubject(
      {int? maxSize,
      void Function()? onListen,
      void Function()? onCancel,
      bool sync = false});

  /// Receives a broadcast stream of events from the platform.
  ///
  /// Optionally, [arguments] can be passed to the platform method.
  /// This method establishes a communication channel with the platform and
  /// returns a stream of events received from the platform.
  @override
  Stream<dynamic> receiveBroadcastStream([dynamic arguments]) {
    final MethodChannel methodChannel = MethodChannel(name, codec);
    late Subject controller;
    controller = newSubject(onListen: () async {
      binaryMessenger.setMessageHandler(name, (ByteData? reply) async {
        if (reply == null) {
          controller.close();
        } else {
          try {
            controller.add(codec.decodeEnvelope(reply));
          } on PlatformException catch (e) {
            controller.addError(e);
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
    }, onCancel: () async {
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
    });
    return controller.stream;
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
