
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../../apiData.dart';

class BoolStep extends StatefulWidget {

  BoolStep({
    this.info,
    this.valueCallBack,
  });

  final FieldInfo info;
  final Function(FieldInfo info) valueCallBack;

  @override
  createState() => BoolStepState();

}

class BoolStepState extends State<BoolStep> {


  SingingCharacter _character = SingingCharacter.NO;

  @override
  void initState() {
    setState(() {
      _character = _getValue();
    });
    super.initState();
  }

  @override
  void didUpdateWidget(BoolStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.info.id != widget.info.id) {
      setState(() {
        _character = _getValue();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RadioListTile<SingingCharacter>(
          title: const Text('Да', style: TextStyle(
              fontFamily: 'Regular',
              fontSize: 18,
              color: Colors.black
          )),
          value: SingingCharacter.YES,
          groupValue: _character,
          onChanged: (SingingCharacter value) {
            setState(() {
              _character = value;
              widget.valueCallBack(FieldInfo(
                id: widget.info.id,
                value: true,
                isOnlyDictionary: widget.info.isOnlyDictionary,
                isBlock: widget.info.isBlock,
                isRequired: widget.info.isRequired,
                defaultValue: widget.info.defaultValue,
                items: widget.info.items,
                name: widget.info.name,
                dataType: widget.info.dataType,
              ));
            });
          },
        ),
        RadioListTile<SingingCharacter>(
          title: const Text('Нет', style: TextStyle(
              fontFamily: 'Regular',
              fontSize: 18,
              color: Colors.black
          ),),
          value: SingingCharacter.NO,
          groupValue: _character,
          onChanged: (SingingCharacter value) {
            setState(() {
              _character = value;
              widget.valueCallBack(FieldInfo(
                id: widget.info.id,
                value: false,
                isOnlyDictionary: widget.info.isOnlyDictionary,
                isBlock: widget.info.isBlock,
                isRequired: widget.info.isRequired,
                defaultValue: widget.info.defaultValue,
                items: widget.info.items,
                name: widget.info.name,
                dataType: widget.info.dataType,
              ));
            });
          },
        ),
      ],
    );
  }

  SingingCharacter _getValue() {
    if (widget.info.value != null && widget.info.value is bool) {
      return widget.info.value ? SingingCharacter.YES : SingingCharacter.NO;
    }
    if (widget.info.defaultValue != null && widget.info.defaultValue is bool) {
      return widget.info.defaultValue ? SingingCharacter.YES : SingingCharacter.NO;
    }
    return SingingCharacter.NO;
  }

}

enum SingingCharacter { YES, NO }
