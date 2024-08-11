import 'package:example_plugin/example_plugin_method_channel.dart';
import 'package:example_plugin/example_plugin_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockExamplePluginPlatform
    with MockPlatformInterfaceMixin
    implements ExamplePluginPlatform {
  @override
  Stream<int> valuesBehaviorSubject() {
    // TODO: implement valuesBehaviorSubject
    throw UnimplementedError();
  }

  @override
  Stream<int> valuesPublishSubject() {
    // TODO: implement valuesPublishSubject
    throw UnimplementedError();
  }

  @override
  Stream<int> valuesReplaySubject() {
    // TODO: implement valuesReplaySubject
    throw UnimplementedError();
  }
}

void main() {
  final ExamplePluginPlatform initialPlatform = ExamplePluginPlatform.instance;

  test('$MethodChannelExamplePlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelExamplePlugin>());
  });
}
