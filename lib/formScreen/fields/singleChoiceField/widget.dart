import 'package:flutter/material.dart';
import 'package:live_sklad/apiData.dart';
import 'package:live_sklad/styles.dart';

class SingleChoiceField<T> extends StatelessWidget {

  SingleChoiceField({
    this.onTap,
    this.info,
    this.valueFactory,
  });

  final FieldInfo info;
  final Function onTap;
  final String Function(dynamic value) valueFactory;

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

  Text _getValue() {
    if (info.value != null) {
      if (info.value is String) {
        return Text(info.value, style: info.isBlock ? _hintStyle : _valueStyle,);
      } else {
        return Text(valueFactory(info.value), style: info.isBlock ? _hintStyle : _valueStyle,);
      }
    }
    if (!info.isBlock) {
      if (info.defaultValue != null) {
        if (info.defaultValue is String) {
          return Text(info.defaultValue, style: info.isBlock ? _hintStyle : _valueStyle,);
        } else {
          return Text(valueFactory(info.defaultValue), style: info.isBlock ? _hintStyle : _valueStyle,);
        }
      }
    }
    return Text('Выберите значение', style: _hintStyle,);
  }

  @override
  Widget build(BuildContext context) {
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
          GestureDetector(
            onTap: info.isBlock ? null : onTap,
            child: Container(
              height: 48,
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
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _getValue(),
                  Icon(Icons.keyboard_arrow_down, color: Colors.black,),
                ],
              ),
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

}