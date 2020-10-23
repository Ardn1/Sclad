
import 'dart:async';
import 'package:live_sklad/api.dart';
import 'package:live_sklad/apiData.dart';
import 'package:live_sklad/preferences.dart';
import 'package:live_sklad/stepperScreen/widget.dart';

class CreateOrderBloc {

  final String shopId;
  CreateOrderBloc({this.shopId});

  CreateOrderState _state;

  TypeOrder _typeOrderSelect;
  List<FieldInfo> _form;

  bool _completeSetAccess = false;
  bool _problemAccess = false;
  bool _howKnowAccess = false;
  bool _brandModelDeviceAccess = false;

  StreamController _controller = StreamController<CreateOrderState>();
  StreamController _eventController = StreamController<Event>();

  Stream<CreateOrderState> get stream {
    PrefManager.getInstance()
        .then((value) => value)
        .then((value) {
          value.getAccess().forEach((element) {
            switch (element) {
              case 'completeSetAccess': _completeSetAccess = true; break;
              case 'problemAccess': _problemAccess = true; break;
              case 'howKnowAccess': _howKnowAccess = true; break;
              case 'brandModelDeviceAccess': _brandModelDeviceAccess = true; break;
            }
          });
    });
    CreateOrderState state = OpenTypeOrder(typeOrder: _typeOrderSelect);
    if(_state == null) _state = state;
    _controller.sink.add(_state);
    return _controller.stream;
  }

  Stream<Event> get eventStream => _eventController.stream;

  double _getProgress (int index) => (index + 1)/_form.length;

  //get current position by Step Info
  int _getPosition (StepInfo info) {
    int pos;
    if(_form != null) {
      _form.forEach((element) {
        if(element.id == info.info.id) {
          pos = _form.indexOf(element);
          return pos;
        }
      });
    }
    return pos;
  }

  dispose () {
    _controller.close();
    _eventController.close();
  }

  onTypeOrderSelect(TypeOrder type) async {
    if (_typeOrderSelect != null && type.id == _typeOrderSelect.id) {
      _updateState(OpenStepper(
          step: StepInfo(
            info: _form[0],
            next: Action(
              title: _form.length == 1 ? '' : _form[1].description,
              isComplete: _form.length == 1,
            ),
            previously: Action(
              title: 'Тип заказа',
            ),
            progress: _getProgress(0),
          )
      ));
      return;
    }
    _typeOrderSelect = type;
    Api api = await Api.getInstance();
    api.getFormByTypeId(_typeOrderSelect.id).then((value) {
      if(value != null) {
        _form = (value['data'] as List)
            .map((e) => FieldInfo.fromJson(e))
            .toList()
            ..sort((a, b) {
              int a1 = int.parse(a.position.split('.')[0]);
              int a2 = int.parse(a.position.split('.')[1]);
              int a3 = int.parse(a.position.split('.')[2]);
              int b1 = int.parse(b.position.split('.')[0]);
              int b2 = int.parse(b.position.split('.')[1]);
              int b3 = int.parse(b.position.split('.')[2]);
              if (a1 > b1) {
                return 1;
              } else if (a1 < b1) {
                return -1;
              } else {
                if (a2 > b2) {
                  return 1;
                } else if (a2 < b2) {
                  return -1;
                } else {
                  if (a3 > b3) {
                    return 1;
                  } else if (a3 < b3) {
                    return -1;
                  } else {
                    return 0;
                  }
                }
              }
            });
        int telegramPos;
        _form.forEach((element) {
          if(element.name == TELEGRAM) telegramPos = _form.indexOf(element);
        });
        if (telegramPos != null) _form.removeAt(telegramPos);
        _updateState(OpenStepper(
            step: StepInfo(
              info: _form[0],
              next: Action(
                title: _form.length == 1 ? '' : _form[1].description,
                isComplete: _form.length == 1,
              ),
              previously: Action(
                title: 'Тип заказа',
              ),
              progress: _getProgress(0),
            )
        ));
      }
    });
  }

  onNextField(StepInfo stepInfo) {
    onStepFieldChange(stepInfo, doAfter: () {
      int pos = _findPosAfter(_getPosition(stepInfo));
      if (pos != null) {
        if (stepInfo.info.isRequired && stepInfo.info.value == null) {
          _eventController.sink.add(ShowError(error: 'Поле обязательно'));
        } else {
          _updateState(OpenStepper(
              step: StepInfo(
                progress: _getProgress(pos),
                previously: _getActionByCurrentPosition(pos),
                next: _getActionByCurrentPosition(pos, isNext: true),
                info: _form[pos],
              )
          ));
        }
      } else {
        onCreate();
      }
    });
  }

