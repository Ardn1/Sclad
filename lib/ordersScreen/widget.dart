import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live_sklad/OrderParams.dart';
import 'package:live_sklad/editOrderScreen/editOrderScreen.dart';
import 'package:live_sklad/ordersScreen/bloc.dart';
import 'package:live_sklad/ordersScreen/toolbar/widget.dart';
import 'package:live_sklad/preferences.dart';
import 'package:live_sklad/styles.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils.dart';


class OrdersScreen extends StatefulWidget {

  static const route = '/main';

  OrdersScreen({this.controller, this.shopCallback, this.newOrder});

  final ScrollController controller;
  final Function(String id) shopCallback;
  final Map newOrder;

  @override
  createState() => OrdersScreenState();

}

class OrdersScreenState extends State<OrdersScreen> {

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
    new GlobalKey<RefreshIndicatorState>();

  OrdersScreenBloc _bloc;

  @override
  void initState() {
    _bloc = OrdersScreenBloc(newOrder: widget.newOrder);
    _bloc.refreshStream.listen((event) {
      if (event is LoadShow) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Загрузка...'),
        ));
      } else if (event is LoadHide) {
        Future.delayed(Duration(milliseconds: 300)).then((value) =>
            Scaffold.of(context).hideCurrentSnackBar());
      } else if (event is InternetError) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Проверьте подключение к интернету'),
        ));
      } else if (event is ReachEndList) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Вы достигли конца списка'),
        ));
      }
    });
