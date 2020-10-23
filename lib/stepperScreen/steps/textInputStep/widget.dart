
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import '../../../apiData.dart';
import '../../../styles.dart';

class TextInputStep extends StatefulWidget {

  TextInputStep({
    this.info,
    this.valueCallBack,
    this.type,
  });

  final FieldInfo info;
  final TextStepType type;
  final Function(FieldInfo info) valueCallBack;

  @override
  createState() => TextInputStepState();

}

class TextInputStepState extends State<TextInputStep> {

  FocusNode _focusNode;
  bool _isFocusInit = false;
  String _text;

  @override
  void initState() {
    _focusNode = FocusNode();
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
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 19, right: 19),
      child: TextField(
        keyboardType: TextInputType.number,
        focusNode: _focusNode,
        inputFormatters: _getFormaters(),
        textAlignVertical: TextAlignVertical.center,
        minLines: widget.type == TextStepType.TEXT ? 10 : 1,
        maxLines: widget.type == TextStepType.TEXT ? 10 : 1,
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
        onChanged: widget.type != TextStepType.MONEY ? (text) {
          dynamic res = text;

          print(text);
          print(_text);
          widget.valueCallBack(FieldInfo(
            id: widget.info.id,
            value: res,
            isOnlyDictionary: widget.info.isOnlyDictionary,
            isBlock: widget.info.isBlock,
            isRequired: widget.info.isRequired,
            defaultValue: widget.info.defaultValue,
            items: widget.info.items,
            name: widget.info.name,
            dataType: widget.info.dataType,
          ));
          _text = text;
        } : null,
        controller: _getController(),
      ),
    );
  }

  dynamic _getDefaultValue() {
    if (widget.info.value != null) {
      return widget.info.value.toString();
    }
    if (widget.info.defaultValue != null) {
      return widget.info.defaultValue.toString();
    }
    return null;
  }

  _getController() {
    return TextEditingController()..value = TextEditingValue(
      selection: TextSelection.fromPosition(TextPosition(
          offset: _getDefaultValue() is String ?
          _getDefaultValue().length : 0)),
      text: _getDefaultValue() is String ? _getDefaultValue() : '',
    );
  }

  List<TextInputFormatter> _getFormaters () {
    if (widget.type == TextStepType.NUMBER) return [
      WhitelistingTextInputFormatter.digitsOnly,
    ];
    if (widget.type == TextStepType.MONEY) return [
      MoneyInputFormatter(
        onValueChange: (val) {
          var res;
          if (val % 1 == 0) {
            res = val.toInt();
          } else res = val;
          widget.valueCallBack(FieldInfo(
            id: widget.info.id,
            value: res == 0 ? '' : res,
            isOnlyDictionary: widget.info.isOnlyDictionary,
            isBlock: widget.info.isBlock,
            isRequired: widget.info.isRequired,
            defaultValue: widget.info.defaultValue,
            items: widget.info.items,
            name: widget.info.name,
            dataType: widget.info.dataType,
          ));
        }
      ),
    ];
    else return [];
  }


}

enum TextStepType {
  TEXT,
  STRING,
  MONEY,
  NUMBER,
}
