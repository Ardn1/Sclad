import 'dart:async';
import 'dart:convert';
import 'package:live_sklad/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api.dart';

class LoginScreenBloc {

  String _email;
  String _password;

  StreamController _streamController = StreamController<LoginState>();

  Stream<LoginState> get stream => _streamController.stream;

  void dispose() {
    _streamController.close();
  }

  void onEmailChange(String text) {
    this._email = text;
  }

  void onPasswordChange(String text) {
    this._password = text;
  }

  void onLoginPress() async {
    auth(_email, _password)
        .then((value) async {
          if(value['error'] != null && value['error']['details'] != null) {
            _streamController.sink.add(ShowError(error: value['error']['details']));
            return;
          }
          if(value['data'] !=null && value['data']['accessToken'] != null) {
            PrefManager manager = await PrefManager.getInstance();
            manager.saveAuth(value['data']);
            _streamController.sink.add(GoToMain());
          }
    });
  }
}

class LoginState {}

class ShowError extends LoginState {
  ShowError({this.error});
  String error;
}

class GoToMain extends LoginState {}