  onPrevField(StepInfo stepInfo) {
    int pos = _findPosPrev(_getPosition(stepInfo));
    if (pos != null) {
      _updateState(OpenStepper(
          step: StepInfo(
            progress: _getProgress(pos),
            previously: _getActionByCurrentPosition(pos),
            next: _getActionByCurrentPosition(pos, isNext: true),
            info: _form[pos],
          )
      ));
    } else {
      _updateState(OpenTypeOrder(typeOrder: _typeOrderSelect));
    }
  }

  _updateState(CreateOrderState state) {
    _state = state;
    if(_state is OpenStepper) {
      (_state as OpenStepper).brandModelDeviceAccess = _brandModelDeviceAccess;
      (_state as OpenStepper).completeSetAccess = _completeSetAccess;
      (_state as OpenStepper).problemAccess = _problemAccess;
      (_state as OpenStepper).howKnowAccess = _howKnowAccess;
      _form.forEach((element) {
        if (element.value is TypeDevice)
          (_state as OpenStepper).typeDeviceId = (element.value as TypeDevice).id;
        if (element.value is Brand)
          (_state as OpenStepper).brandId = (element.value as Brand).id;
      });
    }
    _controller.sink.add(_state);
  }

  onStepFieldChange(StepInfo stepInfo, {Function doAfter}) {
    /** FIND FIELD WHERE VALUE CHANGE */
    print('onStepFieldChange ${stepInfo.info.dataType}');
    _form.forEach((element) {
      if (stepInfo.info.id == element.id) {
        int currentPosition = _form.indexOf(element);
        /** IF COUNTERAET SET INTO NAME/PHONES FIELD */
        if(_form[currentPosition].value != stepInfo.info.value
            && stepInfo.info.value is Counteragent) {
          _setCounteragent((stepInfo.info.value as Counteragent).id, onNext: () {
            _updateState(OpenStepper(
              step: StepInfo(
                info: _form[currentPosition],
                progress: _getProgress(currentPosition),
                previously: _getActionByCurrentPosition(currentPosition),
                next: _getActionByCurrentPosition(currentPosition, isNext: true),
                isClose: doAfter != null,
              ),
            ));
          });
        }
        /** IF STRING OR NULL SET INTO NAME FIELD */
        if(_form[currentPosition].value is Counteragent
            && !(stepInfo.info.value is Counteragent)) {
          _form.forEach((element) {
            int pos = _form.indexOf(element);
            if(_form[pos].type == COUNTERAGENT) {
              _form[pos].value = null;
              _form[pos].isBlock = false;
            }
            if (_form[pos].name == NAME && !(_form[pos].defaultValue is String)) {
              _form[pos].defaultValue = null;
            }
          });
          _updateState(OpenStepper(
            step: StepInfo(
              info: _form[currentPosition],
              progress: _getProgress(currentPosition),
              previously: _getActionByCurrentPosition(currentPosition),
              next: _getActionByCurrentPosition(currentPosition, isNext: true),
              isClose: doAfter != null,
            ),
          ));
        }
        _form[currentPosition].value = stepInfo.info.value;
        if (stepInfo.info.dataType != MONEY)_updateState(OpenStepper(
          step: StepInfo(
            info: _form[currentPosition],
            progress: _getProgress(currentPosition),
            previously: _getActionByCurrentPosition(currentPosition),
            next: _getActionByCurrentPosition(currentPosition, isNext: true),
            isClose: doAfter != null,
          ),
        ));
      }
    });
    Future.delayed(Duration(milliseconds: 50), () {doAfter?.call();});
  }

  Action _getActionByCurrentPosition(int position, {bool isNext = false}) => Action(
    isComplete: isNext ? _findPosAfter(position) != null ? false : true : false,
    title: isNext ? _findPosAfter(position) != null
        ? _form[_findPosAfter(position)].description : ''
        : _findPosPrev(position) != null
        ? _form[_findPosPrev(position)].description : 'Тип заказа',
  );

