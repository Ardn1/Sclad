
import 'dart:async';
import 'package:live_sklad/api.dart';
import 'package:live_sklad/apiData.dart';

class NameStepBloc {

  static const int PAGE_SIZE = 30;

  NameStepBloc({this.info, this.valueCallBack}) {
//    _notify(info.value);
    print('NameStepBloc: ${info.value}');
    _state = NameState(
      counteragents: [],
      selected: _getInitialValue(),
    );
  }

  final FieldInfo info;
  final Function(FieldInfo info) valueCallBack;

  int _page = 1;
  bool _isLoad = false;
  NameState _state;
  StreamSubscription _searchSub;

  StreamController _controller = StreamController<NameState>();

  Stream<NameState> get steam {
//    _controller.add(_state);
//    _notify(_state.selected);
    load();
    return _controller.stream;
  }

  dynamic _getInitialValue () {
    if(info.value is Counteragent || info.value is String) {
      return info.value;
    }
    if(info.defaultValue is Counteragent || info.defaultValue is String) {
      return info.defaultValue;
    }
    return null;
  }

  load () {
    print('load');
    if (_isLoad) return;
    _isLoad = true;
    Api.getInstance().then((api) {
      api.getCounteragentsByName(
          pageSize: PAGE_SIZE,
          page: _page,
          filter: _state.selected is String ? _state.selected : '').then((value) {
            print('load');
        if(value != null) {
          _state.counteragents = info.value is Counteragent ? [] : (value['data'] as List)
              .map((e) => Counteragent.fromJson(e))
              .toList();
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
    if(info.isBlock) return;
    _state.selected = text;
    if(!info.isOnlyDictionary) {
      _notify(text.length != 0 ? text : null);
    }
    if(_searchSub != null) _searchSub.cancel();
    _searchSub = Future.delayed(Duration(milliseconds: 600)).asStream()
      .listen((event) {
        load();
    });
  }

  onItemSelect(Counteragent counteragent) {
    if(info.isBlock) return;
    _state.selected = counteragent;
    _state.counteragents = [];
    _page = 1;
    _notify(counteragent);
    _controller.sink.add(_state);
  }

  onClear() {
    print('onClear');
    _page = 1;
    _state.selected = info.defaultValue != null
        ? info.defaultValue is Counteragent
          ? null
          : info.defaultValue
        : null;
    if (info.isOnlyDictionary) {
      _notify(null);
    } else {
      _notify(_state.selected);
    }
    load();
  }

  onReachEnd() {
    if (_isLoad) return;
    _isLoad = true;
    _page ++;
    Api.getInstance().then((api) {
      api.getCounteragentsByName(
          pageSize: PAGE_SIZE,
          page: _page,
          filter: _state.selected is String ? _state.selected : '').then((value) {
        if(value != null) {
          _state.counteragents.addAll(info.value is Counteragent ? [] : (value['data'] as List)
              .map((e) => Counteragent.fromJson(e)).toList());
          _controller.sink.add(_state);
        }
        _isLoad = false;
      });
    });
  }

  _notify(dynamic value) {
    if(valueCallBack != null) {
      valueCallBack(FieldInfo(
        value: value,
        id: info.id,
        defaultValue: info.defaultValue,
        isRequired: info.isRequired,
        isOnlyDictionary: info.isOnlyDictionary,
        isBlock: info.isBlock
      ));
    }
  }

}

class NameState {

  NameState({this.counteragents, this.selected});

  dynamic selected; // Counteragent OR String
  List<Counteragent> counteragents;

}

