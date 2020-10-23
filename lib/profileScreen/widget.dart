import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:live_sklad/loginScreen/widget.dart';
import 'package:live_sklad/preferences.dart';
import 'package:live_sklad/stepperScreen/widget.dart';
import 'package:package_info/package_info.dart';

import '../api.dart';
import '../styles.dart';

class ProfileScreen extends StatefulWidget {

  @override
  createState() => ProfileScreenState();

}

class ProfileScreenState extends State<ProfileScreen> {

  String _version = '?.?.?';

  @override
  void initState() {
    PackageInfo.fromPlatform()
      .then((value) {
        setState(() {
          _version = value.version;
        });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('MainScreenState BUILD');
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('App version $_version'),
            Text('Profile Screen'),
            RaisedButton(
              child: Text('EXIT'),
              onPressed: () async {
                PrefManager.getInstance().then((value) {
                  value.clearData().then((value) {
                    Navigator.of(context).pushReplacementNamed(LoginScreen.route);
                  });
                  Api.getInstance().then((value) => value.clear());
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}


