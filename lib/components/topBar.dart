import 'package:flutter/material.dart';
import 'package:client/appConstants.dart';
import 'package:google_fonts/google_fonts.dart';

class TopBar extends AppBar {
  TopBar(BuildContext context, String title, { Key key, PreferredSizeWidget bottom, IconData actionIcon, Function onPop, Function action}) : super(
    title: Text(title, style: GoogleFonts.mulish(color: Colors.white, fontSize: 26)),
    bottom: bottom,
    elevation: 1.0,
    backgroundColor: AppConstants.mainColor,
    centerTitle: false,
    brightness: Brightness.dark,
    leading: Navigator.canPop(context) ?
      GestureDetector(
        onTap: () {
          if (onPop == null) {
            Navigator.of(context).pop();
          } else {
            onPop();
          }
        },
        child: Icon(Icons.keyboard_arrow_left, size: 30, color: Colors.white)
      ) : null,
    actions: actionIcon != null && action != null ? [
      TextButton(
        onPressed: action,
        child: Icon(
          actionIcon,
          color: Colors.white,
          size: 20.0,
        ),
      )
    ] : null
  );
}