import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../main.dart';
import '../API/apiservice.dart';
import '../app_theme.dart';
import '../database/token_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'edit_observation_screen.dart';


class SavedObservations extends StatefulWidget {
  @override
  _SavedObservationsState createState() => _SavedObservationsState();
}

class _SavedObservationsState extends State<SavedObservations> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSomeProgress = false;
  bool isSelected = false;
  bool checkObs = false;
  late List titles = [];
  late List description = [];
  late List imageFile = [];
  late List indexes = [];
  late List savedSlugs = [];
  late List savedPublic = [];
  late List savedUserGroupName = [];
  late List savedUserGroupId = [];


  ///Delete Observation by Index
  void deleteObsById(int index) async {
    await objectbox.removeObservation(index);
  }

  ///Send Observation by Index
  Future<int> sendOffObservations(int index) async {
    List<File> imageFile = [];
    String? title = "";
    String? descri = "";
    String? geocode = "";
    String? slug = "";
    bool? public = false;
    double? latitude;
    double? longitude;
    List<String>? imagens = [];
    String? userGroup = "";

    var list = await objectbox.queryObservation(index);

    title = list?.titulo;
    descri = list?.descricao;
    geocode = list?.geocode;
    public = list?.public;
    slug = list?.slugs;
    latitude = list?.latitude;
    longitude = list?.longitude;
    imagens = list?.imageFile;
    userGroup = list?.userGroupSlug;

    for(int j=0; j<imagens!.length; j++) {
      imageFile.add(File(imagens[j]));
    }

    var response = await APIService.sendObs(title!,descri!,geocode!,public!,slug!,latitude!,longitude!, imageFile,userGroup!);

    if (response ==200) {
      imageFile.clear();
      deleteObsById(index);
      Navigator.of(context).pop();
      _sendObsSuccess(context);
    } else {
      Navigator.of(context).pop();
      _sendObsFailed(context);
    }
    return response;
  }

  ///Send All Observations
  Future<int?> sendAllObservations(List index) async {

    List<File>? imageFile = [];
    String? title = "";
    String? descri = "";
    String? geocode = "";
    String? slug = "";
    bool? public = false;
    double? latitude;
    double? longitude;
    List<String>? imagens = [];
    int? response;
    String? userGroup = "";

    for (int i =0; i<index.length; i++) {
      var list = await objectbox.queryObservation(index[i]);

      title = list!.titulo;
      descri = list.descricao;
      geocode = list.geocode;
      public = list.public;
      slug = list.slugs;
      latitude = list.latitude;
      longitude = list.longitude;
      imagens = list.imageFile;
      userGroup = list.userGroupSlug;

      for(int j=0; j<imagens!.length; j++) {
        imageFile.add(File(imagens[j]));
      }

      response = await APIService.sendObs(title!,descri!,geocode!,public!,slug!,latitude!,longitude!, imageFile,userGroup! );
      if (response == 200) {
        imageFile.clear();
        deleteObsById(index[i]);
      }

    }
    return response;
  }

  ///Check if there are any Observations pending
  void checkObservations() async {
    String _emailController2 = await TokenStorage.readSecureData("authed");


    var list = await objectbox.queryAllObservations();
    print(list);


    for (int i=0; i<list.length; i++) {
      String emailControl = list[i]["email"];
      if (emailControl == _emailController2) {
        titles.add(list[i]["Titulo"]);
        description.add(list[i]["Descricao"]);
        imageFile.add(list[i]["imageFile"]);
        indexes.add(list[i]["id"]);
        savedSlugs.add(list[i]["nameOfSlug"]);
        savedPublic.add(list[i]["Public"]);
        savedUserGroupId.add(list[i]["idOfUserGroup"]);
      }
    }



    if (titles.isNotEmpty) {
      setState(() {
        checkObs = true;
      });

    } else {
      print("Lista Vazia");
    }

  }

  ///Back Button to dismiss the view observation window
  Future<bool> _onBackPressed() async {
    return false;
  }

  @override
  void initState() {
    super.initState();
    checkObservations();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppTheme.nearlyWhite.withOpacity(0.9),
          body: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    top: 150,
                    left: 50,
                    right: 50,
                  ),
                  child: Image.asset('assets/images/IVDP_logo.png'),
                ),
                const SizedBox(height:35),
                Visibility(
                  visible: !checkObs,
                  child: Container(
                    child: Center(
                      child: Text(
                          AppLocalizations.of(context)!.no_offObservation,
                        style: const TextStyle(
                          color: Color(0xFF346cb0),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),),
                    ),
                  ),
                ),
                Visibility(
                  visible: checkObs,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(12,0,12,0),
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xff336db0),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.6),
                                    offset: const Offset(4, 4),
                                    blurRadius: 8.0),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async{
                                  showDialog(context: context, builder: (context){
                                    return Center(child: CircularProgressIndicator(
                                      color: Color(0xff336db0),
                                    ));
                                  });

                                  try {
                                    final result = await InternetAddress.lookup('google.com');
                                    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {

                                      int? resposta;

                                      resposta = await sendAllObservations(indexes);

                                      setState(() {
                                        if (resposta == 200) {
                                          titles.clear();
                                          indexes.clear();
                                          description.clear();
                                          imageFile.clear();
                                          savedPublic.clear();
                                          savedSlugs.clear();
                                          checkObs = false;
                                          savedUserGroupId.clear();
                                        }
                                      });
                                      if (resposta == 200) {
                                        Navigator.of(context).pop();
                                        _sendObsSuccess(_scaffoldKey.currentContext!);
                                      }

                                    }
                                  } on SocketException catch (_) {
                                    Navigator.of(context).pop();
                                    _offlineError(context);
                                  }

                                },
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      AppLocalizations.of(context)!.send_all,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height:35),
                Visibility(
                  visible: checkObs,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(5, 0, 12, 0),
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          Container(
                            height: 50,
                            alignment: Alignment.center,
                            width: 68,

                            child: Text(
                              AppLocalizations.of(context)!.edit,
                              style: const TextStyle(
                                  color: Color(0xFF346cb0),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                              width: 129,
                              height: 50,
                              alignment: Alignment.centerLeft,

                              child:
                              Text(
                                  AppLocalizations.of(context)!.title,
                                style: const TextStyle(
                                    color: Color(0xFF346cb0),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              )),

                          Container(
                            height: 50,
                            alignment: Alignment.center,
                            width: 45,

                            child: Text(
                              AppLocalizations.of(context)!.see,
                              style: const TextStyle(
                                  color: Color(0xFF346cb0),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            height: 50,
                            alignment: Alignment.center,
                            width: 50,

                            child: Text(
                              AppLocalizations.of(context)!.delete,
                              style: const TextStyle(
                                  color: Color(0xFF346cb0),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),

                          Container(
                            height: 50,
                            width: 50,
                            alignment: Alignment.center,
                            child: Text(
                              AppLocalizations.of(context)!.send,
                              style: const TextStyle(
                                  color: Color(0xFF346cb0),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(

                  height: 300,
                  width: MediaQuery.of(context).size.width,

                  child: Container(
                    margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                    child: Visibility(
                      visible: checkObs,
                      child: ListView.builder(
                        key: UniqueKey(),
                        scrollDirection: Axis.vertical,
                        itemCount: titles.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                              leading: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditObs(
                                          savedTitle: titles[index],
                                          savedDesc: description[index],
                                          savedImages: imageFile[index],
                                          savedIndex: indexes[index],
                                          savedSlug: savedSlugs[index],
                                          savedPriv: savedPublic[index],
                                          savedUserGroup: savedUserGroupId[index],
                                        )),
                                  );
                                },
                              ),
                              title: Container(
                                  height: 50,
                                  alignment: Alignment.centerLeft,
                                  child: Text('${titles[index]}')),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [

                                  IconButton(
                                    icon: const Icon(Icons.remove_red_eye),
                                    onPressed: () {
                                      showMessageDialog(context,index);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () {
                                      deleteObsById(indexes[index]);

                                      setState(() {
                                        titles.removeAt(index);
                                        indexes.removeAt(index);
                                        description.removeAt(index);
                                        imageFile.removeAt(index);
                                        savedPublic.removeAt(index);
                                        savedSlugs.removeAt(index);
                                        savedUserGroupId.removeAt(index);

                                         if (titles.isEmpty) {
                                           setState(() {
                                             checkObs = false;
                                           });
                                         }

                                      });


                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.send),
                                    onPressed: () async {
                                      showDialog(context: context, builder: (context){
                                        return Center(child: CircularProgressIndicator(
                                          color: Color(0xff336db0),
                                        ));
                                      });

                                      int resposta;
                                      try {
                                        final result = await InternetAddress.lookup('google.com');
                                        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                                          resposta = await sendOffObservations(indexes[index]);

                                          setState(() {
                                            if (resposta == 200) {
                                              deleteObsById(indexes[index]);
                                              titles.removeAt(index);
                                              indexes.removeAt(index);
                                              description.removeAt(index);
                                              imageFile.removeAt(index);
                                              savedPublic.removeAt(index);
                                              savedSlugs.removeAt(index);
                                              if (titles.isEmpty) {
                                              }
                                            }
                                          });

                                        }
                                      } on SocketException catch (_) {
                                        Navigator.of(context).pop();
                                        _offlineError(context);
                                      }
                                    },
                                  ),
                                ],
                              ));
                        },
                      ),
                    ),
                  ),
                ),

              ]
          )
      ),
    );
  }

  //Messages Pop Up
  showMessageDialog(BuildContext context, int index) =>
      showDialog(context: _scaffoldKey!.currentContext!, builder: (context)=> Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: Container(
          height: 500,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFFEDF0F2),
              border: Border.all(color: const Color(0xFF346cb0))
          ),
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              Center(
                child: Container(
                  child: Column(
                    children: [
                      Text(
                        titles[index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text(
                      description[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50.0),
              SizedBox(
                height: 100,
                width: 280,
                child: Container(
                  alignment: Alignment.center,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: imageFile[index].length,
                    itemBuilder: (context, index2) {
                      return Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 3, 0),
                        decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF346cb0))
                        ),
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: GestureDetector(
                            child: Hero(
                              tag: 'imageHero',
                              child: Image.file(
                                File(imageFile[index][index2]),
                                fit: BoxFit.fill,
                              ),
                            ),
                            onTap: () {

                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) {
                                return DetailScreen(url: imageFile[index][index2]);
                              }));
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 50.0),
              DialogButton(
                color: const Color(0xFF346cb0),
                onPressed: () => Navigator.of(context,rootNavigator: true).pop(),
                width: 120,
                child: Text(
                    AppLocalizations.of(context)!.continuar,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),

            ],
          ),
        ),
      ),
      );

  _sendObsSuccess(BuildContext context) {
    Alert(
      context: _scaffoldKey!.currentContext!,
      type: AlertType.success,
      title: AppLocalizations.of(context)!.success,
      desc: AppLocalizations.of(context)!.obs_send,
      buttons: [
        DialogButton(
          onPressed: () async {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          width: 120,
          child: Text(
            AppLocalizations.of(context)!.ok,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  _sendObsFailed(BuildContext context) {
    Alert(
      context: _scaffoldKey!.currentContext!,
      type: AlertType.error,
      title: AppLocalizations.of(context)!.error,
      desc: AppLocalizations.of(context)!.err_send_obs,
      buttons: [
        DialogButton(
          onPressed: () => Navigator.of(context,rootNavigator: true).pop(),
          width: 120,
          child: Text(
            AppLocalizations.of(context)!.ok,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  _offlineError(BuildContext context) {
    Alert(
      context: _scaffoldKey!.currentContext!,
      type: AlertType.info,
      title: AppLocalizations.of(context)!.no_connection,
      desc: AppLocalizations.of(context)!.check_connection,
      buttons: [
        DialogButton(
          onPressed: () => Navigator.of(context,rootNavigator: true).pop(),
          width: 120,
          child: Text(
            AppLocalizations.of(context)!.ok,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }



}

class DetailScreen extends StatefulWidget {

  final String url;

  DetailScreen({Key? key, required this.url})
      : assert(url != null),
        super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
  }

  @override
  void dispose() {

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: Image.file(
              File(widget.url),
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}