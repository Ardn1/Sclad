import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:live_sklad/ImageScreen/widget.dart';
import 'package:live_sklad/createOrderScreen/widget.dart';
import 'package:live_sklad/loginScreen/widget.dart';
import 'package:live_sklad/mainScreen/widget.dart';
import 'package:live_sklad/splashScreen/widget.dart';
import 'package:live_sklad/typeOrderSelectScreen/widget.dart';

import 'package:live_sklad/editOrderScreen/editOrderScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return /* MaterialApp( routes: {EditOrderScreen()});*/
    MaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: [
        const Locale('en', 'US'), // American English
        const Locale('ru', 'RU'), // Russian
      ],
      locale: Locale('ru', 'RU'),
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.route,
      title: 'LiveSklad',
      routes: {
        SplashScreen.route : (context) => SplashScreen(),
        LoginScreen.route : (context) => LoginScreen(),
        MainScreen.route : (context) => MainScreen(),
        TypeOrderScreen.route : (context) => TypeOrderScreen(),
        CreateOrderScreen.route : (context) =>
            EditOrderScreen(
        //      shopId: (ModalRoute.of(context).settings.arguments as CreateOrderScreenArguments).shopId,
            ),
        EditOrderScreen.routeName: (context) => EditOrderScreen(),
        ImageScreen.route : (context) =>
            ImageScreen(
              uuid: (ModalRoute.of(context).settings.arguments as ImageScreenArguments).uuid,
            ),
      },
    );
  }
}