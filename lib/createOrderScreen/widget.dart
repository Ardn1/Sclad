import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:live_sklad/api.dart';
import 'package:live_sklad/apiData.dart';
import 'package:live_sklad/createOrderScreen/bloc.dart';
import 'package:live_sklad/formScreen/widget.dart';
import 'package:live_sklad/preraymentSheet/widget.dart';
import 'package:live_sklad/stepperScreen/widget.dart';
import 'package:live_sklad/typeOrderSelectScreen/widget.dart';

import '../toast.dart';

class CreateOrderScreen extends StatefulWidget {

  static final String route = '/create_order';

  CreateOrderScreen({this.shopId});
  final shopId;

  @override
  createState() => CreateOrderScreenState();

}

class CreateOrderScreenState extends State<CreateOrderScreen> {

  CreateOrderBloc _bloc;
  FlutterToast _toast;
  GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();
  StreamSubscription _errorEventStream;

  @override
  void dispose() {
    _bloc.dispose();
    if(_errorEventStream!=null)_errorEventStream.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _toast = FlutterToast(context);
    _bloc = CreateOrderBloc(shopId: widget.shopId);
    _bloc.eventStream.listen((event) {
      if(event is ShowError) {
        _showError(event.error);
      } else if (event is ShowPrepayment) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => PrepaymentSheet(
            cashRegisters: event.cashRegister,
            goWithoutPayment: (){
              Navigator.pop(context);
              _bloc.onCreateWithoutPay();
            },
            goPayment: (cashRegister, bank, cash) {
              Navigator.pop(context);
              _bloc.onPrepaymentChoice(cashRegister, bank, cash);
            },
          ),
        );
      } else if (event is GoToOrderList) {
        if (event.newOrder != null) {
          Navigator.pop(context, event.newOrder);
        } else {
          Navigator.pop(context);
        }
      }
    });
    Api.getInstance().then((api) {
      _errorEventStream = api.subscribeOnErrors((error) {
        _keyScaffold.currentState.showSnackBar(SnackBar(
          content: Text(error.message),
        ));
      });
    });
    super.initState();
  }

  void _showError(String text) {
    _toast.showToast(
      child: customToast(text),
      gravity: ToastGravity.CENTER,
    );
  }

  Widget _streamBuilder (_, snapshot) {
    if (snapshot.data is OpenTypeOrder) {
      return TypeOrderScreen(
        typeOrderSelect: (snapshot.data as OpenTypeOrder).typeOrder,
        callBack: (type) {
          _bloc.onTypeOrderSelect(type);
        },
      );
    } else if (snapshot.data is OpenStepper) {
      return StepperScreen(
        onClose: _bloc.onClose,
        step: (snapshot.data as OpenStepper).step,
        onFieldChange: _bloc.onStepFieldChange,
        onNext: _bloc.onNextField,
        onPrev: _bloc.onPrevField,
        onForm: _bloc.onGoToForm,
        brandModelDeviceAccess: (snapshot.data as OpenStepper)
            .brandModelDeviceAccess,
        completeSetAccess: (snapshot.data as OpenStepper).completeSetAccess,
        howKnowAccess: (snapshot.data as OpenStepper).howKnowAccess,
        problemAccess: (snapshot.data as OpenStepper).problemAccess,
        brandId: (snapshot.data as OpenStepper).brandId,
        typeDeviceId: (snapshot.data as OpenStepper).typeDeviceId,
        shopId: widget.shopId,
      );
    } else if (snapshot.data is OpenForm) {
      return FormScreen(
        fields: (snapshot.data as OpenForm).fields,
        typeOrder: (snapshot.data as OpenForm).typeOrder,
        openStepCallback: _bloc.onGoToStep,
        onClose: _bloc.onClose,
        onCreate: _bloc.onCreate,
        valueCallback: _bloc.onFieldChange,
        lastPosition: (snapshot.data as OpenForm).lastPosition,
      );
    } else {
      return Text('Error');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _keyScaffold,
      body: StreamBuilder(
        stream: _bloc.stream,
        builder: _streamBuilder,
      ),
    );
  }

}

class CreateOrderScreenArguments {
  final String shopId;
  CreateOrderScreenArguments({this.shopId});
}