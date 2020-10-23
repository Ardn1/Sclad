import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
import 'package:live_sklad/styles.dart';

import '../../../apiData.dart';

class DateTimeChoiceStep extends StatefulWidget {

  DateTimeChoiceStep({
    this.info,
    this.valueCallBack,
    this.type,
  });

  final FieldInfo info;
  final DateType type;
  final Function(FieldInfo info) valueCallBack;

  @override
  State<StatefulWidget> createState() => _DateTimeChoiceStepState();
}

class _DateTimeChoiceStepState extends State<DateTimeChoiceStep> {

  DateTime _firstDate;
  DateTime _lastDate;

  DateTimeState _state;

  @override
  void initState() {
    super.initState();

    DateTime val = _getDefaultValue();

    _state =  DateTimeState(
      selectDate: val,
      selected: Selected.HOUR,
      hour: widget.type == DateType.DATE_TIME ? val.hour : null,
      minute: widget.type == DateType.DATE_TIME ? val.minute : null,
      sliderValue: widget.type == DateType.DATE_TIME ? val.hour.toDouble() : null
    );

    _firstDate = DateTime.now().subtract(Duration(days: 9999));
    _lastDate = DateTime.now().add(Duration(days: 9999));
  }


  @override
  void didUpdateWidget(DateTimeChoiceStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.info.id != widget.info.id) {
      setState(() {
        DateTime val = _getDefaultValue();
        _state =  DateTimeState(
            selectDate: val,
            selected: Selected.HOUR,
            hour: widget.type == DateType.DATE_TIME ? val.hour : null,
            minute: widget.type == DateType.DATE_TIME ? val.minute : null,
            sliderValue: widget.type == DateType.DATE_TIME ? val.hour.toDouble() : null
        );
      });
    }
  }

  DateTime _getDefaultValue () {
    print(widget.info.value);
    if (widget.info.value != null) {
      if (widget.info.value is String) {
        if (widget.info.value is String) {
          if ((widget.info.value as String).contains('after;')) {
            return DateTime.now().add(Duration(
              days: int.parse((widget.info.value as String).split(';')[1]),
              hours: int.parse((widget.info.value as String).split(';')[2]),
              minutes: int.parse((widget.info.value as String).split(';')[3]),
            ));
          } else if ((widget.info.value as String).contains('afterintime;')) {
            var date = DateTime.now().add(Duration(days: int.parse((widget.info.value as String).split(';')[1])));
            return DateTime(
              date.year,
              date.month,
              date.day,
              int.parse((widget.info.value as String).split(';')[2]),
              int.parse((widget.info.value as String).split(';')[3]),
            );
          } else return _parseDateTime(widget.info.value);
        }
      } else {
        return DateTime.fromMillisecondsSinceEpoch(widget.info.value);
      }
    }
    if (widget.info.defaultValue != null) {
      if (widget.info.defaultValue is String) {
        if ((widget.info.defaultValue as String).contains('after;')) {
          return DateTime.now().add(Duration(
            days: int.parse((widget.info.defaultValue as String).split(';')[1]),
            hours: int.parse((widget.info.defaultValue as String).split(';')[2]),
            minutes: int.parse((widget.info.defaultValue as String).split(';')[3]),
          ));
        } else if ((widget.info.defaultValue as String).contains('afterintime;')) {
          var date = DateTime.now().add(Duration(days: int.parse((widget.info.defaultValue as String).split(';')[1])));
          return DateTime(
            date.year,
            date.month,
            date.day,
            int.parse((widget.info.defaultValue as String).split(';')[2]),
            int.parse((widget.info.defaultValue as String).split(';')[3]),
          );
        } else return _parseDateTime(widget.info.defaultValue);
      }
      else {
        return DateTime.fromMillisecondsSinceEpoch(widget.info.defaultValue);
      }
    }
    return DateTime.now();
  }

  DateTime _parseDateTime (String text) => DateTime(
    int.parse(text.split('T')[0].split('-')[0]),
    int.parse(text.split('T')[0].split('-')[1]),
    int.parse(text.split('T')[0].split('-')[2]),
    int.parse(text.split('T')[1].split(':')[0]),
    int.parse(text.split('T')[1].split(':')[1]),
  );

  _notify() {
    widget.valueCallBack(FieldInfo(
      id: widget.info.id,
      value: _state.selectDate.millisecondsSinceEpoch,
      isOnlyDictionary: widget.info.isOnlyDictionary,
      isBlock: widget.info.isBlock,
      isRequired: widget.info.isRequired,
      defaultValue: widget.info.defaultValue,
      items: widget.info.items,
      name: widget.info.name,
      dataType: widget.info.dataType,
    ));
  }

  @override
  Widget build(BuildContext context) {

    dp.DatePickerStyles styles = dp.DatePickerRangeStyles(
      selectedDateStyle: Theme.of(context).accentTextTheme.bodyText1.copyWith(
        color: StyleColor.white,
        fontFamily: 'Regular',
        fontSize: 20,
      ),
      selectedSingleDateDecoration: BoxDecoration(
        color: StyleColor.blue2,
        shape: BoxShape.circle,
      ),
      defaultDateTextStyle: TextStyle(
        color: Colors.black,
        fontFamily: 'Regular',
        fontSize: 17,
      ),
      displayedPeriodTitle: TextStyle(
        color: StyleColor.grey1,
        fontFamily: 'Regular',
        fontSize: 22,
      ),
      dayHeaderStyleBuilder: (index) => dp.DayHeaderStyle(
          textStyle: TextStyle(
            color: StyleColor.lightGrey,
            fontFamily: 'Regular',
            fontSize: 18,
          )
      )
    );
    return ListView(
      children: [
        Row(
          children: [
            Expanded(
              child: dp.DayPicker(
                selectedDate: _state.selectDate,
                onChanged: _onSelectedDateChanged,
                firstDate: _firstDate,
                lastDate: _lastDate,
                datePickerStyles: styles,
              ),
            )
          ],
        ),
        _state.hour != null ? Container(
          margin: EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                child: Container(
                  child: Text(_state.hour.toString().length < 2
                      ? '0${_state.hour.toString()}' : _state.hour.toString(), style: TextStyle(
                      fontFamily: _state.selected == Selected.HOUR ? 'Medium' : 'Regular',
                      fontSize: _state.selected == Selected.HOUR ? 22 : 20,
                      color: _state.selected == Selected.HOUR ? StyleColor.white : Colors.black
                  ),),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: _state.selected == Selected.HOUR ? StyleColor.blue2 : Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(5))
                  ),
                ),
                onTap: () {
                  setState(() {
                    _state.selected = Selected.HOUR;
                    _state.sliderValue = _state.hour.toDouble();
                  });
                },
              ),
              Text(' : ', style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Medium',
                  fontSize: 22
              ),),
              GestureDetector(
                child: Container(
                  child: Text(_state.minute.toString().length < 2
                      ? '0${_state.minute.toString()}' : _state.minute.toString(), style: TextStyle(
                      fontFamily: _state.selected == Selected.MINUTE ? 'Medium' : 'Regular',
                      fontSize: _state.selected == Selected.MINUTE ? 22 : 20,
                      color: _state.selected == Selected.MINUTE ? StyleColor.white : Colors.black
                  ),),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: _state.selected == Selected.MINUTE ? StyleColor.blue2 : Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(5))
                  ),
                ),
                onTap: () {
                  setState(() {
                    _state.selected = Selected.MINUTE;
                    _state.sliderValue = _state.minute.toDouble();
                  });
                },
              ),
            ],
          ),
        ) : Container(),
        _state.hour != null ? Slider(
            value: _state.sliderValue,
            min: 0,
            max: _state.selected == Selected.HOUR ? 23 : 59,
            divisions: _state.selected == Selected.HOUR ? 23 : 59,
            activeColor: StyleColor.blue1,
            inactiveColor: StyleColor.lightGrey,
            onChanged: (double newValue) {
              setState(() {
                _state.sliderValue = newValue;
                _state.selected == Selected.HOUR
                    ? _state.hour = _state.sliderValue.floor()
                    : _state.minute = _state.sliderValue.floor();
                _state.selectDate = DateTime(
                    _state.selectDate.year,
                    _state.selectDate.month,
                    _state.selectDate.day,
                    _state.hour,
                    _state.minute
                );
                _notify();
              });
            },
            semanticFormatterCallback: (double newValue) {
              return '${newValue.round()}';
            }
        ) : Container(),
      ],
    );
  }

  void _onSelectedDateChanged(DateTime newDate) {
    setState(() {
      _state.selectDate = newDate.add(Duration(
        hours: _state.hour != null ? _state.hour : 0,
        minutes: _state.minute != null ? _state.minute : 0,
      ));
      _notify();
    });
  }

}

class DateTimeState {
  
  DateTime selectDate;
  double sliderValue;
  int hour;
  int minute;
  Selected selected;
  DateTimeState({this.hour, this.minute, this.selectDate, this.sliderValue, this.selected});

}

enum Selected {
  HOUR, MINUTE
}

enum DateType {
  DATE,
  DATE_TIME,
}



