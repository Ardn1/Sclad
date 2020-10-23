
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:live_sklad/stepperScreen/widget.dart';
import 'package:live_sklad/utils.dart';

import '../../../apiData.dart';
import '../../../styles.dart';
import 'bloc.dart';


class SingleChoiceStep<T> extends StatefulWidget {

  SingleChoiceStep({
    this.info,
    this.isOnlyDict,
    this.valueCallBack,
    this.search,
    this.addMethod,
    this.getTitle,
    this.isDictPermission,
    this.valueFactory,
    this.getClearValue,
  });

  final FieldInfo info;
  final Function(FieldInfo info) valueCallBack;
  final bool isOnlyDict;
  final Future<List<T>> Function(String text, int page, int pageSize) search;
  final Future<T> Function(String name) addMethod;
  final String Function(T) getTitle;
  final T Function(T) getClearValue;
  final bool isDictPermission;
  final T Function(Map json) valueFactory;

  @override
  createState() => _SingleChoiceStepState(
    info: info,
    valueCallBack: valueCallBack,
    search: search,
    addMethod: addMethod,
    getTitle: getTitle,
    isOnlyDict: isOnlyDict,
    isDictPermission: isDictPermission,
    valueFactory: valueFactory,
    getClearValue: getClearValue,
  );

}

class _SingleChoiceStepState<T> extends State<SingleChoiceStep> {

  _SingleChoiceStepState({
    this.info,
    this.isOnlyDict,
    this.valueCallBack,
    this.search,
    this.addMethod,
    this.getTitle,
    this.isDictPermission,
    this.valueFactory,
    this.getClearValue,
  });

  final FieldInfo info;
  final Function(FieldInfo info) valueCallBack;
  final bool isOnlyDict;
  final Future<List<T>> Function(String text, int page, int pageSize) search;
  final Future<T> Function(String name) addMethod;
  final String Function(T) getTitle;
  final T Function(T) getClearValue;
  final bool isDictPermission;
  final T Function(Map json) valueFactory;

  SingleChoiceStepBloc<T> _bloc;

  ScrollController _controller;
  bool _isFocusInit = false;
  bool _isClear = false;

  FocusNode _focusNode;
  FocusNode _focusNodeUnUse;

  bool _isScroll = false;
  bool _isKeyboardShow = true;
  int _keyboardId;
  final KeyboardVisibilityNotification _visibilityNotification = KeyboardVisibilityNotification();

  @override
  void initState() {
    _bloc = SingleChoiceStepBloc<T>(
      getClearValue: getClearValue,
      info: info,
      valueCallBack: valueCallBack,
      search: search,
      addMethod: addMethod,
      isOnlyDict: isOnlyDict,
      valueFactory: valueFactory,
      getTitle: getTitle,
    );
    _focusNode = FocusNode();
    _focusNodeUnUse = FocusNode();
    _controller = ScrollController()..addListener(_scrollListener);
    _keyboardId = _visibilityNotification.addNewListener(
      onHide: () {
        if (!_isScroll && _isKeyboardShow) {
          _bloc.onKeyboardHide();
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

  _scrollListener () {
    _isScroll = true;
    FocusScope.of(context).requestFocus(FocusNode());
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
  void didUpdateWidget(SingleChoiceStep<T> oldWidget) {
    if (oldWidget.info.id != widget.info.id) {
      _bloc = SingleChoiceStepBloc<T>(
        info: (widget as SingleChoiceStep<T>).info,
        valueCallBack: (widget as SingleChoiceStep<T>).valueCallBack,
        search: (widget as SingleChoiceStep<T>).search,
        addMethod: (widget as SingleChoiceStep<T>).addMethod,
        isOnlyDict: (widget as SingleChoiceStep<T>).isOnlyDict,
        valueFactory: (widget as SingleChoiceStep<T>).valueFactory,
      );
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _visibilityNotification.removeListener(_keyboardId);
    _visibilityNotification.dispose();
    _controller.removeListener(_scrollListener);
    _controller.dispose();
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _bloc.stream,
      initialData: SingleChoiceState<T>(
        selected: widget.info.value,
        isAddNewString: null,
        isCanAddInDict: false,
        items: []
      ),
      builder: (_, AsyncSnapshot<SingleChoiceState<T>> snapshot) {
        if (snapshot.data.selected == null && _isClear) {
          FocusScope.of(context).requestFocus(_focusNode);
          _isClear = false;
        }
        return Column(
          children: [
            (snapshot.data.selected == null || snapshot.data.selected is String)
                ? Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 19, right: 19),
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
                      offset: snapshot.data.selected is String ?
                      snapshot.data.selected.toString().length : 0)),
                  text: snapshot.data.selected is String ? snapshot.data.selected : '',
                ),
              ),
            )
                : Padding(
              child: Container(
                height: 48,
                padding: EdgeInsets.only(
                  top: 5,
                  bottom: 5,
                  right: 15,
                  left: 15,
                ),
                decoration: BoxDecoration(
                    color: StyleColor.disabled,
                    border: Border.all(color: StyleColor.disabledStroke, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(5))
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        child: Text(getTitle(snapshot.data.selected as T),
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Regular',
                            fontSize: 18,
                          ),),
                      ),
                    ),
                    getIconButton(
                      color: StyleColor.red1,
                      onTap: () {
                        _bloc.onClear();
                        _isClear = true;
                      },
                      icon: AppIcons.CLOSE,
                    )
                  ],
                ),
              ),
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 19, right: 19),
            ),
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
                    child: Text('По запросу "${snapshot.data.selected}" ничего не найдено. '
                        '${isDictPermission || !isOnlyDict ? 'Вы можете ' : ''}'
                        '${isDictPermission ? 'добавить значение в справочник' : ''}'
                        '${isDictPermission && !isOnlyDict ? ' или ' : ''}'
                        '${!isOnlyDict ? 'продолжить создание заказа по кнопке "Далее"' : ''}'
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
                        child: Text('+ Добавить в справочник ${snapshot.data.selected}',
                          style: TextStyle(
                            color: StyleColor.blue1,
                            fontSize: 16,
                            fontFamily: 'Medium',
                          ),),
                      ),
                    ),
                    padding: EdgeInsets.only(top: 10, bottom: 10, left: 19, right: 19),
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
                  itemBuilder: (_, index) => getSearchItem(
                      title: getTitle(snapshot.data.items[index]),
                      onTap: (){
                        FocusScope.of(context).requestFocus(_focusNodeUnUse);
                        _bloc.onItemSelect(getClearValue(snapshot.data.items[index]));
                      }
                  ),
                ),
              ),
            )
          ],
        );
      }
    );
  }

}