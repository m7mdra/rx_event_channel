


# SubjectEventChannel

`SubjectEventChannel` is a Dart class that extends Flutter's `EventChannel` to facilitate asynchronous communication between Flutter and platform-specific code using `RxDart`'s `Subject` types. This class enables the management and broadcasting of events through various types of `RxDart` subjects, such as `BehaviorSubject`, `ReplaySubject`, and `PublishSubject`.

## Overview

The `SubjectEventChannel` class is designed for efficient event handling and communication with platform-specific code. It leverages `RxDart`'s subjects to offer flexible event management strategies, including buffering and replaying of events.

## Constructors

### `SubjectEventChannel`

```dart
const SubjectEventChannel(
  this.name,
  this.subject, {
  this.codec = const StandardMethodCodec(),
  this.maxSize,
  BinaryMessenger? binaryMessenger,
})
```

- **Parameters**:

| Parameter       | Type             | Description                                                                                         |
|-----------------|------------------|-----------------------------------------------------------------------------------------------------|
| `name`          | `String`         | The name of the event channel used for communication with the platform.                            |
| `subject`       | `Subject`        | The RxDart `Subject` used for managing events. Can be `BehaviorSubject`, `ReplaySubject`, or `PublishSubject`. |
| `codec`         | `MethodCodec`    | Optional. Specifies how to encode and decode messages between Dart and the platform. Defaults to `StandardMethodCodec()`. |
| `maxSize`       | `int?`           | Optional. For `ReplaySubject`, specifies the maximum number of events to retain. If `null`, no limit is applied. |
| `binaryMessenger` | `BinaryMessenger?` | Optional. The binary messenger for sending/receiving messages. If `null`, it defaults to the appropriate messenger based on runtime context. |



### `SubjectEventChannel.behavior`

```dart
SubjectEventChannel.behavior(
  this.name, {
  this.sync = false,
  this.codec = const StandardMethodCodec(),
  BinaryMessenger? binaryMessenger,
})
```

- **Parameters**:

| Parameter       | Type             | Description                                                                                         |
|-----------------|------------------|-----------------------------------------------------------------------------------------------------|
| `name`          | `String`         | The name of the event channel used for communication with the platform.                            |
| `sync`          | `bool`           | Optional. Determines if the subject should be synchronous or asynchronous. Defaults to `false`.    |
| `codec`         | `MethodCodec`    | Optional. Codec for encoding/decoding method calls.                                                 |
| `binaryMessenger` | `BinaryMessenger?` | Optional. The binary messenger for sending/receiving messages. If `null`, it defaults to the appropriate messenger based on runtime context. |

### `SubjectEventChannel.replay`

```dart
SubjectEventChannel.replay(
  this.name, {
  this.sync = false,
  this.maxSize,
  this.codec = const StandardMethodCodec(),
  BinaryMessenger? binaryMessenger,
})
```

- **Parameters**:

| Parameter       | Type             | Description                                                                                         |
|-----------------|------------------|-----------------------------------------------------------------------------------------------------|
| `name`          | `String`         | The name of the event channel used for communication with the platform.                            |
| `sync`          | `bool`           | Optional. Determines if the subject should be synchronous or asynchronous. Defaults to `false`.    |
| `maxSize`       | `int?`           | Optional. The buffer size for storing old events in `ReplaySubject`.                               |
| `codec`         | `MethodCodec`    | Optional. Codec for encoding/decoding method calls.                                                 |
| `binaryMessenger` | `BinaryMessenger?` | Optional. The binary messenger for sending/receiving messages. If `null`, it defaults to the appropriate messenger based on runtime context. |

### `SubjectEventChannel.publish`

```dart
SubjectEventChannel.publish(
  this.name, {
  this.sync = false,
  this.codec = const StandardMethodCodec(),
  BinaryMessenger? binaryMessenger,
})
```

- **Parameters**:

| Parameter       | Type             | Description                                                                                         |
|-----------------|------------------|-----------------------------------------------------------------------------------------------------|
| `name`          | `String`         | The name of the event channel used for communication with the platform.                            |
| `sync`          | `bool`           | Optional. Determines if the subject should be synchronous or asynchronous. Defaults to `false`.    |
| `codec`         | `MethodCodec`    | Optional. Codec for encoding/decoding method calls.                                                 |
| `binaryMessenger` | `BinaryMessenger?` | Optional. The binary messenger for sending/receiving messages. If `null`, it defaults to the appropriate messenger based on runtime context. |

## Bring your own subject:

You can supply a custom implementation of subject class by simply using default constructor:

```dart
final subject = XYSubject()
final eventChannel = SubjectEventChannel('name', subject)
```


## Usage Example

see `example_plugin` project for more comprehensive example .


## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

If you would like to contribute to this project, please fork the repository and submit a pull request with your changes. For major changes, please open an issue first to discuss what you would like to change.

TODO:

- [x] Testing.
- [ ] Improve documentation.
- [ ] publish to pub.dev.

