
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_multi_formatter/formatters/money_input_formatter.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:live_sklad/apiData.dart';
import 'package:live_sklad/styles.dart';
import 'package:live_sklad/toast.dart';

class PrepaymentSheet extends StatefulWidget {

  PrepaymentSheet({
    @required this.cashRegisters,
    @required this.goPayment,
    @required this.goWithoutPayment,
  });
  final List<CashRegister> cashRegisters;
  final Function(CashRegister select ,dynamic bank, dynamic cash,) goPayment;
  final Function() goWithoutPayment;

  @override
  createState() => _PrepaymentSheetState();

}

class _PrepaymentSheetState extends State<PrepaymentSheet> {

  CashRegister _selected;
  dynamic _cash;
  dynamic _bank;
  final _focus = FocusNode();

//  final MoneyMaskedTextController _cashController = MoneyMaskedTextController(
//    decimalSeparator: '.',
//    thousandSeparator: ',',
//  );
//  final MoneyMaskedTextController _bankController = MoneyMaskedTextController(
//    decimalSeparator: '.',
//    thousandSeparator: ',',
//  );
  FlutterToast _toast;



  @override
  void initState() {
    _toast = FlutterToast(context);
    widget.cashRegisters.forEach((element) {
      if (element.isDefault) _selected = element;
    });
    if (_selected == null) _selected = widget.cashRegisters[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: MediaQuery.of(context).viewInsets,
    decoration: new BoxDecoration(
      color: Colors.white,
      borderRadius: new BorderRadius.only(
        topLeft: const Radius.circular(25.0),
        topRight: const Radius.circular(25.0),
      ),
    ),
    child: Padding(
      padding: EdgeInsets.all(20),
      child: ListView(
        shrinkWrap: true,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  child: Text('Предоплата по заказу',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Medium',
                      fontSize: 22,
                    ),),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 20, bottom: 20),
                  color: StyleColor.light,
                  height: 1,
                ),
              )
            ],
          ),
          _getTitle('Касса'),
          Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DropdownButton(
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 30,),
                      underline: Container(),
                      value: _selected.id,
                      items: widget.cashRegisters.map((e) => DropdownMenuItem(
                        value: e.id,
                        child: Text(e.name, style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'Regular'
                        ),),
                      )).toList(),
                      onChanged: (id) {
                        widget.cashRegisters.forEach((element) {
                          if (element.id == id) {
                            setState(() {
                              _selected = element;
                            });
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                  color: StyleColor.field,
                  border: Border.all(
                    color: StyleColor.disabledStroke,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(5))
              ),
            ),
          ),
          _getTitle('Наличные', margin: EdgeInsets.only(bottom: 10)),
          _getTextField(_onChangeCashHandler, null, (str) {
            FocusScope.of(context).requestFocus(_focus);
          }),
          _getTitle('По карте', margin: EdgeInsets.only(top: 10, bottom: 10)),
          _getTextField(_onChangeBankHandler, _focus, null, isDone: true),
          _getBtn('Оплатить',
              margin: EdgeInsets.only(top: 20),
              onTap:_onGoPayHandler),
          _getBtn('Продолжить без оплаты',
              margin: EdgeInsets.only(top: 20),
              onTap: widget.goWithoutPayment),
        ],
      ),
    ),
  );

  _onChangeCashHandler(String val) {
    _cash = double.parse(val.replaceAll(',', ''));
    if (_cash % 1 == 0.0) _cash = (_cash as double).toInt();
  }

  _onChangeBankHandler(String val) {
    _bank = double.parse(val.replaceAll(',', ''));
    if (_bank % 1 == 0.0) _bank = (_bank as double).toInt();
  }

  _onGoPayHandler() {
    if (_selected != null && (_cash != null || _bank != null )) {
      widget.goPayment(_selected, _bank != null ? _bank : 0 , _cash != null ? _cash : 0);
    } else {
      _toast.showToast(child: customToast('Укажите размер оплаты, или нажмите "Продолжить без оплаты"'));
    }
  }

  Widget _getTitle(String title, {EdgeInsets margin}) => Row(
    children: [
      Expanded(
        child: Container(
          margin: margin,
          child: Text(title,
            style: TextStyle(
              color: StyleColor.grey1,
              fontFamily: 'Regular',
              fontSize: 15,
            ),),
        ),
      ),
    ],
  );

  Widget _getTextField(
      Function(String text) onChange,
      FocusNode focusNode,
      Function(String str) onSubmitted,
      {bool isDone = false}
  ) => Row(
    children: [
      Expanded(
        child: TextField(
          textInputAction: isDone ? TextInputAction.done : TextInputAction.next,
          onSubmitted: onSubmitted,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          textAlignVertical: TextAlignVertical.center,
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
          onChanged: onChange,
          inputFormatters: [
            MoneyInputFormatter(),
          ],
        ),
      )
    ],
  );
  
  Widget _getBtn(String title, {Function onTap, EdgeInsets margin}) => GestureDetector(
    onTap: onTap,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: margin,
          alignment: Alignment.center,
          height: 46,
          width: 280,
          decoration: BoxDecoration(
            color: StyleColor.blue1,
            borderRadius: BorderRadius.all(Radius.circular(23)),
          ),
          child: Text(title, style: TextStyle(
              color: StyleColor.white,
              fontSize: 19,
              fontFamily: 'Medium'
          ),),
        )
      ],
    ),
  );

}