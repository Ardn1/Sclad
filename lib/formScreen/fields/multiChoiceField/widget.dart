
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../apiData.dart';
import '../../../styles.dart';
import '../../../utils.dart';

class MultiChoiceField extends StatefulWidget {

  MultiChoiceField({
    @required this.info,
    @required this.valueCallback,
    @required this.getTitle,
    @required this.onTap,
  });

  final FieldInfo info;
  final Function(FieldInfo info) valueCallback;

  final String Function(dynamic val) getTitle;
  final Function onTap;
  
  @override
  createState() => _MultiChoiceFieldState();
  
}

class _MultiChoiceFieldState extends State<MultiChoiceField> {
  
  List _items = [];

  final TextStyle _errorStyle = TextStyle(
    fontFamily: 'Regular',
    fontSize: 16,
    color: StyleColor.red1,
  );
  final TextStyle _hintStyle = TextStyle(
    fontFamily: 'Regular',
    fontSize: 18,
    color: StyleColor.description,
  );
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

  @override
  void initState() {
    if (widget.info.value != null && widget.info.value is List) {
      _items = widget.info.value;
    } else if (widget.info.defaultValue != null && widget.info.defaultValue is List && !widget.info.isBlock) {
      _items = widget.info.defaultValue;
    }
    super.initState();
  }
  
  Widget _getItem(dynamic element) => Container(
    decoration: BoxDecoration(
        color: widget.info.isBlock ? StyleColor.disabledMultiple : StyleColor.light,
        borderRadius: BorderRadius.all(Radius.circular(5))
    ),
    padding: EdgeInsets.all(3),
    margin: EdgeInsets.all(3),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.getTitle(element), style: TextStyle(
          color: widget.info.isBlock ? StyleColor.grey1 : Colors.black,
          fontFamily: 'Regular',
          fontSize: 18,
        ),),
        Container(width: 5,),
        widget.info.isBlock ? Container() : getIconButton(
            color: StyleColor.description,
            icon: AppIcons.CLOSE,
            onTap: () {
              _onDeleteItemHandler(_items.indexOf(element));
            },
        ),
      ],
    ),
  );
  
  _onDeleteItemHandler(int index) {
    setState(() {
      _items.removeAt(index);
    });
    widget.valueCallback(FieldInfo(
      isBlock: widget.info.isBlock,
      value: _items.length == 0 ? null : _items,
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
  } 
  
  @override
  Widget build(BuildContext context) => Padding(
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
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: widget.info.isBlock ? null : widget.onTap,
                child: Container(
                  height: _items.length == 0 ? 48 : null,
                  padding: EdgeInsets.all(5),
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
                  child: _items.length == 0
                      ? Container(
                    padding: EdgeInsets.only(left: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Выберите значение', style: _hintStyle,),
                        ),
                        Padding(
                          child: getIconButton(
                              onTap: widget.info.isBlock ? null : widget.onTap,
                              icon: AppIcons.PLUS,
                              color: widget.info.isBlock ? StyleColor.grey1 : StyleColor.blue2
                          ),
                          padding: EdgeInsets.only(right: 2, left: 0),
                        ),
                      ],
                    ),
                  )
                      : Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          children: _items.map((e) => _getItem(e)).toList(),
                        ),
                      ),
                      Padding(
                        child: getIconButton(
                            onTap: widget.info.isBlock ? null : widget.onTap,
                            icon: AppIcons.PLUS,
                            color: widget.info.isBlock ? StyleColor.grey1 : StyleColor.blue2
                        ),
                        padding: EdgeInsets.only(right: 2, left: 0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        widget.info.errorMessage != null ? Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(widget.info.errorMessage, style: _errorStyle,),
        ): Container(),
      ],
    ),
  );
  
}