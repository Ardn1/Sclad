
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../apiData.dart';
import '../../../styles.dart';

class DateTimeField extends StatelessWidget {

  DateTimeField({
    this.onTap,
    this.info,
    this.isTimeOn,
    this.valueCallBack,
  });

  final FieldInfo info;
  final Function onTap;
  final bool isTimeOn;
  final Function(FieldInfo info) valueCallBack;

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

  DateTime _getDefaultValue () {
    if (info.value != null) {
      if (info.value is String) {
        if ((info.value as String).contains('after;')) {
          return DateTime.now().add(Duration(
            days: int.parse((info.value as String).split(';')[1]),
            hours: int.parse((info.value as String).split(';')[2]),
            minutes: int.parse((info.value as String).split(';')[3]),
          ));
        } else if ((info.value as String).contains('afterintime;')) {
          var date = DateTime.now().add(Duration(days: int.parse((info.value as String).split(';')[1])));
          return DateTime(
            date.year,
            date.month,
            date.day,
            int.parse((info.value as String).split(';')[2]),
            int.parse((info.value as String).split(';')[3]),
          );
        } else return _parseDateTime(info.value);
      } else {
        return DateTime.fromMillisecondsSinceEpoch(info.value);
      }
    }
    if (!info.isBlock) {
      if (info.defaultValue != null) {
        if (info.defaultValue is String) {
          if ((info.defaultValue as String).contains('after;')) {
            return DateTime.now().add(Duration(
              days: int.parse((info.defaultValue as String).split(';')[1]),
              hours: int.parse((info.defaultValue as String).split(';')[2]),
              minutes: int.parse((info.defaultValue as String).split(';')[3]),
            ));
          } else if ((info.defaultValue as String).contains('afterintime;')) {
            var date = DateTime.now().add(Duration(days: int.parse((info.defaultValue as String).split(';')[1])));
            return DateTime(
              date.year,
              date.month,
              date.day,
              int.parse((info.defaultValue as String).split(';')[2]),
              int.parse((info.defaultValue as String).split(';')[3]),
            );
          } else return _parseDateTime(info.defaultValue);
        }
        else {
          return DateTime.fromMillisecondsSinceEpoch(info.defaultValue);
        }
      }
    }
    return null;
  }

  DateTime _parseDateTime (String text) => DateTime(
    int.parse(text.split('T')[0].split('-')[0]),
    int.parse(text.split('T')[0].split('-')[1]),
    int.parse(text.split('T')[0].split('-')[2]),
    int.parse(text.split('T')[1].split(':')[0]),
    int.parse(text.split('T')[1].split(':')[1]),
  );

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = _getDefaultValue();
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
                  Text(dateTime != null
                      ? '${dateTime.day<10?'0${dateTime.day}':dateTime.day}.'
                      '${dateTime.month<10?'0${dateTime.month}':dateTime.month}.${dateTime.year}'
                      '${isTimeOn ? ' ${dateTime.hour<10?'0${dateTime.hour}':dateTime.hour}' : ''}'
                      '${isTimeOn ? ':':''}${isTimeOn ? ''
                      '${dateTime.minute<10?'0${dateTime.minute}':dateTime.minute}' : ''}'
                      : 'Выберите дату',
                    style: dateTime != null
                        ? info.isBlock ? _hintStyle : _valueStyle
                        : _hintStyle,),
                  Icon(Icons.calendar_today, color: info.isBlock ? StyleColor.description : Colors.black,),
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