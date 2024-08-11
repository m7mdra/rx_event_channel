import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rx_event_channel/rx_event_channel.dart';

import 'mock_stream_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('replay subject channel', () {
    test('test channel replaying with all previous event', () async {
      final name = 'channel1';
      final channel = SubjectEventChannel.replay(name, maxSize: 4);
      var streamHandler = MockStreamSender.value([1, 2, 3, 4, 5]);
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(channel, streamHandler);
      final broadcastStream = channel.receiveBroadcastStream();
      final stream1 = broadcastStream;
      final stream2 = broadcastStream;
      expect(stream1, emitsInOrder([1, 2, 3, 4]));
      //simulated delayed subscription
      await Future.delayed(Duration(seconds: 1));
      expect(stream2, emitsInOrder([2, 3, 4, 5]));
    });

    test('test channel replaying error', () async {
      final name = 'channel1';
      final channel = SubjectEventChannel.replay(name);
      var streamHandler = MockStreamSender.errorCode('123');
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(channel, streamHandler);
      final broadcastStream = channel.receiveBroadcastStream();
      expect(broadcastStream, emitsError(isA<PlatformException>()));
    });

    test('test channel replaying values then error', () async {
      final name = 'channel1';
      final channel = SubjectEventChannel.replay(name);
      var streamHandler = MockStreamSender.valueThenError([1, 2, 3, 4], '123');
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(channel, streamHandler);
      final broadcastStream = channel.receiveBroadcastStream();
      expect(broadcastStream,
          emitsInAnyOrder([1, 2, 3, 4, emitsError(isA<PlatformException>())]));
    });
  });
}