//    WidgetsBinding.instance
//        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    super.initState();
  }

  @override
  void didUpdateWidget(OrdersScreen oldWidget) {
    print('didUpdateWidget ORDER SCREEN');
    if (widget.newOrder != null) {
      _bloc.onNewOrder(widget.newOrder);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('build ORDER SCREEN');
    return Center(
      child: NotificationListener<ScrollNotification>(
        onNotification: (notify) {
          widget.controller.notifyListeners();
          return null;
        },
        child: Container(
          color: StyleColor.light,
          child: NestedScrollView(
            controller: widget.controller != null ? widget.controller : null,
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, innerBoxScrolled) => [
              OrdersToolbar(
                onShopChange: (ShopsAccess shop) {
                  _bloc.onShopChange(shop);
                  widget?.shopCallback(shop.id);
                },
                onTextChange: (text) {
                  _bloc.onSearchChange(text);
                },
              ),
            ],
            body: Builder(
              builder: (context) {
                final innerScrollController = PrimaryScrollController.of(context);
                innerScrollController.addListener(() {
                  if (innerScrollController.offset >= innerScrollController.position.maxScrollExtent &&
                      !innerScrollController.position.outOfRange) {
                    _bloc.reachEndList();
                  }
                });
                return RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: () {
                    return _bloc.onRefresh();
                  },
                  child: StreamBuilder(
                    stream: _bloc.ordersStream,
                    initialData: [],
                    builder: (context, snapshot) {
                      if(snapshot.data is List<Order>) {
                        List<Order> orders = snapshot.data as List<Order>;
                        if(orders.length != 0) {
                          return ListView.builder(
                            padding: EdgeInsets.only(
                                top: 6,
                                bottom: 6
                            ),
                            itemBuilder: (_, index) => _getItem(orders[index]),
                            itemCount: orders.length,
                          );
                        } else {
                          return Center(
                            child: Text('Заказы не найдены'),
                          );
                        }
                      } else {
                        return Center(
                          child: Text('Заказы не найдены'),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _getItem (Order order) => GestureDetector(
    onTap: (){
      Navigator.pushNamed(
        context,
        EditOrderScreen.routeName ,
        arguments: OrderParams(
          order,
        ),
      );
      print("Tapped"+order.id.toString());
      },
    child: Stack(
      children: [
        Positioned(
          top: 0, bottom: 0, right: 0, left: 0,
          child: Container(
            margin: EdgeInsets.only(
                left: 8,
                right: 8,
                top: 4,
                bottom: 4
            ),
            decoration: BoxDecoration(
                color: (order.phones != null && order.phones.length != 0)
                    ? StyleColor.blue1 : StyleColor.lightGrey,
                borderRadius: BorderRadius.all(Radius.circular(5))
            ),
          ),
        ),
        Slidable(
          actionPane: SlidableBehindActionPane(),
          secondaryActions: <Widget>[
            Container(
              child: IconButton(
                icon: SvgPicture.asset((order.phones != null && order.phones.length != 0)
                    ? AppIcons.PHONE_ON : AppIcons.PHONE_OFF),
                onPressed: (order.phones != null && order.phones.length != 0) ?
                    () {
                      if(order.phones.length == 1) {
                        launch('tel://${order.phones[0]}');
                        return;
                      }
                      showDialog(context: context,
                        builder: (context) => getSingleSelectDialog(
                          order.phones,
                          onTap: (index) {
                            launch('tel://${order.phones[index]}');
                            Navigator.pop(context);
                          }
                        )
                      );
                    } : null,
              ),
              margin: EdgeInsets.only(
                right: 16,
              ),
            ),
          ],
          child: Container(
            margin: EdgeInsets.only(
              left: 8,
              right: 8,
              top: 4,
              bottom: 4
            ),
            decoration: BoxDecoration(
                color: StyleColor.white,
                borderRadius: BorderRadius.all(Radius.circular(5)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4.0,
                      offset: Offset(0.0, 0.5)
                  )
                ],
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: 8,
                bottom: 8,
                left: 12,
                right: 12
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('#', style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Regular',
                            color: StyleColor.blue1
                          )),
                          findText(order.number,
                            family: 'Regular',
                            size: 14,
                            color: StyleColor.text
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 5, right: 2),
                            child: SvgPicture.asset(AppIcons.CALENDAR),
                          ),
                          Text(order.dateCreate, style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Regular',
                              color: StyleColor.text
                          )),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              left: 5
                            ),
                            padding: EdgeInsets.only(
                              left: 6,
                              right: 6,
                              top: 4,
                              bottom: 4
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                              color: Color(order.status.color),
                            ),
                            child: Text(order.status.title, style: TextStyle(
                              color: StyleColor.white,
                              fontSize: 13,
                              fontFamily: 'Medium',
                            ),),
                          ),
                        ],
                      )
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: order.device != null ? 2:0),
                    child: Row(
                      children: [
                        order.isUrgent ? Container(
                          margin: EdgeInsets.only(right: 5),
                          child: SvgPicture.asset(AppIcons.IS_URGENT,),
                        ) : Container(),
                        order.isStatusDeadline ? Container(
                          margin: EdgeInsets.only(right: 5),
                          child: SvgPicture.asset(AppIcons.STATUS_DEADLINE),
                        ) : Container(),
                        order.isDeadline ? Container(
                          margin: EdgeInsets.only(right: 5),
                          child: SvgPicture.asset(AppIcons.DEADLINE),
                        ) : Container(),
                        if(order.device!=null) Expanded(
                          child: findText(order.device,
                              family: 'Medium',
                              size: 17,
                              color: StyleColor.text1
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 3),
                    child: Row(
                      children: [
                        Container(
                          child: findText(order.contractor,
                              family: 'Regular',
                              size: 15,
                              color: StyleColor.text
                          ),
                          margin: EdgeInsets.only(right: 5),
                        ),
                        order.sum != 0 && order.sum != null ? Container(
                          padding: EdgeInsets.only(top: 3),
                          margin: EdgeInsets.only(right: 5),
                          child: SvgPicture.asset(AppIcons.DOT),
                        ) : Container(),
                        order.sum != 0 && order.sum != null ? Text('${order.sum.toStringAsFixed(2)} руб.', style: TextStyle(
                          fontFamily: 'Regular',
                          fontSize: 15,
                          color: StyleColor.text
                        ),) : Container(),
                      ],
                    )
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );

}
