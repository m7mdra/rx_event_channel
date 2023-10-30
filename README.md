
<!--   
This README describes the package. If you publish this package to pub.dev,  
this README's contents appear on the landing page for your package.  
  
For information about how to write a good package README, see the guide for  
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).   
  
For general information about developing packages, see the Dart guide for  
[creating packages](https://dart.dev/guides/libraries/create-library-packages)  
and the Flutter guide for  
[developing packages and plugins](https://flutter.dev/developing-packages).   
-->  
A Flutter package providing a Subject Event Channel that allows seamless communication  
between Flutter and platform-specific code using various types of RxDart Subjects.  
  
  
 A Flutter package providing a Subject Event Channel that allows seamless communication  
 between Flutter and platform-specific code using various types of RxDart Subjects.  
  
 ## Features  
- Create different types of RxDart Subjects for communication with the platform side:  
  - `SubjectEventChannel`: is the base class that is responsible for actual communication logic, children of `SubjectEventChannel`  will be responsible for creating the appropriate subject/stream creation. 
  - `BehaviorEventChannel`: Delivers the last event to new subscribers.  
  - `PublishEventChannel`: Publishes events to all subscribers.  
  - `ReplayEventChannel`: Replays a specified number of events to new subscribers.  
  
## Getting started  
  
Replace instance of `EventChannel` with one the following implementation `BehaviorSubject`, `PublishSubject`  
  or `ReplaySubject` depending on your scenario and that's it.  
  
## Additional information  
  
To create custom implementation of `SubjectEventChannel` simply extend it and provide a to it a `Subject` and all logic will be handled for you.

```dart
class TimeoutEventChannel extends SubjectEventChannel {  
  TimeoutEventChannel(super.name);  
  
  @override  
  Subject newSubject(  
      {int? maxSize,  
 void Function()? onListen,  
 void Function()? onCancel,  
  bool sync = false}) {  
    return TimeoutSubject(StreamController());  
  }  
}  
  
class TimeoutSubject extends Subject<dynamic> {  
  final StreamController<dynamic> _streamController;  
  
  TimeoutSubject(this._streamController)  
      : super(_streamController, _streamController.stream);  
}
```

## TODO
- Add Tests
