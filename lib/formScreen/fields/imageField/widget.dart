
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_sklad/ImageScreen/widget.dart';
import 'package:live_sklad/api.dart';
import 'package:live_sklad/preferences.dart';
import 'package:live_sklad/styles.dart';
import 'package:live_sklad/utils.dart';
import 'package:uuid/uuid.dart';

import '../../../apiData.dart';

class ImageChoiceField extends StatefulWidget{

  ImageChoiceField({
    this.info,
    this.valueCallBack,
  });

  final FieldInfo info;
  final Function(FieldInfo info) valueCallBack;

  @override
  createState() => ImageChoiceStepField();

}

class ImageChoiceStepField extends State<ImageChoiceField> {

  final picker = ImagePicker();

  String _path;
  List<String> _images = [];

  final TextStyle _titleStyle = TextStyle(
    fontFamily: 'Regular',
    fontSize: 15,
    color: StyleColor.grey1,
  );
  final TextStyle _errorStyle = TextStyle(
    fontFamily: 'Regular',
    fontSize: 16,
    color: StyleColor.red1,
  );
  final TextStyle _titleReqStyle = TextStyle(
    fontFamily: 'Regular',
    fontSize: 15,
    color: StyleColor.red1,
  );

  @override
  void initState() {
    PrefManager.getInstance().then((value) {
      _path = 'https://images.livesklad.com/${value.getSelectelId()}/orders/';
      if (widget.info.value is List) {
        setState(() {
          _images = widget.info.value;
        });
      }
    });
    super.initState();
  }

  _notify() {
    widget.valueCallBack(FieldInfo(
      id: widget.info.id,
      value: _images != null && _images.length > 0 ? _images : null,
      isOnlyDictionary: widget.info.isOnlyDictionary,
      isBlock: widget.info.isBlock,
      isRequired: widget.info.isRequired,
      defaultValue: widget.info.defaultValue,
      items: widget.info.items,
      name: widget.info.name,
      dataType: widget.info.dataType,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.info.description != null ? Container(
          margin: EdgeInsets.only(left: 10, bottom: widget.info.errorMessage is String ? 5:0),
          child: Row(
            children: [
              Text(widget.info.description, style: _titleStyle,),
              Text(widget.info.isRequired ? '*' : '', style: _titleReqStyle,)
            ],
          ),
        ) : Container(),
        Container(
          margin: widget.info.errorMessage is String ? EdgeInsets.only(left: 10, right: 10, bottom: 5) : null,
          decoration: widget.info.errorMessage is String ? BoxDecoration(
            border: Border.all(
              color: StyleColor.red1,
              width: 2,
            ),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ) : null,
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.start,
                  children: _images.map((e) => _getImageItem(e)).toList()..add(
                      GestureDetector(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: Radius.circular(10),
                            strokeWidth: 2,
                            dashPattern: [3, 3, 3, 3],
                            color: StyleColor.lightGrey,
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              child: Container(
                                height: 70,
                                width: 70,
                                padding: EdgeInsets.all(22),
                                child: SvgPicture.asset(AppIcons.PLUS, color: StyleColor.lightGrey,),
                              ),
                            ),
                          ),
                        ),
                        onTap: _uploadImage,
                      )
                  ),
                ),
              )
            ],
          ),
        ),
        widget.info.errorMessage != null ? Row(
          children: [
            Container(
              padding: EdgeInsets.only(left: 10),
              child: Text(widget.info.errorMessage, style: _errorStyle,),
            )
          ],
        ): Container(),
      ],
    );
  }

  Widget _getImageItem (String uuid) => Padding(
    padding: EdgeInsets.all(10),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: GestureDetector(
        child: Image.network(
          '$_path$uuid',
          height: 80.0,
          width: 80.0,
        ),
        onTap: () async {
          Navigator.of(context)
              .pushNamed(ImageScreen.route, arguments: ImageScreenArguments(uuid: uuid))
              .then((value) {
            if (value is String) {
              setState(() {
                _images.remove(value);
                _notify();
              });
            }
          });
        },
      ),
    ),
  );

  _uploadImage() async {
    showDialog(
      context: context,
      child: getSingleSelectDialog(['Камера', 'Галерея'], onTap: (index) async {
        Navigator.of(context).pop();
        var quality = 70;
        var size = 1000.0;
        final PickedFile pickedFile = await picker.getImage(
            source: index == 0 ? ImageSource.camera : ImageSource.gallery,
            imageQuality: quality,
            maxWidth: size,
            maxHeight: size
        );
        if (pickedFile != null) {
          File file = File(pickedFile.path);
          String uuid = await Api.getInstance()
              .then((value) => value.putImage(file))
              .then((value) => value);
          File smallFile = await _compress(file);
          String uuidSmall = await Api.getInstance()
              .then((value) => value.putImage(smallFile, isPreview: true, uuid: uuid))
              .then((value) => value);
          if (uuid != null) {
            setState(() {
              _images.add(uuid);
              _notify();
            });
          }
        }
      }),
    );
  }

  Future<File> _compress(File file) async {
    var path = file.absolute.path;
    var newPath = '${path.substring(0, path.length-6)}small${path.substring(path.length-6, path.length)}';
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      newPath,
      quality: 90,
      minHeight: 100,
      minWidth: 100,
    );
    return result;
  }

}