
import 'dart:async';

import 'package:live_sklad/ordersScreen/bloc.dart';
import 'package:live_sklad/preferences.dart';

class ToolbarBloc {

  StreamController _shopController = StreamController<ToolbarState>();

  Stream<ToolbarState> get shopStream {
    PrefManager.getInstance().then((value) {
      _shopController.add(ToolbarState(select: value.getShops()[0], shops: value.getShops()));
    });

    return _shopController.stream;
  }

  dispose() {
    _shopController.close();
  }

  onShopPress(ShopsAccess shop) {
    PrefManager.getInstance().then((value) {
      _shopController.add(ToolbarState(select: shop, shops: value.getShops()));
    });
  }

}

class ToolbarState {

  ToolbarState({this.select, this.shops});

  ShopsAccess select;
  List<ShopsAccess> shops;

}