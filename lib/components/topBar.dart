import 'package:flutter/material.dart';
import 'package:client/appConstants.dart';
import '../main.dart';

class TopBar extends AppBar {
  TopBar(BuildContext context, String title, { Key key, PreferredSizeWidget bottom, bool showLogout = false }) : super(
    title: Text(title, style: TextStyle(color: Colors.white, fontSize: 26, fontFamily: AppConstants.topBarFont)),
    bottom: bottom,
    elevation: 1.0,
    backgroundColor: AppConstants.darkMainColor40,
    centerTitle: false,
    brightness: Brightness.dark,
    leading: Navigator.canPop(context) ?
      GestureDetector(
        onTap: () { Navigator.of(context).pop(); },
        child: Icon(Icons.keyboard_arrow_left, size: 30, color: Colors.white)
      ) : null,
    actions: showLogout ? [
      FlatButton(
        onPressed: () async {
          await MyApp.reset(context);
        },
        child: Icon(
          Icons.logout,
          color: Colors.white,
          size: 20.0,
        ),
        shape: CircleBorder(),
        splashColor: Colors.transparent,
        highlightColor: AppConstants.yellowMainColor,
      )
    ] : null
  );
}