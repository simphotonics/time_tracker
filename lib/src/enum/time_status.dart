import 'package:serialize_enum/serialize_enum.dart';

/// Enumeration representing the time status of an object.
enum TimeStatus with SerializeByName<TimeStatus> {
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

  const TimeStatus();

  /// Reads json map and returns the corresponding instance of `TimeStatus`.
  factory TimeStatus.fromJson(Map<String, dynamic> json) =>
      SerializeByName.fromJson(json: json, values: values);
}
