import 'package:flutter/material.dart';

Widget customToast (String text) => Container(
  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(25.0),
    color: Colors.grey,
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Flexible(
        child: Text(text,style: TextStyle(
            color: Colors.white
        ),),
      ),
    ],
  ),
);