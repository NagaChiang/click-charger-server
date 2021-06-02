import 'package:dotenv/dotenv.dart';

class Config {
  static String get firebaseProjectId => env['firebaseProjectId'] ?? '';
}
