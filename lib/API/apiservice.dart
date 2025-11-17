import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../database/getToken.dart';
import '../database/token_storage.dart';

class APIService {

  TokenStorage tokenStorage = TokenStorage();

  static var _url = ("mysenseapi.utad.pt");
  static var urlLogin = Uri.https('mysenseapi.utad.pt', '/api/login');
  static var urlSigU = Uri.https('mysenseapi.utad.pt', '/api/register');
  static var urlServ = Uri.https('mysenseapi.utad.pt', '/api/services');
  static var urlUser = Uri.https('mysenseapi.utad.pt', '/api/user');
  //static var urlUserGroup = Uri.https('mysenseapi.utad.pt', '/api/usergroups');

  static Map<String,String> titlesObs= {
    'A - Gomo de Inverno' : 'a_winter_bud',
    'B - Gomo de Algodão' : 'b_woolly_bud',
    'C - Ponta Verde' : 'c_bud_break',
    'D - Saída de Folhas' : 'd_leaf_emergence',
    'E - Folhas Livres' : 'e_leaves_separated',
    'F - Cachos Visíveis' : 'f_inflorescences_visible',
    'G - Cachos Separados' : 'g_inflorescences_separated',
    'H - Botões Florais Separados' : 'h_flowers_separated',
    'I - Floração"' : 'i_bloom',
    'J - Alimpa' : 'j_fruit_set',
    'K - Bago de Ervilha' : 'k_berries_pea_size',
    'L - Cacho Fechado' : 'l_berries_touching',
    'M - Pintor' : 'm_veraison',
    'N - Maturação' : 'n_maturity',
    'O - Atempamento da Vara' : 'o_cane_maturation',
    'P - Queda de Folhas' : 'p_leaf_fall',
  };



  static var urlUserGroup = Uri(
    scheme: 'https',
    host: 'mysenseapi.utad.pt',
    path: '/api/usergroups',
  );


  static Future<int> login(String email, String password) async {
    var header = {"Content-Type": "application/json"};

    Map params = {
      "email": email,
      "password": password,
    };

    var _body = json.encode(params);

    var response = await http.post(urlLogin, headers: header, body: _body);

    Map token = jsonDecode(response.body);


    if (response.statusCode == 200) {
      String _token = token['token'];
      TokenStorage.writeSecureData(email + password, _token);
    }

    return response.statusCode;
  }

  static Future<int> signUp(String name, String email, String username,
      String password) async {
    var header = {"Content-Type": "application/json"};

    Map params = {
      "name": name,
      "email": email,
      "username": username,
      "password": password,
    };

    var _body = json.encode(params);
    print("json enviado: $_body");

    var response = await http.post(urlSigU, headers: header, body: _body);
    print(response.statusCode);

    if (response.statusCode == 302) {
      return response.statusCode;
    } else {
      Map token = jsonDecode(response.body);
      String _token = token['token'];

      if (response.statusCode == 200) {
        TokenStorage.writeSecureData(email + password, _token);
      }


      return response.statusCode;
    }
  }

  static Future<List> getService() async {
    String _header = await getToken();
    var header = {"Authorization": _header};

    var response = await http.get(urlServ, headers: header);
    //print (response.statusCode);
    var services = jsonDecode(response.body);

    return services;
  }

  static Future<List> getUser() async {
    String _header = await getToken();
    var header = {"Authorization": _header};

    var response = await http.get(urlUser, headers: header);
    print(response.body);

    Map data = jsonDecode(response.body);


    String _name = data['name'];
    String _image = data['avatar'];
    String _email = data['email'];
    String _username = data['username'];

    List<String> _data = [_name, _image, _email, _username];
    return _data;

  }

  static Future<List> getUserGroup() async {
    String _header = await getToken();
    var header = {"Authorization": _header};


    var response = await http.get(urlUserGroup, headers: header);



    Map data = jsonDecode(response.body);

    List data2 = data['groups'];
    print(data2);
    List nameList = [];
    List uuidList = [];

    for(int i=0;i<data2.length;i++){
      nameList.add(data2[i]['name']);
      uuidList.add(data2[i]['uuid']);
    }


    List<List> _data = [nameList,uuidList];

    return _data;

  }

