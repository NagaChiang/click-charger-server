import 'dart:io';

const rtdnApiName = 'rtdn';
const verifyApiName = 'verify';

final internetAddress = InternetAddress.anyIPv4;
final port = int.parse(Platform.environment['PORT'] ?? '8080');
final baseUrl = 'http://127.0.0.1:$port';
