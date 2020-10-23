
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:live_sklad/stepperScreen/widget.dart';
import 'package:live_sklad/utils.dart';

import '../../../apiData.dart';
import '../../../styles.dart';
import 'bloc.dart';


class MultiChoiceStep<T> extends StatefulWidget {

  MultiChoiceStep({
    this.info,
    this.valueCallBack,
    this.search,
    this.addMethod,
    this.getTitle,
    this.isDictPermission,
    this.valueFactory,
    this.equals,
    this.searchValueFactory,
    this.getClearValue,
    this.isClose,
  });

  final bool isClose;
  final FieldInfo info;
  final T Function(String value) searchValueFactory;
  final Function(FieldInfo info) valueCallBack;
  final bool Function(T value1, T value2) equals;
  final Future<List<T>> Function(String text, int page, int pageSize) search;
  final Future<T> Function(String name) addMethod;
  final String Function(T) getTitle;
  final bool isDictPermission;
  final T Function(T) getClearValue;
  final T Function(dynamic value) valueFactory;

  @override
  createState() => _MultiChoiceStepState(
    info: info,
    valueCallBack: valueCallBack,
    search: search,
    addMethod: addMethod,
    getTitle: getTitle,
    isDictPermission: isDictPermission,
    valueFactory: valueFactory,
    equals: equals,
    searchValueFactory: searchValueFactory,
    getClearValue: getClearValue,
  );

}

class _MultiChoiceStepState<T> extends State<MultiChoiceStep> {

  _MultiChoiceStepState({
    this.info,
    this.valueCallBack,
    this.search,
    this.addMethod,
    this.getTitle,
    this.isDictPermission,
    this.valueFactory,
    this.equals,
    this.searchValueFactory,
    this.getClearValue,
  });

  final FieldInfo info;
  final T Function(String value) searchValueFactory;
  final Function(FieldInfo info) valueCallBack;
  final bool Function(T value1, T value2) equals;
  final Future<List<T>> Function(String text, int page, int pageSize) search;
  final Future<T> Function(String name) addMethod;
  final T Function(T) getClearValue;
  final bool isDictPermission;
  final T Function(dynamic value) valueFactory;
  final String Function(T) getTitle;

  ScrollController _controller;
  bool _isScroll = false;
  bool _isFocusInit = false;
  bool _isKeyboardShow = false;
  bool _isFirst = true;

  int _keyboardId;

  FocusNode _focusNode;
  FocusNode _focusNodeUnUse;

  final KeyboardVisibilityNotification _visibilityNotification = KeyboardVisibilityNotification();

  MultiChoiceStepBloc<T> _bloc;