  static Future<int> sendObs(String title, String description, String geocode,
      bool public, String slug, double latitude, double longitude,
      List<File> media, String userGroup) async {
    var _slug = slug;

    String urlSendObs = ("/api/services/${_slug}/observation");
    var urlSO = Uri.https(_url, urlSendObs);

    String _header = await getToken();
    var header = {
      "Content-Type": "application/json",
      "Authorization": _header,
    };
    Map params = {
      "title": title,
      "description": description,
      "latitude": latitude,
      "longitude": longitude,
      "geocode": geocode,
      "public": public,
      "user-groups": [
        userGroup
      ]
    };

    var _body = json.encode(params);
    print("json enviado: $_body");


    var response = await http.post(urlSO, headers: header, body: _body);
    print(response.statusCode);
    print(response.body);


    var services = jsonDecode(response.body);

    String imgURL = services['images-url'];
    print('Response status Observ: ${response.statusCode}');
    print(response.body);

    Uri myUri = Uri.parse(imgURL);
    var header2 = {
      "Content-Type": "multipart/form-data",
      "Authorization": _header
    };

    print(media);

    // create multipart request
    var request = new http.MultipartRequest("POST", myUri);
    int numero = 0;

    for (var file in media) {
      String fileName = file.path
          .split("/")
          .last;
      var stream = new http.ByteStream(file.openRead());
      stream.cast();

      // get file length
      var length = await file.length();
      print(length);

      // multipart that takes file
      var multipartFileSign = new http.MultipartFile(
          'images[$numero]', stream, length, filename: fileName);
      //print(fileName);
      numero++;

      request.files.add(multipartFileSign);
    }

    request.headers.addAll(header2);
    var response2 = await request.send();

    response2.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });

    return response2.statusCode;
  }

  static Future<int> sendObsVPS(String title, String description, String geocode,
      bool public, String slug, double latitude, double longitude,
      List<File> media, String userGroup) async {

    var _slug = slug;
    var setTitle = titlesObs[title];

    print(titlesObs[title]);


    String urlSendObs = ("/api/services/${_slug}/observation");
    var urlSO = Uri.https(_url, urlSendObs);

    String _header = await getToken();

    var header = {
      "Content-Type": "application/json",
      "Authorization": _header,
    };

    Map params = {

      "title-uuid": setTitle,
      "title": setTitle,
      "description": description,
      "latitude": latitude,
      "longitude": longitude,
      "geocode": geocode,
      "public": public,
      "user-groups": [
        userGroup
      ]
    };

    var _body = json.encode(params);
    print("json enviado: $_body");


    var response = await http.post(urlSO, headers: header, body: _body);
    print(response.statusCode);
    print(response.body);


    var services = jsonDecode(response.body);

    String imgURL = services['images-url'];
    print('Response status Observ: ${response.statusCode}');
    print(response.body);

    Uri myUri = Uri.parse(imgURL);
    var header2 = {
      "Content-Type": "multipart/form-data",
      "Authorization": _header
    };

    print(media);

    // create multipart request
    var request = new http.MultipartRequest("POST", myUri);
    int numero = 0;

    for (var file in media) {
      String fileName = file.path
          .split("/")
          .last;
      var stream = new http.ByteStream(file.openRead());
      stream.cast();

      // get file length
      var length = await file.length();
      print(length);

      // multipart that takes file
      var multipartFileSign = new http.MultipartFile(
          'images[$numero]', stream, length, filename: fileName);
      //print(fileName);
      numero++;

      request.files.add(multipartFileSign);
    }

    request.headers.addAll(header2);
    var response2 = await request.send();

    response2.stream.transform(utf8.decoder).listen((value) {
      print(value);

    });

    return response2.statusCode;

  }

  static Future<int> getNrObs(String slug) async {
    String urlSendObs = ("/api/services/${slug}");
    var urlGO = Uri.https(_url, urlSendObs);

    String _header = await getToken();

    var header = {
      "Content-Type": "multipart/form-data",
      "Authorization": _header
    };

    var response = await http.get(urlGO, headers: header);

    print('Response status: ${response.statusCode}');

    var services = jsonDecode(response.body);

    //print (services["observations"][1]);
    int contador = 0;
    print(services["observations"].length);

    return services["observations"].length;
  }

  static Future<List<List<String>>> getObsData(String slug) async {


    List observationName = [];
    List<String>? observationTitle = [];
    List<String>? observationDesc = [];
    List? observationPhoto = [];
    List<String>? observationPhotoUrl = [];
    List<List<String>>? imagesUrl = [];
    List<List<String>>? observations = [];

    String urlSendObs = ("/api/services/${slug}");
    var urlGO = Uri.https(_url, urlSendObs);

    String _header = await getToken();

    var header = {
      "Content-Type": "multipart/form-data",
      "Authorization": _header
    };

    var response = await http.get(urlGO, headers: header);


    var services = jsonDecode(response.body);

    int tamanho = services["observations"].length;

    for (int i = 0; i < tamanho; i++) {
      observationName.add(services["observations"][i]);
      observationTitle.add(observationName[i]["title"]);
      observationDesc.add(observationName[i]["description"].toString());
      observationPhoto.add(observationName[i]["images"]);

    }

    for (int i = 0; i < tamanho; i++) {
      for (int j = 0; j < observationPhoto[i].length; j++) {
        observationPhotoUrl.add(observationPhoto[i][j]["url"]);
      }
      imagesUrl.add(observationPhotoUrl.toList());
      observationPhotoUrl.clear();
    }

    observations.add(observationTitle);
    observations.add(observationDesc);

    return observations;

  }

  static Future<List<List<String>>> getObsImages(String slug) async {
    List observationName = [];
    List observationPhoto = [];
    List<String> observationPhotoUrl = [];
    List<List<String>> imagesUrl = [];

    String urlSendObs = ("/api/services/${slug}");
    var urlGO = Uri.https(_url, urlSendObs);

    String _header = await getToken();

    var header = {
      "Content-Type": "multipart/form-data",
      "Authorization": _header
    };

    var response = await http.get(urlGO, headers: header);

    var services = jsonDecode(response.body);

    int tamanho = services["observations"].length;

    for (int i = 0; i < tamanho; i++) {
      observationName.add(services["observations"][i]);
      observationPhoto.add(observationName[i]["images"]);
    }

    for (int i = 0; i < observationPhoto.length; i++) {
      for (int j = 0; j < observationPhoto[i].length; j++) {
        observationPhotoUrl.add(observationPhoto[i][j]["url"]);
      }
      imagesUrl.add(observationPhotoUrl.toList());
      observationPhotoUrl.clear();
    }


    return imagesUrl;
  }

}
