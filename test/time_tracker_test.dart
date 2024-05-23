import 'dart:convert';

import 'package:test/test.dart';
import 'package:time_tracker/time_tracker.dart';

import 'src/tennis_match.dart';

// Matchers
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
      final tennisMatch = TennisMatch(['Tim', 'Andy']);
      expect(tennisMatch, HasStatus(TimeStatus.ready));
    });
  });

  group('Transitions:', () {
    test('ready -> started', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])..start();
      expect(tennisMatch, HasStatus(TimeStatus.started));
      expect(tennisMatch.timePoints, hasLength(1));
    });
    test('started -> paused', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])..start();
      tennisMatch.pause();
      expect(tennisMatch, HasStatus(TimeStatus.paused));
      expect(tennisMatch.timePoints, hasLength(2));
    });
    test('started -> ended', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..end();
      expect(tennisMatch, HasStatus(TimeStatus.ended));
      expect(tennisMatch.timePoints, hasLength(2));
    });
    test('paused -> resumed', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause()
        ..resume();
      expect(tennisMatch, HasStatus(TimeStatus.resumed));
      expect(tennisMatch.timePoints, hasLength(3));
    });
    test('paused -> ended', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause()
        ..end();
      expect(tennisMatch.timePoints, hasLength(3));
      expect(tennisMatch, HasStatus(TimeStatus.ended));
    });
    test('resumed -> paused', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause()
        ..resume();
      expect(tennisMatch, HasStatus(TimeStatus.resumed));
      expect(tennisMatch.timePoints, hasLength(3));
    });
    test('resumed -> ended', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause()
        ..resume()
        ..end();
      expect(tennisMatch, HasStatus(TimeStatus.ended));
      expect(tennisMatch.timePoints, hasLength(4));
    });
  });

  group('Void Transitions:', () {
    test('ready -> paused', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])..pause();
      expect(tennisMatch, HasStatus(TimeStatus.ready));
      expect(tennisMatch.timePoints, hasLength(0));
    });
    test('ready -> resumed', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])..resume();
      expect(tennisMatch, HasStatus(TimeStatus.ready));
      expect(tennisMatch.timePoints, hasLength(0));
    });
    test('ready -> ended', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])..end();
      expect(tennisMatch, HasStatus(TimeStatus.ready));
      expect(tennisMatch.timePoints, hasLength(0));
    });
    test('started -> resumed', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..resume();
      expect(tennisMatch, HasStatus(TimeStatus.started));
      expect(tennisMatch.timePoints, hasLength(1));
    });
    test('started -> started', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..start();
      expect(tennisMatch, HasStatus(TimeStatus.started));
      expect(tennisMatch.timePoints, hasLength(1));
    });
    test('paused -> started', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause()
        ..start();
      expect(tennisMatch.timePoints, hasLength(2));
      expect(tennisMatch, HasStatus(TimeStatus.paused));
    });
    test('paused -> paused', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause()
        ..pause();
      expect(tennisMatch.timePoints, hasLength(2));
      expect(tennisMatch, HasStatus(TimeStatus.paused));
    });
    test('resumed -> started', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause()
        ..resume()
        ..start();
      expect(tennisMatch, HasStatus(TimeStatus.resumed));
      expect(tennisMatch.timePoints, hasLength(3));
    });
    test('resumed -> resumed', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause()
        ..resume()
        ..resume();
      expect(tennisMatch, HasStatus(TimeStatus.resumed));
      expect(tennisMatch.timePoints, hasLength(3));
    });
    test('ended -> started', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..end()
        ..start();
      expect(tennisMatch, HasStatus(TimeStatus.ended));
      expect(tennisMatch.timePoints, hasLength(2));
    });
    test('ended -> paused', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..end()
        ..pause();
      expect(tennisMatch, HasStatus(TimeStatus.ended));
      expect(tennisMatch.timePoints, hasLength(2));
    });
    test('ended -> resumed', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..end()
        ..resume();
      expect(tennisMatch, HasStatus(TimeStatus.ended));
      expect(tennisMatch.timePoints, hasLength(2));
    });
    test('ended -> ended', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..end()
        ..end();
      expect(tennisMatch, HasStatus(TimeStatus.ended));
      expect(tennisMatch.timePoints, hasLength(2));
    });
  });

  group('Time Points:', () {
    test('startTime ready', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy']);
      expect(tennisMatch.startTime, isNull);
      expect(tennisMatch.endTime, isNull);
    });
    test('startTime started', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])..start();
      expect(tennisMatch.startTime, isNotNull);
      expect(tennisMatch.endTime, isNull);
    });
    test('startTime paused', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause();
      expect(tennisMatch.startTime, isNotNull);
      expect(tennisMatch.endTime, isNull);
    });
    test('startTime paused', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause()
        ..resume();
      expect(tennisMatch.startTime, isNotNull);
      expect(tennisMatch.endTime, isNull);
    });
    test('startTime paused', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause()
        ..resume()
        ..end();
      expect(tennisMatch.startTime, isNotNull);
      expect(tennisMatch.endTime, isNotNull);
    });
  });

  group('Duration:', () {
    test('ready', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy']);
      expect(tennisMatch.duration, Duration.zero);
      expect(tennisMatch.durationOfPauses, Duration.zero);
    });
    test('started', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])..start();
      expect(tennisMatch, HasDurationLargerZero());
      expect(tennisMatch.durationOfPauses, Duration.zero);
    });

    test('paused', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause();
      expect(tennisMatch, HasDurationLargerZero());
      expect(tennisMatch, HasPausesLargerZero());
    });
    test('end', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause()
        ..resume()
        ..end();
      expect(tennisMatch, HasDurationLargerZero());
      expect(tennisMatch, HasPausesLargerZero());
      final totalTime = tennisMatch.endTime!.difference(tennisMatch.startTime!);
      expect(totalTime, tennisMatch.duration + tennisMatch.durationOfPauses);
    });
  });
  group('Serialize:', () {
    test('json', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause()
        ..resume()
        ..end();

      final json = tennisMatch.toJson();
      expect(tennisMatch.status.toJson(), json[TimeTracker.$status]);
      expect(tennisMatch.timePoints, json[TimeTracker.$timePoints]);
    });
  });

  group('Deserialize:', () {
    test('json from map', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause()
        ..resume()
        ..end();

      final json = tennisMatch.toJson();
      final revivedTennisMatch = TennisMatch.fromJson(json);
      expect(tennisMatch, revivedTennisMatch);
    });
    test('json from String', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause()
        ..resume()
        ..end();

      final json = tennisMatch.toJson();
      final jsonString = jsonEncode(json);
      final jsonDecoded = jsonDecode(jsonString);

      expect(json, jsonDecoded);
      expect(tennisMatch, TennisMatch.fromJson(jsonDecoded));
    });
  });
}
