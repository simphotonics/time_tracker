import 'package:serialize_enum/serialize_enum.dart';

/// Enumeration representing the time status of an object.
enum TimeStatus() with SerializeByName<TimeStatus> {
  /// The object has not been started yet.
  ready,

  /// The object has been started.
  started,

  /// The object has been paused.
  paused,

  /// The object was paused and has been resumed.
  resumed,

  /// The time line of the object has ended.
  ended;

  /// Reads json map and returns the corresponding instance of `TimeStatus`.
  factory fromJson(Json json) =>
      SerializeByName.fromJson(json: json, values: values);

  /// Returns `true` is this is [ready] and false otherwise.
  bool get isReady => this == ready;

  /// Returns `true` if this is not [ready] and false otherwise.
  bool get isOtherThanReady => this != ready;

  /// Returns `true` is this is [started] and false otherwise.
  bool get hasStarted => this == started;

  /// Returns `true` if this is not [started] and false otherwise.
  bool get hasNotStarted => this != started;

  /// Returns `true` if this is [paused] and false otherwise.
  bool get isPaused => this == paused;

  /// Returns `true` if this is not [paused] and false otherwise.
  bool get isNotPaused => this != paused;

  /// Returns `true` is this is [resumed] and false otherwise.
  bool get hasResumed => this == resumed;

  /// Returns `true` if this is not [resumed] and false otherwise.
  bool get hasNotResumed => this != resumed;

  /// Returns `true` is this is [ended] and false otherwise.
  bool get hasEnded => this == ended;

  /// Returns `true` if this is not [ended] and false otherwise.
  bool get hasNotEnded => this != ended;
}
