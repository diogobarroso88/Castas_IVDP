import 'dart:io';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../API/apiservice.dart';
import '../app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  GlobalKey<FormState> globalFormKey = new GlobalKey<FormState>();

  late String emailController;
  late String passwordController;
  late String nameController;
  late String usernameController;

  late String key;
  bool hidePassword = true;
  bool isSomeProgress = false;

  @override
  void initState() {
    super.initState();
  }

  bool validateAndSave() {
    if (globalFormKey.currentState!.validate()) {
      globalFormKey.currentState?.save();
      return true;
    } else
      return false;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.nearlyWhite,
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: AppTheme.nearlyWhite,
          body: SingleChildScrollView(
            child: Form(
              key: globalFormKey,
              child: Column(
                children: <Widget>[

                  Container(
                    padding: const EdgeInsets.only(
                      top: 130,
                      left: 50,
                      right: 50,
                      bottom: 10,
                    ),
                    child: Image.asset('assets/images/IVDP_logo.png'),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 50),
                    child: Text(
                      AppLocalizations
                          .of(context)
                          !.sign_up,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildComposer(),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
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
                            onTap: () async {
                              if (validateAndSave() == true) {
                                //adicionar roda
                                key = emailController + passwordController;
                                try {
                                  final result = await InternetAddress.lookup(
                                      'google.com');
                                  if (result.isNotEmpty &&
                                      result[0].rawAddress.isNotEmpty) {
                                    var response = await APIService.signUp(
                                        nameController, emailController,
                                        usernameController, passwordController);
                                    if (response == 200) {
                                      _registerSuccess(context);
                                    } else if (response == 302) {
                                      _alreadyRegisted(context);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(AppLocalizations
                                              .of(context)
                                              !.snack_error),
                                        ),
                                      );
                                    }
                                    FocusScope.of(context).requestFocus(
                                        FocusNode());
                                  }
                                } on SocketException catch (_) {

                                  _offlineError(context);
                                }
                              }
                            },
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  AppLocalizations
                                      .of(context)
                                      !.sign_up,
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
                  const SizedBox(height: 15),
                  buildLoginButton(),
                  const SizedBox(height: 35),
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
                          ? AppLocalizations
                          .of(context)
                          !.bad_email
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
                          hintText: AppLocalizations
                              .of(context)
                              !.email),

                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      validator: (input) =>
                      input!.isEmpty
                          ? AppLocalizations
                          .of(context)
                          !.register_name
                          : null,
                      maxLines: 1,
                      maxLength: 100,
                      onChanged: (String txt) {
                        nameController = txt;
                      },

                      style: const TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontSize: 16,
                        color: AppTheme.dark_grey,
                      ),
                      cursorColor: Colors.blue,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.person_pin,
                            color: Colors.black26,
                          ),
                          border: InputBorder.none,
                          counterText: '',
                          hintText: AppLocalizations
                              .of(context)
                              !.name),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      validator: (input) =>
                      input!.isEmpty
                          ? AppLocalizations
                          .of(context)
                          !.register_username
                          : null,
                      maxLines: 1,
                      maxLength: 100,
                      onChanged: (String txt) {
                        usernameController = txt;
                      },

                      style: const TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontSize: 16,
                        color: AppTheme.dark_grey,
                      ),
                      cursorColor: Colors.blue,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Colors.black26,
                          ),
                          border: InputBorder.none,
                          counterText: '',
                          hintText: AppLocalizations
                              .of(context)
                              !.username),
                    ),
                    TextFormField(
                      obscureText: hidePassword,
                      keyboardType: TextInputType.text,
                      validator: (input) =>
                      input!.isEmpty
                          ? AppLocalizations
                          .of(context)
                          !.bad_password
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
                          hintText: AppLocalizations
                              .of(context)
                              !.password),
                    ),
                  ]),


            ),

          ),
        ),
      ),
    );
  }

  Widget buildLoginButton() {
    return GestureDetector(
      onTap: () =>
          Navigator.popUntil(context, (route) => route.isFirst),
      child: RichText(
        text: TextSpan(
            children: [
              TextSpan(
                text: AppLocalizations
                    .of(context)
                    !.back_to,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13, fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                  text: AppLocalizations
                      .of(context)
                      !.login_page,
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

  _registerSuccess(BuildContext context) {
    Alert(
      context: globalFormKey!.currentContext!,
      type: AlertType.success,
      title:  AppLocalizations.of(context)!.success,
      desc: AppLocalizations.of(context)!.check_email,
      buttons: [
        DialogButton(
          child: Text(
            AppLocalizations.of(context)!.ok,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () async {
            Navigator.popUntil(context, (route) => route.isFirst);
          },

          width: 120,
        )
      ],
    ).show();
  }
  _alreadyRegisted(BuildContext context) {
    Alert(
      context: globalFormKey!.currentContext!,
      type: AlertType.error,
      title:  AppLocalizations.of(context)!.error,
      desc: AppLocalizations.of(context)!.double_acc,
      buttons: [
        DialogButton(
          child: Text(
            AppLocalizations.of(context)!.ok,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.of(context,rootNavigator: true).pop(),

          width: 120,
        )
      ],
    ).show();
  }

  _offlineError(BuildContext context) {
    Alert(
      context: globalFormKey!.currentContext!,
      type: AlertType.info,
      title: AppLocalizations.of(context)!.no_connection,
      desc: AppLocalizations.of(context)!.check_connection,
      buttons: [
        DialogButton(
          child: Text(
            AppLocalizations.of(context)!.ok,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.of(context,rootNavigator: true).pop(),
          width: 120,
        )
      ],
    ).show();
  }
}