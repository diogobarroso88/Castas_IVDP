import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../API/apiservice.dart';
import '../app_theme.dart';
import 'package:flutter/material.dart';
import '../database/token_storage.dart';
import '../main.dart';
import '../screens/login_screen.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({Key? key, this.screenIndex, this.iconAnimationController, this.callBackIndex}) : super(key: key);

  final AnimationController? iconAnimationController;
  final DrawerIndex? screenIndex;
  final Function(DrawerIndex)? callBackIndex;



  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {

  List<DrawerList>? drawerList;
  String nome = "";
  String image = "";
  String email = "";
  String username = "";
  String imageUrl= "";
  int nrObs=0;
  List<String> subsSlugs = [];
  List<String> _slugs = [];
  List<String> userGroupsName = [];
  List<String> userGroupsSlug = [];

  /// Read and write from Objectbox database
  void putUser() async {
    await objectbox.addUser(nome,email,username,image,nrObs,subsSlugs,_slugs,userGroupsName,userGroupsSlug);
  }

  void readAll() async {

    var list = await objectbox.queryAllUsers();


    if (list.isEmpty) {
      print ("Lista Users Vazia!");
      getUserdata();
    } else {
      var _emailContr = await TokenStorage.readSecureData("authed");
      String _emailController = _emailContr.toString();
      for (int i=0; i<list.length; i++) {
        if (list[i]["Email"] == _emailController){
          nome = list[i]["Nome"];
          image = list[i]["Endereco Foto"];
        }
      }

      if (nome.isEmpty) {
        getUserdata();
        for (int i=0; i<list.length; i++) {
          if (list[i]["Email"] == _emailController){
            nome = list[i]["Nome"];
            image = list[i]["Endereco Foto"];
          }
        }
      }

    }
  }

  void getUserdata() async {

    List _data = await APIService.getUser();
    setState(() {
      nome = _data[0];
      imageUrl = _data[1];
      email = _data[2];
      username = _data[3];
    });
    Uri uriUrl = Uri.parse(imageUrl);
    final response = await http.get(uriUrl);
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File(path.join(documentDirectory.path, 'avatar$nome.png'));
    file.writeAsBytesSync(response.bodyBytes);
    setState(() {
      image = file.path;
    });


    var _data2 = await APIService.getService();
    String _nameslug;
    String _slug;


    for(int i=0;i<_data2.length;i++){
      if(_data2[i]["subscribed"]==true){
        _nameslug = _data2[i]["name"];
        _slug = _data2[i]["slug"];
        setState(() {
          subsSlugs.add(_nameslug);
          _slugs.add(_slug);
        });
      }
    }

    if (_slugs.isNotEmpty) {
      for(int i=0; i<_slugs.length; i++){
        var _data3 = await APIService.getNrObs(_slugs[i]);
        setState(() {
          nrObs = nrObs + _data3;
        });
      }
    } else {
      setState(() {
        nrObs = 0;
      });
    }

    List _dataUserGroup = await APIService.getUserGroup();
    for (int i=0;i<_dataUserGroup[0].length;i++) {
      userGroupsName.add(_dataUserGroup[0][i]);
      userGroupsSlug.add(_dataUserGroup[1][i]);
    }


    putUser();


  }

  Future getServices() async {
    var _data = await APIService.getService();

    for(int i=0;i<15;i++){
      if(_data[i]["subscribed"]==true){
        //subsSlugs.add(_data[i]);
        nrObs++;
      }
    }
  }


  @override
  void initState() {
    super.initState();
    readAll();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    setDrawerListArray();
    super.didChangeDependencies();
  }

  void setDrawerListArray() {
    drawerList = <DrawerList>[
      DrawerList(
        index: DrawerIndex.HOME,
        labelName: AppLocalizations.of(context)!.homepage,
        icon: const Icon(Icons.home),
      ),
      /*
      DrawerList(
        index: DrawerIndex.FeedBack,
        labelName: AppLocalizations.of(context).rate_app,
        icon: const Icon(Icons.help),
      ),
      DrawerList(
        index: DrawerIndex.Share,
        labelName: AppLocalizations.of(context).share_us,
        icon: const Icon(Icons.share),
      ),
       */
      DrawerList(
        index: DrawerIndex.About,
        labelName: AppLocalizations.of(context)!.privacy,
        icon: const Icon(Icons.privacy_tip),
      ),


    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.notWhite.withOpacity(0.9),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: widget.iconAnimationController!,
                    builder: (BuildContext context, Widget? child) {
                      return ScaleTransition(
                        scale: AlwaysStoppedAnimation<double>(1.0 - (widget.iconAnimationController!.value) * 0.2),
                        child: RotationTransition(
                          turns: AlwaysStoppedAnimation<double>(Tween<double>(begin: 0.0, end: 24.0)
                                  .animate(CurvedAnimation(parent: widget.iconAnimationController!, curve: Curves.fastOutSlowIn))
                                  .value /
                              360),
                          child: CircleAvatar(
                            //backgroundImage: NetworkImage(image),
                            radius:40,
                            child: ClipOval(
                              child: Image.file(
                                File(image),
                                fit: BoxFit.fill,
                              )
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Text(
                      nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.grey,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Divider(
            height: 1,
            color: AppTheme.grey.withOpacity(0.6),
          ),
          Expanded(
            flex:1,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(0.0),
              itemCount: drawerList?.length,
              itemBuilder: (BuildContext context, int index) {
                return inkwell(drawerList![index]);
              },
            ),
          ),

          Divider(
            height: 1,
            color: AppTheme.grey.withOpacity(0.6),
          ),
          Column(
            children: <Widget>[
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.logout,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppTheme.darkText,
                  ),
                  textAlign: TextAlign.left,
                ),
                trailing: const Icon(
                  Icons.power_settings_new,
                  color: Colors.red,
                ),
                onTap: () async {
                  await TokenStorage.deleteSecureData("logged");
                  await TokenStorage.deleteSecureData("authed");
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const LoginScreen(),
                      ));
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).padding.bottom,
              )
            ],
          ),
        ],
      ),
    );
  }
  

  Widget inkwell(DrawerList listData) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.1),
        highlightColor: Colors.transparent,
        onTap: () {
          navigationtoScreen(listData.index!);
        },
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                children: <Widget>[
                  const SizedBox(
                    width: 6.0,
                    height: 46.0,

                  ),
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  listData.isAssetsImage
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: Image.asset(listData.imageName, color: widget.screenIndex == listData.index ? Colors.blue : AppTheme.nearlyBlack),
                        )
                      : Icon(listData.icon?.icon, color: widget.screenIndex == listData.index ? Colors.blue : AppTheme.nearlyBlack),
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  Text(
                    listData.labelName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: widget.screenIndex == listData.index ? Colors.blue : AppTheme.nearlyBlack,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            widget.screenIndex == listData.index
                ? AnimatedBuilder(
                    animation: widget.iconAnimationController!,
                    builder: (BuildContext context, Widget? child) {
                      return Transform(
                        transform: Matrix4.translationValues(
                            (MediaQuery.of(context).size.width * 0.75 - 64) * (1.0 - widget.iconAnimationController!.value - 1.0), 0.0, 0.0),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.75 - 64,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(28),
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(28),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }

  Future<void> navigationtoScreen(DrawerIndex indexScreen) async {
    widget.callBackIndex!(indexScreen);
  }
}

enum DrawerIndex {
  // ignore: constant_identifier_names
  HOME,
  FeedBack,
  Help,
  Share,
  About,
  Testing,
}

class DrawerList {
  DrawerList({
    this.isAssetsImage = false,
    this.labelName = '',
    this.icon,
    this.index,
    this.imageName = '',
  });

  String labelName;
  Icon? icon;
  bool isAssetsImage;
  String imageName;
  DrawerIndex? index;
}
