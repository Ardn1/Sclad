
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live_sklad/apiData.dart';
import 'package:live_sklad/stepperScreen/steps/boolChoice/widget.dart';
import 'package:live_sklad/stepperScreen/steps/dateChoice/widget.dart';
import 'package:live_sklad/stepperScreen/steps/imageChoice/widget.dart';
import 'package:live_sklad/stepperScreen/steps/multiChoice/widget.dart';
import 'package:live_sklad/stepperScreen/steps/name/widget.dart';
import 'package:live_sklad/stepperScreen/steps/phones/widget.dart';
import 'package:live_sklad/stepperScreen/steps/singleChoice/widget.dart';
import 'package:live_sklad/stepperScreen/steps/textInputStep/widget.dart';
import 'package:live_sklad/styles.dart';

import '../api.dart';
import '../utils.dart';

class StepperScreen extends StatelessWidget {

  StepperScreen({
    this.step,
    this.onFieldChange,
    this.onClose,
    this.onForm,
    this.onNext,
    this.onPrev,
    this.howKnowAccess,
    this.problemAccess,
    this.completeSetAccess,
    this.brandModelDeviceAccess,
    this.typeDeviceId,
    this.brandId,
    this.shopId
  });

  final StepInfo step;
  final Function(StepInfo info) onFieldChange;
  final Function() onClose;
  final Function() onForm;
  final Function(StepInfo info) onNext;
  final Function(StepInfo info) onPrev;

