import 'dart:io';
import 'package:flutter/gestures.dart';
import '../API/apiservice.dart';
import '../main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import '../app_theme.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../database/token_storage.dart';
import '../models/castas_list.dart';
import '../models/image_helper.dart';

class SendObs extends StatefulWidget {



  @override
  _SendObsState createState() => _SendObsState();
}

class _SendObsState extends State<SendObs> {
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();

  var my_services;

  _onclicked(value) {
    print('Clicked...' + value.toString());
  }

  List<bool> _selections = [true, false];
  bool public = false;
  bool isSomeProgress = false;
  bool notValidated = false;
  bool isOnline = true;
  bool notPheno = true;
  bool isPheno = false;
  Position? _position;


  late Future locationMap;

  late String titleController="";
  late String setTitleController="";
  late String descriptionController="";
  late String geocodeController="";
  late String userGroupController="";
  late String slugChoose = "" ;
  late String titleChoose = "";
  late String userGroupChoose = "";
  late double latitude;
  late double longitude;




  List<String> setName = [];
  List listItem = [];
  List listSlug = [];
  List listUserGroupName = [];
  List listUserGroupId = [];
  List<bool> tintobranco = [true,false];
  Map slugs = {};
  Map userGroups = {};
  String userGroup = ("cHgxlASbYYOdK2dv");
  String demandingSlug = ("vine-varieties-identification");




  ///Image Picker
  final imageHelper = ImageHelper();
  int  maxAssetsCount = 6;
  int nrTempImages = 0;
  int nrImages = 0;

  List<File> imageFile = [];
  List<File> tempImageFile = [];
  List<String> imageFilePath =[];

  void _clearCachedFiles(int index) {
    setState(() {
      imageFile.removeAt(index);
      nrImages --;
    });
  }

