import 'dart:io';
import 'package:castas_ivdp/screens/signup_screen.dart';
import '../main.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../API/apiservice.dart';
import '../app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../database/token_storage.dart';
import '../models/languages.dart';
import '../navigation_home_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}



class _LoginScreenState extends State<LoginScreen> {
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();


  late String emailController;
  late String passwordController;
  late String _selectedLang ="";
  late String _bandeira="";
  late String key="";

  bool hidePassword = true;


  @override
  void initState() {
    super.initState();
    whatLanguage();
  }

  /// Back Button
  Future<bool> _onBackPressed() async {
    return false;
  }

  /// Validation of authentication fields
  bool validateAndSave() {
    if(globalFormKey.currentState!.validate()){
      globalFormKey.currentState!.save();
      return true;
    } else
      return false;
  }

  /// Language Selection
  void _changeLanguage(Language language) {
    Locale _temp;
    switch(language.languageCode){
      case 'pt':
        _temp = Locale(language.languageCode, 'PT');
        break;
      case 'en':
        _temp = Locale(language.languageCode, 'GB');
        break;
      case 'es':
        _temp = Locale(language.languageCode, 'ES');
        break;
      default:
        _temp = Locale(language.languageCode, 'PT');
    }
    MyApp.setLocale(context, _temp);
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
      _selectedLang = linguaSel;
      _bandeira = bandeira;
    });


  }
  void whatLanguage() async {
    String linguaSel;
    String bandeira;
    String? langSelected;
    var languageSelected = await TokenStorage.readSecureData("lingua");

    if (languageSelected == null){
      langSelected="pt";
      await TokenStorage.writeSecureData("lingua", langSelected);
    } else {
      langSelected=languageSelected.toString();
    }

    switch(langSelected){
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
      _selectedLang = linguaSel;
      _bandeira = bandeira;
    });
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: AppTheme.nearlyWhite,
          body: SingleChildScrollView(

              child: Form(
                key: globalFormKey,
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 35),
                    buildLanguageSelection(),
                    Container(
                      padding: const EdgeInsets.only(
                        top: 50,
                        left: 50,
                        right: 50,
                        bottom: 10,
                      ),
                      child: Image.asset('assets/images/IVDP_logo.png'),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 50),
                      child: Text(
                        AppLocalizations.of(context)!.init_sess,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildComposer(),
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(12,0,12,0),
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xff336db0),
                            borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
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
                                 validateAndSave();
                                if (validateAndSave()==true) {
                                  showDialog(context: context, builder: (context){
                                    return Center(child: CircularProgressIndicator(
                                      color: Color(0xff336db0),
                                    ));
                                  });

                                  key=emailController+passwordController;
                                  var token = await TokenStorage.readSecureData(key);
                                  if (token == null ) {
                                    try {
                                      final result = await InternetAddress.lookup('google.com');
                                      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                                        var response = await APIService.login(emailController, passwordController);
                                        if (response != 200) {
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(AppLocalizations.of(context)!.wrong_emailPass,),
                                            ),
                                          );
                                        } else {

                                          String _token = await TokenStorage.readSecureData(key);
                                          TokenStorage.writeSecureData("logged", _token);
                                          TokenStorage.writeSecureData("authed", emailController);
                                          Navigator.of(context).pop();

                                          Navigator.pushReplacement(context,
                                              MaterialPageRoute(builder:(context)=> NavigationHomeScreen()
                                              ));
                                        }
                                      }
                                    } on SocketException catch (_) {
                                      Navigator.of(context).pop();
                                      _offlineError(context);
                                    }


                                  } else {
                                    TokenStorage.writeSecureData("logged", token);
                                    TokenStorage.writeSecureData("authed", emailController);
                                    Navigator.of(context).pop();
                                    Navigator.pushReplacement(context,
                                        MaterialPageRoute(builder:(context)=> NavigationHomeScreen()
                                        ));
                                  }
                                  FocusScope.of(context).requestFocus(FocusNode());
                                }
                              },
                              child:  Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    AppLocalizations.of(context)!.button1,
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
                    Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        padding: const EdgeInsets.all(15),
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            buildSignInButton(),
                          ],
                        )
                    ),
                  ],
                ),
              ),

            ),

        ),
      ),

    );

  }

  Widget _buildComposer() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 12, right: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.withOpacity(0.8),
                offset: const Offset(4, 4),
                blurRadius: 8),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.all(4.0),
            color: AppTheme.white,
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
              child: Column(
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      validator: (input) =>
                      !input!.contains("@")
                          ? AppLocalizations.of(context)!.bad_email
                          : null,
                      maxLines: 1,
                      maxLength: 100,
                      onChanged: (String txt) {
                        emailController = txt;
                      },
                      style: const TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontSize: 16,
                        color: AppTheme.dark_grey,
                      ),
                      cursorColor: Colors.blue,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.black26,
                          ),
                          border: InputBorder.none,
                          counterText: '',
                          hintText: AppLocalizations.of(context)!.email,

                    )),
                    TextFormField(
                      obscureText: hidePassword,
                      keyboardType: TextInputType.text,
                      validator: (input) =>
                      input!.isEmpty
                          ? AppLocalizations.of(context)!.bad_password
                          : null,
                      maxLines: 1,
                      maxLength: 100,
                      onChanged: (String txt) {
                        passwordController = txt;
                      },

                      style: const TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontSize: 16,
                        color: AppTheme.dark_grey,
                      ),
                      cursorColor: Colors.blue,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.black26,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                            color: Colors.black26,
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                          border: InputBorder.none,
                          counterText: '',
                          hintText: AppLocalizations.of(context)!.password,
                    )),
                  ]),



            ),

          ),
        ),
      ),
    );
  }

  Widget buildLanguageSelection(){

    return Container(
      padding: const EdgeInsets.only(right: 20),
      alignment: Alignment.centerRight,
      child: DropdownButton(
        hint: Text(
          _selectedLang +"  "+ _bandeira,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        onChanged: (Language? language){
          TokenStorage.writeSecureData("lingua", language!.languageCode);
          selectedLanguage(language.languageCode);
          _changeLanguage(language);
        },

        underline: const SizedBox(),

        items: Language.languageList().map<DropdownMenuItem<Language>>((lang) => DropdownMenuItem(
          value: lang,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget> [
              Text(lang.name),
              Text(lang.flag),


            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget buildSignInButton(){
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SignUp()),
      ),
      child: RichText(
        text: TextSpan(
            children: [
              TextSpan(
                text: AppLocalizations.of(context)!.no_account,
                style: const TextStyle(
                  color : Colors.black,
                  fontSize: 13, fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                  text: AppLocalizations.of(context)!.button2,
                  style: const TextStyle(
                      color: Color(0xfff79c4f),
                      fontSize: 13,
                      fontWeight: FontWeight.w600
                  )
              )
            ]
        ),
      ),
    );
  }

  _offlineError(BuildContext context) {
    Alert(
      context: globalFormKey!.currentContext!,
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
