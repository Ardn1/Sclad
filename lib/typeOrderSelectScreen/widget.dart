import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live_sklad/apiData.dart';
import 'package:live_sklad/styles.dart';
import 'package:live_sklad/typeOrderSelectScreen/bloc.dart';

import '../api.dart';

class TypeOrderScreen extends StatefulWidget {

  static final String route = '/type_order_select';

  final TypeOrder typeOrderSelect;
  final Function(TypeOrder typeOrder) callBack;

  TypeOrderScreen({this.typeOrderSelect, this.callBack});

  @override
  createState() => TypeOrderScreenState();

}

class TypeOrderScreenState extends State<TypeOrderScreen> {

  TypeOrderBloc _bloc;
  StreamSubscription _subscription;
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _bloc.dispose();
    if(_subscription != null) _subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _bloc = TypeOrderBloc(select: widget.typeOrderSelect);
    Api.getInstance().then((api) {
      _subscription = api.subscribeOnErrors((Error event) {
        _scaffold.currentState.showSnackBar(SnackBar(
          content: Text(event.message),
        ));
      });
    });
    super.initState();
  }
  
  Widget _streamBuilderHandler (_, AsyncSnapshot<TypeOrderState> snap) =>
      Scaffold(
        backgroundColor: StyleColor.white,
        key: _scaffold,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: StyleColor.light,
                  border: Border(bottom: BorderSide(width: 2, color: StyleColor.light)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                          onTap: (){Navigator.pop(context);},
                          ),
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Text(
                            snap.data.select != null ? 'Тип заказа' : 'Новый заказ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Medium',
                              fontSize: 22,
                              color: StyleColor.text,
                              height: 0.8,
                            ),),
                        ),
                      ),
                    ),
                    Container(width: 50,),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 15, top: 15, bottom: 5),
                      child: Text('Выберите тип заказа', style: TextStyle(
                        color: StyleColor.text,
                        fontSize: 16,
                        fontFamily: 'Medium',
                      ),),
                    ),
                  ),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 5),
                itemCount: snap.data.types.length,
                itemBuilder: (_, index) => _getItem(
                    typeOrder: snap.data.types[index],
                    isSelect: snap.data.select == index
                ),
              )
            ],
          ),
        ),
      );

  Widget _getAppBar ({String title}) => AppBar(
    title: Text(title),
  );

  Widget _getItem ({TypeOrder typeOrder, bool isSelect}) => GestureDetector(
    child: Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: isSelect ? StyleColor.light : Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(27)),
        border: Border.all(
          color: StyleColor.disabledMultiple,
          width: 2
        ),
      ),
      height: 54,
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(typeOrder.name, style: TextStyle(
                color: Colors.black,
                fontFamily: 'Regular',
                fontSize: 18
            ),),
          ),
          Icon(Icons.arrow_forward, color: StyleColor.lightGrey,),
        ],
      ),
    ),
    onTap: (){_onTypePressHandler(typeOrder);},
  );

  _onTypePressHandler (TypeOrder typeOrder) {
    if(widget.callBack != null) widget.callBack(typeOrder);
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<TypeOrderState>(
      stream: _bloc.stream,
      initialData: TypeOrderState(types: []),
      builder: _streamBuilderHandler,
    );
  }

}