  ///Checking Online Feature to present the map
  Future isItOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          isOnline = true;
        });
      }
    } on SocketException catch (_) {
      setState(() {
        isOnline = false;
      });
    }
  }


  ///GPS Location and Map
  Future<List<double>> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    List<double> coordenadas = [];

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position _position = await Geolocator.getCurrentPosition();
    if (this.mounted) {
      setState(() {
        latitude = _position.latitude;
        longitude = _position.longitude;
      });
    }
    coordenadas.add(_position.latitude);
    coordenadas.add(_position.longitude);
    return coordenadas;
  }


  InputDecoration myTextFieldDecoration({
    String hintText = "",
    }) {
    return InputDecoration(
      border: InputBorder.none,
      hintText: hintText,

      );
  }


  ///Save, read and delete observations from database
  void readAll() async {

    var list = await objectbox.queryAllUsers();
    String _emailController = await TokenStorage.readSecureData("authed");

    for (int i=0; i<list.length; i++) {
      if (list[i]["Email"] == _emailController){
        setState(() {
          listItem = list[i]["Slugs Subscritas"];
          listSlug = list[i]["Nome Slug"];
          listUserGroupName = list[i]["UserGroups"];
          listUserGroupId = list[i]["UserGroupsSlug"];
        });

        for (int j=0; j<listItem.length; j++) {

          setState(() {
            slugs[listItem[j]] = listSlug[j];
          });
        }

        for (int j=0; j<listUserGroupName.length; j++) {

          setState(() {
            userGroups[listUserGroupName[j]] = listUserGroupId[j];
          });
        }


        setState(() {
          slugChoose=listItem[0];
          userGroupChoose=listUserGroupName[0];

        });

        if (slugChoose == "Registo de estados fenológicos da videira"){
          setState(() {
            isPheno = true;
            notPheno = false;
          });
        } else {
          setState(() {
            isPheno = false;
            notPheno = true;
          });
        }

      }
    }


  }

  void keepObservation() async {
    String _emailController = await TokenStorage.readSecureData("authed");

    await objectbox.addObservation(titleController, descriptionController, geocodeController, public, demandingSlug, longitude, latitude,  imageFilePath, _emailController, slugChoose, userGroup);
  }

  void readObservations() async {
    var list = await objectbox.queryAllObservations();

    for (int i=0; i<list.length; i++) {
      print(list.toString());
    }
  }

  void deleteById(int index) async {
    await objectbox.removeObservation(index);
  }

  ///Back button
  Future<bool> _onBackPressed() async {
    return false;
  }

  @override
  void initState() {
    super.initState();
    readAll();
    locationMap = _determinePosition();
    isItOnline();
  }

  ///Validation to required fields
  void validateAndSave() {
    if(globalFormKey.currentState!.validate()){
      globalFormKey.currentState?.save();
      notValidated = false;
      return;
    } else notValidated = true;
  }

  @override
  Widget build(BuildContext context) {


    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Container(
        color: AppTheme.nearlyWhite.withOpacity(0.9),
        child: SafeArea(
          top: false,
          child: Scaffold(
            backgroundColor: AppTheme.nearlyWhite.withOpacity(0.9),
            body: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Form(
                  key: globalFormKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 40),
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(icon: const Icon(Icons.arrow_back),
                            onPressed: (){
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                              AppLocalizations.of(context)!.send_obs_ivdp,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Color(0xFF346cb0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),
                        buildTitle(),
                        const SizedBox(height: 25),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Center(
                                child: Container(
                                  height: 45,
                                  width: 120,
                                  margin: const EdgeInsets.fromLTRB(16,0,12,0),
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
                                      onTap: () async {
                                        print(nrImages);
                                          if(nrImages<6){
                                            final files = await imageHelper.pickImageCamera();
                                            tempImageFile = files.map((e) => File(e.path)).toList();

                                            if (tempImageFile.isNotEmpty) {
                                                for (var i = 0; i < tempImageFile.length; i++) {
                                                  if (nrImages<6){
                                                    imageFile.add(File(tempImageFile[i].path));
                                                    imageFilePath.add(tempImageFile[i].path);
                                                    setState(() {
                                                      nrImages++;
                                                    },
                                                  );
                                                } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text(AppLocalizations.of(context)!.too_many_images,),
                                                      ),
                                                    );
                                                  }

                                              }
                                            }
                                          }
                                      },
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            AppLocalizations.of(context)!.camera,
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
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Center(
                                child: Container(
                                  height: 45,
                                  width: 120,
                                  margin: const EdgeInsets.fromLTRB(12,0,12,0),
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
                                      onTap: () async {
                                        print(nrImages);
                                        if(nrImages<6){
                                          final files = await imageHelper.pickImageGallery(multiple: true);
                                          tempImageFile = files.map((e) => File(e.path)).toList();

                                          if (tempImageFile.isNotEmpty) {
                                            for (var i = 0; i < tempImageFile.length; i++) {
                                              if (nrImages<6){
                                                imageFile.add(File(tempImageFile[i].path));
                                                imageFilePath.add(tempImageFile[i].path);
                                                setState(() {
                                                  nrImages++;
                                                },
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(AppLocalizations.of(context)!.too_many_images,),
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        }
                                      },
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            AppLocalizations.of(context)!.load_pics,
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
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                margin: const EdgeInsets.all(4.0),
                                child:
                                nrImages == 0
                                    ? null
                                    : Stack(
                                      children: [
                                          Image.file(
                                            imageFile[0],
                                            fit: BoxFit.fill,
                                            height: 95,
                                            width: 95),
                                          Positioned(
                                            top: -12,
                                            right: -12,
                                            child: IconButton(
                                                icon: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withOpacity(0.5), // Cor de fundo opcional
                                                    shape: BoxShape.rectangle,
                                                    borderRadius: BorderRadius.circular(0), // Sem bordas arredondadas
                                                  ),
                                                  padding: EdgeInsets.all(0.1), // Espaçamento interno
                                                  child: const Icon(
                                                    Icons.close_rounded,
                                                    color: Colors.white,
                                                    size: 25,
                                                  ),
                                                ),
                                              onPressed: () {
                                              _clearCachedFiles(0);
                                              },
                                            )
                                    ),
                                  ],
                                )
                            ),
                            Container(
                                margin: const EdgeInsets.all(4.0),
                                child:
                                nrImages <= 1
                                    ? null
                                    : Stack(
                                      children: [
                                        Image.file(
                                          imageFile[1],
                                          fit: BoxFit.fill,
                                          height: 95,
                                          width: 95),
                                        Positioned(
                                          top: -12,
                                          right: -12,
                                          child: IconButton(
                                              icon: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.5), // Cor de fundo opcional
                                                  shape: BoxShape.rectangle,
                                                  borderRadius: BorderRadius.circular(0), // Sem bordas arredondadas
                                                ),
                                                padding: EdgeInsets.all(0.1),
                                                child: const Icon(
                                                  Icons.close_rounded,
                                                  color: Colors.white,
                                                  size: 25,
                                                ),
                                              ),
                                            onPressed: () {
                                            _clearCachedFiles(1);
                                          },
                                        )
                                    ),
                                  ],
                                )
                            ),
                            Container(
                                margin: const EdgeInsets.all(4.0),
                                child:
                                nrImages <= 2
                                    ? null
                                    : Stack(
                                      children: [
                                        Image.file(
                                          imageFile[2],
                                          fit: BoxFit.fill,
                                          height: 95,
                                          width: 95),
                                        Positioned(
                                          top: -12,
                                          right: -12,
                                          child: IconButton(
                                            icon: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.5), // Cor de fundo opcional
                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius.circular(0), // Sem bordas arredondadas
                                              ),
                                              padding: EdgeInsets.all(0.1),
                                              child: const Icon(
                                                Icons.close_rounded,
                                                color: Colors.white,
                                                size: 25,
                                              ),
                                            ),
                                            onPressed: () {
                                            _clearCachedFiles(2);
                                          },
                                        )
                                    ),
                                  ],
                                )
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                margin: const EdgeInsets.all(4.0),
                                child:
                                nrImages <= 3
                                    ? null
                                    : Stack(
                                      children: [
                                        Image.file(
                                          imageFile[3],
                                          fit: BoxFit.fill,
                                          height: 95,
                                          width: 95),
                                        Positioned(
                                          top: -12,
                                          right: -12,
                                          child: IconButton(
                                            icon: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.5), // Cor de fundo opcional
                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius.circular(0), // Sem bordas arredondadas
                                              ),
                                              padding: EdgeInsets.all(0.1),
                                              child: const Icon(
                                                Icons.close_rounded,
                                                color: Colors.white,
                                                size: 25,
                                              ),
                                            ),
                                            onPressed: () {
                                            _clearCachedFiles(3);
                                          },
                                        )
                                    ),
                                  ],
                                )
                            ),
                            Container(
                                margin: const EdgeInsets.all(4.0),
                                child:
                                nrImages <= 4
                                    ? null
                                    : Stack(
                                      children: [
                                        Image.file(
                                          imageFile[4],
                                          fit: BoxFit.fill,
                                          height: 95,
                                          width: 95),
                                        Positioned(
                                          top: -12,
                                          right: -12,
                                          child: IconButton(
                                            icon: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.5), // Cor de fundo opcional
                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius.circular(0), // Sem bordas arredondadas
                                              ),
                                              padding: EdgeInsets.all(0.1),
                                              child: const Icon(
                                                Icons.close_rounded,
                                                color: Colors.white,
                                                size: 25,
                                              ),
                                            ),
                                            onPressed: () {
                                            _clearCachedFiles(4);
                                          },
                                        )
                                    ),
                                  ],
                                )
                            ),
                            Container(
                                margin: const EdgeInsets.all(4.0),
                                child:
                                nrImages <= 5
                                    ? null
                                    : Stack(
                                      children: [
                                        Image.file(
                                          imageFile[5],
                                          fit: BoxFit.fill,
                                          height: 95,
                                          width: 95),
                                        Positioned(
                                          top: -12,
                                          right: -12,
                                          child: IconButton(
                                            icon: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.5), // Cor de fundo opcional
                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius.circular(0), // Sem bordas arredondadas
                                              ),
                                              padding: EdgeInsets.all(0.1),
                                              child: const Icon(
                                                Icons.close_rounded,
                                                color: Colors.white,
                                                size: 25,
                                              ),
                                            ),
                                            onPressed: () {
                                            _clearCachedFiles(5);
                                          },
                                        )
                                    ),
                                  ],
                                )
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        buildDescription(),
                        const SizedBox(height: 15),

                            prSet1(),

                        const SizedBox(height: 25),
                        Visibility(visible: isOnline, child: buildContainer()),
                        const SizedBox(height: 25),
                        Column(
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

                                        if (titleController !=""){
                                          if (slugs[slugChoose] != null) {
                                            if (imageFile.isNotEmpty) {
                                              _determinePosition();
                                              keepObservation();
                                              _keepObsSuccess(context);
                                            } else {
                                              _noImageError(context);}
                                            } else {
                                            _noServiceError(context);
                                          }

                                        } else {

                                          _noTitleError(context);
                                        }


                                      },
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            AppLocalizations.of(context)!.save,
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
                        const SizedBox(height: 10),
                        Column(
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
                                        validateAndSave();
                                        if (titleController !=""){
                                          if (slugs[slugChoose] != null){
                                            if (imageFile.isNotEmpty) {
                                              try {
                                                final result = await InternetAddress.lookup('google.com');
                                                if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {

                                                  _determinePosition();

                                                    var response = await APIService.sendObs(titleController,descriptionController,geocodeController,public,demandingSlug,latitude,longitude, imageFile,userGroup);
                                                    if (response ==200) {
                                                      Navigator.of(context).pop();
                                                      _sendObsSuccess(context);
                                                    } else {
                                                      Navigator.of(context).pop();
                                                      _sendObsFailed(context);
                                                    }

                                                }
                                              } on SocketException catch (_) {
                                                validateAndSave();
                                                if (notValidated == false) {
                                                  if (imageFile.isNotEmpty){
                                                    Navigator.of(context).pop();
                                                    _offlineError(context);
                                                  }
                                                }
                                              }
                                            }else {
                                              Navigator.of(context).pop();
                                              _noImageError(context);
                                            }
                                          }else {
                                            Navigator.of(context).pop();
                                            _noServiceError(context);
                                          }
                                        } else {
                                          Navigator.of(context).pop();
                                          _noTitleError(context);
                                        }
                                      },
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            AppLocalizations.of(context)!.send,
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
                        const SizedBox(height:55),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Page Widgets

  Widget buildSlug(){
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 15.0),
            child: Text(
              AppLocalizations.of(context)!.obs_service,
              style: const TextStyle(
                  color: Color(0xFF346cb0),
                  fontSize: 16,
                  fontWeight: FontWeight.w800
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton(
                hint: slugs.isEmpty ? Text(AppLocalizations.of(context)!.no_slugs) : Text(AppLocalizations.of(context)!.choose_service,),
                isExpanded: true,
                onChanged: (newValue) {

                  if (newValue == "Registo de estados fenológicos da videira"){
                    setState(() {
                      isPheno = true;
                      notPheno = false;
                    });
                  } else {
                    setState(() {
                      isPheno = false;
                      notPheno = true;
                    });
                  }
                  setState(() {
                    slugChoose = newValue as String;
                    print(slugChoose);
                  });
                  print (slugs[slugChoose]);
                },
                value: slugChoose,
                items: listItem.map((valueItem) {
                  return DropdownMenuItem(
                    value: valueItem,
                    child: Text(valueItem),
                  );
                }).toList(),
              ),
            ),
          ),
        ]
    );
  }
  /*
  Widget buildUserGroup(){
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 15.0),
            child: Text(
              AppLocalizations.of(context)!.userGroup_esc,
              style: const TextStyle(
                  color: Color(0xFF346cb0),
                  fontSize: 16,
                  fontWeight: FontWeight.w800
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton(
                hint: userGroups.isEmpty ? Text(AppLocalizations.of(context)!.no_slugs) : Text(AppLocalizations.of(context)!.choose_service,),
                isExpanded: true,
                onChanged: (newValue) {
                  setState(() {
                    userGroupChoose = newValue as String;
                    print(userGroupChoose);
                  });
                  print (userGroups[userGroupChoose]);
                },
                value: userGroupChoose,
                items: listUserGroupName.map((valueItem) {
                  return DropdownMenuItem(
                    value: valueItem,
                    child: Text(valueItem),
                  );
                }).toList(),
              ),
            ),
          ),
        ]
    );
  }
  */


  Widget buildTitle() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 15.0),
            child: Text(
              AppLocalizations.of(context)!.obs_title,
              style: const TextStyle(
                  color: Color(0xFF346cb0),
                  fontSize: 16,
                  fontWeight: FontWeight.w800
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0,2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(15.0),
            alignment: Alignment.centerLeft,
            height: 60,
            child: Autocomplete(
              optionsBuilder: (TextEditingValue textEditingValue){
                if(textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                  print ("diogo");
                }
                return castasList.where((String nomeCastas) {
                  return nomeCastas
                      .toLowerCase()
                      .startsWith(textEditingValue.text.toLowerCase());
                });
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmited) {
                return TextFormField(
                  controller: textEditingController,
                  decoration: myTextFieldDecoration(hintText: "Insira o nome da casta"),
                  focusNode: focusNode,
                  onFieldSubmitted: (String value) {
                    titleController = value;
                    print('You just typed a new entry  $value');
                  },
                );
              },
              onSelected: (String selection) {
                titleController = selection;
                debugPrint('You just selected $titleController');
              },

            ),

          )

        ],
      );
  }


  Widget buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(left: 15.0),
          child: Text(
            AppLocalizations.of(context)!.description,
            style: const TextStyle(
                color: Color(0xFF346cb0),
                fontSize: 16,
                fontWeight: FontWeight.w800
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0,2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(15.0),
          alignment: Alignment.centerLeft,
          height: 120,
          child: TextFormField(
            maxLines: 10,
            keyboardType: TextInputType.text,
            onSaved: (String? value){
              descriptionController = value!;
            },
            style: const TextStyle(
                color: Colors.black87
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: AppLocalizations.of(context)!.description_hint,
              hintStyle: const TextStyle(
                  color: Colors.black38
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget prSet(){
    return Column(
      children: <Widget>[
        Container(

          child:Row(
              children: <Widget> [
                  Container(
                      child: Text(
                      AppLocalizations.of(context)!.private,
                      style: const TextStyle(
                          color: Color(0xFF346cb0),
                          fontSize: 16,
                          fontWeight: FontWeight.w800
                          ),
                      ),
                  ),
            const SizedBox(width: 2),
            Container(
              child: Text(
                AppLocalizations.of(context)!.public,
                style: const TextStyle(
                    color: Color(0xFF346cb0),
                    fontSize: 16,
                    fontWeight: FontWeight.w800
                ),
              ),
            )
          ]),
        ),
        Container(
          margin: const EdgeInsets.only(right: 12),
          child: ToggleButtons(borderWidth: 3,
            constraints: const BoxConstraints(minWidth: 55, minHeight: 50),
            borderRadius: BorderRadius.circular(5),
            isSelected: _selections,
            onPressed: (int index){
              setState(() {
                for (int buttonIndex = 0; buttonIndex < _selections.length; buttonIndex++) {
                  if (buttonIndex == index) {
                    _selections[buttonIndex] = true;
                  } else {
                    _selections[buttonIndex] = false;}
                }
              });
              if(_selections[0]==false) {
                setState(() {
                  public = true;
                });
              } else {
                setState(() {
                  public = false;
                });
              }
            },children: const [
            Icon(Icons.lock_outline,),
            Icon(Icons.lock_open_outlined)],
          ),
        ),
      ],
    );
  }

  Widget prSet1(){
    return ToggleButtons(
      borderRadius: BorderRadius.circular(8),
      selectedColor: Colors.white,
      color: Colors.black,
      fillColor: Color(0xFF346cb0),
      isSelected: [!public, public],
      onPressed: (index) {
        if(index==0) {
          setState(() {
            public = false;
          });
        } else {
        setState(() {
          public = true;
        });
        }
      },
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(AppLocalizations.of(context)!.private),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(AppLocalizations.of(context)!.public),
        ),
      ],
    );
  }

  Widget buildGeo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(left:12.0),
          child: Text(
            AppLocalizations.of(context)!.geocode,
            style: const TextStyle(
                color: Color(0xFF346cb0),
                fontSize: 16,
                fontWeight: FontWeight.w800
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.only(left: 12.0),
          width: 150.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0,2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(15.0),
          alignment: Alignment.centerLeft,
          height: 50,
          child: TextFormField(
            keyboardType: TextInputType.text,
            onSaved: (String? value){
              geocodeController = value!;
            },
            style: const TextStyle(
                color: Colors.black87
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: AppLocalizations.of(context)!.optional,
              hintStyle: const TextStyle(
                  color: Colors.black38
              ),
            ),
          ),
        )
      ],
    );
  }

  Container buildContainer() {
    return Container(
        margin: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF346cb0))
        ),
        width: 400,
        height: 400,
        child: FutureBuilder(
            future: locationMap,
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.done){
                if (snapshot.hasData) {
                  return Center(
                    child: Stack(
                        children:[
                          FlutterMap(
                            options: MapOptions(
                              center: LatLng(snapshot.data[0], snapshot.data[1]),
                              zoom: 17.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: "https://api.mapbox.com/styles/v1/diogobarroso/ckqkqr9fx2vyw18mo8mmhved5/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZGlvZ29iYXJyb3NvIiwiYSI6ImNrcWtxbjRnZjAyOGMydW51b3l5c2t4bXMifQ._tptIHXmx4DtllDbP9A4SQ",
                                userAgentPackageName: 'com.example.app',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    width: 80.0,
                                    height: 80.0,
                                    point: LatLng(snapshot.data[0], snapshot.data[1]),
                                    builder: (ctx) =>
                                        Container(
                                          child: Icon(
                                            Icons.location_on,
                                            size: 40,
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.gps_fixed_sharp,
                              size: 25,
                              color: Colors.black,
                            ),
                            onPressed: () async {
                              setState(() {
                                locationMap = _determinePosition();
                              });
                            },
                          ),

                        ]),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }} else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }


  //Messages Pop Up


  _sendObsSuccess(BuildContext context) {
    Alert(
      context: globalFormKey.currentContext!,
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

  _keepObsSuccess(BuildContext context) {
    Alert(
      context: globalFormKey.currentContext!,
      type: AlertType.success,
      title:  AppLocalizations.of(context)!.success,
      desc: AppLocalizations.of(context)!.saved_obs,
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
      context: globalFormKey.currentContext!,
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

  _noImageError(BuildContext context) {
    Alert(
      context: globalFormKey.currentContext!,
      type: AlertType.warning,
      title: AppLocalizations.of(context)!.alert,
      desc: AppLocalizations.of(context)!.no_image,
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

  _noTitleError(BuildContext context) {
    Alert(
      context: globalFormKey.currentContext!,
      type: AlertType.warning,
      title: AppLocalizations.of(context)!.alert,
      desc: AppLocalizations.of(context)!.no_title,
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

  _noServiceError(BuildContext context) {
    Alert(
      context: globalFormKey.currentContext!,
      type: AlertType.warning,
      title: AppLocalizations.of(context)!.alert,
      desc: AppLocalizations.of(context)!.choose_service,
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
      context: globalFormKey.currentContext!,
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