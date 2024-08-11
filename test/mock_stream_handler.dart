import 'package:flutter_test/flutter_test.dart';

class MockStreamSender extends MockStreamHandler {
  final List<dynamic>? values;
  final String? errorCode;
  final bool _valueFirst;

  MockStreamSender.value(this.values)
      : errorCode = null,
        _valueFirst = true;

  MockStreamSender.errorCode(this.errorCode)
      : values = null,
        _valueFirst = false;

  MockStreamSender.valueThenError(this.values, this.errorCode)
      : _valueFirst = true;

  @override
  void onCancel(Object? arguments) {}

  @override
  void onListen(Object? arguments, MockStreamHandlerEventSink events) {
    if (_valueFirst) {
      success(events);
      error(events);
    } else {
      error(events);
      success(events);
    }
  }

  void success(MockStreamHandlerEventSink events) {
    if (values == null) return;
    for (final value in values!) {
      events.success(value);
    }
  }

  void error(MockStreamHandlerEventSink events) {
    if (errorCode == null) return;
    events.error(code: errorCode!);
  }
}
