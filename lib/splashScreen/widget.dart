import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:live_sklad/loginScreen/widget.dart';
import 'package:live_sklad/mainScreen/widget.dart';
import 'package:live_sklad/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {

  static const route = '/splash';

  @override
  Widget build(BuildContext context) {

    PrefManager.getInstance()
      .then((value) {
      Navigator.of(context).pushReplacementNamed(
          value.getToken() != null ?
          MainScreen.route : LoginScreen.route
      );
    });

    return Scaffold(
      body: Center(
        child: Text('Splash Screen'),
      ),
    );
  }

}