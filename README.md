
# Time Tracker
[![Dart](https://github.com/simphotonics/time_tracker/actions/workflows/dart.yml/badge.svg)](https://github.com/simphotonics/time_tracker/actions/workflows/dart.yml)

## Introduction

A commonly required task consists in recording the time a process *starts*, is *paused/resumed*,
and the time it
has *ended*. The mixin [`TimeTracker`][TimeTracker] is designed
to perform this job. Its methods provide similar functionality to
a [`StopWatch`][StopWatch],
however instead of elapsed ticks it records a [`DateTime`][DateTime] point
whenever its status changes.

The image below shows the available states (grey font) defined by
the enum [`TimeStatus`][TimeStatus] and available transitions (green arrows)
defined by the mixin [`TimeTracker`][TimeTracker].

![TimeStatus](https://github.com/simphotonics/time_tracker/raw/main/images/time_status.svg?sanitize=true)

## Usage

To use this library include [`time_tracker`][time_tracker]
as a dependency in your pubspec.yaml file.

In addition to methods for recording time points,
the mixin [`TimeTracker`][TimeTracker] provides helper methods
for json-serialization. It is recommended that classes *with*
[`TimeTracker`][TimeTracker] override the getter `hashCode`
and the equality operator
such that a deserialized object will compare equal
to the original object.

The example below shows how to create the class `TennisMatch` *with*
the mixin `TimeTracker`.


```Dart
mport 'package:exception_templates/exception_templates.dart';
import 'package:time_tracker/time_tracker.dart';

/// Demonstrates how to use TimeTracker.
class TennisMatch with TimeTracker {
  final List<String> players;

  TennisMatch(List<String> players) : players = List.unmodifiable(players);

  /// Constructs an object from a json map.
  factory TennisMatch.fromJson(Map<String, Object?> json) {
    if (json case {'players': List players}) {
      // Use `initTrackerfromJson` to initializer the time tracker.
      return TennisMatch(players.cast<String>())..initTrackerfromJson(json);
    } else {
      throw ErrorOf<TennisMatch>(
        message: 'Error in TennisMatch.fromJson',
        invalidState: ' Found map: $json',
      );
    }
  }

  @override
  Map<String, Object?> toJson() {
    // Providing the entries related to the time tracker.
    final json = trackerToJson();
    // Adding the rest of the entries.
    json['players'] = players;
    return json;
  }

  @override
  int get hashCode => Object.hash(trackerHashCode, players);

  /// Returns `true` if the two instances have the same time status,
  /// time points, and player list.
  @override
  bool operator ==(Object other) {
    return other is TennisMatch &&
        players.equal(other.players) &&
        trackerEqual(other);
  }

  @override
  String toString() {
    return 'TennisMatch: players: $players | status: ${status.name} '
        '| duration: $duration';
  }
}
```

The program below demonstrates how to use an object of type `TennisMatch` to
start, pause, resume, and end the match. It also shows how to serialize and
deserialize the object using ['dart:convert'][dart:convert].

```Dart
void main() async {
  /// Create object (start time is recorded)
  final match = TennisMatch(['Tim', 'Andy']);
  print('----- Create an object of type TennisMatch -----');
  print(match);
  match.start();

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
----- Create an object of type TennisMatch -----
TennisMatch: players: [Tim, Andy] | status: ready | duration: 0:00:00.000000

Status: started at: 2025-10-09 23:53:16.841832
Status: paused at: 2025-10-09 23:53:19.854479
Status: resumed at: 2025-10-09 23:53:20.858332
Status: ended at: 2025-10-09 23:53:22.859459

---------- Json Encoding -------------
Serialized object:
{"status":{"timeStatus":"ended"},"timePoints":[1760050396841832,1760050399854479,1760050400858332,1760050402859459],"players":["Tim","Andy"]}

Deserialized object:
TennisMatch: players: [Tim, Andy] | status: ended | duration: 0:00:05.013774

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

[TimeTracker]: https://pub.dev/documentation/time_tracker/latest/time_tracker/TimeTracker-mixin.html

[StopWatch]: https://api.dart.dev/stable/dart-core/Stopwatch-class.html