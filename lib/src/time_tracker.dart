import '../src/extensions/equal.dart';

/// Interface adding the method `toJson()`.
abstract class Serializable {
  Map<String, dynamic> toJson();
}

abstract class TimeControls {
  /// Starts the objects time line. Records the first time point.
  void start();

  /// Pauses the objects time line. Adds a time point
  /// indicating the start of a pause.
  void pause();

  /// Resumes a paused object. Adds a time point,
  /// indicating the end of a pause.
  void resume();

  /// Ends the objects time line. Records the last time point.
  void end();
}

/// Enumeration representing the time status of an object.
enum TimeStatus implements Serializable {
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
      TimeStatus.values[json['timeStatus'] as int];

  /// Returns an json map representing the instance of `TimeStatus`.
  @override
  Map<String, dynamic> toJson() => {'timeStatus': index};
}

/// A Dart object that records time-status changes.
/// * The object can be started, paused, resumed, and ended.
/// * To retrieve the current state use the getter `status`.
/// * To retrieve the recorded time points use the getter `dateTimePoints`.
/// * To retrieve the recorded time points as microseconds since epoch use
///   getter `timePoints`.
///   Note: Every time the objects status changes a new time point is
///   added.
class TimeTracker implements Serializable, TimeControls {
  TimeStatus _status = TimeStatus.ready;
  final _timePoints = <int>[];

  /// Constructs a `TimeTracker` object with status `TimeStatus.ready`.
  TimeTracker();

  /// Constructs a `TimeTracker` object with status `TimeStatus.started`.
  /// Note: The instantiation time is the first time point recorded
  /// in `timePoints`.
  TimeTracker.startNow() {
    _timePoints.add(DateTime.now().microsecondsSinceEpoch);
    _status = TimeStatus.started;
  }

  /// Constructs a `TimeTracker` object from a json map
  /// (typically generated from a decoded json String.)
  TimeTracker.fromJson(Map<String, dynamic> json)
      : _status = TimeStatus.fromJson(json[$status]) {
    _timePoints.addAll(json[$timePoints].cast<int>());
  }

  /// Returns a json-encodable map representing this.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        $status: _status.toJson(),
        $timePoints: List.of(_timePoints, growable: false)
      };

  /// Sets the time status of the object to `TimeStatus.started`
  /// if the current time status is `TimeStatus.ready`.
  /// Records the first time point.
  @override
  void start() {
    if (_status == TimeStatus.ready) {
      _timePoints.add(DateTime.now().microsecondsSinceEpoch);
      _status = TimeStatus.started;
    }
  }

  /// Sets the time status of the object to `TimeStatus.paused`
  /// if the current time status is `TimeStatus.started` or
  /// `TimeStatus.resumed` and adds a time point.
  @override
  void pause() {
    if (_status == TimeStatus.started || _status == TimeStatus.resumed) {
      _timePoints.add(DateTime.now().microsecondsSinceEpoch);
      _status = TimeStatus.paused;
    }
  }

  /// Sets the time status of the object to `TimeStatus.resumed`
  /// if the current status is `Timestatus.paused` and adds
  /// a time point.
  @override
  void resume() {
    if (_status == TimeStatus.paused) {
      _timePoints.add(DateTime.now().microsecondsSinceEpoch);
      _status = TimeStatus.resumed;
    }
  }

  /// Sets the time status of the object to `TimeStatus.ended`.
  /// Adds a time point marking the completion time.
  /// ---
  ///
  /// Note: If the object has status `TimeStatus.ready` or
  /// status `TimeStatus.ended` the above actions are skipped!
  @override
  void end() {
    switch (_status) {
      case TimeStatus.ended:
        break;
      case TimeStatus.ready:
        break;
      default:
        _status = TimeStatus.ended;
        _timePoints.add(DateTime.now().microsecondsSinceEpoch);
    }
  }

  /// Returns the duration between object start point and end point.
  ///
  /// ---
  /// - Paused time periods are omitted.
  /// - If the status of the object is `TimeStatus.started`, the
  ///   difference between `DateTime.now()` and start time is returned.
  Duration get duration {
    switch (_status) {
      case TimeStatus.ready:
        return Duration.zero;
      case TimeStatus.started:
        return DateTime.now().difference(startTime!);
      default:
        Duration result = Duration.zero;
        final points = dateTimePoints;
        for (var i = 0; i < points.length; i = i + 2) {
          result += points[i + 1].difference(points[i]);
        }
        return result;
    }
  }

  /// Returns the duration of all pauses added together.
  /// If the object is in status `TimeStatus.paused`, then the
  /// difference between `DateTime.now()` and the last recorded time point
  /// is considered to be the duration of the last pause.
  Duration get durationOfPauses {
    switch (_status) {
      case TimeStatus.ready:
      case TimeStatus.started:
        return Duration.zero;
      case TimeStatus.paused:
        return duration + DateTime.now().difference(lastTimePoint!);
      case TimeStatus.resumed:
      case TimeStatus.ended:
        return lastTimePoint!.difference(startTime!) - duration;
    }
  }

  /// Returns the recorded time points of the object. Every time the object is
  /// paused or resumed an additional time point is added.
  /// * The first entry is the start point.
  /// * Subsequent points mark the start/end of a pause.
  /// * The last entry marks the completion time of the object if the object
  ///   status is `TimeStatus.ended`.
  List<DateTime> get dateTimePoints =>
      _timePoints.map((e) => DateTime.fromMicrosecondsSinceEpoch(e)).toList();

  /// Returns the recorded time points as microseconds
  /// since epoch. Every time the object is
  /// paused or resumed an additional time point is added.
  /// * The first entry is the start point.
  /// * Subsequent points mark the start/end of a pause.
  /// * The last entry marks the completion time of the object if the object
  ///   status is `TimeStatus.ended`.
  List<int> get timePoints => [..._timePoints];

  /// Returns the creation time of the object or `null` if the tracker was
  /// not started yet.
  DateTime? get startTime => (_status == TimeStatus.ready)
      ? null
      : DateTime.fromMicrosecondsSinceEpoch(_timePoints.first);

  /// Returns the last recorded time point or `null` if the tracker is in
  /// state `TimeState.ready`.
  DateTime? get lastTimePoint => (_status == TimeStatus.ready)
      ? null
      : DateTime.fromMicrosecondsSinceEpoch(_timePoints.last);

  /// Returns the end time of the object or `null` if the status of the
  /// objects is not `TimeStatus.ended`.
  DateTime? get endTime => (_status == TimeStatus.ended)
      ? DateTime.fromMicrosecondsSinceEpoch(_timePoints.last)
      : null;

  /// Returns the current object status: `TimeStatus.started`,
  /// `TimeStatus.paused`, or `TimeStatus.ended`.
  TimeStatus get status => _status;

  /// Json key for the variable `timePoints`..
  static final String $timePoints = 'timePoints';

  /// Json key for the variable `status`.
  static final String $status = 'status';

  @override
  int get hashCode => Object.hash(_status, _timePoints);

  /// Returns `true` if the two instances have the same time status and
  /// the same time points.
  @override
  bool operator ==(Object other) {
    return other is TimeTracker &&
        other._status == _status &&
        other._timePoints.equal(_timePoints);
  }

  @override
  String toString() {
    return 'TimeTrackable: status = ${status.name}, '
        'timePoints: $dateTimePoints';
  }
}
