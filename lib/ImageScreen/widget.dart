
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:live_sklad/api.dart';
import 'package:live_sklad/styles.dart';

import '../preferences.dart';

class ImageScreen extends StatefulWidget {

  static const String route = '/image';

  ImageScreen({this.uuid});
  final String uuid;

  @override
  createState() => ImageScreenState();

}

class ImageScreenState extends State<ImageScreen> {

  String _path;
  
  @override
  void initState() {
    PrefManager.getInstance().then((value) {
      setState(() {
        _path = 'https://images.livesklad.com/${value.getSelectelId()}/orders/${widget.uuid}';
      });
    });
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Изображение'),
      ),
      body: Stack(
        children: [
          Center(
            child: _path != null ?
              Image.network(_path) : Container(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: InkWell(
              child: Container(
                margin: EdgeInsets.only(bottom: 20),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: StyleColor.lightGrey,
                ),
                child: Icon(Icons.delete_forever),
              ),
              onTap: () {
                Api.getInstance()
                    .then((value) => value.deleteImage(widget.uuid))
                    .then((value) {
                      if (value) Navigator.pop(context, widget.uuid);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

}

class ImageScreenArguments {
  ImageScreenArguments({this.uuid});
  final String uuid;
}