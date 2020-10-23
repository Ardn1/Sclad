
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PrefManager {

  PrefManager._(this._preferences);

  SharedPreferences _preferences;
  static PrefManager _instance;

  static Future<PrefManager> getInstance() async {
    if(_instance == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _instance = PrefManager._(prefs);
    }
    return _instance;
  }

  void saveToken(String token) {
    _preferences.setString('token', token);
  }

  Future<bool> clearData() {
    return _preferences.clear();
  }

  void saveAuth(Map authResponse) {
    _preferences.setString('auth', json.encode(Auth.fromResponse(authResponse).toJson()));
  }

  String getToken() {
    if(_preferences.getString('auth') == null) return null;
    Auth auth = Auth.fromJson(json.decode(_preferences.getString('auth')));
    return auth.accessToken;
  }

  String getSelectelId() {
    if(_preferences.getString('auth') == null) return null;
    Auth auth = Auth.fromJson(json.decode(_preferences.getString('auth')));
    return auth.selectelId;
  }

  List<String> getAccess() {
    Auth auth = Auth.fromJson(json.decode(_preferences.getString('auth')));
    return auth.access;
  }

  List<ShopsAccess> getShops() {
    Auth auth = Auth.fromJson(json.decode(_preferences.getString('auth')));
    return auth.shopsAccess;
  }

}

class Auth {

  String name;
  String surname;
  String accessToken;
  String selectelId;
  List<String> access;
  List<ShopsAccess> shopsAccess;

  Auth.fromResponse(Map j) {
    name = j['name'];
    surname = j['surname'];
    accessToken = j['accessToken'];
    selectelId = j['selectelId'];
    access = List<String>.from(j['access'] as List);
    shopsAccess = List<ShopsAccess>.from((j['shopsAccess'] as List)
        .map((e) => ShopsAccess.fromJson(e)).toList());
  }

  Auth.fromJson(Map<String, dynamic> j) {
    name = j['name'];
    surname = j['surname'];
    accessToken = j['accessToken'];
    selectelId = j['selectelId'];
    access = List<String>.from(json.decode(j['access']));
    shopsAccess = List<ShopsAccess>.from((json.decode(j['shopsAccess']) as List)
        .map((e) => ShopsAccess.fromJson(e)));
  }

  Map<String, dynamic> toJson () => {
    'name' : name,
    'surname' : surname,
    'accessToken' : accessToken,
    'selectelId' : selectelId,
    'access' : json.encode(access),
    'shopsAccess' : json.encode(shopsAccess),
  };
}

class ShopsAccess {

  String id;
  String name;
  String color;
  int sort;
  bool isEnabledCash;

  ShopsAccess.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    color = json['color'];
    sort = json['sort'];
    isEnabledCash = json['isEnabledCash'] == 'true' ? true : false;
  }

  Map<String, dynamic> toJson () => {
    'id': id,
    'name': name,
    'color': color,
    'sort': sort,
    'isEnabledCash': isEnabledCash ? 'true' : 'false',
  };

  @override
  String toString() {
    return '$id $name $color';
  }
}