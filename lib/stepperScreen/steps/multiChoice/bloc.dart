
import 'dart:async';
import 'package:live_sklad/utils.dart';

import '../../../apiData.dart';

class MultiChoiceStepBloc<T> {

  MultiChoiceStepBloc({
    this.info,
    this.valueCallBack,
    this.search,
    this.addMethod,
    this.valueFactory,
    this.equals,
    this.searchValueFactory
  });

  FieldInfo info;
  Function(FieldInfo info) valueCallBack;
  bool Function(T value1, T value2) equals;
  Future<List<T>> Function(String text, int page, int pageSize) search;
  Future<T> Function(String name) addMethod;
  T Function(dynamic value) valueFactory;
  T Function(String value) searchValueFactory;

  StreamController _controller = StreamController<MultiChoiceState<T>>();
  MultiChoiceState<T> _state;
  StreamSubscription _searchSub;

  int _page = 1;
  static const int _PAGE_SIZE = 30;
  bool _isLoad = false;

  Stream<MultiChoiceState<T>> get stream {
    var val = _getInitialValue();
    if(_state == null) {
      _state = MultiChoiceState<T>(
        search: null,
        selectedItems: val,
        items: [],
        isCanAddInDict: false,
        isAddNewString: null,
      );
    }
    _controller.add(_state);
//    _notify(val);
    _load();
    return _controller.stream;
  }

  _getInitialValue () {
    if(info.value != null && info.value is List<T>) {
      return info.value as List<T>;
    }
    if (info.defaultValue != null && info.defaultValue is List && valueFactory != null) {
      return (info.defaultValue as List).map((e) => valueFactory(e)).toList();
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
        defaultValue: info.defaultValue,
        items: info.items,
        name: info.name,
        dataType: info.dataType
      ));
    }
  }

  _load() {
    if (_isLoad) return;
    _isLoad = true;
    search(_state.search is String ? _state.search : '', _page, _PAGE_SIZE)
        .then((value) {
      _state.items = value;
      _filter();
      _state.isAddNewString = null;
      if (!_controller.isClosed) _controller.add(_state);
      _isLoad = false;
    });
  }

  onItemDelete (T value) {
    _state.selectedItems.remove(value);
//    if(_state.selectedItems.length == 0) _state.selectedItems = null;
    _notify(_state.selectedItems);
    _load();
  }

  onItemSelect (T value) {
    if(_state.selectedItems == null) _state.selectedItems = List<T>();
    _state.selectedItems.add(value);
    _state.search = null;
    _state.isCanAddInDict = false;
    _state.isAddNewString = null;
    _notify(_state.selectedItems);
    _load();
  }

  onSearch (String text) {
    _page = 1;
    _state.search = text.trim()
        .replaceAll(START_TAG, '')
        .replaceAll(END_TAG, '')
        .length > 0 ? text : null;
    if(_searchSub != null) {
      _searchSub.cancel();
    }
    _searchSub = Future.delayed(Duration(milliseconds: 500)).asStream().listen((event) {
      search(text.trim(), _page, _PAGE_SIZE)
          .then((value) {
        if ((value == null || value.length == 0) && addMethod != null && _state.search.trim().length > 0) {
          _state.isCanAddInDict = true;
          _state.isAddNewString = null;
          _state.items = [];
        } else {
          _state.isCanAddInDict = false;
          _state.items = value;
          _filter();
        }
        _controller.sink.add(_state);
        _isLoad = false;
      });
    });
  }

  _filter() {
    _state.items = _state.items.where((element) {
      if (equals != null) {
        bool res = true;
        _state.selectedItems?.forEach((selectedElement) {
          if(equals(element, selectedElement)) {
            res = false;
            return;
          }
        });
        return res;
      } else return true;
    }).toList();
  }

  onAddDict() {
    if (addMethod != null && _state.search is String) {
      String foo = _state.search;
      addMethod(_state.search).then((value) {
        _state.selectedItems.add(value);
        _state.search = null;
        _state.isCanAddInDict = false;
        _state.isAddNewString =  foo;
        _notify(_state.selectedItems);
        _controller.sink.add(_state);
      });
    }
  }

  reachEndList() {
    if (_isLoad) return;
    _isLoad = true;
    _page ++;
    search(_state.selectedItems is String ? _state.selectedItems : '', _page, _PAGE_SIZE)
        .then((value) {
      _state.items.addAll(value);
      _state.isAddNewString = null;
      _controller.sink.add(_state);
      _isLoad = false;
    });
  }

  onAddItem() {
    if(searchValueFactory != null && _state.search != null && _state.search.trim().length > 0) {
      if (_state.selectedItems == null) _state.selectedItems = [];
      _state.selectedItems.add(searchValueFactory(_state.search));
      _state.search = null;
      _state.isCanAddInDict = false;
      _state.isAddNewString = null;
      _notify(_state.selectedItems);
      _load();
    }
  }

}

class MultiChoiceState<T> {

  MultiChoiceState({
    this.search,
    this.selectedItems,
    this.items,
    this.isCanAddInDict,
    this.isAddNewString
  });

  String search;
  List<T> selectedItems;
  List<T> items;
  bool isCanAddInDict;
  String isAddNewString;

}
