
import 'dart:async';

import 'package:live_sklad/api.dart';
import 'package:live_sklad/preferences.dart';

import '../utils.dart';

class OrdersScreenBloc {

  static const int PAGE_SIZE = 20;

  OrdersScreenBloc({this.newOrder});
  Map newOrder;

  String _shopId;
  int _page;
  String _search;
  List<Order> _orders = [];

  bool _isLoad = false;
  StreamSubscription _subscription;

  StreamController _ordersController = StreamController<List<Order>>();
  StreamController _refreshController = StreamController<NotifyState>();

  Stream<List<Order>> get ordersStream => _ordersController.stream;
  Stream<NotifyState> get refreshStream => _refreshController.stream;

  void dispose() {
    _ordersController.close();
    _refreshController.close();
  }

  Future<Null> onRefresh() {
    Completer<Null> completer = Completer();
    _isLoad = true;
    _page = 1;
    _refreshList(completer: completer, all: true);
    return completer.future;
  }

  reachEndList() {
    if (!_isLoad) {
      _refreshController.add(LoadShow());
      _isLoad = true;
      _page++;
      _refreshList(all: false);
    }
  }

  onShopChange(ShopsAccess shop) {
    if(!_isLoad) {
      _refreshController.add(LoadShow());
      _isLoad = true;
      _shopId = shop.id;
      _page = 1;
      _refreshList(all: true);
    }
  }

  onSearchChange(text) {
    if(!_isLoad) {
      if(_subscription != null) _subscription.cancel();
      _subscription = Future.delayed(const Duration(milliseconds: 700))
          .asStream().listen((event) {
            print('onSearchChange');
        _refreshController.add(LoadShow());
        _isLoad = true;
        _search = text;
        _page = 1;
        _refreshList(all: true);
        _subscription.cancel();
      });
    }
  }

  _refreshList({Completer completer, bool all}) {
    Api.getInstance().then((value) {
      value.getOrders(_shopId, page: _page, pageSize: PAGE_SIZE, filter: _search)
          .then((value) {
            print('ORDERS $value');
            if (value['error'] != null) {
              _refreshController.add(LoadHide());
              _refreshController.add(InternetError());
              if(completer != null)completer.complete();
              _isLoad = false;
              return;
            }

            List data = value['data'] as List;
            if(all) {
              if(newOrder != null) {
                print('NEW ORDER IS ADD ${Order.fromJson(newOrder)}');
                _orders = [null];
                _orders[0] = Order.fromJson(newOrder);
                newOrder = null;
                _orders.addAll(data.map((e) => Order.fromJson(e)).toList());
              }
              _orders = List.of(data.map((e) => Order.fromJson(e)).toList());
            } else {
              _orders.addAll(data.map((e) => Order.fromJson(e)).toList());
            }
            _ordersController.sink.add(_orders);
            if (completer!=null) completer.complete();
            _isLoad = false;
            _refreshController.add(LoadHide());
            if(data.length == 0) {
              _refreshController.add(ReachEndList());
            }
      });
    });
  }

  void onNewOrder(Map<dynamic, dynamic> newOrder) {
    if (newOrder != null) {
      if (_orders == null) {
        _orders = [null];
        _orders[0] = Order.fromJson(newOrder);
      } else {
        _orders.insert(0, Order.fromJson(newOrder));
      }
      _ordersController.sink.add(_orders);
    }
  }
}

class Order {
  String id;
  String number;
  String dateCreate;
  Status status;
  String contractor;
  String device;
  bool isUrgent;
  bool isDeadline;
  bool isStatusDeadline;
  double sum;
  List<String> phones;

  Order.fromJson(Map json) {
    id = json['id'];
    number = json['number'];
    String date = json['dateCreate'].toString().split('T')[0];
    dateCreate = '${date.split('-')[2]}.${date.split('-')[1]}.${date.split('-')[2]}';
    status = Status(
      title: json['status']['name'],
      color: fromHex(json['status']['color'])
    );
    contractor = json['counteragent']['name'];
    isUrgent = json['isUrgent'];
    isDeadline = json['deadline'] != null &&
        DateTime.now().isAfter(DateTime.parse(json['deadline']));
    isStatusDeadline = json['statusDeadline'] != null &&
        DateTime.now().isAfter(DateTime.parse(json['statusDeadline']));
    if(json.containsKey('summ') && json['summ']['price'] is int) {
      sum = json['summ']['price'].toDouble();
    } else if (json.containsKey('summ') && json['summ']['price'] is double) {
      sum = json['summ']['price'];
    }
    phones = json['counteragent']['phones'] != null
        ? (json['counteragent']['phones'] as List).map((e) => e.toString()).toList()
        : [];
    String dev = '';
    if(json['brand'] != null) dev = dev + json['brand'];
    if(json['model'] != null) dev = dev + ' ' + json['model'];
    if(dev.length == 0) dev = null;
    device = dev;
  }

  @override
  String toString() {
    return 'Order{id: $id, number: $number, dateCreate: $dateCreate, status: $status, contractor: $contractor, device: $device, isUrgent: $isUrgent, isDeadline: $isDeadline, isStatusDeadline: $isStatusDeadline, sum: $sum, phones: $phones}';
  }
}

class Status {
  String title;
  int color;
  Status({this.title, this.color});
}

class Shop {
  String title;
  int color;
}

class NotifyState {}

class LoadShow extends NotifyState {}
class LoadHide extends NotifyState {}
class InternetError extends NotifyState {}
class ReachEndList extends NotifyState {}
