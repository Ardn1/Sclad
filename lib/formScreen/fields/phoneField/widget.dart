
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:live_sklad/utils.dart';

import '../../../apiData.dart';
import '../../../styles.dart';

class PhonesField extends StatefulWidget {

  PhonesField({
    this.onTap,
    this.info,
    this.valueCallBack,
  });

  final FieldInfo info;
  final Function onTap;
  final Function(FieldInfo info) valueCallBack;

  @override
  createState() => _PhonesFieldState();

}

class _PhonesFieldState extends State<PhonesField> {

  List<String> _phones = [];

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
  final TextStyle _addStyle = TextStyle(
    fontFamily: 'Regular',
    fontSize: 18,
    color: StyleColor.blue1,
  );


  @override
  void initState() {
    if (widget.info.value is List) {
      _phones = (widget.info.value as List).map((e) => e.toString()).toList();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          widget.info.description != null ? Container(
            margin: EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                Text(widget.info.description, style: _titleStyle,),
                Text(widget.info.isRequired ? '*' : '', style: _titleReqStyle,)
              ],
            ),
          ) : Container(),

          Column(
            children: _getItems(),
          ),
          widget.info.errorMessage != null ? Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(widget.info.errorMessage, style: _errorStyle,),
          ): Container(),
          widget.info.isBlock ? Container() : Padding(
            padding: EdgeInsets.only(top: 5),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Row(
                children: [
                  Flexible(
                    child: Text('+ Добавить поле', style: _addStyle,),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _getItems() {
    if (_phones.length > 0) {
      return _phones.map((e) => _getItem(e)).toList();
    } else return [_getHint()];
  }

  Widget _getItem(String phone) => Row(
    children: [
      Expanded(
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: EdgeInsets.only(bottom: 5),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                color: widget.info.isBlock
                    ? StyleColor.disabled
                    : StyleColor.field,
                border: Border.all(
                  color: widget.info.errorMessage != null
                      ? StyleColor.red1
                      : StyleColor.disabledStroke,
                  width: 2,
                ),
                borderRadius: BorderRadius.all(Radius.circular(5))
            ),
            height: 48,
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(phone, style: widget.info.isBlock ? _hintStyle : _valueStyle,),
                ),
                widget.info.isBlock ? Container() : getIconButton(
                  color: StyleColor.red1,
                  icon: AppIcons.CLOSE,
                  onTap: (){
                    setState(() {
                      _phones.remove(phone);
                    });
                    widget.valueCallBack(FieldInfo(
                      isBlock: widget.info.isBlock,
                      value: _phones,
                      type: widget.info.type,
                      name: widget.info.name,
                      dataType: widget.info.dataType,
                      items: widget.info.items,
                      isOnlyDictionary: widget.info.isOnlyDictionary,
                      isRequired: widget.info.isRequired,
                      defaultValue: widget.info.defaultValue,
                      id: widget.info.id,
                      description: widget.info.description,
                      groupDescription: widget.info.groupDescription,
                      position: widget.info.position,
                    ));
                  },
                ),
              ],
            ),
          ),
        ),
      )
    ],
  );

  Widget _getHint() => Row(
    children: [
      Expanded(
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: EdgeInsets.only(bottom: 5),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                color: widget.info.isBlock
                    ? StyleColor.disabled
                    : StyleColor.field,
                border: Border.all(
                  color: widget.info.errorMessage != null
                      ? StyleColor.red1
                      : StyleColor.disabledStroke,
                  width: 2,
                ),
                borderRadius: BorderRadius.all(Radius.circular(5))
            ),
            height: 48,
            padding: EdgeInsets.all(10),
            child:  Text('Введите значение', style: _hintStyle,),
          ),
        ),
      )
    ],
  );

}