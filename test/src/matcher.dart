import 'package:test/expect.dart' show Matcher;
import 'package:test/test.dart' show CustomMatcher;
import 'package:time_tracker/time_tracker.dart';

class HasStatus<T extends TimeTracker> extends CustomMatcher {
  new(TimeStatus status)
    : super("TimeTracker with status that is", "status", status);
  @override
  Object? featureValueOf(actual) => (actual as T).status;
}

class HasDuration<T extends TimeTracker> extends CustomMatcher {
  new(Matcher matcher)
    : super("TimeTracker with duration that is", "duration", matcher);
  @override
  Object? featureValueOf(actual) => (actual as T).duration;
}

class HasPauseDuration<T extends TimeTracker> extends CustomMatcher {
  new(Matcher matcher)
    : super(
        "TimeTracker with pause duration that is:",
        "pause duration",
        matcher,
      );
  @override
  Object? featureValueOf(actual) => (actual as T).durationOfPauses;
}
