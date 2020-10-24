import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:live_sklad/apiData.dart';
import 'package:live_sklad/preferences.dart';
import 'package:uuid/uuid.dart';

const BASE_URL = 'https://api.livesklad.com/';
const BASE_IMAGE_URL = 'https://images.livesklad.com/';

Future<Map> auth (String email, String password) async {
  const AUTH = 'login';
  try {
    http.Response response = await http.post(
      '$BASE_URL$AUTH',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
        'isMobile' : 'true',
      }),
    );
    return json.decode(response.body);
  } on SocketException catch (_) {
    return {'error': {'details':'Отсутствует подключение к интернету'}};
  }
}

class Api {

  static Api _instance;
  Api({this.token, this.selectelId});
  String token;
  String imageToken;
  String selectelId;
  StreamController _eventController = StreamController<Error>.broadcast();

  StreamSubscription subscribeOnErrors (Function(Error error) listener) {
    return _eventController.stream.listen((event) {
      if (event is Error) listener(event);
    });
  }

  _setToken (String token) {
    this.token = token;
  }

  dispose () {
    _eventController.close();
  }

  clear() {
    _instance = null;
  }

  static Future<Api> getInstance() async {
    PrefManager preferences = await PrefManager.getInstance();
    if (_instance == null) {
      String shareToken = preferences.getToken();
      if (shareToken == null) throw Exception('Token not instance');
      _instance = Api(token: shareToken, selectelId: preferences.getSelectelId());
      await _instance._authImageStore();
    } else {
      _instance._setToken(preferences.getToken());
    }
    return _instance;
  }

