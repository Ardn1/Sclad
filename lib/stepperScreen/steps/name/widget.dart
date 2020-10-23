
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:live_sklad/apiData.dart';
import 'package:live_sklad/stepperScreen/steps/name/bloc.dart';
import 'package:live_sklad/stepperScreen/widget.dart';
import 'package:live_sklad/styles.dart';
import 'package:live_sklad/utils.dart';

class NameStep extends StatefulWidget {

  NameStep({this.info, this.valueCallBack});
  final FieldInfo info;
  final Function(FieldInfo info) valueCallBack;

  @override
  createState() => _NameStepState();

}

class _NameStepState extends State<NameStep> {

  NameStepBloc _bloc;
  ScrollController _controller;

  @override
  void initState() {
    _bloc = NameStepBloc(
        info: widget.info,
        valueCallBack: widget.valueCallBack
    );
    _controller = ScrollController()..addListener(() {
      if (_controller.position.extentAfter < 300) {
        _bloc.onReachEnd();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: _bloc.steam,
      initialData: NameState(
        counteragents: [],
        selected: widget.info.value,
      ),
      builder: (_,AsyncSnapshot<NameState> snapshot) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10, right: 19, left: 19),
              child: NormalField(
                controller: _controller,
                selectValue: snapshot.data.selected != null
                    && snapshot.data.selected is Counteragent
                    ? getSearchItem(
                    title: (snapshot.data.selected as Counteragent).name,
                    items: (snapshot.data.selected as Counteragent).phones,) : null,
                onChange: _bloc.onSearch,
                onClear: _bloc.onClear,
                text: snapshot.data.selected is String ? snapshot.data.selected : null,
              ),
            ),
            snapshot.data.counteragents != null
                && snapshot.data.counteragents.length == 0
                && snapshot.data.selected is String
                ? Padding(
              padding: EdgeInsets.only(top: 2, left: 19, right: 19, bottom: 2),
              child: Text('По запросу "${snapshot.data.selected}" ни чего не найдено, '
                  '${!widget.info.isOnlyDictionary ? 'будет создан новый клиент' : ''}',
                style: TextStyle(
                  color: StyleColor.grey1,
                  fontSize: 15,
                  fontFamily:'Regular'
              ),),
            ) : Container(),
            snapshot.data.counteragents != null
                && snapshot.data.counteragents.length != 0
                && (snapshot.data.selected is String)
                ? Padding(
              padding: EdgeInsets.only(top: 2, left: 19, right: 19, bottom: 2),
              child: Text('Выберите контрагента из списка'
                  '${!widget.info.isOnlyDictionary ?
              ' или нажмите "Далее" для создания нового контрагента' : ''}',
                  style: TextStyle(
                    color: StyleColor.grey1,
                    fontSize: 15,
                    fontFamily:'Regular'
              )),
            ) : Container(),
            Expanded(
              child: ListView.builder(
                controller: _controller,
                itemCount: snapshot.data.counteragents.length,
                itemBuilder: (_, int index) => getSearchItem(
                  title: snapshot.data.counteragents[index].name,
                  items: snapshot.data.counteragents[index].phones,
                  onTap: () {
                    Counteragent contr = snapshot.data.counteragents[index];
                    contr.name = contr.name.replaceAll(START_TAG, '')
                        .replaceAll(END_TAG, '');
                    contr.phones = contr.phones
                        .map((e) => e.replaceAll(START_TAG, '')
                        .replaceAll(END_TAG, '')).toList();
                    _bloc.onItemSelect(contr);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}