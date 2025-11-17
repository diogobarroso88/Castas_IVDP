import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../API/apiservice.dart';
import '../app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../database/token_storage.dart';
import '../main.dart';
import '../navigation_home_screen.dart';



class CheckObsScreen extends StatefulWidget {
  @override
  _CheckObsScreenState createState() => _CheckObsScreenState();
}

class _CheckObsScreenState extends State<CheckObsScreen> {
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();

  late List titles=[];
  late List reversedTitles=[];
  late List description=[];
  late List reversedDescription=[];
  late List imageUrl=[];
  late List reversedImages=[];

  late Future slugList;
  late String image ="";

  late String slugChoose="";
  late List listItem=[];
  late List listSlug=[];
  late Map slugs= {};
  late String title="";
  late String selectedValue="";

  bool isSomeProgress = false;
  bool isSelected = false;

  /// Read data from objectbox database
  Future<List> readAll() async {


    var list = await objectbox.queryAllUsers();
    String _emailController = await TokenStorage.readSecureData("authed");

    for (int i=0; i<list.length; i++) {
      if (list[i]["Email"] == _emailController){
        setState(() {
          listItem = list[i]["Slugs Subscritas"];
          listSlug = list[i]["Nome Slug"];
        });
        for (int j=0; j<listItem.length; j++) {
          setState(() {
            slugs[listItem[j]] = listSlug[j];
          });
        }
        if (listItem.isEmpty){
          _noServicesError(context);
        }
      }
    }
    if (mounted){
      setState(() {
        selectedValue = listItem[0];
      });
    }
    await showObs(selectedValue);
    return (listItem);

  }

