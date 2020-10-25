import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:client/components/toastNotification.dart';
import 'package:client/services/ocfClient.dart';

import '../appConstants.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashState createState() => new _SplashState();
}

class _SplashState extends State<SplashScreen> {
  bool _tryGetTokenInBackground = true;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
              child: Image(
                image: AssetImage('assets/logo.png'),
                width: 220
              )
            )
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.only(bottom: 35, left: 20, right: 20),
                child: SpinKitDoubleBounce(color: AppConstants.blueMainColor)
              )
            )
          ),
          OCFClient.getTokenRequestWidget(context, false, _tryGetTokenInBackground, _initializeOCFClient, _showResetAppConfigurationDialog)
        ]
      )
    );
  }

  Future _initializeOCFClient(String response) async {
    var isInitialized = await OCFClient.initialize(response);
    if (isInitialized) {
      Navigator.of(context).pushNamedAndRemoveUntil('/devices', (route) => false);
    } else {
      await MyApp.reset(context);
      ToastNotification.show(context, AppConstants.unableToInitializeClientSetupRedirect);
    }
  }

  void _showResetAppConfigurationDialog() {
    setState(() { _tryGetTokenInBackground = false; });
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(AppConstants.resetApplicationDialogText),
          actions: <Widget>[
            FlatButton(
              child: Text(AppConstants.resetApplicationDialogCancelButton),
              onPressed: () {
                setState(() { _tryGetTokenInBackground = true; });
                Navigator.of(context).pop(false);
              }
            ),
            FlatButton(
              child: Text(AppConstants.resetApplicationDialogOkButton),
              onPressed: () async => await MyApp.reset(context)
            ),
          ],
        );
      }
    );
  }
}