  final bool completeSetAccess;
  final bool problemAccess;
  final bool howKnowAccess;
  final bool brandModelDeviceAccess;
  final String typeDeviceId;
  final String brandId;
  final String shopId;


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: StepperToolbar(
          title: step.info.description,
          progress: step.progress,
          isRequired: step.info.isRequired,
          onClose: onClose,
          onGoToForm: onForm,
        ),
        body: _getStep(),
        bottomNavigationBar: _getBottomNavBar(),
      ),
    );
  }

  _valueCallback (FieldInfo info) {
    print('--------------');
    print('_valueCallback');
    print('--------------');
    step.info = info;
    onFieldChange(step);
  }

  Widget _getStep() {
    if (step.info.name != null) {
      //detect system fields
      switch (step.info.name) {
        case NAME: return NameStep(
          info: step.info,
          valueCallBack: _valueCallback,
        );
        case PHONES: return PhonesStep(
          info: step.info,
          valueCallBack: _valueCallback,
          isClose: step.isClose,
        );
        case HOW_KNOW: return SingleChoiceStep<HowKnow>(
            isDictPermission: howKnowAccess,
            info: step.info,
            valueCallBack: _valueCallback,
            search: (text, page, pageSize) =>
                Api.getInstance()
                    .then((value) => value)
                    .then((value) => value.getHowKnows())
                    .then((value) => value != null ? (value['data'] as List) : [])
                    .then((value) => value.map((e) => HowKnow.fromJson(e)).toList())
                    .then((value) => value.where((element) =>
                      text != null && text.length != 0
                          ? element.name.toLowerCase().contains(text)
                          : true).toList())
                    .then((value) => value.map((e) {
                      int start = e.name.toLowerCase().split(text.toLowerCase())[0].length;
                      int end = start + text.length;
                      e.name = e.name.substring(0, start) + START_TAG + e.name.substring(start, end) + END_TAG + e.name.substring(end);
                      return e;
                }).toList()),
            getTitle: (HowKnow element) => element.name,
            isOnlyDict: true,
            addMethod: (text) => Api.getInstance().then((value) => value)
                .then((value) => value.addHowKnow(text))
                .then((value) => value != null ? HowKnow.fromJson(value['data']) : null),
            valueFactory: (Map json) => HowKnow.fromJson(json),
          getClearValue: (value) => value.copyWith(name: value.name.replaceAll(START_TAG, '').replaceAll(END_TAG, '')),
        );
        case TYPE_DEVICE: return SingleChoiceStep<TypeDevice>(
            isDictPermission: brandModelDeviceAccess,
            info: step.info,
            valueCallBack: _valueCallback,
            getTitle: (TypeDevice type) => type.name,
            isOnlyDict: step.info.isOnlyDictionary,
            search: (text, page, pageSize) =>
              Api.getInstance()
                .then((value) => value)
                .then((value) => value.getTypeDevices(
                  filter: text,
                  page: page,
                  pageSize: pageSize,
              )).then((value) => value != null ? (value['data'] as List) : [])
                .then((value) => value.map((e) => TypeDevice.fromJson(e)).toList()),
            addMethod: (text) => Api.getInstance().then((value) => value)
                .then((value) => value.addTypeDevice(text))
                .then((value) => value != null ? TypeDevice.fromJson(value['data']) : null),
            valueFactory: (Map json) => TypeDevice.fromJson(json),
          getClearValue: (value) => value.copyWith(name: value.name.replaceAll(START_TAG, '').replaceAll(END_TAG, '')),
          );
        case BRAND: return SingleChoiceStep<Brand>(
            isDictPermission: brandModelDeviceAccess,
            info: step.info,
            valueCallBack: _valueCallback,
            getTitle: (Brand brand) => brand.name,
            isOnlyDict: step.info.isOnlyDictionary,
            valueFactory: (Map json) => Brand.fromJson(json),
            search: (text, page, pageSize) =>
              Api.getInstance()
                .then((value) => value)
                .then((value) => value.getBrands(
                  filter: text,
                  page: page,
                  pageSize: pageSize,
              )).then((value) => value != null ? (value['data'] as List) : [])
                .then((value) => value.map((e) => Brand.fromJson(e)).toList()),
            addMethod: (text) => Api.getInstance().then((value) => value)
                .then((value) => value.addTypeDevice(text))
                .then((value) => value != null ? Brand.fromJson(value['data']) : null),
            getClearValue: (value) => value.copyWith(name: value.name.replaceAll(START_TAG, '').replaceAll(END_TAG, '')),
          );
        case MODEL: return SingleChoiceStep<Model>(
            isDictPermission: brandModelDeviceAccess,
            info: step.info,
            valueCallBack: _valueCallback,
            getTitle: (Model model) => model.name,
            isOnlyDict: step.info.isOnlyDictionary,
            valueFactory: (Map json) => Model.fromJson(json),
            search: (text, page, pageSize) async => typeDeviceId != null ?
                Api.getInstance()
                    .then((value) => value)
                    .then((value) => value.getModels(
                  typeDeviceId: typeDeviceId,
                  brandId: brandId,
                  filter: text,
                  page: page,
                  pageSize: pageSize,
                )).then((value) => value != null ? (value['data'] as List) : [])
                    .then((value) => value.map((e) => Model.fromJson(e)).toList())
                : [],
            addMethod: typeDeviceId != null ? (text) => Api.getInstance().then((value) => value)
                .then((value) => value.addModel(text, brandId, typeDeviceId: typeDeviceId))
                .then((value) {
                  print('addMethod $value');
                  return value;
                })
                .then((value) => value != null ? Model.fromJson(value['data']) : null) : null,
            getClearValue: (value) => value.copyWith(name: value.name.replaceAll(START_TAG, '').replaceAll(END_TAG, '')),
          );
        case COMPLETE_SET: return MultiChoiceStep<CompleteSet>(
            isClose: step.isClose,
            isDictPermission: completeSetAccess,
            info: step.info,
            valueCallBack: _valueCallback,
            getTitle: (complete) => complete.name,
            valueFactory: (value) => CompleteSet(name: value),
            searchValueFactory: (str) => CompleteSet(name: str),
            equals: (v1, v2) => v1.name == v2.name,
            search: (text, page, pageSize) =>
                Api.getInstance()
                  .then((value) => value.getCompleteSet(
                    filter: text != null ? text : '',
                    pageSize: pageSize,
                    page: page,
            )),
            addMethod: (name) => Api.getInstance()
                .then((value) => value.addCompleteSet(name: name)),
          getClearValue: (value) => value.copyWith(name: value.name.replaceAll(START_TAG, '').replaceAll(END_TAG, '')),
          );
        case PROBLEM: return MultiChoiceStep<Problem>(
            isClose: step.isClose,
            isDictPermission: problemAccess,
            info: step.info,
            valueCallBack: _valueCallback,
            getTitle: (problem) => problem.name,
            valueFactory: (value) => Problem(name: value),
            searchValueFactory: (str) => Problem(name: str),
            equals: (v1, v2) => v1.name == v2.name,
            search: (text, page, pageSize) =>
                Api.getInstance()
                    .then((value) => value.getProblems(
                  filter: text != null ? text : '',
                  pageSize: pageSize,
                  page: page,
                )).then((value) {
                  print(value);
                  return value;
                }),
            addMethod: (name) => Api.getInstance()
                .then((value) => value.addProblem(name: name)),
            getClearValue: (value) => value.copyWith(name: value.name.replaceAll(START_TAG, '').replaceAll(END_TAG, '')),
          );
        case COLOR: return SingleChoiceStep<String>(
            addMethod: null,
            isOnlyDict: step.info.isOnlyDictionary,
            getTitle: (item) => item,
            isDictPermission: false,
            info: step.info,
            valueCallBack: _valueCallback,
            search: (text, _, __) async =>
                step.info.items
                    .where((element) => element.toLowerCase().contains(text.toLowerCase()))
                    .toList().map((e) {
                  int start = e.toLowerCase().split(text.toLowerCase())[0].length;
                  int end = start + text.length;
                  e = e.substring(0, start) + START_TAG + e.substring(start, end) + END_TAG + e.substring(end);
                  return e;
                }).toList(),
            getClearValue: (value) => value.replaceAll(START_TAG, '').replaceAll(END_TAG, ''),
        );
        case APPEARANCE: return MultiChoiceStep<String>(
            isClose: step.isClose,
            isDictPermission: false,
            info: step.info,
            valueCallBack: _valueCallback,
            getTitle: (color) => color,
            valueFactory: (value) => value,
            searchValueFactory: (str) => str,
            equals: (v1, v2) => v1.replaceAll(START_TAG, '').replaceAll(END_TAG, '').toLowerCase()
                == v2.replaceAll(START_TAG, '').replaceAll(END_TAG, '').toLowerCase(),
            search: (text, page, pageSize) async => step.info.items
                  .where((element) => element.contains(text))
                  .toList().map((e) {
                    int start = e.toLowerCase().split(text.toLowerCase())[0].length;
                    int end = start + text.length;
                    e = e.substring(0, start) + START_TAG + e.substring(start, end) + END_TAG + e.substring(end);
                    return e;
                  }).toList(),
            getClearValue: (value) => value.replaceAll(START_TAG, '').replaceAll(END_TAG, ''),
          );
        case MANAGER: return SingleChoiceStep<ManagerMaster>(
            addMethod: null,
            isDictPermission: false,
            isOnlyDict: true,
            getTitle: (manager) => manager.name,
            valueFactory: (json) => ManagerMaster.fromJson(json),
            valueCallBack: _valueCallback,
            info: step.info,
            search: (text, _, __) => Api.getInstance()
                .then((value) => value.getMastersByShopId(
              shopId: shopId,
              filter: text,
              isMaster: false,
            )),
            getClearValue: (value) => value.copyWith(name: value.name.replaceAll(START_TAG, '').replaceAll(END_TAG, '')),
          );
        case MASTER: return SingleChoiceStep<ManagerMaster>(
            addMethod: null,
            isDictPermission: false,
            isOnlyDict: true,
            getTitle: (manager) => manager.name,
            valueFactory: (json) => ManagerMaster.fromJson(json),
            valueCallBack: _valueCallback,
            info: step.info,
            search: (text, _, __) => Api.getInstance()
                .then((value) => value.getMastersByShopId(
              shopId: shopId,
              filter: text,
              isMaster: true,
            )),
          getClearValue: (value) => value.copyWith(name: value.name.replaceAll(START_TAG, '').replaceAll(END_TAG, '')),
          );
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
        case COUNTERAGENT_NODE:
        case BIRTHPLACE:
        case SN:
        case SERIAL_NUMBER: return TextInputStep(
            info: step.info,
            valueCallBack: _valueCallback,
            type: TextStepType.STRING,
          );
        case ORDER_NODE: return TextInputStep(
            info: step.info,
            valueCallBack: _valueCallback,
            type: TextStepType.TEXT,
          );
        case PREPAYMENT:
        case IS_URGENT: return BoolStep(
            info: step.info,
            valueCallBack: _valueCallback,
          );
        case DEADLINE: return DateTimeChoiceStep(
            info: step.info,
            valueCallBack: _valueCallback,
            type: DateType.DATE_TIME,
          );
        case BIRTH_DATE:
        case PASSPORT_DATE: return DateTimeChoiceStep(
            info: step.info,
            valueCallBack: _valueCallback,
            type: DateType.DATE,
          );
        case IMAGES: return ImageChoiceStep(
            info: step.info,
            valueCallBack: _valueCallback,
          );
        default: return Container(
          child: Center(
            child: Text('System Step'),
          ),
        );
      }
    } else {
      switch (step.info.dataType) {
        case ENUM: return SingleChoiceStep<String>(
            addMethod: null,
            isOnlyDict: step.info.isOnlyDictionary,
            getTitle: (item) => item,
            isDictPermission: false,
            info: step.info,
            valueCallBack: _valueCallback,
            search: (text, _, __) async =>
                step.info.items
                    .where((element) => element.toLowerCase().contains(text.toLowerCase()))
                    .toList().map((e) {
                  int start = e.toLowerCase().split(text.toLowerCase())[0].length;
                  int end = start + text.length;
                  e = e.substring(0, start) + START_TAG + e.substring(start, end) + END_TAG + e.substring(end);
                  return e;
                }).toList(),
            getClearValue: (value) => value.replaceAll(START_TAG, '').replaceAll(END_TAG, ''),
          );
        case MULTIPLE: return MultiChoiceStep<String>(
            isClose: step.isClose,
            info: step.info,
            valueCallBack: _valueCallback,
            getTitle: (text) => text,
            isDictPermission: false,
            search: (text, _, __) async =>
                step.info.items
                    .where((element) => element.toLowerCase().contains(text.toLowerCase()))
                    .map((e) => e.toString())
                    .toList().map((e) {
                  int start = e.toLowerCase().split(text.toLowerCase())[0].length;
                  int end = start + text.length;
                  e = e.substring(0, start) + START_TAG + e.substring(start, end) + END_TAG + e.substring(end);
                  return e;
                }).toList(),
            valueFactory: (value) => value.toString(),
            equals: (v1, v2) => v1.replaceAll(START_TAG, '').replaceAll(END_TAG, '').toLowerCase()
                == v2.replaceAll(START_TAG, '').replaceAll(END_TAG, '').toLowerCase(),
            searchValueFactory: (str) => str,
            getClearValue: (value) => value.replaceAll(START_TAG, '').replaceAll(END_TAG, ''),
          );
        case NUMBER: return TextInputStep(
            info: step.info,
            valueCallBack: _valueCallback,
            type: TextStepType.NUMBER,
          );
        case MONEY: return TextInputStep(
            info: step.info,
            valueCallBack: _valueCallback,
            type: TextStepType.MONEY,
          );
        case TEXT: return TextInputStep(
            info: step.info,
            valueCallBack: _valueCallback,
            type: TextStepType.TEXT,
          );
        case STRING: return TextInputStep(
            info: step.info,
            valueCallBack: _valueCallback,
            type: TextStepType.STRING,
          );
        case BOOLEAN: return BoolStep(
            info: step.info,
            valueCallBack: _valueCallback,
          );
        case DATE: return DateTimeChoiceStep(
            info: step.info,
            valueCallBack: _valueCallback,
            type: DateType.DATE,
          );
        case DATE_TIME: return DateTimeChoiceStep(
            info: step.info,
            valueCallBack: _valueCallback,
            type: DateType.DATE_TIME,
          );
      }
      return Container(
        child: Center(
          child: Text('Typical Step'),
        ),
      );
    }
  }

  Widget _getBottomNavBar() {
    return Container(
      height: 80,
      margin: EdgeInsets.only(bottom: 12),
      color: Colors.transparent,
      child: Padding(
        child: Row(
          children: [
            _getBtn(step.previously, false),
            _getBtn(step.next, true)
          ],
        ),
        padding: EdgeInsets.only(left: 14, right: 14, top: 3, bottom: 3),
      ),
    );
  }

  Widget _getBtn (Action action, bool isNext) => Flexible(
    flex: 1,
    child: Padding(
      padding: EdgeInsets.only(left: 5, right: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: Border.all(
                      width: 2,
                      color: isNext ? StyleColor.blue1 : StyleColor.lightGrey,
                    ),
                    color: action.isComplete ? StyleColor.blue1 : Colors.transparent,
                  ),
                  height: 46,
                  child: Center(
                    child: Text(action.isComplete ? 'Создать' : isNext ? 'Далее' : 'Назад',
                      style: TextStyle(
                          color: action.isComplete ? StyleColor.white : StyleColor.text,
                          fontSize: 19,
                          fontFamily: 'Medium',
                      ),),
                  ),
                ),
                onTap: () {
                  isNext ? onNext(step) : onPrev(step);
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 3, bottom: 5),
            child: Text(action.isComplete ? '' : action.title, style: TextStyle(
              color: StyleColor.description,
              fontFamily: 'Regular',
              fontSize: 14,
            ),
            maxLines: 1,
            ),
          ),
        ],
      ),
    ),
  );

}

