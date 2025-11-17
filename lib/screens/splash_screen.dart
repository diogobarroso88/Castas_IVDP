import 'package:flutter/material.dart';
import 'package:castas_ivdp/database/token_storage.dart';
import 'package:castas_ivdp/screens/login_screen.dart';
import '../navigation_home_screen.dart';

class Splash extends StatefulWidget{
  const Splash({Key? key}) : super (key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  late bool _authed=false;

  @override

  void initState(){
    super.initState();
    _isAuthed();
    _navigate();
  }

  void _isAuthed() async {

    var token = await TokenStorage.readSecureData("logged");

    if (token==null) {
      setState(() {
        _authed = false;
      });
    } else {
      setState(() {
        _authed = true;
      });
    }
  }

  _navigate() async{
    print(_authed);
    await Future.delayed(Duration(milliseconds: 1000), (){});
    if (_authed==false){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> NavigationHomeScreen()));
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Image.asset('assets/images/logoIVDP.png'),
        ),
      ),
    );
  }
}