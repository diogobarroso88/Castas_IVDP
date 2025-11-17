import 'package:objectbox/objectbox.dart';

@Entity()

class User {

  int? id;
  String? nome;
  String? email;
  String? username;
  String? filePath;
  int? nrObs;
  List<String>? subSlug;
  List<String>? subSlugname;
  List<String>? userGroupsName;
  List<String>? userGroupsSlug;

  User({
    this.id,
    this.nome,
    this.email,
    this.username,
    this.filePath,
    this.nrObs,
    this.subSlug,
    this.subSlugname,
    this.userGroupsName,
    this.userGroupsSlug,
  });




}

@Entity()
class Observation{
  int? id;
  String? titulo;
  String? descricao;
  String? geocode;
  bool? public;
  String? slugs;
  double? latitude;
  double? longitude;
  List<String>? imageFile;
  String? emailController;
  String? nameOfSlug;
  String? userGroupSlug;

  Observation({
    this.id,
    this.titulo,
    this.descricao,
    this.geocode,
    this.public,
    this.slugs,
    this.latitude,
    this.longitude,
    this.imageFile,
    this.emailController,
    this.nameOfSlug,
    this.userGroupSlug,
  });
}