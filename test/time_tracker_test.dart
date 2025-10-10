import 'dart:convert';

import 'package:exception_templates/exception_templates.dart' show ErrorOf;
import 'package:test/test.dart';
import 'package:time_tracker/time_tracker.dart';

import 'src/matcher.dart';
import 'src/tennis_match.dart';

const ready = TimeStatus.ready;
const started = TimeStatus.started;
const resumed = TimeStatus.resumed;
const paused = TimeStatus.paused;
const ended = TimeStatus.ended;

/// Creates a [TennisMatch] with [status] and [timePoints].
TennisMatch matchFactory({
  required TimeStatus status,
  required List<int> timePoints,
}) => TennisMatch.fromJson({
  'players': ['Ben', 'Dan'],
  'status': status.toJson(),
  'timePoints': timePoints,
});

void main() {
  group('Constructors:', () {
    test('default', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy']);
      expect(tennisMatch, HasStatus(ready));
    });
  });

  group('Transitions:', () {
    test('ready -> started', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])..start();
      expect(tennisMatch, HasStatus(started));
      expect(tennisMatch.timePoints, hasLength(1));
    });
    test('started -> paused', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])..start();
      tennisMatch.pause();
      expect(tennisMatch, HasStatus(paused));
      expect(tennisMatch.timePoints, hasLength(2));
    });
    test('started -> ended', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..end();
      expect(tennisMatch, HasStatus(ended));
      expect(tennisMatch.timePoints, hasLength(2));
    });
    test('paused -> resumed', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause()
        ..resume();
      expect(tennisMatch, HasStatus(resumed));
      expect(tennisMatch.timePoints, hasLength(3));
    });
    test('paused -> ended', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause()
        ..end();
      expect(tennisMatch.timePoints, hasLength(3));
      expect(tennisMatch, HasStatus(ended));
    });
    test('resumed -> paused', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause()
        ..resume();
      expect(tennisMatch, HasStatus(resumed));
      expect(tennisMatch.timePoints, hasLength(3));
    });
    test('resumed -> ended', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause()
        ..resume()
        ..end();
      expect(tennisMatch, HasStatus(ended));
      expect(tennisMatch.timePoints, hasLength(4));
    });
  });

  group('Void Transitions:', () {
    test('ready -> paused', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])..pause();
      expect(tennisMatch, HasStatus(ready));
      expect(tennisMatch.timePoints, hasLength(0));
    });
    test('ready -> resumed', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])..resume();
      expect(tennisMatch, HasStatus(ready));
      expect(tennisMatch.timePoints, hasLength(0));
    });
    test('ready -> ended', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])..end();
      expect(tennisMatch, HasStatus(ready));
      expect(tennisMatch.timePoints, hasLength(0));
    });
    test('started -> resumed', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..resume();
      expect(tennisMatch, HasStatus(started));
      expect(tennisMatch.timePoints, hasLength(1));
    });
    test('started -> started', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..start();
      expect(tennisMatch, HasStatus(started));
      expect(tennisMatch.timePoints, hasLength(1));
    });
    test('paused -> started', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause()
        ..start();
      expect(tennisMatch.timePoints, hasLength(2));
      expect(tennisMatch, HasStatus(paused));
    });
    test('paused -> paused', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause()
        ..pause();
      expect(tennisMatch.timePoints, hasLength(2));
      expect(tennisMatch, HasStatus(paused));
    });
    test('resumed -> started', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause()
        ..resume()
        ..start();
      expect(tennisMatch, HasStatus(resumed));
      expect(tennisMatch.timePoints, hasLength(3));
    });
    test('resumed -> resumed', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause()
        ..resume()
        ..resume();
      expect(tennisMatch, HasStatus(resumed));
      expect(tennisMatch.timePoints, hasLength(3));
    });
    test('ended -> started', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..end()
        ..start();
      expect(tennisMatch, HasStatus(ended));
      expect(tennisMatch.timePoints, hasLength(2));
    });
    test('ended -> paused', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..end()
        ..pause();
      expect(tennisMatch, HasStatus(ended));
      expect(tennisMatch.timePoints, hasLength(2));
    });
    test('ended -> resumed', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..end()
        ..resume();
      expect(tennisMatch, HasStatus(ended));
      expect(tennisMatch.timePoints, hasLength(2));
    });
    test('ended -> ended', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..end()
        ..end();
      expect(tennisMatch, HasStatus(ended));
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
      expect(tennisMatch, HasDuration(equals(Duration.zero)));
      expect(tennisMatch.durationOfPauses, Duration.zero);
    });
    test('started', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])..start();
      expect(tennisMatch, HasDuration(greaterThan(Duration.zero)));
      expect(tennisMatch.durationOfPauses, Duration.zero);
    });

    test('paused', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause();
      expect(tennisMatch, HasDuration(greaterThan(Duration.zero)));
      expect(tennisMatch, HasPauseDuration(equals(Duration.zero)));
    });
    test('end', () {
      final tennisMatch = TennisMatch(['Tim', 'Andy'])
        ..start()
        ..pause()
        ..resume()
        ..end();
      expect(tennisMatch, HasDuration(greaterThan(Duration.zero)));
      expect(tennisMatch, HasPauseDuration(greaterThan(Duration.zero)));
      final totalTime = tennisMatch.endTime!.difference(tennisMatch.startTime!);
      expect(totalTime, tennisMatch.duration + tennisMatch.durationOfPauses);
    });
  });

  group('Duration in us:', () {
    test('ready', () {
      final tennisMatch = matchFactory(status: ready, timePoints: []);
      expect(tennisMatch.durationAsMicroseconds, 0);
      expect(tennisMatch.pauses, <int>[]);
    });
    test('started', () {
      final tennisMatch = matchFactory(status: started, timePoints: [0]);
      expect(tennisMatch.pauses, <int>[]);
    });

    test('paused', () {
      final tennisMatch = matchFactory(status: paused, timePoints: [0, 1000]);
      expect(tennisMatch.durationAsMicroseconds, 1000);
      expect(tennisMatch.pauses, <int>[]);
    });
    test('resumed', () {
      final tennisMatch = matchFactory(
        status: ended,
        timePoints: List.generate(11, (i) => i * 1000),
      );
      expect(tennisMatch.durationAsMicroseconds, 5000);
      expect(tennisMatch.pauses, [for (var i = 0; i < 5; i++) 1000]);
    });
    test('end', () {
      final tennisMatch = matchFactory(
        status: ended,
        timePoints: [0, 1000, 2000, 3000],
      );
      expect(tennisMatch.durationAsMicroseconds, 2000);
      expect(tennisMatch.pauses, [1000]);
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
  group('Json Validation Error:', () {
    test('failed init in state ready', () {
      expect(
        () => matchFactory(status: ready, timePoints: [0, 1000, 2000, 3000]),
        throwsA(
          isA<ErrorOf<TimeTracker>>().having(
            (e) => e.message,
            'message',
            'Invalid time line detected',
          ),
        ),
      );
    });
    test('failed init in state started', () {
      expect(
        () => matchFactory(status: started, timePoints: [0, 1000]),
        throwsA(
          isA<ErrorOf<TimeTracker>>().having(
            (e) => e.message,
            'message',
            'Invalid time line detected',
          ),
        ),
      );
    });
    test('failed init in state paused', () {
      expect(
        () => matchFactory(status: paused, timePoints: [0, 1000, 2000]),
        throwsA(
          isA<ErrorOf<TimeTracker>>().having(
            (e) => e.message,
            'message',
            'Invalid time line detected',
          ),
        ),
      );
    });
    test('failed init in state resumed', () {
      expect(
        () => matchFactory(status: resumed, timePoints: [0, 1000]),
        throwsA(
          isA<ErrorOf<TimeTracker>>().having(
            (e) => e.message,
            'message',
            'Invalid time line detected',
          ),
        ),
      );
    });
    test('failed init in state ended', () {
      expect(
        () => matchFactory(status: ended, timePoints: [0]),
        throwsA(
          isA<ErrorOf<TimeTracker>>().having(
            (e) => e.message,
            'message',
            'Invalid time line detected',
          ),
        ),
      );
    });
  });
}
