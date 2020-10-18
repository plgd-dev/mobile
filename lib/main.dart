import 'package:flutter/material.dart';
import 'package:my_app/appConstants.dart';
import 'package:my_app/screens/devicesScreen.dart';
import 'package:my_app/screens/setupScreen.dart';
import 'package:my_app/screens/splashScreen.dart';
import 'package:my_app/services/ocfClient.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'globals.dart';

bool _isSetupRequired = true;

Future main() async {
    WidgetsFlutterBinding.ensureInitialized();
    Globals.localStorage = await SharedPreferences.getInstance();
    _isSetupRequired = !Globals.localStorage.containsKey(OCFClient.cloudConfigurationStorageKey);
    runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'plgd.cloud',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        indicatorColor: AppConstants.darkMainColor,
        accentColor: AppConstants.darkMainColor,
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))
          )
        )
      ),
      initialRoute: _isSetupRequired ? '/setup' : '/splash',
      routes: {
        '/setup': (context) => SetupScreen(),
        '/splash': (context) => SplashScreen(),
        '/devices': (context) => DevicesScreen(),
      }
    );
  }

  static Future reset(BuildContext context) async {
    var storage = await SharedPreferences.getInstance();
    await storage.remove(OCFClient.cloudConfigurationStorageKey);
    OCFClient.destroy();
    WebView.platform.clearCookies();
    Navigator.of(context).pushNamedAndRemoveUntil('/setup', (route) => false);
  }
}