  @override
  void initState() {
    _bloc = MultiChoiceStepBloc<T>(
      info: info,
      valueCallBack: valueCallBack,
      search: search,
      addMethod: addMethod,
      valueFactory: valueFactory,
      equals: equals,
      searchValueFactory: searchValueFactory
    );
    _focusNode = FocusNode();
    _focusNodeUnUse = FocusNode();
    _controller = ScrollController()..addListener(() {
      _isScroll = true;
      FocusScope.of(context).requestFocus(_focusNodeUnUse);
    });
    _focusNode.addListener(() {
      if (_isFirst) {
        _isFirst = false;
        _isKeyboardShow = !_isKeyboardShow;
        return;
      }
      if (!_isScroll && _isKeyboardShow) {
        _bloc.onAddItem();
        _isScroll = false;
        FocusScope.of(context).requestFocus(_focusNode);
      }
      _isKeyboardShow = !_isKeyboardShow;
      if (_isScroll) _isScroll = false;
    });
    _keyboardId = _visibilityNotification.addNewListener(
      onHide: () {
        if (!_isScroll && _isKeyboardShow) {
          _bloc.onAddItem();
        }
        _isScroll = false;
        _isKeyboardShow = false;
      },
      onShow: () {
        _isKeyboardShow = true;
      },
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!_isFocusInit) {
      FocusScope.of(context).requestFocus(_focusNode);
      _isFocusInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(MultiChoiceStep<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isClose) _bloc.onAddItem();
    if (oldWidget.info != widget.info) {
      _bloc = MultiChoiceStepBloc<T>(
          info: (widget as MultiChoiceStep<T>).info,
          valueCallBack: (widget as MultiChoiceStep<T>).valueCallBack,
          search: (widget as MultiChoiceStep<T>).search,
          addMethod: (widget as MultiChoiceStep<T>).addMethod,
          valueFactory: (widget as MultiChoiceStep<T>).valueFactory,
          equals: (widget as MultiChoiceStep<T>).equals,
          searchValueFactory: (widget as MultiChoiceStep<T>).searchValueFactory
      );
    }
  }

  @override
  void dispose() {
    _bloc.onAddItem();
    _controller.dispose();
    _visibilityNotification.removeListener(_keyboardId);
//    _focusNode.dispose();
//    _focusNodeUnUse.dispose();
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _bloc.stream,
      initialData: MultiChoiceState<T>(
        selectedItems: widget.info.value,
        isAddNewString: null,
        isCanAddInDict: false,
        items: []
      ),
      builder: (_, AsyncSnapshot<MultiChoiceState<T>> snapshot) =>
        Column(
          children: [
            Padding(
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      focusNode: _focusNode,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(
                          fontSize: 18,
                          color: StyleColor.text,
                          fontFamily: 'Regular'
                      ),
                      decoration: InputDecoration(
                        hintText: 'Введите значение',
                        contentPadding: EdgeInsets.all(10),
                        fillColor: StyleColor.field,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          borderSide: BorderSide(
                              width: 3, color: StyleColor.lightGrey
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          borderSide: BorderSide(
                              width: 2, color: StyleColor.blue2
                          ),
                        ),
                      ),
                      onChanged: _bloc.onSearch,
                      controller: TextEditingController()..value = TextEditingValue(
                        selection: TextSelection.fromPosition(TextPosition(
                            offset: snapshot.data.search is String ?
                            snapshot.data.search.toString().length : 0)),
                        text: snapshot.data.search is String ? snapshot.data.search : '',
                      ),
                    ),
                  ),
                  Padding(
                    child: getIconButton(
                        onTap: snapshot.data.search != null && snapshot.data.search.length > 0
                            ? _bloc.onAddItem : null,
                        icon: AppIcons.PLUS,
                        color: (snapshot.data.search != null && snapshot.data.search.length > 0)  ?
                        StyleColor.blue2 : StyleColor.lightGrey
                    ),
                    padding: EdgeInsets.all(9),
                  ),
                ],
              ),
              padding: EdgeInsets.only(left: 19, top: 10, bottom: 10, right: 10),
            ),
            snapshot.data.selectedItems != null && snapshot.data.selectedItems.length > 0
                ? Padding(
              padding: EdgeInsets.only(left: 19, bottom: 10, right: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      direction: Axis.horizontal,
                      children: snapshot.data.selectedItems
                          .map((e) =>
                          Container(
                            decoration: BoxDecoration(
                                color: StyleColor.light,
                                borderRadius: BorderRadius.all(Radius.circular(5))
                            ),
                            padding: EdgeInsets.all(3),
                            margin: EdgeInsets.all(3),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(getTitle(e), style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Regular',
                                  fontSize: 18,
                                ),),
                                Container(width: 5,),
                                getIconButton(
                                    color: StyleColor.description,
                                    icon: AppIcons.CLOSE,
                                    onTap: (){
                                      _bloc.onItemDelete(e);
                                    }
                                ),
                              ],
                            ),
                          )).toList(),
                    ),
                  )
                ],
              ),
            )
                : Container(),
            snapshot.data.isAddNewString != null
                ? Row(
                  children: [
                    Container(
                      child: Text('Значение "${snapshot.data.isAddNewString}" добавлено в стравочник.',
                        style: TextStyle(
                          color: StyleColor.green,
                          fontFamily: 'Regular',
                          fontSize: 15,
                        ),),
                      padding: EdgeInsets.only(left: 19),
                    )
                  ],
                )
                : Container(),
            snapshot.data.isCanAddInDict
                ? Row(
                  children: [
                    Flexible(
                      child: Container(
                        child: Text('По запросу "${snapshot.data.search}" ничего не найдено. '
                            '${isDictPermission
                            || ((snapshot.data.selectedItems != null &&
                              snapshot.data.selectedItems.length > 0)
                            || !info.isRequired)? 'Вы можете ' : ''}'
                            '${isDictPermission ? 'добавить значение в справочник' : ''}'
                            '${isDictPermission && ((snapshot.data.selectedItems != null &&
                            snapshot.data.selectedItems.length > 0)
                            || !info.isRequired) ? ' или ' : ''}'
                            '${((snapshot.data.selectedItems != null &&
                            snapshot.data.selectedItems.length > 0)
                            || !info.isRequired) ? 'продолжить создание заказа по кнопке "Далее"' : ''}'
                            '.',
                          style: TextStyle(
                            color: StyleColor.grey1,
                            fontFamily: 'Regular',
                            fontSize: 15,
                          ),
                        ),
                        padding: EdgeInsets.only(left: 19),
                      ),
                    )
                  ],
                )
                : Container(),
            snapshot.data.isCanAddInDict
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ClipRRect(
                      child: Padding(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _bloc.onAddDict,
                            child: Text('+ Добавить в справочник ${snapshot.data.search}',
                              style: TextStyle(
                                color: StyleColor.blue1,
                                fontSize: 16,
                                fontFamily: 'Medium',
                              ),),
                          ),
                        ),
                        padding: EdgeInsets.all(10),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    )
                  ],
                )
                : Container(),
            Expanded(
              child: Container(
                child: ListView.builder(
                  controller: _controller,
                  itemCount: snapshot.data.items.length,
                  itemBuilder: (_, index) => Row(
                    children: [
                      Flexible(
                        child: getSearchItem(
                          title: getTitle(snapshot.data.items[index]),
                          onTap: () {
                            _bloc.onItemSelect(getClearValue(snapshot.data.items[index]));
                          }
                        ),
                      ),
                      Padding(
                        child: getIconButton(
                            onTap: (){
                              _bloc.onItemSelect(getClearValue(snapshot.data.items[index]));
                            },
                            icon: AppIcons.PLUS,
                            color: StyleColor.blue2
                        ),
                        padding: EdgeInsets.only(right: 19),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        )
    );
  }

}