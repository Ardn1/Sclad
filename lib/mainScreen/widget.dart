import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live_sklad/createOrderScreen/widget.dart';
import 'package:live_sklad/mainScreen/bloc.dart';
import 'package:live_sklad/ordersScreen/widget.dart';
import 'package:live_sklad/preferences.dart';
import 'package:live_sklad/profileScreen/widget.dart';
import 'package:live_sklad/styles.dart';
import 'package:live_sklad/typeOrderSelectScreen/widget.dart';

import '../api.dart';
import '../utils.dart';

class MainScreen extends StatefulWidget {

  static const route = '/main';

  @override
  createState() => MainScreenState();

}

class MainScreenState extends State<MainScreen> {

  ScrollController _hideBottomNavController;

  bool _isVisible;
  MainScreenBloc _bloc;
  String _shopId;

  MainState _state = OpenOrders();

  @override
  initState() {
    super.initState();
    _bloc = MainScreenBloc();
    _isVisible = true;
    _hideBottomNavController = ScrollController();
    _hideBottomNavController.addListener(() {
        if (_hideBottomNavController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          if (_isVisible)
            setState(() {
              _isVisible = false;
            });
        }
        if (_hideBottomNavController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (!_isVisible)
            setState(() {
              _isVisible = true;
            });
        }
      },
    );
    _bloc.stream.listen((event) {
      setState(() {
        _state = event;
      });
    });
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  Widget _getScreen () {
    if(_state is OpenOrders) {
      return OrdersScreen(
        controller: _hideBottomNavController,
        shopCallback: (id) {
          _shopId = id;
        },
        newOrder: (_state as OpenOrders).newOrder,
      );
    } else if (_state is OpenProfile) {
      return ProfileScreen();
    } else {
      return Center(
        child: Text('Error'),
      );
    }
  }

  _addButtonTapHandler() {
    if(_shopId == null || _state is OpenProfile) {
      PrefManager.getInstance()
          .then((value) => value.getShops())
          .then((value) {
            showDialog(
                context: context,
                builder: (context) => getSingleSelectDialog(
                    value.map((e) => e.name).toList(),
                    onTap: (index) {
                      _shopId = value[index].id;
                      Navigator.pop(context);
                      _goToCreateOrder();
                    }
                )
            );
      });
    } else {
      _goToCreateOrder();
    }
  }

  _goToCreateOrder() async {
    var order =  await Navigator.of(context).pushNamed(CreateOrderScreen.route,
        arguments: CreateOrderScreenArguments(shopId: _shopId));
    if (order is Map) {
      _bloc.onNewOrderAdd(order);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: StyleColor.white,
      child: SafeArea(
        child: Scaffold(
          extendBody: true,
          body: Stack(
            children: [
              _getScreen(),
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: _isVisible ? 92 : 0.0,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                            color: StyleColor.white,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                topLeft: Radius.circular(20)
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 3.0,
                                  offset: Offset(0.0, -0.2)
                              ),
                            ]
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Flexible(
                              child: Center(
                                child: _getNavItem(
                                    AppIcons.HOME,
                                    'Заказы',
                                        (){_bloc.onOrdersSelect();},
                                    _state is OpenOrders
                                ),
                              ),
                            ),
                            Flexible(
                              child: Center(
                                child: _getNavItem(
                                    AppIcons.PROFILE,
                                    'Профиль',
                                        (){_bloc.onProfileSelect();},
                                    _state is OpenProfile
                                ),
                              ),
                            ),
                            Spacer(flex: 1),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 40,
                        width: 64,
                        height: 64,
                        child: Material(
                          color: Colors.transparent,
                          child: Ink(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 3),
                              color: StyleColor.blue1,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 0.0,
                                    offset: Offset(0.0, -0.5)
                                ),
                              ],
                            ),
                            child: InkWell(
                              customBorder: CircleBorder(),
                              child: Container(
                                padding: EdgeInsets.all(15),
                                child: SvgPicture.asset(AppIcons.PLUS),
                              ),
                              onTap: _addButtonTapHandler,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getNavItem (String icon, String title, Function onTap, bool isActive) => Material(
    color: Colors.transparent,
    child: Ink(
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(icon, color: isActive ? StyleColor.blue1 : StyleColor.grey1,),
              Container(
                margin: EdgeInsets.only(left: 5),
                child: Text(title, style: TextStyle(
                  fontFamily: 'Medium',
                  fontSize: 14,
                  color: isActive ? StyleColor.blue1 : StyleColor.grey1,
                ),),
              )
            ],
          ),
        ),
        onTap: onTap,
      ),
    ),
  );
}