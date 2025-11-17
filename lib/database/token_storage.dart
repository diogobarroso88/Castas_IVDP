import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage{
  static const storage = FlutterSecureStorage();

  static Future writeSecureData(String key, String token) async {
    await storage.write(key: key, value: token);
  }

  static Future readSecureData(String
  key) async {
    String? readData = await storage.read(key: key);
    return readData;
  }

  static Future deleteSecureData(String key) async {
    await storage.delete(key: key);
  }

  static Future readAllSecureData() async {
    Map<String, String> allValues = await storage.readAll();
    //print(allValues);
  }

  static Future deleteAll() async {
    await storage.deleteAll();
  }
}
