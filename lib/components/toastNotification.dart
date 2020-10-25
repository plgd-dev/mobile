import 'package:flushbar/flushbar.dart';
import 'package:client/appConstants.dart';
import 'package:flutter/material.dart';

class ToastNotification {
  static void show(BuildContext context, String text) {
    Flushbar(
      message: text,
      backgroundColor: AppConstants.blueMainColor,
      flushbarPosition: FlushbarPosition.TOP,
      margin: EdgeInsets.all(5),
      borderRadius: 10,
      duration: Duration(seconds: 3),
      icon: Icon(
        Icons.warning_amber_rounded,
        color: AppConstants.yellowMainColor
      )
    )..show(context);
  }
}