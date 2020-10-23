
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:live_sklad/stepperScreen/widget.dart';
import 'package:live_sklad/utils.dart';
import '../../../apiData.dart';
import '../../../styles.dart';

class BoolField extends StatefulWidget {

  BoolField({
    this.info,
    this.valueCallBack,
  });

  final FieldInfo info;
  final Function(FieldInfo info) valueCallBack;

  @override
  createState() => BoolStepField();

}

class BoolStepField extends State<BoolField> {

  bool _value = false;

  final TextStyle _titleStyle = TextStyle(
    fontFamily: 'Regular',
    fontSize: 18,
    color: Colors.black,
  );
  final TextStyle _titleReqStyle = TextStyle(
    fontFamily: 'Regular',
    fontSize: 18,
    color: Colors.black,
  );
  final TextStyle _hintStyle = TextStyle(
    fontFamily: 'Regular',
    fontSize: 18,
    color: StyleColor.description,
  );

  @override
  void initState() {
    setState(() {
      _value = _getValue();
    });
    super.initState();
  }

  @override
  void didUpdateWidget(BoolField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.info.id != widget.info.id) {
      setState(() {
        _value = _getValue();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
      child: Column(
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(widget.info.description, style: widget.info.isBlock ? _hintStyle : _titleStyle,),
                    Text(widget.info.isRequired ? '*' : '', style: _titleReqStyle,)
                  ],
                ),
                Switch(
                  value: _value,
                  onChanged: widget.info.isBlock ? null : (bool) {
                  setState(() {
                    _value = bool;
                    widget.valueCallBack(FieldInfo(
                      id: widget.info.id,
                      value: _value,
                      isOnlyDictionary: widget.info.isOnlyDictionary,
                      isBlock: widget.info.isBlock,
                      isRequired: widget.info.isRequired,
                      defaultValue: widget.info.defaultValue,
                      items: widget.info.items,
                      name: widget.info.name,
                      dataType: widget.info.dataType,
                    ));
                  });
                },)
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _getValue() {
    if (widget.info.value != null && widget.info.value is bool) {
      return widget.info.value;
    }
    if (widget.info.defaultValue != null && widget.info.defaultValue is bool) {
      return widget.info.defaultValue;
    }
    return false;
  }

}
