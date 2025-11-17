import 'dart:io';
import 'dart:math';
import '../main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../database/token_storage.dart';
import 'login_screen.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSomeProgress = false;

  //objectbox
  late String nome = "";
  late String image = "";
  late String username = "";
  late String email = "";
  late String imageUrl= "";
  late int nrServicos = 0;
  late int nrObs = 0;
  late List<String> subsSlugs = [];
  late List<String> _slugs = [];
  late int id = 0;
  late List<String> userGroupsName = [];
  late List<String> userGroupsSlug = [];

  void readAll() async {
    var list = await objectbox.queryAllUsers();
    String _emailController = await TokenStorage.readSecureData("authed");

    for (int i = 0; i < list.length; i++) {
      if (list[i]["Email"] == _emailController) {
        setState(() {
          nome = list[i]["Nome"];
          image = list[i]["Endereco Foto"];
          username = list[i]["Username"];
          email = list[i]["Email"];
          nrObs = list[i]["Numero de Observações"];
          nrServicos = list[i]["Slugs Subscritas"].length;
        });
      }
    }
    print (nome);

  }

  void refreshData() async {
    Random random = new Random();
    int randomNumber = random.nextInt(10000);
    setState(() {
      isSomeProgress =true;
    });

    var list = await objectbox.queryAllUsers();
    String _emailController = await TokenStorage.readSecureData("authed");
    print(_emailController);
    for (int i = 0; i < list.length; i++) {
      if (list[i]["Email"] == _emailController) {
        id = list[i]["id"];
      }
    }

    var listObsDel = await objectbox.queryAllObservations();
    for (int i=0;i<listObsDel.length;i++){
      if (listObsDel[i]["email"]==_emailController) {
        await objectbox.removeObservation(listObsDel[i]["id"]);
      }
    }

    await objectbox.removeUser(id);
    await TokenStorage.deleteSecureData("authed");
    await TokenStorage.deleteSecureData("logged");

    Navigator.of(context).pop();
    _updateInfo(context);
  }

  Future<bool> _onBackPressed() async {
    return false;
  }

  void initState() {
    readAll();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: Stack(
          key: _scaffoldKey,
          children: [
            Column(
              children: [
                Expanded(
                  flex:5,
                  child:Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF346cb0),
                    ),
                    child: Column(
                        children: [
                          const SizedBox(height: 110.0,),
                          ClipOval(
                              child: Image.file(
                                File(image),
                                fit: BoxFit.fill,
                              )
                          ),
                          const SizedBox(height: 10.0,),
                          Text(nome,
                              style: const TextStyle(
                                color:Colors.white,
                                fontSize: 20.0,
                              )),
                        ]
                    ),
                  ),
                ),
                const SizedBox(height: 20.0,),
                Expanded(
                  flex: 5,
                  child: Container(
                    color: Colors.grey[200],
                    child: Align(
                        alignment: const Alignment(0,-0.4),
                        child:Card(
                            child: Container(
                                width: 370.0,
                                height:290.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(AppLocalizations.of(context)!.info,
                                        style: const TextStyle(
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.w800,
                                        ),),
                                      Divider(color: Colors.grey[300],),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.person_pin,
                                            color: Color(0xFF346cb0),
                                            size: 35,
                                          ),
                                          const SizedBox(width: 20.0,),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(nome,
                                                style: const TextStyle(
                                                  fontSize: 15.0,
                                                ),),
                                              Text(AppLocalizations.of(context)!.name,
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  color: Colors.grey[400],
                                                ),)
                                            ],
                                          )

                                        ],
                                      ),
                                      const SizedBox(height: 20.0,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.person_outlined,
                                            color: Color(0xFF346cb0),
                                            size: 35,
                                          ),
                                          const SizedBox(width: 20.0,),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(username,
                                                style: const TextStyle(
                                                  fontSize: 15.0,
                                                ),),
                                              Text(AppLocalizations.of(context)!.username,
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  color: Colors.grey[400],
                                                ),)
                                            ],
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 20.0,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.email,
                                            color: Color(0xFF346cb0),
                                            size: 35,
                                          ),
                                          const SizedBox(width: 20.0,),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(email,
                                                style: const TextStyle(
                                                  fontSize: 15.0,
                                                ),),
                                              Text(AppLocalizations.of(context)!.email,
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  color: Colors.grey[400],
                                                ),)
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20.0,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.refresh,
                                            color: Color(0xFF346cb0),
                                            size: 35,
                                          ),
                                          const SizedBox(width: 20.0,),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TextButton(
                                                onPressed: () async {
                                                  showDialog(context: context, builder: (context){
                                                    return Center(child: CircularProgressIndicator(
                                                      color: Color(0xff336db0),
                                                    ));
                                                  });
                                                  try {
                                                    final result = await InternetAddress.lookup('google.com');
                                                    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                                                      refreshData();
                                                    }
                                                  } on SocketException catch (_) {
                                                    Navigator.of(context).pop();
                                                    _offlineError(context);
                                                  }
                                                },
                                                child: Text(AppLocalizations.of(context)!.reload_info,
                                                  style: const TextStyle(
                                                    fontSize: 15.0,
                                                    color: Colors.black,
                                                  ),),),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                            )
                        )
                    ),
                  ),
                ),
              ],
            ),
            Stack(
                children: [
                  Positioned(
                      top:MediaQuery.of(context).size.height*0.45,
                      left: 5.0,
                      right: 5.0,
                      child: Card(
                          child: Padding(
                            padding:const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  child: Column(
                                      children: [
                                        Text(AppLocalizations.of(context)!.subs_serv,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14.0
                                          ),),
                                        const SizedBox(height: 5.0,),
                                        Text("$nrServicos",
                                          style: const TextStyle(
                                            fontSize: 15.0,
                                          ),)
                                      ]),
                                ),
                                Container(
                                    child:Column(
                                      children: [
                                        Text(AppLocalizations.of(context)!.subs_obs,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14.0
                                          ),),
                                        const SizedBox(height: 5.0,),
                                        Text("$nrObs",
                                          style: const TextStyle(
                                            fontSize: 15.0,
                                          ),)
                                      ],
                                    )
                                ),
                              ],
                            ),
                          )
                      )
                  ),
                ]
            )
          ],

        ),
      ),
    );
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

  _updateInfo(BuildContext context) {
    Alert(
      context: _scaffoldKey!.currentContext!,
      type: AlertType.success,
      title: AppLocalizations.of(context)!.success,
      desc: AppLocalizations.of(context)!.reload_S,
      buttons: [
        DialogButton(
          onPressed: () async {
            await TokenStorage.deleteSecureData("logged");
            await TokenStorage.deleteSecureData("authed");
            Navigator.of(context,rootNavigator: true).pop();
            await Navigator.pushReplacement(context,
                new MaterialPageRoute(builder:(context)=> LoginScreen()
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