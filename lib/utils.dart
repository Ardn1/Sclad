
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live_sklad/styles.dart';

int fromHex(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return int.parse(buffer.toString(), radix: 16);
}

const String START_TAG = '<b class="find-text" >';
const String END_TAG = '</b>';

RichText findText (String text, {String family, double size, Color color}) {
  String str = text.replaceAll(START_TAG, '<!><!?>').replaceAll(END_TAG, '<!>');
  List<TextSpan> spans = [];
  str.split('<!>').forEach((val) {
    spans.add(TextSpan(
        text: val.replaceAll('<!?>', ''),
        style:  TextStyle(
            color: color != null ? color : Colors.black,
            fontSize: size != null ? size : 12,
            fontFamily: family != null ? family : 'Regular',
            backgroundColor: val.contains('<!?>') ? Colors.yellow : Colors.transparent
        )
    ));
  });
  return RichText(
    textAlign: TextAlign.start,
    text: TextSpan(
        children: spans
    ),
  );
}

Dialog getSingleSelectDialog (List<String> items, {Function(int index) onTap}) {
  return Dialog(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0))
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: StyleColor.white,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              double topLeft = index != 0 ? 0: 10;
              double topRight = index != 0 ? 0: 10;
              double bottomLeft = index != (items.length-1) ? 0: 10;
              double bottomRight = index != (items.length-1) ? 0: 10;
              return ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(topLeft),
                  topRight: Radius.circular(topRight),
                  bottomLeft: Radius.circular(bottomLeft),
                  bottomRight: Radius.circular(bottomRight),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    child: Padding(
                      child: Text(items[index], style: TextStyle(
                          fontFamily: 'Regular',
                          fontSize: 16
                      ),),
                      padding: EdgeInsets.all(20),
                    ),
                    onTap: () {
                      if (onTap != null) onTap(index);
                    },
                  ),
                ),
              );
            },
          ),
        )
      ],
    ),
  );
}

class NormalField extends StatefulWidget {

  NormalField({this.selectValue, this.onClear, this.onChange, this.text, this.controller});

  final Widget selectValue;
  final String text;
  final Function() onClear;
  final Function(String text) onChange;
  final ScrollController controller;

  @override
  createState() => NormalFieldState();

}

class NormalFieldState extends State<NormalField> {

  FocusNode _focusNode;
  Color _fieldColor;
  bool _isFocusInit = false;
  bool _isClear = false;

  @override
  void initState() {
    _focusNode = FocusNode();
    _fieldColor = StyleColor.lightGrey;
    _focusNode.addListener(() {
      setState(() {
        _fieldColor = _focusNode.hasFocus ?
          StyleColor.blue2 : StyleColor.lightGrey;
      });
    });
    widget.controller.addListener(_scrollListener);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!_isFocusInit) {
      FocusScope.of(context).requestFocus(_focusNode);
      _isFocusInit = true;
    }
    super.didChangeDependencies();
  }

  _scrollListener () {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  void dispose() {
//    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectValue == null && _isClear) {
      FocusScope.of(context).requestFocus(_focusNode);
      _isClear = false;
    }
    return AnimatedContainer(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        border: Border.all(width: 2.0, color: widget.selectValue != null
            ? StyleColor.lightGrey : _fieldColor),
        color: widget.selectValue != null ? StyleColor.disabled : StyleColor.field
      ),
      child: widget.selectValue != null ? _getSelectedBody() : _getBody(),
      duration: Duration(milliseconds: 500),
    );
  }

  Widget _getSelectedBody () {
    
    return Padding(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: widget.selectValue,
            flex: 9,
          ),
          Flexible(
            child: getIconButton(
              onTap: () {
                widget.onClear();
                _isClear = true;
              },
              icon: AppIcons.CLOSE,
              color: StyleColor.red1,
            ),
            flex: 1,
          ),
        ],
      ),
      padding: EdgeInsets.all(10),
    );
  }
  
  Widget _getBody() {
    print('_getBody ${widget.text}');
    return Container(
      height: 48,
      child: TextField(
        controller: TextEditingController()..value = TextEditingValue(
            selection: TextSelection.fromPosition(TextPosition(offset: widget.text != null ?
            widget.text.length : 0)),
            text: widget.text != null ? widget.text : ''
        ),
        onChanged: widget.onChange,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Введите заначение',
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.all(10),
          hintStyle: TextStyle(
              fontFamily: 'Regular',
              fontSize: 18,
              color: StyleColor.grey1
          ),
        ),
      ),
    );
  }
  
}

Widget getIconButton({Function onTap, String icon, Color color}) => ClipRRect(
  borderRadius: BorderRadius.all(Radius.circular(5)),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      child: SvgPicture.asset(icon, color: color != null ? color : Colors.black,),
      onTap: onTap,
    ),
  ),
);
