
import 'dart:async';
import '../../../apiData.dart';

class SingleChoiceStepBloc<T> {

  SingleChoiceStepBloc({
    this.info,
    this.isOnlyDict,
    this.valueCallBack,
    this.search,
    this.addMethod,
    this.valueFactory,
    this.getClearValue,
    this.getTitle,
  });

  FieldInfo info;
  Function(FieldInfo info) valueCallBack;
  bool isOnlyDict;
  Future<List<T>> Function(String text, int page, int pageSize) search;
  Future<T> Function(String name) addMethod;
  T Function(Map json) valueFactory;
  final T Function(T) getClearValue;
  final String Function(T) getTitle;

  StreamController _controller = StreamController<SingleChoiceState<T>>();
  SingleChoiceState<T> _state;
  StreamSubscription _searchSub;

  int _page = 1;
  static const int _PAGE_SIZE = 30;
  bool _isLoad = false;

  Stream<SingleChoiceState<T>> get stream {
    var val = _getInitialValue();
    if(_state == null) {
      _state = SingleChoiceState<T>(
        selected: val,
        items: [],
        isCanAddInDict: false,
        isAddNewString: null,
      );
    }
    _controller.sink.add(_state);
    if(val != info.value && val is T) _notify(val);
    if(!(_state.selected is T)) _load();
    return _controller.stream;
  }

  _getInitialValue () {
    if(info.value != null && info.value is T) {
      return info.value;
    }
    if(!isOnlyDict && info.value is String) {
      return info.value;
    }
    if (info.defaultValue != null) {
      return info.defaultValue is Map && valueFactory != null
          ? valueFactory(info.defaultValue)
          : info.defaultValue;
    }
    return null;
  }

  dispose() {
    _controller.close();
    if (_searchSub != null) _searchSub.cancel();
  }

  _notify(dynamic value) {
    if(valueCallBack != null) {
      valueCallBack(FieldInfo(
        id: info.id,
        value: value,
        isOnlyDictionary: info.isOnlyDictionary,
        isBlock: info.isBlock,
        isRequired: info.isRequired,
        defaultValue: null,
        items: info.items,
        name: info.name,
        dataType: info.dataType
      ));
    }
  }

  _load() {
    if (_isLoad) return;
    _isLoad = true;
    search(_state.selected is String ? _state.selected : '', _page, _PAGE_SIZE)
        .then((value) {
      _state.items = value;
      _state.isAddNewString = null;
      if (!_controller.isClosed) _controller.add(_state);
      _isLoad = false;
    });
  }

  onItemSelect (T value) {
    _state.selected = value;
    _state.items = [];
    _state.isCanAddInDict = false;
    _state.isAddNewString = null;
    _notify(value);
    _controller.sink.add(_state);
  }

  onClear () {
    _state.selected = null;
    _state.items = [];
    _state.isCanAddInDict = false;
    _state.isAddNewString = null;
    _notify(_state.selected);
    _load();
  }

  onSearch (String text) {
    _page = 1;
    _state.selected = text.length > 0 ? text : null;
    if(!isOnlyDict) _notify(_state.selected);
    if(_searchSub != null) {
      _searchSub.cancel();
    }
    _searchSub = Future.delayed(Duration(milliseconds: 500)).asStream().listen((event) {
      search(text, _page, _PAGE_SIZE)
          .then((value) {
        if ((value == null || value.length == 0) && addMethod != null && _state.selected != null) {
          _state.isCanAddInDict = true;
          _state.isAddNewString = null;
          _state.items = [];
        } else {
          _state.isCanAddInDict = false;
          _state.items = value;
          if (value.length == 1 && _state.selected is String
          && getTitle(getClearValue(value[0])).trim().toLowerCase() == _state.selected.toString().trim().toLowerCase()) {
            info.value = getClearValue(value[0]);
          }
        }
        _controller.sink.add(_state);
        _isLoad = false;
      });
    });
  }

  onAddDict() {
    if (addMethod != null && _state.selected is String) {
      String foo = _state.selected;
      addMethod(_state.selected).then((value) {
        _state.selected = value;
        _state.items = [];
        _state.isCanAddInDict = false;
        _state.isAddNewString =  foo;
        _notify(value);
        _controller.sink.add(_state);
      });
    }
  }

  reachEndList() {
    if (_isLoad) return;
    _isLoad = true;
    _page ++;
    search(_state.selected is String ? _state.selected : '', _page, _PAGE_SIZE)
        .then((value) {
      _state.items.addAll(value);
      _state.isAddNewString = null;
      _controller.sink.add(_state);
      _isLoad = false;
    });
  }

  void onKeyboardHide() {
    if (_state.selected is String
        && _state.items.length > 0
        && _state.selected == getTitle(getClearValue(_state.items[0]))) {
      onItemSelect(getClearValue(_state.items[0]));
    }
  }

}

class SingleChoiceState<T> {

  SingleChoiceState({
    this.selected,
    this.items,
    this.isCanAddInDict,
    this.isAddNewString
  });

  dynamic selected;
  List<T> items;
  bool isCanAddInDict;
  String isAddNewString;

}

