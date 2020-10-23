import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_svg/svg.dart';
import 'package:live_sklad/formScreen/fields/boolField/widget.dart';
import 'package:live_sklad/formScreen/fields/dateTimeField/widget.dart';
import 'package:live_sklad/formScreen/fields/imageField/widget.dart';
import 'package:live_sklad/formScreen/fields/multiChoiceField/widget.dart';
import 'package:live_sklad/formScreen/fields/phoneField/widget.dart';
import 'package:live_sklad/formScreen/fields/singleChoiceField/widget.dart';
import 'package:live_sklad/formScreen/fields/textField/widget.dart';
import 'package:live_sklad/stepperScreen/steps/imageChoice/widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../apiData.dart';
import '../styles.dart';

class EditOrderScreen extends StatefulWidget {

  EditOrderScreen({
    this.fields,
    this.onClose,
    this.onCreate,
    this.valueCallback,
    this.typeOrder,
    this.openStepCallback,
    this.lastPosition,
  });

  final FieldInfo lastPosition;

  final List<FieldInfo> fields;
  final TypeOrder typeOrder;
  final Function onClose;
  final Function onCreate;
  final Function(FieldInfo info) valueCallback;
  final Function(FieldInfo info) openStepCallback;

  @override
  createState() => EditOrderScreenState(
    fields: fields,
    onClose: onClose,
    onCreate: onCreate,
    valueCallback: valueCallback,
    typeOrder: typeOrder,
    openStepCallback: openStepCallback,
    lastPosition: lastPosition,
  );

}

class EditOrderScreenState extends State<EditOrderScreen> {

  EditOrderScreenState({
    this.fields,
    this.onClose,
    this.onCreate,
    this.valueCallback,
    this.typeOrder,
    this.openStepCallback,
    this.lastPosition,
  });

  final FieldInfo lastPosition;

  final List<FieldInfo> fields;
  final TypeOrder typeOrder;
  final Function onClose;
  final Function onCreate;
  final Function(FieldInfo info) valueCallback;
  final Function(FieldInfo info) openStepCallback;

  ItemScrollController _controller;
  Map<String, int> _map = {};

