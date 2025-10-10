import 'dart:convert';
import '../../test/src/tennis_match.dart';

void main() async {
  print('----- Create an object of type TennisMatch -----');
  final match = TennisMatch(['Tim', 'Andy']);
  print(match);
  match.start();

  print('\nStatus: ${match.status.name} at: ${match.startTime}');

  await Future.delayed(const Duration(seconds: 3), () {
    // Pause object
    match.pause();
    print('Status: ${match.status.name}  at: ${match.lastTimePoint}');
  });

  await Future.delayed(const Duration(seconds: 1), () {
    // Resume object
    match.resume();
    print('Status: ${match.status.name} at: ${match.lastTimePoint}');
  });

  await Future.delayed(const Duration(seconds: 2), () {
    // Mark object as ended.
    match.end();
    print('Status: ${match.status.name}   at: ${match.lastTimePoint}');
  });

  print('');
  print('---------- Getters -------------------');
  print('match.durationAsMicroseconds: ${match.durationAsMicroseconds}\n');
  print('match.durationOfPauses: ${match.durationOfPauses}\n');
  print('match.pauses: ${match.pauses} in us\n');

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
