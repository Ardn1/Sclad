import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:live_sklad/loginScreen/bloc.dart';
import 'package:live_sklad/mainScreen/widget.dart';
import 'package:live_sklad/styles.dart';
import 'package:live_sklad/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {

  static const route = '/login';

  @override
  createState() => LoginScreenState();

}

class LoginScreenState extends State<LoginScreen> {

  final focus = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  LoginScreenBloc _block;
  FlutterToast _toast;

  @override
  void initState() {
    _toast = FlutterToast(context);
    _block = LoginScreenBloc();
    _block.stream.listen((event) {
      if(event is ShowError) {
        var data = event;
        _showError(data.error);
        return;
      } else if (event is GoToMain) {
        Navigator.of(context).pushReplacementNamed(MainScreen.route);
        return;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _block.dispose();
    super.dispose();
  }

  void _showError(String text) {
    _toast.showToast(child: customToast(text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: EdgeInsets.only(
                left: 30,
                right: 30,
                top: 10,
                bottom: 10
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(AppIcons.LOGO),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Text('Добро пожаловать в', style: TextStyle(
                            fontFamily: 'Regular',
                            fontSize: 22,
                            color: StyleColor.lightGrey
                        ),),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Text('LiveSklad', style: TextStyle(
                            fontFamily: 'Regular',
                            fontSize: 40,
                            color: StyleColor.text
                        )),
                      ),
                    ],
                  ),
                  flex: 5,
                ),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(
                        child: Container(
                          child: _getField((text) =>
                              _block.onEmailChange(
                            text.trim()),
                            'Email',
                            action: TextInputAction.next,
                            onSubmitted: (text) {
                              FocusScope.of(context).requestFocus(focus);
                            }
                          ),
                        ),
                        flex: 1,
                      ),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Container(
                                child: _getField((text) => _block.onPasswordChange(text.trim()),
                                    'Пароль',
                                  focus: focus,
                                  action: TextInputAction.done,
                                  onSubmitted: (text) {
                                    _block.onLoginPress();
                                  },
                                  isPassword: true,
                                ),
                              ),
                              flex: 2,
                            ),
                            Flexible(
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  child: Text('Забыли пароль?', style: TextStyle(
                                      color: StyleColor.blue1,
                                      fontSize: 16,
                                      fontFamily: 'Medium'
                                  ),),
                                  onTap: (){
                                    launch('https://my.livesklad.com/#/reset_password/');
                                  },
                                ),
                              ),
                              flex: 1,
                            ),
                          ],
                        ),
                        flex: 1,
                      )
                    ],
                  ),
                  flex: 3,
                ),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      InkWell(
                        child: Container(
                          padding: EdgeInsets.only(
                              top: 13,
                              bottom: 13,
                              left: 60,
                              right: 60
                          ),
                          decoration: BoxDecoration(
                              color: StyleColor.blue1,
                              borderRadius: BorderRadius.all(Radius.circular(23))
                          ),
                          child: Text('Войти', style: TextStyle(
                              color: StyleColor.white,
                              fontSize: 19,
                              fontFamily: 'Medium'
                          ),),
                        ),
                        onTap: () => _block.onLoginPress(),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('У вас нет аккаунта? ', style: TextStyle(
                                fontFamily: 'Regular',
                                fontSize: 16,
                                color: StyleColor.text
                            ),),
                            InkWell(
                              child: Text('Регистрация', style: TextStyle(
                                  color: StyleColor.blue1,
                                  fontSize: 16,
                                  fontFamily: 'Medium'
                              ),),
                              onTap: () {
                                launch('https://livesklad.com/');
                              },
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  flex: 2,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextField _getField(Function onChange, String hint,
      {FocusNode focus, TextInputAction action, Function onSubmitted, bool isPassword}) => TextField(
    focusNode: focus,
    obscureText: isPassword != null ? isPassword : false,
    textInputAction: action,
    onSubmitted: onSubmitted,
    onChanged: onChange,
    style: TextStyle(
      color: StyleColor.text,
      fontSize: 19,
      fontFamily: 'Regular'
    ),
    decoration: InputDecoration(
      labelText: hint,
      labelStyle: TextStyle(
          fontFamily: 'Regular',
          fontSize: 19,
          color: StyleColor.grey1
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: StyleColor.blue1, width: 2),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: StyleColor.lightGrey, width: 2),
      ),
    ),
  );

}