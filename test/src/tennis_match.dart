import 'package:exception_templates/exception_templates.dart';
import 'package:time_tracker/time_tracker.dart';

/// Demonstrates how to use TimeTracker.
class TennisMatch with TimeTracker {
  final _players = <String>[];

  /// Note the use of the constructor `super.startNow()`.
  /// This creates an instance of TennisMatch with status: started
  /// and records the instantiation time as the first time point.
  TennisMatch(List<String> players) {
    _players.addAll(players);
  }

  /// Constructs an object from a json map.
  TennisMatch.fromJson(Map<String, dynamic> json) {
    if (json case {'players': List players}) {
      _players.addAll(players.cast<String>());
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
