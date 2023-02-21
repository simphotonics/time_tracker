import 'package:time_tracker/src/time_tracker.dart';
import 'package:test/test.dart';

class HasStatus<T extends TimeTracker> extends CustomMatcher {
  HasStatus(matcher) : super("TimeTracker with status:", "status", matcher);
  @override
  featureValueOf(actual) => (actual as T).status;
}

class HasDurationLargerZero<T extends TimeTracker> extends CustomMatcher {
  HasDurationLargerZero() : super("TimeTracker with:", "duration", true);
  @override
  featureValueOf(actual) => (actual as T).duration > Duration.zero;
}

class HasPausesLargerZero<T extends TimeTracker> extends CustomMatcher {
  HasPausesLargerZero() : super("TimeTracker with:", "duration", true);
  @override
  featureValueOf(actual) => (actual as T).durationOfPauses > Duration.zero;
}

void main() {
  group('Constructors:', () {
    test('default', () {
      final tracker = TimeTracker();
      expect(tracker, HasStatus(TimeStatus.ready));
    });
    test('startNow', () {
      final tracker = TimeTracker.startNow();
      expect(tracker, HasStatus(TimeStatus.started));
      expect(tracker.timePoints, hasLength(1));
    });
  });

  group('Transitions:', () {
    test('ready -> started', () {
      final tracker = TimeTracker()..start();
      expect(tracker, HasStatus(TimeStatus.started));
      expect(tracker.timePoints, hasLength(1));
    });
    test('started -> paused', () {
      final tracker = TimeTracker.startNow()..pause();
      tracker.pause();
      expect(tracker, HasStatus(TimeStatus.paused));
      expect(tracker.timePoints, hasLength(2));
    });
    test('started -> ended', () {
      final tracker = TimeTracker.startNow()..end();
      expect(tracker, HasStatus(TimeStatus.ended));
      expect(tracker.timePoints, hasLength(2));
    });
    test('paused -> resumed', () {
      final tracker = TimeTracker.startNow()
        ..pause()
        ..resume();
      expect(tracker, HasStatus(TimeStatus.resumed));
      expect(tracker.timePoints, hasLength(3));
    });
    test('paused -> ended', () {
      final tracker = TimeTracker.startNow()
        ..pause()
        ..end();
      expect(tracker.timePoints, hasLength(3));
      expect(tracker, HasStatus(TimeStatus.ended));
    });
    test('resumed -> paused', () {
      final tracker = TimeTracker.startNow()
        ..pause()
        ..resume();
      expect(tracker, HasStatus(TimeStatus.resumed));
      expect(tracker.timePoints, hasLength(3));
    });
    test('resumed -> ended', () {
      final tracker = TimeTracker.startNow()
        ..pause()
        ..resume()
        ..end();
      expect(tracker, HasStatus(TimeStatus.ended));
      expect(tracker.timePoints, hasLength(4));
    });
  });

  group('Void Transitions:', () {
    test('ready -> paused', () {
      final tracker = TimeTracker()..pause();
      expect(tracker, HasStatus(TimeStatus.ready));
      expect(tracker.timePoints, hasLength(0));
    });
    test('ready -> resumed', () {
      final tracker = TimeTracker()..resume();
      expect(tracker, HasStatus(TimeStatus.ready));
      expect(tracker.timePoints, hasLength(0));
    });
    test('ready -> ended', () {
      final tracker = TimeTracker()..end();
      expect(tracker, HasStatus(TimeStatus.ready));
      expect(tracker.timePoints, hasLength(0));
    });
    test('started -> resumed', () {
      final tracker = TimeTracker.startNow()..resume();
      expect(tracker, HasStatus(TimeStatus.started));
      expect(tracker.timePoints, hasLength(1));
    });
    test('started -> started', () {
      final tracker = TimeTracker.startNow()..start();
      expect(tracker, HasStatus(TimeStatus.started));
      expect(tracker.timePoints, hasLength(1));
    });
    test('paused -> started', () {
      final tracker = TimeTracker.startNow()
        ..pause()
        ..start();
      expect(tracker.timePoints, hasLength(2));
      expect(tracker, HasStatus(TimeStatus.paused));
    });
    test('paused -> paused', () {
      final tracker = TimeTracker.startNow()
        ..pause()
        ..pause();
      expect(tracker.timePoints, hasLength(2));
      expect(tracker, HasStatus(TimeStatus.paused));
    });
    test('resumed -> started', () {
      final tracker = TimeTracker.startNow()
        ..pause()
        ..resume()
        ..start();
      expect(tracker, HasStatus(TimeStatus.resumed));
      expect(tracker.timePoints, hasLength(3));
    });
    test('resumed -> resumed', () {
      final tracker = TimeTracker.startNow()
        ..pause()
        ..resume()
        ..resume();
      expect(tracker, HasStatus(TimeStatus.resumed));
      expect(tracker.timePoints, hasLength(3));
    });
    test('ended -> started', () {
      final tracker = TimeTracker.startNow()
        ..end()
        ..start();
      expect(tracker, HasStatus(TimeStatus.ended));
      expect(tracker.timePoints, hasLength(2));
    });
    test('ended -> paused', () {
      final tracker = TimeTracker.startNow()
        ..end()
        ..pause();
      expect(tracker, HasStatus(TimeStatus.ended));
      expect(tracker.timePoints, hasLength(2));
    });
    test('ended -> resumed', () {
      final tracker = TimeTracker.startNow()
        ..end()
        ..resume();
      expect(tracker, HasStatus(TimeStatus.ended));
      expect(tracker.timePoints, hasLength(2));
    });
    test('ended -> ended', () {
      final tracker = TimeTracker.startNow()
        ..end()
        ..end();
      expect(tracker, HasStatus(TimeStatus.ended));
      expect(tracker.timePoints, hasLength(2));
    });
  });

  group('Time Points:', () {
    test('startTime ready', () {
      final tracker = TimeTracker();
      expect(tracker.startTime, isNull);
      expect(tracker.endTime, isNull);
    });
    test('startTime started', () {
      final tracker = TimeTracker.startNow();
      expect(tracker.startTime, isNotNull);
      expect(tracker.endTime, isNull);
    });
    test('startTime paused', () {
      final tracker = TimeTracker.startNow()..pause();
      expect(tracker.startTime, isNotNull);
      expect(tracker.endTime, isNull);
    });
    test('startTime paused', () {
      final tracker = TimeTracker.startNow()
        ..pause()
        ..resume();
      expect(tracker.startTime, isNotNull);
      expect(tracker.endTime, isNull);
    });
    test('startTime paused', () {
      final tracker = TimeTracker.startNow()
        ..pause()
        ..resume()
        ..end();
      expect(tracker.startTime, isNotNull);
      expect(tracker.endTime, isNotNull);
    });
  });

  group('Duration:', () {
    test('ready', () {
      final tracker = TimeTracker();
      expect(tracker.duration, Duration.zero);
      expect(tracker.durationOfPauses, Duration.zero);
    });
    test('started', () {
      final tracker = TimeTracker()..start();
      expect(tracker, HasDurationLargerZero());
      expect(tracker.durationOfPauses, Duration.zero);
    });

    test('paused', () {
      final tracker = TimeTracker.startNow()..pause();
      expect(tracker, HasDurationLargerZero());
      expect(tracker, HasPausesLargerZero());
    });
    test('end', () {
      final tracker = TimeTracker.startNow()
        ..pause()
        ..resume()
        ..end();
      expect(tracker, HasDurationLargerZero());
      expect(tracker, HasPausesLargerZero());
      final totalTime = tracker.endTime!.difference(tracker.startTime!);
      expect(totalTime, tracker.duration + tracker.durationOfPauses);
    });
  });
  group('Serialize:', () {
    test('json', () {
      final tracker = TimeTracker()
        ..start()
        ..pause()
        ..resume()
        ..end();

      final json = tracker.toJson();
      expect(tracker.status.toJson(), json[TimeTracker.$status]);
      expect(tracker.timePoints, json[TimeTracker.$timePoints]);
    });
  });

  group('Deserialize:', () {
    test('json', () {
      final tracker = TimeTracker()
        ..start()
        ..pause()
        ..resume()
        ..end();

      final json = tracker.toJson();

      final revivedTracker = TimeTracker.fromJson(json);
      expect(tracker, revivedTracker);
    });
  });
  group('Equality', () {});
}
