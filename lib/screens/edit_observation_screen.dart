import 'dart:io';
import '../main.dart';
import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:async';
import '../app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../database/token_storage.dart';
import '../models/castas_list.dart';
import '../models/image_helper.dart';


class EditObs extends StatefulWidget {

  final String savedTitle;
  final String? savedDesc;
  final List savedImages;
  final int savedIndex;
  final String savedSlug;
  final bool savedPriv;
  final String savedUserGroup;



  const EditObs({Key? key, required this.savedTitle, this.savedDesc, required this.savedImages, required this.savedIndex, required this.savedSlug, required this.savedPriv, required this.savedUserGroup})
      : assert(savedTitle != null),
        super(key: key);

  @override
  _EditObsState createState() => _EditObsState();
}

class _EditObsState extends State<EditObs> {
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();


  bool public = false;

  InputDecoration myTextFieldDecoration({
    String hintText = "",
  }) {
    return InputDecoration(
      border: InputBorder.none,
      hintText: hintText,

    );
  }


  List<bool> _selections = [];
  final List<bool> _selections1 = [false, true];
  final List<bool> _selections2 = [true, false];

  bool isSomeProgress = false;
  bool notValidated = false;

  late String titleController="";
  late String descriptionController="";
  late String geocodeController="";
  late String slugChoose="";
  late String userGroupIdSaved = "";
  late String userGroupChoose ="";
  late String emailController="";
  late String userGroupController="";
  late double latitude = 0;
  late double longitude = 0;



  List listItem = [];
  List listUGroup = [];
  List listSlug = [];
  List listUserGroupName = [];
  List listUserGroupId = [];
  Map slugs = {};
  Map userGroups = {};
  String userGroup = ("cHgxlASbYYOdK2dv");
  String slug = ("vine-varieties-identification");


  //MultiImagePicker
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



  //Keep and reed observations from database


  void keepObservation() async {

    var observation = await objectbox.queryObservation(widget.savedIndex);
    observation?.titulo = titleController;
    observation?.descricao = descriptionController;
    observation?.geocode = geocodeController;
    observation?.public = public;
    observation?.slugs = slug;
    observation?.imageFile = imageFilePath;
    observation?.nameOfSlug = slugChoose;
    observation?.emailController = emailController;
    observation?.userGroupSlug = userGroup;

    await objectbox.addObservation(titleController,descriptionController,geocodeController,public,slug,latitude,longitude,imageFilePath,emailController,slugChoose,userGroup);
  }

  void deleteById(int index) async {
    await objectbox.removeObservation(index);
  }

  void carregaImagem(){
    print(widget.savedImages.length);
    for (int i=0; i<widget.savedImages.length;i++) {

      setState(() {
        imageFile.add(File(widget.savedImages[i]));
        imageFilePath.add(widget.savedImages[i]);
      });
    }

    nrImages = imageFile.length;
  }

  void readAll() async {


    String _emailController = await TokenStorage.readSecureData("authed");

    setState(() {
      emailController = _emailController;
      titleController = widget.savedTitle;
      slugChoose = widget.savedSlug;
      userGroupIdSaved = widget.savedUserGroup;
    });
    if (widget.savedPriv == true) {
      setState(() {
        _selections = _selections1;
        public = true;
      });
    } else {
      setState(() {
        _selections = _selections2;
        public = false;
      });
    }
  }

  Future<bool> _onBackPressed() async {
    return false;
  }


  @override
  void initState() {

    carregaImagem();
    readAll();
    super.initState();
  }

  @override
  void dispose() {

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  void validateAndSave() {
    if(globalFormKey.currentState!.validate()){
      globalFormKey.currentState?.save();
      notValidated = false;
      return;
    } else {
      notValidated = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Container(
        color: AppTheme.nearlyWhite,
        child: SafeArea(
          top: false,
          child: Scaffold(
            backgroundColor: AppTheme.nearlyWhite,
            body: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Form(
                  key: globalFormKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 40),
                        Container(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(icon: const Icon(Icons.arrow_back),
                              onPressed: (){
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            AppLocalizations.of(context)!.edit_obs,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Color(0xFF346cb0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
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

                                        if(nrImages<6){
                                          final files = await imageHelper.pickImageGallery(multiple: true);
                                          tempImageFile = files.map((e) => File(e.path)).toList();
                                          if (tempImageFile.isNotEmpty) {
                                            for (var i = 0; i < tempImageFile.length; i++) {
                                              if (nrImages<6){
                                                imageFile.add(File(tempImageFile[i].path));
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
                                          icon: const Icon(
                                            Icons.close_rounded,
                                            color: Colors.white,
                                            size: 25,
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
                                          icon: const Icon(
                                            Icons.close_rounded,
                                            color: Colors.white,
                                            size: 25,
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
                                          icon: const Icon(
                                            Icons.close_rounded,
                                            color: Colors.white,
                                            size: 25,
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
                                          icon: const Icon(
                                            Icons.close_rounded,
                                            color: Colors.white,
                                            size: 25,
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



                        //prSet(),

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

                                        if (titleController !="") {
                                            if (imageFile.isNotEmpty) {
                                              keepObservation();
                                              _keepObsSuccess(context);
                                            } else {
                                              _noImageError(context);
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
                        const SizedBox(height: 25)
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
            initialValue: TextEditingValue(text: widget.savedTitle),
            optionsBuilder: (TextEditingValue textEditingValue){
              if(textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
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
            initialValue: widget.savedDesc,
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
          print (public);
        } else {
          setState(() {
            public = true;
          });
          print (public);
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


  //Message Pop Ups

  _keepObsSuccess(BuildContext context) {
    Alert(
      context: globalFormKey.currentContext!,
      type: AlertType.success,
      title: "Sucesso",
      desc: "Observação Guardada",
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

  _deleteObs(BuildContext context) {
    Alert(
      context: globalFormKey.currentContext!,
      type: AlertType.success,
      title: AppLocalizations.of(context)!.success,
      desc: AppLocalizations.of(context)!.del_obs,
      buttons: [
        DialogButton(
          onPressed: () {
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


}
