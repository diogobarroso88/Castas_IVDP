import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:castas_ivdp/screens/splash_screen.dart';
import 'database/objectbox.dart';
import 'database/token_storage.dart';

late ObjectBox objectbox;



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  objectbox = await ObjectBox.create();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_) => runApp(const MyApp()));
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(locale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  late Locale _locale = const Locale('pt');
  String selectedLang = "";
  String _bandeira ="";
  late bool _authed=false;


  /// Auth check
  void isAuthed() async {

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

  /// Language Selection
  void setLocale(Locale locale) async{

    setState(() {
      _locale = locale;
    });
  }
  void selectedLanguage(String codigopais)  {
    String linguaSel;
    String bandeira;
    switch(codigopais){
      case 'pt':
        linguaSel = "Português";
        bandeira = "🇵🇹";
        break;
      case 'en':
        linguaSel = "English";
        bandeira = "🇬🇧";
        break;
      case 'es':
        linguaSel = "Español";
        bandeira = "🇪🇸";
        break;
      default:
        linguaSel = "Português";
        bandeira = "🇵🇹";
    }
    setState(() {
      selectedLang = linguaSel;
      _bandeira = bandeira;
    });


  }
  void whatLanguage() async {
    String linguaSel;
    String bandeira;
    String? langSelected;
    var lingua = await TokenStorage.readSecureData("lingua");

    if (lingua == null){
      langSelected="pt";
    } else {
      langSelected=lingua.toString();
    }
    switch(langSelected){
      case 'pt':
        setState(() {
          selectedLang = 'pt';
          _locale = Locale(selectedLang);
        });
        break;
      case 'en':
        setState(() {
          selectedLang = 'en';
          _locale = Locale(selectedLang);
        });
        break;
      case 'es':
        setState(() {
          selectedLang = 'es';
          _locale = Locale(selectedLang);
        });
        break;
      default:
        setState(() {
          selectedLang = 'pt';
          _locale = Locale(selectedLang);
        });
    }
  }


  @override
  void initState() {
    super.initState();
    isAuthed();
    whatLanguage();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        title: 'Flutter Demo',
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: _locale,
        supportedLocales: const [
          Locale('pt'), // Portuguese
          Locale('en'), // English
          Locale('es'), // Spanish
        ],
        theme: ThemeData(

          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,


        ),
        home: Splash()
    );
  }
}
