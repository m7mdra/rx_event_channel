import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'example_plugin_method_channel.dart';

abstract class ExamplePluginPlatform extends PlatformInterface {
  /// Constructs a ExamplePluginPlatform.
  ExamplePluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static ExamplePluginPlatform _instance = MethodChannelExamplePlugin();

  /// The default instance of [ExamplePluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelExamplePlugin].
  static ExamplePluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ExamplePluginPlatform] when
  /// they register themselves.
  static set instance(ExamplePluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Stream<int> valuesBehaviorSubject() {
    throw UnimplementedError(
        'valuesBehaviorSubject() has not been implemented.');
  }

  Stream<int> valuesReplaySubject() {
    throw UnimplementedError('valuesReplaySubject() has not been implemented.');
  }

  Stream<int> valuesPublishSubject() {
    throw UnimplementedError(
        'valuesPublishSubject() has not been implemented.');
  }
}
