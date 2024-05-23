
# Time Tracker
[![Dart](https://github.com/simphotonics/time_tracker/actions/workflows/dart.yml/badge.svg)](https://github.com/simphotonics/time_tracker/actions/workflows/dart.yml)

## Introduction

A commonly required task consists in recording the time a process *starts*, is *paused/resumed*,
and the time it
is *completed*. An object of type [`TimeTracker`][TimeTracker] is designed to perform this job.
It is similar to a [`StopWatch`][StopWatch],
however instead of elapsed ticks it records a [`DateTime`][DateTime] point
whenever its status changes.

The image below shows the available states (blue font) defined by
the enum [`TimeStatus`][TimeStatus] and available transitions (orange arrows)
defined by the class [`TimeTracker`][TimeTracker].

![TimeStatus](https://github.com/simphotonics/time_tracker/raw/main/images/time_status.svg?sanitize=true)

Status changing methods are printed with green font. Calling a status changing
method where there is no transition defined has no effect.
For example: calling the method `end()` when the object has status
`TimeStatus.ready` has no effect.

In addition to methods for recording time points,
the mixin [`TimeTracker`][TimeTracker] provides helper methods
for json-serialization. It is recommended that classes *with*
[`TimeTracker`][TimeTracker] override
the equality operator such that a deserialized object will compare equal
to the original object.

## Usage

To use this library include [`time_tracker`][time_tracker]
as a dependency in your pubspec.yaml file.

The example below shows how to construct an object of type `TennisMatch` with
the mixin `TimeTracker`. The object records its own time
points. Note: The getter `hashCode` and the equality operator are overriden
so that decoded objects are equal to the original object.

```Dart
import 'package:exception_templates/exception_templates.dart';
import 'package:time_tracker/time_tracker.dart';

/// Demonstrates how to use TimeTracker.
class TennisMatch with TimeTracker {
  final _players = <String>[];

  TennisMatch(List<String> players) {
    _players.addAll(players);
  }

  /// Constructs an object from a json map.
  TennisMatch.fromJson(Map<String, dynamic> json) {
    if (json case {'players': List players}) {
      _players.addAll(players.cast<String>());

      // Uses the entries of json to initialize the time tracker state.
      initTrackerfromJson(json);
    } else {
      throw ErrorOf<TennisMatch>(
        message: 'Error validating list of players.',
        invalidState: ' Found map: $json',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() {

    // Adds the map entries related to the time tracker.
    final json = trackerToJson();
    json['players'] = List<String>.of(_players);
    return json;
  }

  @override
  int get hashCode => Object.hash(trackerHashCode, _players);

  /// Returns `true` if the two instances have the same time status,
  /// time points, and player list.
  @override
  bool operator ==(Object other) {
    return other is TennisMatch &&
        _players.equal(other._players) &&
        trackerEqual(other);
  }

  @override
  String toString() {
    return 'TennisMatch: players: $_players | status: ${status.name} '
        '| duration: $duration';
  }
}
```

The program below demonstrates how to use an object of type `TennisMatch` to
start, pause, resume, and end the match. It also shows how to serialize and
deserialize the object using ['dart:convert'][dart:convert].
```
void main() async {
  /// Create object (start time is recorded)
  final match = TennisMatch(['Tim', 'Andy'])..start();

  print('----- Create object of type TennisMatch -----');
  print('Status: ${match.status.name} at: ${match.startTime}');

  await Future.delayed(const Duration(milliseconds: 3), () {
    // Pause object
    match.pause();
    print('Status: ${match.status.name} at: ${match.lastTimePoint}');
  });

  await Future.delayed(const Duration(milliseconds: 1), () {
    // Resume object
    match.resume();
    print('Status: ${match.status.name} at: ${match.lastTimePoint}');
  });

  await Future.delayed(const Duration(milliseconds: 2), () {
    // Mark object as ended.
    match.end();
    print('Status: ${match.status.name} at: ${match.lastTimePoint}');
  });

  print('');
  print('---------- Json Encoding -------------');
  final jsonString = jsonEncode(match);
  print('Serialized object:');
  print(jsonString);

  var decodedMatch = TennisMatch.fromJson(jsonDecode(jsonString));
  print('');
  print('Deserialized object:');
  print(decodedMatch);

  print('');
  print('match == decodedMatch: ${match == decodedMatch}');
}
```

<details> <summary> Click to show the console output. </summary>

```Console
$ dart example/bin/time_tracker_example.dart
----- Create object of type TennisMatch -----
Status: started at: 2024-05-23 18:30:06.167586
Status: paused at: 2024-05-23 18:30:06.176602
Status: resumed at: 2024-05-23 18:30:06.180479
Status: ended at: 2024-05-23 18:30:06.183586

---------- Json Encoding -------------
Serialized object:
{"_status":{"timeStatus":"ended"},
 "_timePoints":[
   1716485406167586,
   1716485406176602,
   1716485406180479,
   1716485406183586,
 ],
 "players":["Tim","Andy"],
}

Deserialized object:
TennisMatch: players: [Tim, Andy] | status: ended | duration: 0:00:00.012123

match == decodedMatch: true
```
</details>

## Example

The source code of the program shown above can be found in the folder [example].

## Features and bugs

Please file feature requests and bugs at the [issue tracker].

[issue tracker]: https://github.com/simphotonics/time_tracker/issues

[dart:convert]: https://api.dart.dev/stable/dart-convert/dart-convert-library.html

[DateTime]: https://api.dart.dev/stable/dart-core/DateTime-class.html

[example]: example

[time_tracker]: https://pub.dev/packages/time_tracker

[TimeStatus]: https://pub.dev/documentation/time_tracker/latest/time_tracker/TimeStatus.html

[TimeTracker]: https://pub.dev/documentation/time_tracker/latest/time_tracker/TimeTracker-class.html

[StopWatch]: https://api.dart.dev/stable/dart-core/Stopwatch-class.html