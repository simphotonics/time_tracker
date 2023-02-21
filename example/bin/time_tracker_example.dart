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
    return 'TennisMatch: players: $players | status: ${status.name} '
        '| duration: $duration';
  }
}

void main(List<String> arguments) async {
  /// Create object (start time is recorded)
  final match = TennisMatch(['Tim', 'Andy']);

  print('----- Create object of type TennisMatch -----');
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
