
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:live_sklad/stepperScreen/steps/phones/bloc.dart';
import '../../../apiData.dart';
import '../../../styles.dart';
import '../../../utils.dart';
import '../../widget.dart';

class PhonesStep extends StatefulWidget {

  PhonesStep({this.info, this.valueCallBack, this.isClose});
  final FieldInfo info;
  final Function(FieldInfo info) valueCallBack;
  final bool isClose;

  @override
  createState() => PhonesStepState();

}

class PhonesStepState extends State<PhonesStep> {

  PhonesStepBloc _bloc;
  ScrollController _controller;

  bool _isScroll = false;
  bool _isFocusInit = false;
  bool _isKeyboardShow = false;
  bool _isFirst = true;

  int _keyboardId;

  FocusNode _focusNode;
  FocusNode _focusNodeUnUse;

  MaskedTextController _maskedTextController = MaskedTextController(mask: '*0000000000000000000000');

  final KeyboardVisibilityNotification _visibilityNotification = KeyboardVisibilityNotification();


  @override
  void initState() {
    if (widget.info.defaultValue is List) {
      _maskedTextController.updateMask('${widget.info.defaultValue[0]}0000000000');
      _maskedTextController.value = TextEditingValue(
        text: widget.info.defaultValue[0],
        selection: TextSelection.fromPosition(TextPosition(
          offset: widget.info.defaultValue[0].toString().length,
        )),
      );
    }
    _maskedTextController.addListener(() {
      print(_maskedTextController.text);
      if (_maskedTextController.text.startsWith('+')) {
        if (_maskedTextController.text.startsWith('+7')) {
          if (_maskedTextController.text.length < 19)
            _maskedTextController.updateMask('+7 (000) 000-00-00', moveCursorToEnd: true);
        } else if (_maskedTextController.text.startsWith('+385')) {
          _maskedTextController.updateMask('+385 (00) 000-000', moveCursorToEnd: true);
        } else if (_maskedTextController.text.startsWith('+375')) {
          _maskedTextController.updateMask('+375 (00) 000-00-00', moveCursorToEnd: true);
        } else if (_maskedTextController.text.startsWith('+380')) {
          _maskedTextController.updateMask('+380 (00) 000-00-00', moveCursorToEnd: true);
        } else if (_maskedTextController.text.startsWith('+994')) {
          _maskedTextController.updateMask('+994 (00) 000-00-00', moveCursorToEnd: true);
        } else if (_maskedTextController.text.startsWith('+996')) {
          _maskedTextController.updateMask('+996 (000) 000000', moveCursorToEnd: true);
        } else if (_maskedTextController.text.startsWith('+998')) {
          _maskedTextController.updateMask('+998 (00) 000-0000', moveCursorToEnd: true);
        } else if (_maskedTextController.text.startsWith('+49')) {
          if (_maskedTextController.text.length < 19) {
            _maskedTextController.updateMask('+49 (000) 0000-0000', moveCursorToEnd: true);
          } else if (_maskedTextController.text.length >= 19 && _maskedTextController.text.length < 20) {
            _maskedTextController.updateMask('+49 (0000) 0000-0000', moveCursorToEnd: true);
          } else if (_maskedTextController.text.length >= 20 && _maskedTextController.text.length < 22) {
            _maskedTextController.updateMask('+49 (000000) 00-000000', moveCursorToEnd: true);
          }
        } else if (_maskedTextController.text.startsWith('+1')) {
          _maskedTextController.updateMask('+10000000000000000000000', moveCursorToEnd: true);
        } else _maskedTextController.updateMask('+0000000000000000000000', moveCursorToEnd: true);
      } else if (_maskedTextController.text.startsWith('8')) {
        _maskedTextController.updateMask('8 (000) 000-00-00', moveCursorToEnd: true);
      } else if (_maskedTextController.text.startsWith('87')) {
        _maskedTextController.updateMask('8 (700) 000-0000', moveCursorToEnd: true);
      } else if (_maskedTextController.text.startsWith('7')) {
        _maskedTextController.updateMask('700 000-0000', moveCursorToEnd: true);
      } else if (_maskedTextController.text.startsWith('349')) {
        _maskedTextController.updateMask('349 000-00-00', moveCursorToEnd: true);
      } else {
        if (_maskedTextController.text.replaceAll('-', '').length > 3
            && _maskedTextController.text.replaceAll('-', '').length <= 5) {
          _maskedTextController.updateMask('000-0000000000000000000', moveCursorToEnd: true);
        } else if (_maskedTextController.text.replaceAll('-', '').length > 5
            && _maskedTextController.text.replaceAll('-', '').length <= 6) {
          _maskedTextController.updateMask('00-00-000000000000000000', moveCursorToEnd: true);
        }  else if (_maskedTextController.text.replaceAll('-', '').length > 6
            && _maskedTextController.text.replaceAll('-', '').length <= 7) {
          _maskedTextController.updateMask('000-00-000000000000000000', moveCursorToEnd: true);
        }
        else _maskedTextController.updateMask('*0000000000000000000000', moveCursorToEnd: true);
      }
      _bloc.onSearch(_maskedTextController.text);
    });
    _focusNode = FocusNode();
    _focusNodeUnUse = FocusNode();
    _bloc = PhonesStepBloc(
        info: widget.info,
        valueCallBack: widget.valueCallBack
    );
    _controller = ScrollController()..addListener(() {
      _isScroll = true;
      FocusScope.of(context).requestFocus(_focusNodeUnUse);
      if (_controller.position.extentAfter < 300) {
        _bloc.onReachEnd();
      }
    });
    _focusNode.addListener(() {
      print('addListener  ');
      if (_isFirst) {
        _isFirst = false;
        _isKeyboardShow = !_isKeyboardShow;
        return;
      }
      if (!_isScroll && _isKeyboardShow) {
        _bloc.onPhoneAdd();
        _maskedTextController.text = '';
        _isScroll = false;
        FocusScope.of(context).requestFocus(_focusNode);
      }
      _isKeyboardShow = !_isKeyboardShow;
      if (_isScroll) _isScroll = false;
    });
    _keyboardId = _visibilityNotification.addNewListener(
      onHide: () {
        print('onHide');
        if (!_isScroll && _isKeyboardShow) {
          _bloc.onPhoneAdd();
          _maskedTextController.text = '';
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
  void didUpdateWidget(PhonesStep oldWidget) {
    if (widget.isClose) _bloc.onPhoneAdd();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _maskedTextController.dispose();
    _controller.dispose();
    _visibilityNotification.removeListener(_keyboardId);
    _focusNode.dispose();
    _focusNodeUnUse.dispose();
    _bloc.dispose();
    super.dispose();
  }

  dynamic _getInitialValue () {
    if(widget.info.value is String) {
      return widget.info.value;
    }
    if(widget.info.defaultValue is List<dynamic>) {
      return widget.info.defaultValue[0].toString();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    print('build ${widget.info.value}');
    return StreamBuilder(
      initialData: PhonesState(
        phones: widget.info.value is List<String> ? widget.info.value as List<String> : [],
        isCanAdd: false,
        counteragents: [],
        selected: _getInitialValue(),
      ),
      stream: _bloc.steam,
      builder: (_,AsyncSnapshot<PhonesState> snapshot) {
        if (snapshot.data.selected == null) _maskedTextController.text = '';
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            /** INPUT */
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 19, right: 10),
              child: snapshot.data.selected is Counteragent ?
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  border: Border.all(width: 2, color: StyleColor.lightGrey),
                  color: StyleColor.field,
                ),
                child: Row(
                  children: [
                    Flexible(
                      child: getSearchItem(
                        title: (snapshot.data.selected as Counteragent).name,
                        items: (snapshot.data.selected as Counteragent).phones,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: getIconButton(
                          onTap: _bloc.onClear,
                          icon: AppIcons.CLOSE,
                          color: StyleColor.red1
                      ),
                    )
                  ],
                ),
              ) :
              Container(
                height: 48,
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        textInputAction: TextInputAction.done,
                        focusNode: _focusNode,
                        autocorrect: false,
                        keyboardType: TextInputType.phone,
                        controller: _maskedTextController,
                        textAlignVertical: TextAlignVertical.center,
                        style: TextStyle(
                            fontSize: 18,
                            color: StyleColor.text,
                            fontFamily: 'Regular'
                        ),
                        decoration: InputDecoration(
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
                      ),
                      flex: 8,
                    ),
                    Padding(
                      child: getIconButton(
                          onTap: () {
                            _bloc.onPhoneAdd();
                            _maskedTextController.text = '';
                          },
                          icon: AppIcons.PLUS,
                          color: (snapshot.data.isCanAdd != null && snapshot.data.isCanAdd)  ?
                          StyleColor.blue2 : StyleColor.lightGrey
                      ),
                      padding: EdgeInsets.all(8),
                    ),
                  ],
                ),
              ),
            ),
            /** PHONES */
            snapshot.data.phones is List && snapshot.data.phones.length != 0
                ? Padding(
              padding: EdgeInsets.only(top: 2, bottom: 10, left: 16, right: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      direction: Axis.horizontal,
                      children: snapshot.data.phones
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
                                Text(e, style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Regular',
                                  fontSize: 18,
                                ),),
                                Container(width: 5,),
                                getIconButton(
                                  color: StyleColor.description,
                                  icon: AppIcons.CLOSE,
                                  onTap: (){
                                    _bloc.onPhoneDelete(e);
                                  }
                                ),
                              ],
                            ),
                          )).toList(),
                    ),
                  )
                ],
              ),
            ) : Container(),
            /** COUNTERAGENTS */
            Expanded(
              child: ListView.builder(
                controller: _controller,
                itemCount: snapshot.data.counteragents.length,
                itemBuilder: (_, int index) => getSearchItem(
                  title: snapshot.data.counteragents[index].name,
                  items: snapshot.data.counteragents[index].phones,
                  onTap: () {
                    Counteragent contr = snapshot.data.counteragents[index];
                    contr.name = contr.name.replaceAll(START_TAG, '')
                        .replaceAll(END_TAG, '');
                    contr.phones = contr.phones
                        .map((e) => e.replaceAll(START_TAG, '')
                        .replaceAll(END_TAG, '')).toList();
                    _bloc.onItemSelect(contr);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

}