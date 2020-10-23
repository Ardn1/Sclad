
import 'dart:async';

class MainScreenBloc {

  StreamController _streamController = StreamController<MainState>();

  Stream get stream => _streamController.stream;

  dispose() {
    _streamController.close();
  }

  onOrdersSelect() {
    _streamController.sink.add(OpenOrders());
  }

  onProfileSelect() {
    _streamController.sink.add(OpenProfile());
  }

  void onNewOrderAdd(Map<dynamic, dynamic> order) {
    _streamController.sink.add(OpenOrders(newOrder: order));
  }

}

class MainState {}

class OpenOrders extends MainState {
  OpenOrders({this.newOrder});
  Map newOrder;
}
class OpenProfile extends MainState {}