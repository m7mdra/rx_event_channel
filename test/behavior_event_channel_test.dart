import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rx_event_channel/rx_event_channel.dart';

import 'mock_stream_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('behavior subject channel', () {
    test('test channel emit latest event', () async {
      final name = 'channel1';
      final channel = SubjectEventChannel.behavior(name);

      final streamHandler = MockStreamSender.value([1, 2, 3, 4]);
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(channel, streamHandler);
      final broadcastStream = channel.receiveBroadcastStream();
      final stream1 = broadcastStream;
      expect(stream1, emitsInOrder([1, 2, 3, 4]));
      //simulated delayed subscription
      await Future.delayed(Duration(seconds: 1));
      final stream2 = broadcastStream;
      expect(stream2, emitsInOrder([4]));
    });

    test('test channel emit error event', () async {
      final name = 'channel1';
      final channel = SubjectEventChannel.behavior(name);
      final streamHandler = MockStreamSender.errorCode('123');
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(channel, streamHandler);
      final broadcastStream = channel.receiveBroadcastStream();
      final stream1 = broadcastStream;
      expect(stream1, emitsError(isA<PlatformException>()));
      Future.delayed(Duration(seconds: 1));
      final stream2 = broadcastStream;
      expect(stream2, emitsError(isA<PlatformException>()));
    });
  });
}
