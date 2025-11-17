import 'package:objectbox/objectbox.dart';
import "package:path_provider/path_provider.dart";
import 'package:path/path.dart' as p;


import '../objectbox.g.dart';
import 'model.dart';


/// Provides access to the ObjectBox Store throughout the app.
///
/// Create this in the apps main function.
class ObjectBox {
  /// The Store of this app.
  late final Store _store;

  /// A Box of notes.
  late final Box<User> _userBox;
  late final Box<Observation> _observationBox;

  ObjectBox._create(this._store) {
    _userBox = Box<User>(_store);
    _observationBox = Box<Observation>(_store);

  }

  /// Create ObjectBox instance
  static Future<ObjectBox> create() async {
    final store = await openStore(
        directory: p.join(
            (await getApplicationDocumentsDirectory()).path, "obx-demo"));
    return ObjectBox._create(store);
  }


  /// Get Users and Observations

  Future<List<Map>> queryAllUsers() async {

    var listToReturn = <Map<dynamic, dynamic>>[];
    var listOfUsers = _userBox.getAll();

    for (User user in listOfUsers) {
      var map = {};
      map['Nome'] = user.nome;
      map['Email'] = user.email;
      map['Username'] = user.username;
      map['Endereco Foto'] = user.filePath;
      map['Numero de Observações'] = user.nrObs;
      map['Slugs Subscritas'] = user.subSlug;
      map['Nome Slug'] = user.subSlugname;
      map['UserGroups'] = user.userGroupsName;
      map['UserGroupsSlug'] = user.userGroupsSlug;
      map['id'] = user.id;
      listToReturn.add(map);
    }
    return listToReturn;
  }

  Future<User?> queryPerson(int id) async {
    var usr = _userBox.get(id);
    return usr;
  }

  Future<List<Map<dynamic, dynamic>>> queryAllObservations() async {

    var listToReturn = <Map<dynamic, dynamic>>[];
    var listOfObservations = _observationBox.getAll();

    for (Observation observation in listOfObservations) {
      var map = {};
      map['Titulo'] = observation.titulo;
      map['Descricao'] = observation.descricao;
      map['Geocode'] = observation.geocode;
      map['Public'] = observation.public;
      map['Slug'] = observation.slugs;
      map['latitude'] = observation.latitude;
      map['longitude'] = observation.longitude;
      map['imageFile'] = observation.imageFile;
      map['email'] = observation.emailController;
      map['nameOfSlug'] = observation.nameOfSlug;
      map['idOfUserGroup'] = observation.userGroupSlug;
      map['id'] = observation.id;
      listToReturn.add(map);
    }

    return listToReturn;
  }

  Future<Observation?> queryObservation(int id) async {
    var obs = _observationBox.get(id);
    return obs;
  }

  /// Add and Remove Users and Observations

  Future<void> addUser(String text, String text1, String text2, String text3, int text4, List<String> text5, List<String> text6, List<String> text7, List<String> usergroupsslug) async {
    _userBox.putAsync(User(
      nome: text,
      email: text1,
      username:text2,
      filePath: text3,
      nrObs: text4,
      subSlug: text5,
      subSlugname: text6,
      userGroupsName: text7,
      userGroupsSlug: usergroupsslug,
    )
    );
  }

  Future<void> removeUser(int id) => _userBox.removeAsync(id);

  int removeAllUsers() => _userBox.removeAll();

  Future<void> addObservation(String titulo, String descricao, String geocode, bool public, String slugs, double latitude, double longitude, List<String> imageFile, String emailController, String nameOfSlug, String userGroup) => _observationBox.putAsync(Observation(
    titulo: titulo,
    descricao: descricao,
    geocode: geocode,
    public: public,
    slugs: slugs,
    latitude: latitude,
    longitude: longitude,
    imageFile: imageFile,
    emailController: emailController,
    nameOfSlug: nameOfSlug,
    userGroupSlug: userGroup,
  ));

  Future<void> removeObservation(int id) => _observationBox.removeAsync(id);
}