  Future showObs(String selectedValue) async {
    if (mounted){
      setState(() {
        slugChoose = slugs[selectedValue];

      });
    }
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print(slugChoose);
        print(slugs);
        List<List<String>> obsData  = await APIService.getObsData(slugChoose);
        List<List<String>> obsImg = await APIService.getObsImages(slugChoose);

        if (obsData.isNotEmpty){

          if (mounted){
            setState(() {
              titles = obsData [0];
              reversedTitles = titles.reversed.toList();
              description = obsData [1];
              reversedDescription = description.reversed.toList();
              imageUrl = obsImg;
              reversedImages = imageUrl.reversed.toList();
              isSelected = true;
            });
          }
        } else {
          _noServicesError(context);
        }
      }
    } on SocketException catch (_) {
      _offlineError(context);
    }
  }

  /// Slug Selection widget
  Widget buildSlugs() {


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 15.0),
          child: Text(
            AppLocalizations.of(context)!.choose_service,
            style: const TextStyle(
                color: Color(0xFF346cb0),
                fontSize: 16,
                fontWeight: FontWeight.w800
            ),
          ),
        ),

        Container(
            margin: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
                color: const Color(0xFFFEFEFE),
                border: Border.all(color: const Color(0xFF346cb0))
            ),
            width: 400,
            height: 150,
            child: FutureBuilder(
                future: slugList,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: listItem.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: <Widget>[
                              Radio(
                                  value: listItem[index],
                                  groupValue: selectedValue,
                                  onChanged: (s) async{
                                    selectedValue = s;
                                    setState(() {
                                    });
                                    setState(() {
                                      slugChoose = listSlug[index];
                                    });
                                    try {
                                      final result = await InternetAddress.lookup('google.com');
                                      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                                        setState(() {
                                          isSomeProgress =true;
                                        });
                                        List<List<String>> obsData  = await APIService.getObsData(slugChoose);
                                        List<List<String>> obsImg = await APIService.getObsImages(slugChoose);

                                        if (obsData.isNotEmpty){
                                          setState(() {
                                            titles = obsData [0];
                                            reversedTitles = titles.reversed.toList();
                                            description = obsData [1];
                                            reversedDescription = description.reversed.toList();
                                            imageUrl = obsImg;
                                            reversedImages = imageUrl.reversed.toList();
                                            isSelected = true;
                                            isSomeProgress = false;
                                          });
                                        } else {
                                          //_noServicesError(context);
                                        }
                                      }
                                    } on SocketException catch (_) {
                                      //_offlineError(context);
                                    }

                                  }),
                              Text(listItem[index])
                            ],
                          );

                        }
                    );


                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                })),
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    slugList = readAll();
  }

  void validateAndSave() {
    if(globalFormKey.currentState!.validate()){
      globalFormKey.currentState?.save();
      return;
    }
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
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        const SizedBox(height: 100),
                        Container(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            AppLocalizations.of(context)!.check_observation,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Color(0xFF346cb0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        buildSlugs(),
                        const SizedBox(height: 15),
                        const SizedBox(height:35),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(12,0,12,0),
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              children: [
                                Container(
                                    width: 272,
                                    child:
                                    Text(
                                      AppLocalizations.of(context)!.title_observation,
                                      style: const TextStyle(
                                          color: Color(0xFF346cb0),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    )),
                                Container(
                                  child: Text(
                                    AppLocalizations.of(context)!.see_details,
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
                        SizedBox(
                          height: 400,
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(0, 0, 25, 0),
                            child: Visibility(
                              visible: isSelected,
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: reversedTitles.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                      title: Text('${reversedTitles[index]}'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.remove_red_eye),
                                        onPressed: () {
                                          showMessageDialog(context,index);
                                        },
                                      ));
                                },
                              ),
                            ),
                          ),
                        ),
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

  showMessageDialog(BuildContext context, int index) =>
      showDialog(context: globalFormKey!.currentContext!, builder: (context)=> Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFFEDF0F2),
              border: Border.all(
                color: const Color(0xFF346cb0),
              )
          ),
          height: 450,
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              Center(
                child: Container(
                  child: Column(
                    children: [
                      Text(
                        reversedTitles[index],
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
                    reversedDescription[index] == null
                        ? const Text("")
                        : Text(
                      reversedDescription[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40.0),
              SizedBox(
                height: 100,
                width: 280,
                child: Container(
                  alignment: Alignment.center,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: reversedImages[index].length,
                    itemBuilder: (context, index2) {
                      return Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 3, 0),
                        decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF346cb0))
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          width: 100,
                          height: 100,
                          child: GestureDetector(
                            child: Hero(
                              tag: 'imageHero',
                              child: Image.network(
                                reversedImages[index][index2],
                                fit: BoxFit.fill,
                              ),
                            ),
                            onTap: () {

                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) {
                                return DetailScreen(url: reversedImages[index][index2]);
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

  //Message Pop Up


  _offlineError(BuildContext context) {
    Alert(
      context: globalFormKey!.currentContext!,
      type: AlertType.info,
      title: AppLocalizations.of(context)!.no_connection,
      desc: AppLocalizations.of(context)!.check_connection,
      buttons: [
        DialogButton(
          onPressed: () async {
            Navigator.of(context,rootNavigator: true).pop();
            await Navigator.pushReplacement(context,
                MaterialPageRoute(builder:(context)=> NavigationHomeScreen()
                ));
            setState((){});
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

  _noServicesError(BuildContext context) {
    Alert(
      context: context,
      type: AlertType.error,
      title: AppLocalizations.of(context)!.error,
      desc: AppLocalizations.of(context)!.no_service,
      buttons: [
        DialogButton(
          onPressed: () async {
            Navigator.of(context,rootNavigator: true).pop();
            await Navigator.pushReplacement(context,
                MaterialPageRoute(builder:(context)=> NavigationHomeScreen()
                ));
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


}

class DetailScreen extends StatefulWidget {

  final String url;

  DetailScreen({Key? key, required this.url})
      : assert(url != null),
        super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

Future<bool> _onBackPressed() async {
  return false;
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: GestureDetector(
          child: Center(
            child: Hero(
              tag: 'imageHero',
              child: Image.network(
                widget.url,
              ),
            ),
          ),
          onTap: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ),
    );
  }
}
