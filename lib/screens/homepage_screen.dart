import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../app_theme.dart';
import '../main.dart';


class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  ///Back Button
  Future<bool> _onBackPressed() async {
    return false;
  }

  bool isVisible2 = false;

  ///GPS Location and Map
  Future<List<double>> _determinePosition() async {
    bool serviceEnabled;
    bool margem = false;
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

    coordenadas.add(_position.latitude);
    coordenadas.add(_position.longitude);

    print(coordenadas);
    if (margem == false) {
      setState(() {
        isVisible2 = false;
      });
      print(isVisible2);
    }

    while (margem==false) {
      print(isVisible2);
      Position _position2 = await Geolocator.getCurrentPosition();
      if(_position2.latitude > 36.55 && _position2.latitude < 42.60) {
        if(_position2.longitude > 9.50 && _position2.longitude < -5.65){
          setState(() {
            print("sucesso");

            margem = true;
          });
      }}
    }

    return coordenadas;
  }


  void initState() {
    super.initState();
    //_determinePosition();
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
          backgroundColor: AppTheme.nearlyWhite.withOpacity(0.1),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Column(
                    children: [
                       Container(
                        padding: const EdgeInsets.only(
                          top: 150,
                          left: 50,
                          right: 50,
                        ),
                        child: Image.asset('assets/images/IVDP_logo.png'),
                      ),
                      const SizedBox(height: 35),
                      Container(
                        padding: const EdgeInsets.only(
                          top: 300,
                          left: 180,
                          right: 50,
                          bottom: 10,
                        ),
                        child: const Text("POWERED BY",
                          style: TextStyle(
                              color: Color(0xFF346cb0),
                              fontSize: 10,
                              fontWeight: FontWeight.bold),),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                          left: 230,
                          right: 50,
                          bottom: 100,
                        ),
                        child: Image.asset('assets/images/my_sense.png'),
                      ),


                    ]
                ),
              ],
            ),
          )
      ),
    );
  }
}
