
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:live_sklad/ordersScreen/toolbar/bloc.dart';
import 'package:live_sklad/preferences.dart';
import 'package:live_sklad/utils.dart';

import '../../styles.dart';

class OrdersToolbar extends StatefulWidget {

  OrdersToolbar({this.onTextChange, this.onShopChange});

  final Function onTextChange;
  final Function onShopChange;

  @override
  createState() => OrdersToolbarState();

}

class OrdersToolbarState extends State<OrdersToolbar> {

  ToolbarBloc _bloc;
  ToolbarState state = ToolbarState(select: null, shops: []);

  @override
  void initState() {
    print('initState TOOLBAR');
    _bloc = ToolbarBloc();
    _bloc.shopStream.listen((event) {
      if (widget.onShopChange != null) widget.onShopChange(event.select);
      setState(() {
        state = event;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 70,
      flexibleSpace: Container(
        decoration: BoxDecoration(
            color: StyleColor.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black38,
                  blurRadius: 7.0,
                  offset: Offset(0.0, 0.75)
              )
            ]
        ),
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                    color: StyleColor.light,
                    borderRadius: BorderRadius.all(Radius.circular(5))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      child: Icon(
                        Icons.search,
                        color: StyleColor.lightGrey,
                      ),
                      flex: 1,
                    ),
                    Flexible(
                      child: TextField(
                        autofocus: false,
                        onChanged: widget.onTextChange,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintStyle: TextStyle(
                            color: StyleColor.grey1,
                            fontFamily: 'Regular',
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintText: 'Введите информацию по заказу',
                        ),
                      ),
                      flex: 5,
                    )
                  ],
                ),
              ),
              flex: 4,
            ),
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                      child: Padding(
                        padding: EdgeInsets.all(2),
                        child: Stack(
                          children: [
                            Padding(
                              child: SvgPicture.asset(AppIcons.HOME,
                                  color: state.select != null ?
                                  Color(fromHex(state.select.color)) : Colors.black
                              ),
                              padding: EdgeInsets.all(5),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(2),
                                alignment: Alignment.center,
                                width: 16,
                                decoration: BoxDecoration(
                                  color: state.select != null ?
                                  Color(fromHex(state.select.color)) : Colors.black,
                                  shape: BoxShape.circle
                                ),
                                child: Text(state.shops.length.toString(),
                                  style: TextStyle(
                                      color: StyleColor.white,
                                      fontFamily: 'Medium',
                                      fontSize: 11
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) => getSingleSelectDialog(
                              state.shops.map((e) => e.name).toList(),
                              onTap: (index) {
                                _bloc.onShopPress(state.shops[index]);
                                Navigator.pop(context);
                              }
                            )
                        );
                      }),
                ),
              ),
              flex: 1,
            )
          ],
        ),
      ),
    );
  }

}