import 'package:exception_templates/exception_templates.dart';
import 'package:serialize_enum/serialize_enum.dart' show Json, Serializable;
import 'package:stride/stride.dart';

import '../extension/equal.dart';
import '../enum/time_status.dart';
import '../interface/time_control.dart';

/// A mixin providing methods to records time-status changes.
/// * The object can be started, paused, resumed, and ended.
/// * To retrieve the current state use the getter `status`.
/// * To retrieve the recorded time points use the getter `dateTimePoints`.
/// * To retrieve the recorded time points as microseconds since epoch use
///   the getter `timePoints`.
///   Note: Every time the objects status changes a new time point is
///   added.
mixin TimeTracker implements Serializable, TimeControl {
  TimeStatus _status = TimeStatus.ready;
  final _timePoints = <int>[];

  /// Reads a json map and initializes the
  /// tracker status and time points.
  /// * If the status provided is [Timestatus.ready]
  /// any time points will be ignored to maintain consistency.
  /// * If validation fails and [readyOnValidationError] is `true`,
  /// the tracker will be initialized with a status of
  /// [TimeStatus.ready].
  /// * If validation fails and [readyOnValidationError] is `false` an
  /// error of type [ErrorOf] with type parameter [TimeTracker] will be thrown.
  void initTrackerfromJson(Json json) {
    if (json case {$status: Json jsonStatus, $timePoints: List timePoints}) {
      _status = TimeStatus.fromJson(jsonStatus);

      final message = isValidTimeLine(status: _status, timePoints: timePoints);

      if (message.isEmpty) {
        _timePoints.clear();
        _timePoints.addAll(timePoints.cast<int>());
      } else {
        throw ErrorOf<TimeTracker>(
          message: 'Invalid time line detected',
          expectedState: 'A time line that is compatible with the time status.',
          invalidState: 'Found: $timePoints but $message.',
        );
      }
    } else {
      throw ErrorOf<TimeTracker>(
        message: 'Json validation error',
        expectedState: 'A json map with keys: $status,$timePoints',
        invalidState: 'Found map: $json',
      );
    }
  }

  /// Checks if the provided time line is compatible with
  /// the provided time status. Returns a non-empty message if validation fails.
  static String isValidTimeLine({
    required TimeStatus status,
    required List timePoints,
  }) {
    return switch (status) {
      TimeStatus.ready when timePoints.isNotEmpty => 'timePoints must be empty',
      TimeStatus.started when timePoints.length != 1 =>
        'timePoints can contain only one element',
      TimeStatus.paused when timePoints.length.isOdd =>
        'timePoints must contain an even number of elements',
      TimeStatus.resumed when timePoints.length.isEven =>
        'timePoints must contain an odd number of elements',
      TimeStatus.ended when timePoints.length < 2 =>
        'timePoints must contain more than one element',
      _ => '',
    };
  }

  /// Returns a json-encodable map representing the current
  /// [TimeTracker] status and the stored time points.
  Json trackerToJson() => <String, Object?>{
    $status: _status.toJson(),
    $timePoints: List.unmodifiable(_timePoints),
  };

  /// Sets the time status of the object to [TimeStatus.started]
  /// if the current time status is [TimeStatus.ready].
  /// Records the first time point.
  @override
  void start() {
    if (_status == TimeStatus.ready) {
      _timePoints.add(DateTime.now().microsecondsSinceEpoch);
      _status = TimeStatus.started;
    }
  }

  /// Sets the time status of the object to [TimeStatus.paused]
  /// if the current time status is [TimeStatus.started] or
  /// [TimeStatus.resumed] and adds a time point.
  @override
  void pause() {
    if (_status == TimeStatus.started || _status == TimeStatus.resumed) {
      _timePoints.add(DateTime.now().microsecondsSinceEpoch);
      _status = TimeStatus.paused;
    }
  }

  /// Sets the time status of the object to [TimeStatus.resumed]
  /// if the current status is [TimeStatus.paused] and adds
  /// a time point.
  @override
  void resume() {
    if (_status == TimeStatus.paused) {
      _timePoints.add(DateTime.now().microsecondsSinceEpoch);
      _status = TimeStatus.resumed;
    }
  }

  /// Sets the time status of the object to [TimeStatus.ended].
  /// Adds a time point marking the completion time.
  /// ---
  ///
  /// Note: If the object has status [TimeStatus.ready] or
  /// status [TimeStatus.ended] the above actions are skipped!
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

  /// Returns the duration between the object start point and end point.
  ///
  /// ---
  /// - Note: Time periods representing **pauses** are omitted.
  /// - If the status of the object is [TimeStatus.started], the
  ///   difference between [DateTime.now] and the first time point is returned.
  /// - If the status of the object is [TimeStatus.resumed], the difference
  ///   between now and the start point is returned. Again, pauses are omitted.
  Duration get duration => Duration(microseconds: durationAsMicroseconds);

  /// Returns the duration between the object start point and end point as
  /// microseconds.
  ///
  /// ---
  /// - Note: Time periods representing **pauses** are omitted.
  /// - If the status of the object is [TimeStatus.started], the
  ///   difference between now and the first time point is returned.
  /// - If the status of the object is [TimeStatus.resumed], the difference
  ///   between now and the start point is returned. Again, pauses are omitted.
  int get durationAsMicroseconds {
    switch (_status) {
      case TimeStatus.ready:
        return 0;
      case TimeStatus.started:
        return DateTime.now().microsecondsSinceEpoch - _timePoints.first;
      case TimeStatus.resumed:
      default:
        int us = 0;
        final startPoints = _timePoints.stride(2, 0);
        final endPoints = _timePoints
            .stride(2, 1)
            .followedBy(
              Iterable.generate(
                hasResumed ? 1 : 0,
                (count) => DateTime.now().microsecondsSinceEpoch,
              ),
            );

        final itStart = startPoints.iterator;
        final itEnd = endPoints.iterator;

        while (itStart.moveNext() && itEnd.moveNext()) {
          us += (itEnd.current - itStart.current);
        }
        return us;
    }
  }

  /// Returns a list containing the duration of **completed** pauses
  /// in microseconds.
  ///
  /// Note: If the object is currently in state [TimeStatus.paused], the
  /// interval between the last recorded time point and now is omitted.
  List<int> get pauses {
    switch (_status) {
      case TimeStatus.ready:
      case TimeStatus.started:
        return [];
      case TimeStatus.paused:
      default:
        final pauses = <int>[];
        final startPoints = _timePoints.stride(2, 1);
        final endPoints = _timePoints.stride(2, 2);
        final itStart = startPoints.iterator;
        final itEnd = endPoints.iterator;

        while (itStart.moveNext() && itEnd.moveNext()) {
          pauses.add(itEnd.current - itStart.current);
        }
        return pauses;
    }
  }

  /// Returns the duration of all pauses (in microseconds) added together
  /// If the object is currently in status [TimeStatus.paused], then the
  /// difference between the last recorded time point and now is omitted.
  int get durationOfPausesAsMicroseconds {
    final it = pauses.iterator;

    int us = 0;
    while (it.moveNext()) {
      us += it.current;
    }
    return us;
  }

  /// Returns the duration of all pauses added together.
  /// If the object is in status [TimeStatus.paused], then the
  /// difference between [DateTime.now] and the last recorded time point
  /// is considered to be the duration of the last pause.
  Duration get durationOfPauses =>
      Duration(microseconds: durationOfPausesAsMicroseconds);

  /// Returns the recorded time points of the object. Every time the object is
  /// paused or resumed an additional time point is added.
  /// * The first entry is the start point.
  /// * Subsequent points mark the start/end of a pause.
  /// * The last entry marks the completion time of the object if the object
  ///   status is [TimeStatus.ended].
  List<DateTime> get dateTimePoints =>
      _timePoints.map((e) => DateTime.fromMicrosecondsSinceEpoch(e)).toList();

  /// Returns the recorded time points as microseconds
  /// since epoch. Every time the object is
  /// paused or resumed an additional time point is added.
  /// * The first entry is the start point.
  /// * Subsequent points mark the start/end of a pause.
  /// * The last entry marks the completion time of the object if the object
  ///   status is [TimeStatus.ended].
  List<int> get timePoints => List.unmodifiable(_timePoints);

  /// Returns the start time of the object or `null` if the tracker was
  /// not started yet.
  DateTime? get startTime => (_status == TimeStatus.ready)
      ? null
      : DateTime.fromMicrosecondsSinceEpoch(_timePoints.first);

  /// Returns the last recorded time point or `null` if the tracker is in
  /// state `TimeState.ready].
  DateTime? get lastTimePoint => (_status == TimeStatus.ready)
      ? null
      : DateTime.fromMicrosecondsSinceEpoch(_timePoints.last);

  /// Returns the end time of the object or `null` if the status of the
  /// objects is not [TimeStatus.ended].
  DateTime? get endTime => (_status == TimeStatus.ended)
      ? DateTime.fromMicrosecondsSinceEpoch(_timePoints.last)
      : null;

  /// Returns the current object status: [TimeStatus.started],
  /// [TimeStatus.paused], [TimeStatus.resumed], or [TimeStatus.ended].
  TimeStatus get status => _status;

  /// Json key for the variable `timePoints`..
  static const String $timePoints = 'timePoints';

  /// Json key for the variable `status`.
  static const String $status = 'status';

  int get trackerHashCode => Object.hash(_status, _timePoints);

  /// Returns `true` if the two instances have the same time status and
  /// the same time points.
  bool trackerEqual(Object other) {
    return other is TimeTracker &&
        other._status == _status &&
        other._timePoints.equal(_timePoints);
  }

  String trackerToString() {
    return 'status: ${status.name}';
  }

  /// Returns `true` the current status is [TimeStatus.ready]
  /// and false otherwise.
  bool get isReady => _status.isReady;

  /// Returns `true` if the current status is not [TimeStatus.ready]
  /// and false otherwise.
  bool get isOtherThanReady => _status.isOtherThanReady;

  /// Returns `true` if the current status is [TimeStatus.started]
  /// and false otherwise.
  bool get hasStarted => _status.hasStarted;

  /// Returns `true` if the current status is not [TimeStatus.started]
  /// and false otherwise.
  bool get hasNotStarted => _status.hasNotStarted;

  /// Returns `true` if the current status is [TimeStatus.paused]
  /// and false otherwise.
  bool get isPaused => _status.isPaused;

  /// Returns `true` if the current status is not [TimeStatus.paused]
  /// and false otherwise.
  bool get isNotPaused => _status.isNotPaused;

  /// Returns `true` is the current status is [TimeStatus.resumed]
  /// and false otherwise.
  bool get hasResumed => _status.hasResumed;

  /// Returns `true` if the current status is not [TimeStatus.resumed]
  /// and false otherwise.
  bool get hasNotResumed => _status.hasNotResumed;

  /// Returns `true` is the current status is [TimeStatus.ended]
  /// and false otherwise.
  bool get hasEnded => _status.hasEnded;

  /// Returns `true` if the current status is not [TimeStatus.ended]
  /// and false otherwise.
  bool get hasNotEnded => _status.hasNotEnded;
}
