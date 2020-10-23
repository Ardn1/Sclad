import 'dart:async';
import 'package:live_sklad/api.dart';
import '../apiData.dart';

class TypeOrderBloc {

  TypeOrderBloc({this.select});
  final TypeOrder select;

  StreamController _controller = StreamController<TypeOrderState>();

  Stream<TypeOrderState> get stream {
    Api.getInstance().then((api) {
      api.getTypeOrders().then((value) {
        if (value != null) {
          List<TypeOrder> types = (value['data'] as List).map((e) => TypeOrder.fromJson(e)).toList();
          _controller.sink.add(TypeOrderState(
              types: types,
              select: _detectSelect(types)
          ));
        }
      });
    });
    return _controller.stream;
  }

  int _detectSelect(List<TypeOrder> items) {
    int res;
    if(select != null) {
      items.forEach((element) {
        if(element.id == select.id) {
          res = items.indexOf(element);
          return res;
        }
      });
    }
    return res;
  }

  dispose(){
    _controller.close();
  }

}

class TypeOrderState {
  int select;
  List<TypeOrder> types;
  TypeOrderState({this.types, this.select});
}