class StepperToolbar extends StatelessWidget implements PreferredSizeWidget{

  StepperToolbar({
    this.title,
    this.progress,
    this.onClose,
    this.onGoToForm,
    this.isRequired
  });

  final String title;
  final double progress;
  final bool isRequired;
  final Function() onClose;
  final Function() onGoToForm;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: StyleColor.light,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              child: Material(
                child: InkWell(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: SvgPicture.asset(AppIcons.CLOSE),
                  ),
                  onTap: onGoToForm != null ? onGoToForm : (){Navigator.pop(context);},
                ),
                color: Colors.transparent,
              ),
            ),
            flex: 1,
          ),
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: title,
                          style: TextStyle(
                            fontFamily: 'Medium',
                            fontSize: 22,
                            color: StyleColor.text,
                            height: 0.8,
                        ),),
                        TextSpan(
                          text: isRequired ? '*' : '',
                          style: TextStyle(
                            fontFamily: 'Medium',
                            fontSize: 22,
                            color: StyleColor.red1,
                            height: 0.8,
                          ),)
                      ]
                    ),
                  ),
                  Container(height: 10,),
                  ProgressBar(progress: progress,)
                ],
              ),
            ),
            flex: 4,
          ),
          Flexible(
            child: Container(
              width: 25,
            ),
            flex: 1,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(70.0);

}

