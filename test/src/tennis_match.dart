import 'package:exception_templates/exception_templates.dart';
import 'package:time_tracker/time_tracker.dart';

/// Demonstrates how to use TimeTracker.
class TennisMatch with TimeTracker {
  final List<String> players;

  /// Note the use of the constructor `super.startNow()`.
  /// This creates an instance of TennisMatch with status: started
  /// and records the instantiation time as the first time point.
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