  @override
  void initState() {
    _controller = ItemScrollController();
    Future.delayed(Duration(milliseconds: 1), () {
      if (lastPosition != null) {
        _controller.jumpTo(index: _map[lastPosition.id]);
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
  /*  List form = [];
    form.add('Тип заказа');
    form.add(typeOrder);
    fields.forEach((element) {
      if (!form.contains(element.groupDescription)) {
        form.add(element.groupDescription);
      }
      form.add(element);
    });
    for (var val in form) {
      if (val is FieldInfo) _map[val.id] = form.indexOf(val);
    }*/

    String orderNumb = "A000022";
    bool isHot = true;
    return SafeArea(
       child: Container(
         color: Colors.white,

      child: Column(
        children: [
          ///ToolBar
          Container(
            height: 80,
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(width: 2, color: StyleColor.light))
            ),
            child: Row(
          //    mainAxisSize: MainAxisSize.max,
            //  mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    child: Material(
                      child: InkWell(
                        child: Container(
                          height: 40,
                          width: 40,
                          child: Icon(Icons.arrow_back_ios),
                        ),
                        onTap: onClose != null ? onClose : (){Navigator.pop(context);},
                      ),
                      color: Colors.transparent,
                    ),
                  ),
                ),
            //    Expanded(child:
                 //  Center(child:
                     Container(
                      margin: EdgeInsets.only(left: 5, top: 0),
                      child: Text(
                        'Заказ №' + orderNumb,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'Medium',
                          fontSize: 22,
                          color: StyleColor.text,
                          height: 1.2,
                        ),),
                //    ),
               //   ),
                ),
              //  Expanded(child:
                   Align(
                     alignment: Alignment.centerLeft,
                  child: !isHot?Container():Container(
                    color: Colors.transparent,
                    margin: EdgeInsets.only(left: 5, bottom: 10),
                    width: 11.2*0.99,
                    height: 14*0.99,
                    child: Image.asset(
                      "images/Hot@2x.png",
                     // isHot?"assets/images/ScladIcons/Hot.png":"",
                   //   width: 11.2*0.99,
                 //     height: 14*0.99,
                        fit: BoxFit.fill,
                    ),
                  ),
                //     ),
                ),
                Expanded(

                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                    children: [


                    Expanded(child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      color: Colors.transparent,
                      margin: EdgeInsets.only(right: 15, bottom: 3),
                      width: 25*0.99,
                      height: 25*0.99,
                      child: Image.asset(
                        "images/ScladIcons/History@2x.png",
                        // isHot?"assets/images/ScladIcons/Hot.png":"",
                        //   width: 11.2*0.99,
                        //     height: 14*0.99,
                        fit: BoxFit.fill,
                      ),
                    ),
                  )),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    color: Colors.transparent,
                    margin: EdgeInsets.only(right:25, bottom: 3),
                    width: 21*0.99,
                    height: 21*0.99,
                    child: Image.asset(
                      "images/ScladIcons/ThreePoints@2x.png",
                      // isHot?"assets/images/ScladIcons/Hot.png":"",
                      width: 5*0.99,
                      height: 21*0.99,
                  //    fit: BoxFit.fill,
                    ),
                  ),
                ),
              ], ),),),
              //  Container(width: 50,),
              ],
            ),
          ),
          ///Form
         /* Expanded(
            child: ScrollablePositionedList.builder(
              itemScrollController: _controller,
              itemBuilder: (_, index) {
                if (index == form.length) return Padding(
                  padding: EdgeInsets.all(15),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(23)),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onCreate,
                          child: Container(
                            alignment: Alignment.center,
                            height: 46,
                            width: 212,
                            decoration: BoxDecoration(
                              color: StyleColor.blue1,
                              borderRadius: BorderRadius.all(Radius.circular(23)),
                            ),
                            child: Text('Создать', style: TextStyle(
                                color: StyleColor.white,
                                fontSize: 19,
                                fontFamily: 'Medium'
                            ),),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
                if (form[index] is String) return _getGroupTitle(form[index]);
                else if (form[index] is FieldInfo) {
                  return _getField(form[index]);
                }
                else if (form[index] is TypeOrder) return SingleChoiceField(
                  info: FieldInfo(
                    name: TYPE_ORDER,
                    value: (form[index] as TypeOrder).name,
                    isBlock: false,
                  ),
                  valueFactory: (value) => value.toString(),
                  onTap: () {
                    if(openStepCallback != null) openStepCallback(FieldInfo(
                      name: TYPE_ORDER,
                      value: (form[index] as TypeOrder).name,
                      isBlock: false,
                    ));
                  },
                );
                else return Text('ERROR');
              },
              itemCount: form.length+1,
            ),
          ),*/
        ],
      ),
    ));
  }

  Widget _getField(FieldInfo info) {
    if (info.name == null) {
      switch (info.dataType) {
        case ENUM: return SingleChoiceField(
          info: info,
          onTap: () {
            openStepCallback(info);
          },
          valueFactory: (value) => value as String,
        );
        case STRING: return TextInputField(
          info: info,
          valueCallback: valueCallback,
          type: TextInputFieldType.STRING,
        );
        case MONEY: return TextInputField(
          info: info,
          valueCallback: valueCallback,
          type: TextInputFieldType.MONEY,
        );
        case TEXT: return TextInputField(
          info: info,
          valueCallback: valueCallback,
          type: TextInputFieldType.TEXT,
        );
        case NUMBER: return TextInputField(
          info: info,
          valueCallback: valueCallback,
          type: TextInputFieldType.NUMBER,
        );
        case MULTIPLE: return MultiChoiceField(
          info: info,
          valueCallback: valueCallback,
          onTap: () {
            openStepCallback(info);
          },
          getTitle: (val) => val,
        );
        case BOOLEAN: return BoolField(
          info: info,
          valueCallBack: valueCallback,
        );
        case DATE: return DateTimeField(
          info: info,
          valueCallBack: valueCallback,
          onTap: () {
            openStepCallback(info);
          },
          isTimeOn: false,
        );
        case DATE_TIME: return DateTimeField(
          info: info,
          valueCallBack: valueCallback,
          onTap: () {
            openStepCallback(info);
          },
          isTimeOn: true,
        );
        default: return Text(info.description);
      }
    } else {
      switch (info.name) {
        case NAME:
        case MASTER:
        case MANAGER:
        case TYPE_DEVICE:
        case MODEL:
        case HOW_KNOW:
        case COLOR:
        case BRAND: return SingleChoiceField(
          info: info,
          onTap: () {
            openStepCallback(info);
          },
          valueFactory: (value) {
            if (value is Brand) return value.name;
            else if (value is ManagerMaster) return value.name;
            else if (value is TypeDevice) return value.name;
            else if (value is Model) return value.name;
            else if (value is HowKnow) return value.name;
            else if (value is Map) return value['name'];
            else if (value is Counteragent) return value.name;
            else return value.toString();
          },
        );
        case INN:
        case ADDRESS:
        case OGRN:
        case DIRECTOR:
        case EMAIL:
        case BANK_ACCOUNT:
        case BANK_BIK:
        case BANK_COR:
        case BANK_NAME:
        case BANK_SWIFT:
        case ADDRESS:
        case KPP:
        case APPROXIMATE_PRICE:
        case PASSPORT_CODE_OFFICE:
        case PASSPORT_OFFICE:
        case CONTRACT:
        case BIRTHPLACE:
        case SN:
        case SERIAL_NUMBER: return TextInputField(
          info: info,
          valueCallback: valueCallback,
          type: TextInputFieldType.STRING,
        );
        case ORDER_NODE:
        case COUNTERAGENT_NODE: return TextInputField(
          info: info,
          valueCallback: valueCallback,
          type: TextInputFieldType.TEXT,
        );
        case COMPLETE_SET: return MultiChoiceField(
          info: info,
          valueCallback: valueCallback,
          onTap: () {
            openStepCallback(info);
          },
          getTitle: (val) => val is String ? val : (val as CompleteSet).name,
        );
        case PROBLEM: return MultiChoiceField(
          info: info,
          valueCallback: valueCallback,
          onTap: () {
            openStepCallback(info);
          },
          getTitle: (val) => val is String ? val : (val as Problem).name,
        );
        case APPEARANCE: return MultiChoiceField(
          info: info,
          valueCallback: valueCallback,
          onTap: () {
            openStepCallback(info);
          },
          getTitle: (val) => val,
        );
        case IMAGES: return ImageChoiceField(
          info: info,
          valueCallBack: valueCallback,
        );
        case IS_URGENT: return BoolField(
          info: info,
          valueCallBack: valueCallback,
        );
        case PREPAYMENT: return BoolField(
          info: info,
          valueCallBack: valueCallback,
        );
        case BIRTH_DATE: return DateTimeField(
          info: info,
          valueCallBack: valueCallback,
          onTap: () {
            openStepCallback(info);
          },
          isTimeOn: false,
        );
        case PASSPORT_DATE: return DateTimeField(
          info: info,
          valueCallBack: valueCallback,
          onTap: () {
            openStepCallback(info);
          },
          isTimeOn: false,
        );
        case DEADLINE: return DateTimeField(
          info: info,
          valueCallBack: valueCallback,
          onTap: () {
            openStepCallback(info);
          },
          isTimeOn: true,
        );
        case PHONES: return PhonesField(
          info: info,
          valueCallBack: valueCallback,
          onTap: () {
            openStepCallback(info);
          },
        );
      }
      return Text(info.description);
    }
  }


  Widget _getGroupTitle (String title) => Padding(
    padding: EdgeInsets.only(top: 10, left: 10, right: 10),
    child: Text(title.toUpperCase(),
      style: TextStyle(
        color: StyleColor.blue1,
        fontFamily: 'Medium',
        fontSize: 16,
      ),
    ),
  );

}