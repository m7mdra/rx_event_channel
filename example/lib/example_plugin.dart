import 'example_plugin_platform_interface.dart';

class ExamplePlugin {
  Stream<int> valuesBehaviorSubject() {
    return ExamplePluginPlatform.instance.valuesBehaviorSubject();
  }

  Stream<int> valuesPublishSubject() {
    return ExamplePluginPlatform.instance.valuesPublishSubject();
  }

  Stream<int> valuesReplaySubject() {
    return ExamplePluginPlatform.instance.valuesReplaySubject();
  }
}
