import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_multi_formatter/formatters/money_input_formatter.dart';
import 'package:live_sklad/apiData.dart';
import 'package:live_sklad/stepperScreen/steps/textInputStep/widget.dart';

import '../../../styles.dart';

class TextInputField extends StatelessWidget {

  TextInputField({
    @required this.info,
    @required this.valueCallback,
    @required this.type,
  });

  final FieldInfo info;
  final TextInputFieldType type;
  final Function(FieldInfo info) valueCallback;

  final TextStyle _titleStyle = TextStyle(
    fontFamily: 'Regular',
    fontSize: 15,
    color: StyleColor.grey1,
  );
  final TextStyle _titleReqStyle = TextStyle(
    fontFamily: 'Regular',
    fontSize: 15,
    color: StyleColor.red1,
  );
  final TextStyle _valueStyle = TextStyle(
    fontFamily: 'Regular',
    fontSize: 18,
    color: Colors.black,
  );
  final TextStyle _hintStyle = TextStyle(
    fontFamily: 'Regular',
    fontSize: 18,
    color: StyleColor.description,
  );
  final TextStyle _errorStyle = TextStyle(
    fontFamily: 'Regular',
    fontSize: 16,
    color: StyleColor.red1,
  );

  final MoneyMaskedTextController _controller = MoneyMaskedTextController(
    decimalSeparator: '.',
    thousandSeparator: ',',
  );

  _getController(String value) {
    return TextEditingController()..value = TextEditingValue(
      selection: TextSelection.fromPosition(TextPosition(
          offset: value is String ?
          value.length : 0)),
      text: value is String ? value : '',
    );
  }

  List<TextInputFormatter> _getFormaters() {
    if (type == TextInputFieldType.NUMBER) return [
      WhitelistingTextInputFormatter.digitsOnly,
    ];
    if (type == TextInputFieldType.MONEY) return [
      MoneyInputFormatter(onValueChange: (val) {
        var res;
        if (val % 1 == 0) {
          res = val.toInt();
        } else res = val;
        valueCallback(FieldInfo(
          id: info.id,
          value: res == 0 ? '' : res,
          isOnlyDictionary: info.isOnlyDictionary,
          isBlock: info.isBlock,
          isRequired: info.isRequired,
          defaultValue: info.defaultValue,
          items: info.items,
          name: info.name,
          dataType: info.dataType,
        ));
      }),
    ];
    else return [];
  }

  dynamic _getValue(dynamic text) {
    switch (type) {
      case TextInputFieldType.NUMBER: return text is int ? text : int.parse(text);
      case TextInputFieldType.MONEY:
        return text is String ? double.parse(text.replaceAll(',', '')) : text;
      default: return text;
    }
  }

  @override
  Widget build(BuildContext context) {

    dynamic value = info.value != null
        ? _getValue(info.value)
        : info.defaultValue != null && !info.isBlock
        ? _getValue(info.defaultValue)
        : '';

    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          info.description != null ? Container(
            margin: EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                Text(info.description, style: _titleStyle,),
                Text(info.isRequired ? '*' : '', style: _titleReqStyle,)
              ],
            ),
          ) : Container(),
          Container(
            height: type == TextInputFieldType.TEXT ? null : 48,
            decoration: BoxDecoration(
                color: info.isBlock
                    ? StyleColor.disabled
                    : StyleColor.field,
                border: Border.all(
                  color: info.errorMessage != null
                      ? StyleColor.red1
                      : StyleColor.disabledStroke,
                  width: 2,
                ),
                borderRadius: BorderRadius.all(Radius.circular(5))
            ),
            padding: info.isBlock ? EdgeInsets.all(10) : EdgeInsets.only(bottom: 5),
            child: info.isBlock
                ? Row(children: [
                    Expanded(
                      child: Text(value.toString().length == 0
                          ? 'Введите значение'
                          : value.toString(), style: info.isBlock ? _hintStyle : _valueStyle,),
                    )
                  ],)
                : TextField(
                    minLines: type == TextInputFieldType.TEXT ? 6 : 1,
                    maxLines: type == TextInputFieldType.TEXT ? 6 : 1,
                    style: _valueStyle,
                    decoration: InputDecoration(
                      hintText: 'Введите заначение',
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.all(10),
                      hintStyle: TextStyle(
                          fontFamily: 'Regular',
                          fontSize: 18,
                          color: StyleColor.grey1
                      ),
                    ),
                    onChanged: info.dataType != MONEY ? _onTextChangeHandler : null,
                    controller: _getController(value.toString()),
                    inputFormatters: _getFormaters(),
                  ),
          ),
          info.errorMessage != null ? Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(info.errorMessage, style: _errorStyle,),
          ): Container(),
        ],
      ),
    );
  }

_onTextChangeHandler(String text) {
    dynamic res = text;
    if (type == TextInputFieldType.MONEY) {
      double doub = double.parse(res.replaceAll(',', ''));
      if (doub % 1 == 0) {
        res = doub.toInt();
      } else res = doub;
    } else if (type == TextInputFieldType.NUMBER) {
      res = int.parse(res);
    }
  valueCallback(FieldInfo(
    isBlock: info.isBlock,
    value: res,
    type: info.type,
    name: info.name,
    dataType: info.dataType,
    items: info.items,
    isOnlyDictionary: info.isOnlyDictionary,
    isRequired: info.isRequired,
    defaultValue: info.defaultValue,
    id: info.id,
    description: info.description,
    groupDescription: info.groupDescription,
    position: info.position,
  ));
}
  
}

enum TextInputFieldType {
  TEXT,
  STRING,
  MONEY,
  NUMBER,
}
