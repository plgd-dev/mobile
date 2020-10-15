import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_app/appConstants.dart';

class ToastMessage {
  static void show(String text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: AppConstants.blueMainColor,
      fontSize: 16.0,
      timeInSecForIosWeb: 3
    );
  }
}