  int _findPosAfter (int currentPosition) {
    int res;
    if (currentPosition < _form.length) {
      for (int p = currentPosition + 1; p < _form.length; p++) {
        if (!_form[p].isBlock) {
          res = p;
          break;
        }
      }
    }
    return res;
  }

  int _findPosPrev (int currentPosition) {
    int res;
    if (currentPosition != 0) {
      for (int p = currentPosition - 1; p > -1; p--) {
        if (!_form[p].isBlock) {
          res = p;
          break;
        }
      }
    }
    return res;
  }

  onGoToForm() {
    FieldInfo lastPosition = (_state as OpenStepper).step.info;
    String id;
    _form.forEach((element) {
      element.errorMessage = null;
      if (element.name == NAME && element.defaultValue is Counteragent) {
        id = (element.defaultValue as Counteragent).id;
        if (id != null) {
          element.value = element.defaultValue;
        }
      }
      if (element.name != NAME && element.name != PHONES && element.value == null) {
        switch (element.name) {
          case BRAND:
            if (element.defaultValue.toString().contains('{')) {
              element.value = Brand.fromJson(element.defaultValue);
            } else element.value = element.defaultValue;
            break;
          case MODEL:
            if (element.defaultValue.toString().contains('{')) {
              element.value = Model.fromJson(element.defaultValue);
            } else element.value = element.defaultValue;
            break;
          case TYPE_DEVICE:
            if (element.defaultValue.toString().contains('{')) {
              element.value = TypeDevice.fromJson(element.defaultValue);
            } else element.value = element.defaultValue;
            break;
          case MASTER:
          case MANAGER:
            if (element.defaultValue.toString().contains('{')) {
              element.value = ManagerMaster.fromJson(element.defaultValue);
            } else element.value = element.defaultValue;
            break;
          case BIRTH_DATE:
          case PASSPORT_DATE:
          case DEADLINE:
            if (element.defaultValue is String && !element.isBlock) {
              element.value = _getDateTime(element.defaultValue);
            }
            break;
          default: {
            if (element.dataType == DATE_TIME || element.dataType == DATE) {
              if (element.defaultValue is String) {
                element.value = _getDateTime(element.defaultValue);
              }
            } else {
              element.value = element.defaultValue;
            }
          }
        }

      }
    });
    if (id != null) {
      _setCounteragent(id, onNext: () {
        _updateState(OpenForm(fields: _form, typeOrder: _typeOrderSelect, lastPosition: lastPosition));
      });
      return;
    }
    _updateState(OpenForm(fields: _form, typeOrder: _typeOrderSelect, lastPosition: lastPosition));
  }

