import 'dart:async';

import 'package:client/appLocalizations.dart';
import 'package:client/globals.dart';
import 'package:client/screens/configurationScreen.dart';
import 'package:flutter/material.dart';
import 'package:client/appConstants.dart';
import 'package:client/screens/devicesScreen.dart';
import 'package:client/screens/setupScreen.dart';
import 'package:client/services/ocfClient.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/configurationDetails.dart';

Future main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Globals.initialize();
    runZonedGuarded(
      () => runApp(MyApp()),
      (error, stackTrace) async {
        await Globals.sentry.captureException(
          error,
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
      initialRoute: '/setup',
      routes: {
        '/setup': (context) => SetupScreen(),
        '/devices': (context) => DevicesScreen(),
        '/configuration': (context) => ConfigurationScreen(),
        '/configurationDetails': (context) => ConfigurationDetails(),
      }
    );
  }

  static void showResetAppConfirmationDialog(BuildContext context, Function onCancel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(AppLocalizations.of(context).switchPlgdInstanceDialogText),
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
    OCFClient.destroy();
    await CookieManager.instance().deleteAllCookies();
    if (ModalRoute.of(context).settings.name != '/setup') {
      Navigator.of(context).pushNamedAndRemoveUntil('/setup', (route) => false);
    }
  }
}