  _authImageStore() async {
    http.Response imageResponse = await http.get(
      '${BASE_URL}company/selectel',
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': token,
        'sign': _getSign('company/selectel', {}).toString(),
      },
    );
    if (imageResponse.statusCode == 200) {
      imageToken = json.decode(imageResponse.body)['data']['token'];
    } else {
      _eventController.sink.add(Error(
        message: 'Image token not instance! ${json.decode(imageResponse.body)['message']}',
        type: ErrorType.CODE_666,
      ));
    }
  }

  String _getParamsUrl(Map params) {
    var str = '';
    if (params != null && params.length!=0 ) {
      str = str + '?';
      bool start = true;
      params.forEach((key, value) {
        if(key != 'token') {
          if (value is List) {
            for (int i = 0; i < value.length; i++) {
              if (start) {
                str = '$str$key[]=${params[key][i]}';
                start = false;
              } else {
                str = '$str&$key[]=${params[key][i]}';
              }
            }
          } else if (value is Map) {
            //TODO object param
          } else {
            if (start) {
              str = '$str$key=${params[key]}';
              start = false;
            } else {
              str = '$str&$key=${params[key]}';
            }
          }
        }
      });
    }
    return str;
  }

  String _getSign(String url, Map<String, dynamic> params, {String accToken}) {

    String res = '';
    Map map = params;
    map['token'] = accToken != null ? accToken : token;
    SplayTreeMap treeMap = SplayTreeMap.from(map);
    List<String> keys = map.keys.toList();
    keys.sort();
    treeMap.forEach((key, value) {
      if(value is List || value is Map) {
        res = '$res$key${value.length}';
      } else {
        res = '$res$key$value';
      }
    });
    res = md5.convert(utf8.encode(res)).toString();
    res = '/$url/$res';
    var hmac = Hmac(sha1, utf8.encode('phone'));
    res = hmac.convert(utf8.encode(res)).toString();
    return base64.encode(utf8.encode(res));
  }

  Future<Map> _generateRequest({
    String path,
    Map<String, dynamic> params,
    Map<String, dynamic> body,
    Method method,
  }) async {
    try {
      http.Response response;
      Map<String, String> headers = <String, String> {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': token,
        'sign': _getSign(path, params != null ? params : {}).toString(),
      };

      switch(method) {
        case Method.GET:
          headers['sign'] = _getSign(path, params != null ? params : {});
          response = await http.get('$BASE_URL$path${_getParamsUrl(params)}',
          headers: headers,
        ); break;
        case Method.POST:
          headers['sign'] = _getSign(path, body);
          body.remove('token');
          response = await http.post('$BASE_URL$path',
          headers: headers,
          body: jsonEncode(body),
        ); break;
        case Method.PATCH:
          headers['sign'] = _getSign(path, body);
          body.remove('token');
          response = await http.patch('$BASE_URL$path',
          headers: headers,
          body: jsonEncode(body),
        ); break;
        case Method.DELETE:
          headers['sign'] = _getSign(path, {});
          body.remove('token');
          response = await http.delete('$BASE_URL$path',
          headers: headers,
        ); break;
      }
      if(response != null) {
        if(response.statusCode == 200) {
          if(json.decode(response.body)['data'] != null) {
            return json.decode(response.body);
          } else {
            _eventController.sink.add(Error(
              message: 'Code error',
              type: ErrorType.CODE_666,
            ));
            return null;
          }
        } else if (response.statusCode == 401) {
          _eventController.sink.add(Error(
            message: 'Access deny',
            type: ErrorType.CODE_401,
          ));
          return null;
        } else if (response.statusCode == 555) {
          _eventController.sink.add(Error(
            message: json.decode(response.body)['error']['details'],
            type: ErrorType.CODE_401,
          ));
          return null;
        }
      } else {
        _eventController.sink.add(Error(
          message: 'Code error',
          type: ErrorType.CODE_666,
        ));
        return null;
      }
    } on SocketException catch (_) {
      _eventController.sink.add(Error(
        message: 'Отсутствует подключение к интернету',
        type: ErrorType.INTERNET_ERROR,
      ));
      return null;
    }
  }

  Future<Map> getOrders(String shopId, {
    String sort,
    int page,
    int pageSize,
    String filter,
    List<String> statusIds,
  }) async {
    
    String path = 'shops/$shopId/orders';
    Map<String, dynamic> params = {
      'utc' : 180,
      'sort' : sort != null ? sort : 'dateCreate DESC',
      'isFields' : false,
      'page' : page != null ? page : 1,
      'pageSize' : pageSize != null ? pageSize : 10,
      'version' : '1.11.3.0',
    };
    if(statusIds!=null) params['statusIds'] = statusIds;
    if(filter!=null) params['filter'] = filter;
    try {
      http.Response response = await http.get('$BASE_URL$path${_getParamsUrl(params)}',
        headers: <String, String> {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token,
          'sign': _getSign(path, params),
        },
      );
      return json.decode(response.body);
    } on SocketException catch (_) {
      return {'error': {'details':'Отсутствует подключение к интернету'}};
    }
  }

  Future<Map> getTypeOrders () async {
    String path = 'type-orders';
    return await _generateRequest(
      method: Method.GET,
      path: path,
    );
  }

  Future<Map> getFormByTypeId (String typeId) async {
    String path = 'fields/type-orders/$typeId';
    Map<String, dynamic> params = {
      'isCreateOrder': 'true'
    };
    return await _generateRequest(
      path: path,
      method: Method.GET,
      params: params,
    );
  }

  Future<Map> getCounteragentsByName ({String filter, int page, int pageSize}) async {
    String path = 'counteragents';
    Map<String, dynamic> params = {};
    if (filter != null) params['filter'] = filter;
    if (page != null) params['page'] = page;
    if (pageSize != null) params['pageSize'] = pageSize;
    return await _generateRequest(
      path: path,
      method: Method.GET,
      params: params,
    );
  }

  Future<Map> getCounteragentsByPhone ({String phone, int page, int pageSize}) async {
    String path = 'counteragents';
    Map<String, dynamic> params = {};
    if (phone != null) params['phone'] = phone;
    if (page != null) params['page'] = page;
    if (pageSize != null) params['pageSize'] = pageSize;
    return await _generateRequest(
      path: path,
      method: Method.GET,
      params: params,
    );
  }

  Future<Map> getHowKnows () async {
    String path = 'how-knows';
    return await _generateRequest(
      path: path,
      method: Method.GET,
    );
  }

  Future<Map> addHowKnow (String name) async {
    String path = 'how-knows';
    return await _generateRequest(
      path: path,
      method: Method.POST,
      body: {
        'name' : name
      },
    );
  }

  Future<Map> getTypeDevices ({
    String filter,
    int page,
    int pageSize,
  }) async {
    String path = 'type-devices';
    return await _generateRequest(
      path: path,
      method: Method.GET,
      params: {
        'filter' : filter,
        'page' : page,
        'pageSize' : pageSize,
      }
    );
  }

  Future<Map> addTypeDevice (String name) async {
    String path = 'type-devices';
    return await _generateRequest(
      path: path,
      method: Method.POST,
      body: {
        'name' : name
      },
    );
  }

  Future<Map> getBrands ({
    String filter,
    int page,
    int pageSize,
  }) async => await _generateRequest(
      path: 'brand-devices',
      method: Method.GET,
      params: {
        'filter' : filter,
        'page' : page,
        'pageSize' : pageSize,
      }
  );

  Future<Map> addBrand (String name) async {
    String path = 'brand-devices';
    return await _generateRequest(
      path: path,
      method: Method.POST,
      body: {
        'name' : name
      },
    );
  }

  Future<Map> getCounteragentById(String contragentId) {
    String path = 'counteragents/$contragentId';
    return _generateRequest(
      method: Method.GET,
      path: path,
    );
  }


  Future<Map> getModels ({
    String brandId,
    String typeDeviceId,
    String filter,
    int page,
    int pageSize,
  }) async {
    String path = 'brand-devices/$brandId/model-devices';
    Map<String, dynamic> params = {
      'filter' : filter,
      'page' : page,
      'pageSize' : pageSize,
    };
    if (typeDeviceId != null) params['typeDeviceId'] = typeDeviceId;
    return await _generateRequest(
        path: path,
        method: Method.GET,
        params: params,
    );
  }

  Future<Map> addModel (String name, String brandId, {String typeDeviceId}) async {
    String path = 'brand-devices/$brandId/model-devices';
    Map<String, dynamic> body = {
      'name' : name,
    };
    if (typeDeviceId != null) body['typeDeviceId'] = typeDeviceId;
    return await _generateRequest(
      path: path,
      method: Method.POST,
      body: body,
    );
  }

  Future<List<CompleteSet>> getCompleteSet({
    String filter,
    int page,
    int pageSize,
  }) async => await _generateRequest(
      path: 'complete-sets',
      method: Method.GET,
      params: {
      'filter' : filter,
      'page' : page,
      'pageSize' : pageSize,
    }
  ).then((value) => value != null ? (value['data'] as List)
      .map((e) => CompleteSet.fromJson(e)).toList() : List<CompleteSet>());

  Future<CompleteSet> addCompleteSet({
    String name,
  }) async => await _generateRequest(
      path: 'complete-sets',
      method: Method.POST,
      body: <String, dynamic>{
        'name' : name,
    }).then((value) {
      return  value != null ? CompleteSet.fromJson(value['data']) : null;
  });

  Future<List<Problem>> getProblems({
    String filter,
    int page,
    int pageSize,
  }) async => await _generateRequest(
      path: 'problems',
      method: Method.GET,
      params: {
      'filter' : filter,
      'page' : page,
      'pageSize' : pageSize,
    }
  ).then((value) => value != null ? (value['data'] as List)
      .map((e) => Problem.fromJson(e)).toList() : List<Problem>());

  Future<Problem> addProblem({
    String name,
  }) async => await _generateRequest(
      path: 'problems',
      method: Method.POST,
      body: <String, dynamic>{
        'name' : name,
    }).then((value) {
      return  value != null ? Problem.fromJson(value['data']) : null;
  });

  Future<List<ManagerMaster>> getMastersByShopId ({
    String shopId, String filter, bool isMaster
  }) async => _generateRequest(
    path: 'shops/$shopId/customers/${isMaster ? 'masters' : 'managers'}',
    params: {
      'filter': filter
    },
    method: Method.GET
  ).then((value) => value != null ? (value['data'] as List)
      .map((e) => ManagerMaster.fromJson(e)).toList() : List<ManagerMaster>());

  Future<List<CashRegister>> getCashRegisters({
    @required String shopId,
  }) async => await _generateRequest(
      path: 'shops/$shopId/cash-registers',
      method: Method.GET,
  ).then((value) => value != null ? (value['data'] as List)
      .map((e) => CashRegister.fromJson(e)).toList() : List<CashRegister>());

  Future<Map> saveNewOrder({
    @required String shopId,
    @required Map<String, dynamic> orderBody,
  }) async => await _generateRequest(
      path: 'shops/$shopId/orders',
      method: Method.POST,
      body: orderBody,
  ).then((value) {
    if (value != null) {
      return value;
    } else return null;
  });


  Future<String> putImage (File file, {bool isPreview = false, String uuid}) async {
    if(uuid == null) uuid = Uuid().v1();
    uuid = uuid.replaceAll('.png', '');
    return file.openRead().first.then((value) {
      return http.put(
        '$BASE_IMAGE_URL$selectelId/orders/${isPreview ? 'preview.' : ''}$uuid.png',
        headers: {
          'X-Auth-Token': imageToken,
        },
        body: value,
      ).then((value) {
        return value.statusCode == 201 ? '$uuid.png' : null;
      });
    });
  }

  Future<bool> deleteImage (String uuid) async {
    //https://images.livesklad.com/d88a370a4930eccb5ae967783972c966/orders/bba49900-d49a-11ea-8c3d-99a26ff79207.png
    http.Response response = await http.delete(
      '$BASE_IMAGE_URL$selectelId/orders/$uuid',
      headers: {
        'X-Auth-Token': imageToken,
      },
    );
    http.Response responseSmall = await http.delete(
      '$BASE_IMAGE_URL$selectelId/orders/preview.$uuid',
      headers: {
        'X-Auth-Token': imageToken,
      },
    );
    return (responseSmall.statusCode == 204 && response.statusCode == 204)
      || (responseSmall.statusCode == 404 && response.statusCode == 404);
  }

  Future<String> getOrder(String id) async{

  }


}

class Error {
  Error({this.type, this.message});
  ErrorType type;
  String message;
}

enum ErrorType {
  CODE_401,
  INTERNET_ERROR,
  VALIDATION,
  CODE_666,
}

enum Method {
  GET,
  POST,
  DELETE,
  PATCH,
}


