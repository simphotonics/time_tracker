
# Time Tracker

[![Dart](https://github.com/simphotonics/directed_graph/actions/workflows/dart.yml/badge.svg)](https://github.com/simphotonics/directed_graph/actions/workflows/dart.yml)

## Introduction

A common task is recording the time a process starts, is paused/resumed, and the time it
is completed. An object of type [`TimeTracker`][TimeTracker] is designed to perform this job.
In some sense it is similar to a [`StopWatch`][StopWatch]
however instead of elapsed ticks it records a [`DateTime`][DateTime] point whenever its
status changes.

The image below shows the available tracker states (blue font) and available
transitions (orange arrows) from one state to the another.

![TimeStatus](https://github.com/simphotonics/time_tracker/raw/main/images/time_status.svg?sanitize=true)

Status changing methods are printed with green font. Calling a status changing
method where there is no transition defined has no effect.
For example: calling the method `end()` when the object has status
`TimeStatus.ready` has no effect.

In addition to methods for recording time points,
the class [`TimeTracker`][TimeTracker] provides methods for json-serialization.
It overrides the equality operator such that objects with the
same status and the same recorded time
points are considered equal. As such, a deserialized object will compare equal
to the original object.

## Usage

To use this library include [`time_tracker`][time_tracker]
as a dependency in your pubspec.yaml file.

The example below shows how to construct an object of type `TennisMatch` which
extends `TimeTracker`. With this configuration the object records its own time
points. Note: An alternative to extension would be composition. In that case,
an instance of `TimeTracker` could be stored as a class variable.


```Dart
import 'dart:convert';

import 'package:time_tracker/time_tracker.dart';

/// Demonstrates how to extend TimeTracker.
class TennisMatch extends TimeTracker implements Serializable {
  final players = <String>[];

  /// Note the use of the constructor `super.startNow()`.
  /// This creates an instance of TennisMatch with status: started
  /// and records the instantiation time as the first time point.
  TennisMatch(List<String> players) : super.startNow() {
    this.players.addAll(players);
  }

  /// Constructs an object from a json map.
  TennisMatch.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    players.addAll(json['players'].cast<String>());
  }

  /// Converts an object to a json map.
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['players'] = List<String>.of(players);
    return json;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, players);

  /// Returns `true` if the two instances have the same time status,
  /// time points, and player list.
  @override
  bool operator ==(Object other) {
    return other is TennisMatch &&
        other.players.equal(players) &&
        other.timePoints.equal(timePoints) &&
        other.status == status;
  }

  @override
  String toString() {
    return 'Match: players: $players | status: ${status.name} '
        '| duration: $duration';
  }
}

void main(List<String> arguments) async {
  /// Create object (start time is recorded)
  final match = TennisMatch(['Tim', 'Andy']);

  print('----- Create object of type Match -----');
  print('Status: ${match.status.name} at: ${match.startTime}');

  await Future.delayed(const Duration(seconds: 3), () {
    // Pause object
    match.pause();
    print('Status: ${match.status.name} at: ${match.lastTimePoint}');
  });

  await Future.delayed(const Duration(seconds: 1), () {
    // Resume object
    match.resume();
    print('Status: ${match.status.name} at: ${match.lastTimePoint}');
  });

  await Future.delayed(const Duration(seconds: 2), () {
    // Mark object as ended.
    match.end();
    print('Status: ${match.status.name} at: ${match.lastTimePoint}');
  });

  print(match);

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
$ dart time_tracker_example.dart

----- Create object of type TennisMatch -----
Status: started at: 2023-02-21 13:13:18.356681
Status: paused at: 2023-02-21 13:13:21.369724
Status: resumed at: 2023-02-21 13:13:22.374468
Status: ended at: 2023-02-21 13:13:24.377429
Match: players: [Tim, Andy] | status: ended | duration: 0:00:05.016004

---------- Json Encoding -------------
Serialized object:
{"status":{"timeStatus":4},"timePoints":[1676985198356681,1676985201369724,1676985202374468,1676985204377429],"players":["Tim","Andy"]}

Deserialized object:
TennisMatch: players: [Tim, Andy] | status: ended | duration: 0:00:05.016004

match == decodedMatch: true

$
```
</details>

## Example

The source code of the program shown above can be found in the folder [example].

## Features and bugs

Please file feature requests and bugs at the [issue tracker].

[issue tracker]: https://github.com/simphotonics/time_tracker/issues

[DateTime]: https://api.dart.dev/stable/dart-core/DateTime-class.html

[example]: example

[time_tracker]: https://pub.dev/packages/time_tracker

[TimeTracker]: https://pub.dev/documentation/time_tracker/latest/time_tracker/TimeTracker-class.html

[StopWatch]: https://api.dart.dev/stable/dart-core/Stopwatch-class.html