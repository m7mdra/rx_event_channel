import Flutter
import UIKit

public class ExamplePlugin: NSObject, FlutterPlugin {
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "example_plugin", binaryMessenger: registrar.messenger())
        let instance = ExamplePlugin()
        let behaviorEventChannel = FlutterEventChannel(name: "example.channel1", binaryMessenger: registrar.messenger())
        let replayEventChannel = FlutterEventChannel(name: "example.channel2", binaryMessenger: registrar.messenger())
        let publishEventChannel = FlutterEventChannel(name: "example.channel3", binaryMessenger: registrar.messenger())
        
        behaviorEventChannel.setStreamHandler(RandomNumberGenerator())
        replayEventChannel.setStreamHandler(RandomNumberGenerator())
        publishEventChannel.setStreamHandler(RandomNumberGenerator())
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}


class RandomNumberGenerator : NSObject, FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        start(events)
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stop()
        return nil
    }
    
    private var timer: Timer?
    private let interval: TimeInterval = 1.0
    
    
    private func start(_ sink: @escaping FlutterEventSink) {
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.generateAndSendRandomNumber(sink)
        }
    }
    
    private func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func generateAndSendRandomNumber(_ sink: @escaping FlutterEventSink) {
        let randomNumber = Int.random(in: 0...100)
    
        sink(randomNumber)
    }
}

