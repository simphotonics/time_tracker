import 'dart:convert';
import '../../test/src/tennis_match.dart';

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
