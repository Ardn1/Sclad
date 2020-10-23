
import 'dart:async';
import 'package:live_sklad/api.dart';
import 'package:live_sklad/apiData.dart';

class PhonesStepBloc {

  static const int PAGE_SIZE = 30;

  PhonesStepBloc({this.info, this.valueCallBack});

  final FieldInfo info;
  final Function(FieldInfo info) valueCallBack;

  int _page = 1;
  bool _isLoad = false;

  PhonesState _state;
  StreamSubscription _searchSub;

  StreamController _controller = StreamController<PhonesState>();

  Stream<PhonesState> get steam {
    if(_state == null) _state = PhonesState(
      selected: _getInitialValue(),
      counteragents: [],
      isCanAdd: !info.isBlock,
      phones: []
    );
    _controller.sink.add(_state);
    if(info.value is List<String>) _state.phones = info.value as List<String>;
    return _controller.stream;
  }

  dynamic _getInitialValue () {
    if(info.value is String) {
      return info.value;
    }
    if(info.defaultValue is List<dynamic>) {
      return info.defaultValue[0].toString();
    }
    return null;
  }

  load () {
    if (_isLoad) return;
    _isLoad = true;
    Api.getInstance().then((api) {
      api.getCounteragentsByPhone(
          pageSize: PAGE_SIZE,
          page: _page,
          phone: _state.selected is String
              ? _state.selected.toString().replaceAll('+', '')
              : '',
      ).then((value) {
        if(value != null) {
          if(info.value is List<String>) _state.phones = info.value as List<String>;
          _state.counteragents = info.value is Counteragent ? [] : (value['data'] as List)
              .map((e) => Counteragent.fromJson(e)).toList();
          if (!_controller.isClosed) _controller.add(_state);
        }
        _isLoad = false;
      });
    });
  }

  dispose() {
    _controller.close();
  }

  onSearch(String text) {
    _state.selected = text;
    _state.isCanAdd = !info.isBlock ? text != null && text.length != 0 : false;
    if(_searchSub != null) _searchSub.cancel();
    _searchSub = Future.delayed(Duration(milliseconds: 600)).asStream()
        .listen((event) {
      load();
    });
  }

  onItemSelect(Counteragent counteragent) {
    print('onItemSelect');
    _state.selected = counteragent;
    _state.phones = [];
    _state.isCanAdd = false;
    _state.counteragents = [];
    _page = 1;
    _controller.sink.add(_state);
    _notify(counteragent);
  }

  onClear() {
    _state.selected = info.defaultValue is List<dynamic>
      ? (info.defaultValue as List)[0].toString() : null;
    _page = 1;
    _notify(null);
    if(info.value is List<String>) _state.phones = info.value as List<String>;
    if (_state.selected is String && _state.selected.toString().length > 0)
      _state.isCanAdd = true;
    _controller.sink.add(_state);
  }

  onReachEnd() {
    if (_isLoad) return;
    _isLoad = true;
    _page ++;
    Api.getInstance().then((api) {
      api.getCounteragentsByPhone(
          pageSize: PAGE_SIZE,
          page: _page,
          phone: _state.selected is String ? _state.selected : '',
      ).then((value) {
        if(value != null) {
          _state.counteragents.addAll(info.value is Counteragent ? [] : (value['data'] as List)
              .map((e) => Counteragent.fromJson(e)).toList());
          _controller.sink.add(_state);
          _isLoad = false;
        }
      });
    });
  }

  onPhoneAdd() {
    if(_state.selected is String && _state.selected.toString().length != 0 && !_state.phones.contains(_state.selected.toString())) {
      _state.phones.add(_state.selected);
      _state.selected = null;
      _state.isCanAdd = false;
      _notify(_state.phones);
      load();
    }
  }

  onPhoneDelete(String e) {
    int pos;
    _state.phones.forEach((element) {
      if(e == element) pos = _state.phones.indexOf(element);
    });
    if (pos != null) {
      _state.phones.removeAt(pos);
      _controller.sink.add(_state);
      _notify(_state.phones);
    }
  }

  _notify(dynamic value) {
    if(valueCallBack != null) {
      valueCallBack(FieldInfo(
        id: info.id,
        value: value is List && value.length == 0 ? null : value,
        defaultValue: info.defaultValue,
        isRequired: info.isRequired,
        isOnlyDictionary: info.isOnlyDictionary,
        isBlock: info.isBlock,
      ));
    }
  }
}

class PhonesState {

  PhonesState({
    this.counteragents,
    this.selected,
    this.phones,
    this.isCanAdd,
  });

  bool isCanAdd;
  dynamic selected;
  List<String> phones;
  List<Counteragent> counteragents;

}