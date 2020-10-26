import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:live_sklad/OrderParams.dart';
import 'package:live_sklad/api.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../apiData.dart';
import '../styles.dart';

class EditOrderScreen extends StatefulWidget {
  static const routeName = '/editorderscreen';

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

  var dropDownOptions = [
    "Доплата по заказу",
    "Принять еще заказ от контрагента",
    "Возврат денежных средств"
  ];

  var currentOption = 1;
  var isDropDownClicked = false;

  buildDropdown() => Container(
        padding: EdgeInsets.only(right: 5, left: 5),
        width: double.infinity,
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.orangeAccent,
            ),
            color: Colors.orangeAccent,
            borderRadius: BorderRadius.all(Radius.circular(4))),
        child: DropdownButton(
          onChanged: (value) {
            setState(() {
              currentOption = dropDownOptions.indexOf(value);
            });
          },
          value: dropDownOptions[currentOption],
          underline: Container(),
          iconEnabledColor: Colors.white,
          isExpanded: true,
          style: TextStyle(color: Colors.deepPurple),
          //ЧОМУ НЕ РОБИТ???????????????????????????
          items: dropDownOptions.map((String year) {
            return DropdownMenuItem<String>(
              value: year,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    year.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );

  alohaTest(String id) async{
    Api api = await Api.getInstance();
    print("Getting");
    print(await api.getOrder(id));
  }
  @override
  Widget build(BuildContext context) {

    final OrderParams args = ModalRoute.of(context).settings.arguments;
    alohaTest(args.order.id);
    print("ID!!!!!!!!!!!!!!!!!!!!!!!!!!!!" + args.order.toString());
    String orderNumb = args.order.number;
    bool isHot = true;
    return Scaffold(
        body: buildHeader(orderNumb, isHot));
  }

  buildTabbar()=> DefaultTabController(
    length: 2,
    child: Column(
      children: <Widget>[
        Container(
          constraints: BoxConstraints.expand(height: 50),
          child: TabBar(
            tabs: [
              Tab(
                text: "Информация о заказе",
              ),
              Tab(text: "Работы и материалы"),
            ],
            labelColor: Colors.black,
          ),
        ),
        Expanded(
          child: TabBarView(
              children: [
                Container(
                  child: Text(
                    "Home Body",
                  ),
                ),
                Container(
                  child: Text("Articles Body"),
                ),
              ]),
        )
      ],
    ),
  );

  buildSecondScreen() => Expanded(
          child: Container(
        margin: EdgeInsets.only(left: 16, right: 16, top: 14),
        child: Column(
          children: [
            buildDropdown(),
          ],
        ),
      ));

  buildHeader(String orderNumb, bool isHot) => SafeArea(
    child: Container(
          color: Colors.white,
          child: Column(
            children: [
              //buildTabbar(),
              Container(
                height: 80,
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(width: 2, color: StyleColor.light))),
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
                            onTap: onClose != null
                                ? onClose
                                : () {
                                    Navigator.pop(context);
                                  },
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
                        ),
                      ),
                      //    ),
                      //   ),
                    ),
                    //  Expanded(child:
                    Align(
                      alignment: Alignment.centerLeft,
                      child: !isHot
                          ? Container()
                          : Container(
                              color: Colors.transparent,
                              margin: EdgeInsets.only(left: 5, bottom: 10),
                              width: 11.2 * 0.99,
                              height: 14 * 0.99,
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
                            Expanded(
                                child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                color: Colors.transparent,
                                margin: EdgeInsets.only(right: 15, bottom: 3),
                                width: 25 * 0.99,
                                height: 25 * 0.99,
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
                                margin: EdgeInsets.only(right: 25, bottom: 3),
                                width: 21 * 0.99,
                                height: 21 * 0.99,
                                child: Image.asset(
                                  "images/ScladIcons/ThreePoints@2x.png",
                                  // isHot?"assets/images/ScladIcons/Hot.png":"",
                                  width: 5 * 0.99,
                                  height: 21 * 0.99,
                                  //    fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              buildSecondScreen()
            ],
          ),
        ),
  );
}