class ProgressBar extends StatelessWidget {

  ProgressBar({this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(1.5)),
                child: Container(
                  height: 3,
                  color: StyleColor.lightGrey,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(1.5)),
                child: Container(
                  height: 3,
                  width: constraints.maxWidth * progress,
                  color: StyleColor.blue2,
                ),
              ),
            ],
          );
        }
    );
  }
}

Widget getSearchItem ({String title, List<String> items, Function onTap}) {
  List<Widget> childs = [];
  childs.add(Row(
    children: [
      Flexible(
        child: Container(
          child: findText(title,
              color: StyleColor.text,
              family: 'Medium',
              size: 18
          ),
        ),
      )
    ],
  ));
  if (items != null
      && items.length != 0
      && items[0] != '') {
    childs.add(Container(height: 10,));
    childs.addAll(items.map((e) => Row(
      children: [
        findText(e,
            color: StyleColor.text,
            family: 'Regular',
            size: 18
        )
      ],
    )).toList());
  }
  return InkWell(
    child: Container(
      padding: EdgeInsets.only(top: 15, bottom: 15, left: 19, right: 10),
      child: Column(
        children: childs,
      ),
    ),
    onTap: onTap,
  );
}

class StepInfo {

  StepInfo({this.info, this.next, this.previously, this.progress, this.shopId, this.isClose = false});

  FieldInfo info;
  double progress;
  Action previously;
  Action next;
  String shopId;



  bool isClose;

}

class Action {

  Action({this.title, this.isComplete = false});

  String title;
  bool isComplete;
}