  _getDateTime (String defValue) {
    if (defValue.contains('after;')) {
      return DateTime.now().add(Duration(
        days: int.parse(defValue.split(';')[1]),
        hours: int.parse(defValue.split(';')[2]),
        minutes: int.parse(defValue.split(';')[3]),
      )).millisecondsSinceEpoch;
    } else if (defValue.contains('afterintime;')) {
      var date = DateTime.now().add(Duration(days: int.parse(defValue.split(';')[1])));
      return DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(defValue.split(';')[2]),
        int.parse(defValue.split(';')[3]),
      ).millisecondsSinceEpoch;
    } else return _parseDateTime(defValue).millisecondsSinceEpoch;
  }

  DateTime _parseDateTime (String text) => DateTime(
    int.parse(text.split('T')[0].split('-')[0]),
    int.parse(text.split('T')[0].split('-')[1]),
    int.parse(text.split('T')[0].split('-')[2]),
    int.parse(text.split('T')[1].split(':')[0]),
    int.parse(text.split('T')[1].split(':')[1]),
  );

  _setCounteragent(String id, {Function onNext}) {
    Api.getInstance().then((api) {
      api.getCounteragentById(id)
          .then((value) {
        ///SET COUNTERAGENT
        _form.forEach((element) {
          if (element.name == PHONES && element.value is Counteragent) {
            _form.forEach((el) {
              if (el.name == NAME) el.value = element.value;
            });
          }
        });
        _form.forEach((field) {
          if ((value['data'] as Map).containsKey(field.name)) {
            if (field.name != NAME) {
              field.value = value['data'][field.name];
            }
          }
          if (value['data']['customFields'] is List) {
            (value['data']['customFields'] as List).forEach((element) {
              if (element['id'] == field.id) field.value = element['value'];
            });
          }
        });
        if((value['data'] as Map).containsKey('howKnowId')
            && (value['data'] as Map).containsKey('combobox')
            && (value['data']['combobox'] as Map).containsKey('howKnow')) {
          (value['data']['combobox']['howKnow'] as List).forEach((element) {
            if ((element as Map)['id'] == value['data']['howKnowId']) {
              _form.forEach((el) {
                if (el.name == HOW_KNOW) {
                  el.value = HowKnow.fromJson(element);
                }
              });
            }
          });
        }
        if ((value['data'] as Map).containsKey('node')) {
          _form.forEach((el) {
            if (el.name == COUNTERAGENT_NODE) {
              el.value = value['data']['node'];
            }
          });
        }
        _form.forEach((field) {
          if (field.type == COUNTERAGENT
              && field.name != NAME
              && field.name != HOW_KNOW) {
            field.isBlock = true;
          }
        });
        if (onNext != null) onNext.call();
      });
    });
  }

  onFieldChange(FieldInfo info) {
    int pos;
    _form.forEach((element) {
      if(element.id == info.id) pos = _form.indexOf(element);
    });
    _form[pos].value = info.value;
  }

  onGoToStep(FieldInfo info) {
    if (info.name == TYPE_ORDER) {
      _updateState(OpenTypeOrder(typeOrder: _typeOrderSelect));
    } else {
      int currentPosition = _form.indexOf(info);
      _updateState(OpenStepper(
        step: StepInfo(
          shopId: shopId,
          info: info,
          progress: _getProgress(currentPosition),
          previously: _getActionByCurrentPosition(currentPosition),
          next: _getActionByCurrentPosition(currentPosition, isNext: true),
        ),
      ));
    }
  }

  bool _validate() {
    bool res = true;
    _form.forEach((element) {
      if (element.isRequired) {
        if (element.value == null) {
          res = false;
          element.errorMessage = 'Обязательное поле';
        }
      }
    });
    if (!res) {
      _eventController.sink.add(ShowError(error: 'Заполните обязательные поля'));
      _updateState(OpenForm(fields: _form, typeOrder: _typeOrderSelect));
    }
    return res;
  }

  bool _isPrepayment() {
    bool res = false;
    _form.forEach((element) {
      if (element.name == PREPAYMENT && (element.value == true || (element.value == null && element.defaultValue == true))) {
        res = true;
      }
    });
    return res;
  }

  onCreate () {
    if (_validate()) {
      if (_isPrepayment()) {
        Api.getInstance()
            .then((value) => value.getCashRegisters(shopId: shopId))
            .then((value) {
              _eventController.sink.add(ShowPrepayment(cashRegister: value));
        });
      } else {
        _saveNewOrder();
      }
    }
  }

  onPrepaymentChoice (CashRegister cashRegister, dynamic bank, dynamic cash) {
    _saveNewOrder(def: <String, dynamic>{
      'cashRegisterId' : cashRegister.id,
      'prepaymentMoney' : cash,
      'prepaymentBank' : bank,
    });
  }

  onCreateWithoutPay() {
    _saveNewOrder();
  }

  _saveNewOrder({Map<String, dynamic> def}) {
    if (def == null) def = <String, dynamic>{};
    def['typeOrderId'] = _typeOrderSelect.id;
    _form.forEach((element) {
      if (element.name != null) {
        switch (element.name) {
          case NAME:
            if (element.value != null) {
              if (element.value is Counteragent) {
                def['counteragentId'] = (element.value as Counteragent).id.toString();
              } else {
                def[element.name] = element.value.toString();
              }
            }
            break;
          case PHONES:
            if (element.value is List<String> && !element.isBlock) {
              def['phones'] = element.value;
            }
            break;
          case INN:
          case ADDRESS:
          case OGRN:
          case DIRECTOR:
          case EMAIL:
          case BANK_ACCOUNT:
          case BANK_BIK:
          case BANK_COR:
          case BANK_NAME:
          case BANK_SWIFT:
          case ADDRESS:
          case KPP:
          case APPROXIMATE_PRICE:
          case PASSPORT_CODE_OFFICE:
          case PASSPORT_OFFICE:
          case CONTRACT:
          case BIRTHPLACE:
          case SN:
          case SERIAL_NUMBER:
          case ORDER_NODE:
          case COUNTERAGENT_NODE:
            if (element.value != null && !element.isBlock)
              def[element.name] = element.value.toString();
            break;
          case MASTER:
            if (element.value != null && !element.isBlock) {
              if (element.value is ManagerMaster) {
                def['masterId'] = (element.value as ManagerMaster).id.toString();
              }
            }
            break;
          case MANAGER:
            if (element.value != null && !element.isBlock) {
              if (element.value is ManagerMaster) {
                def['managerId'] = (element.value as ManagerMaster).id.toString();
              }
            }
            break;
          case TYPE_DEVICE:
            if (element.value != null && !element.isBlock) {
              if (element.value is TypeDevice) {
                def['typeDeviceId'] = (element.value as TypeDevice).id.toString();
              } else {
                def['typeDevice'] = element.value.toString();
              }
            }
            break;
          case MODEL:
            if (element.value != null && !element.isBlock)
              if (element.value is Model) {
                def['model'] = (element.value as Model).name.toString();
              } else {
                def['model'] = element.value.toString();
              }
            break;
          case HOW_KNOW:
            if (element.value != null && !element.isBlock && element.value is HowKnow)
              def['howKnowId'] = (element.value as HowKnow).id;
            break;
          case BRAND:
            if (element.value != null && !element.isBlock)
              if (element.value is Brand) {
                def['brandId'] = (element.value as Brand).id.toString();
                def['brand'] = (element.value as Brand).name.toString();
              } else {
                def['brand'] = element.value.toString();
              }
            break;
          case IMAGES:
            if (element.value is List<String>) {
              def['images'] = element.value;
            } break;
          case COMPLETE_SET:
            if (element.value is List) {
              def[element.name] = (element.value as List).map((e) {
                if (e is CompleteSet) {
                  return e.name.toString();
                } else return e.toString();
              }).toList();
            } break;
          case PROBLEM:
            if (element.value is List) {
              def[element.name] = (element.value as List).map((e) {
                if (e is Problem) {
                  return e.name.toString();
                } else return e.toString();
              }).toList();
            } break;
          case COLOR:
            if (element.value is String) {
              def[element.name] = element.value.toString();
            } break;
          case APPEARANCE:
            if (element.value is List) {
              def[element.name] = (element.value as List).map((e) => e.toString())
                  .toList();
            } break;
          case IS_URGENT:
          case PREPAYMENT:
            if (element.value != null && element.value is bool)
              def[element.name] = element.value;
            break;
          case BIRTH_DATE:
          case PASSPORT_DATE:
          case PASSPORT_DATE:
          case DEADLINE:
            if (element.value != null && element.value is int)
              def[element.name] = element.value;
            break;
        }
      } else {
        if (!def.containsKey('customFields')) def['customFields'] = List<Map<String, dynamic>>();
        if (!element.isBlock && element.value != null) {
          (def['customFields'] as List<Map<String, dynamic>>).add(<String, dynamic>{
            'id': element.id,
            'value': element.value,
          });
        }
      }
    });

    Api.getInstance().then((value) => value.saveNewOrder(shopId: shopId, orderBody: def))
      .then((value) {

       if (value != null) {
         _eventController.sink.add(GoToOrderList(
           newOrder: value['data'],
         ));
       }
    });

  }

  onClose() {
    //TODO pop and clean images
    _eventController.sink.add(GoToOrderList());
  }
}

class CreateOrderState {}
class Event {}

class OpenTypeOrder extends CreateOrderState {
  OpenTypeOrder({this.typeOrder});
  TypeOrder typeOrder;
}

class OpenStepper extends CreateOrderState {
  StepInfo step;
  OpenStepper({this.step});
  bool completeSetAccess;
  bool problemAccess;
  bool howKnowAccess;
  bool brandModelDeviceAccess;
  String typeDeviceId;
  String brandId;
}

class OpenForm extends CreateOrderState {
  List<FieldInfo> fields;
  TypeOrder typeOrder;
  FieldInfo lastPosition;
  OpenForm({this.fields, this.typeOrder, this.lastPosition});
}

class ShowError extends Event {
  ShowError({this.error});
  String error;
}

class ShowPrepayment extends Event {
  ShowPrepayment({this.cashRegister});
  final List<CashRegister> cashRegister;
}

class GoToOrderList extends Event {
  GoToOrderList({this.newOrder});
  final Map newOrder;
}





