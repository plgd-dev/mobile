import 'dart:async';

import 'package:client/appLocalizations.dart';
import 'package:client/globals.dart';
import 'package:flutter/material.dart';
import 'package:client/appConstants.dart';
import 'package:client/screens/devicesScreen.dart';
import 'package:client/screens/setupScreen.dart';
import 'package:client/screens/splashScreen.dart';
import 'package:client/services/ocfClient.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

bool _isSetupRequired = true;

Future main() async {
    WidgetsFlutterBinding.ensureInitialized();
    Globals.localStorage = await SharedPreferences.getInstance();
    _isSetupRequired = !Globals.localStorage.containsKey(OCFClient.cloudConfigurationStorageKey);
    runZonedGuarded(
      () => runApp(MyApp()),
      (error, stackTrace) async {
        await Globals.sentry.captureException(
          exception: error,
          stackTrace: stackTrace,
        );
      },
    );
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
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('de', ''),
        const Locale('ko', ''),
        const Locale('zh', '')
      ],
      initialRoute: _isSetupRequired ? '/setup' : '/splash',
      routes: {
        '/setup': (context) => SetupScreen(),
        '/splash': (context) => SplashScreen(),
        '/devices': (context) => DevicesScreen(),
      }
    );
  }

  static void showResetAppConfirmationDialog(BuildContext context, Function onCancel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(AppLocalizations.of(context).resetApplicationDialogText),
          actions: <Widget>[
            FlatButton(
              child: Text(AppLocalizations.of(context).resetApplicationDialogCancelButton),
              onPressed: () {
                onCancel();
                Navigator.of(context).pop(false);
              }
            ),
            FlatButton(
              child: Text(AppLocalizations.of(context).resetApplicationDialogYesButton),
              onPressed: () async => await MyApp.reset(context)
            ),
          ],
        );
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
