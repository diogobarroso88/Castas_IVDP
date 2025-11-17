import '../database/token_storage.dart';

Future<String> getToken() async {

  var token = await TokenStorage.readSecureData("logged");
  String _token = token.toString();
  String header = ("Bearer " + _token);

  return header;
}