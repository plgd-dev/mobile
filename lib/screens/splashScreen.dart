import 'dart:ui';

import 'package:client/appConstants.dart';
import 'package:client/appLocalizations.dart';
import 'package:client/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:client/components/toastNotification.dart';
import 'package:client/services/ocfClient.dart';

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
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
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
          OCFClient.getTokenRequestWidget(context, false, _tryGetTokenInBackground, _initializeOCFClient, _showResetAppConfirmationDialog, _onHttpError)
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
      ToastNotification.show(context, AppLocalizations.of(context).unableToInitializeClientNotification + AppLocalizations.of(context).requestApplicationSetupNotification);
    }
  }

  Future _onHttpError() async {
    await MyApp.reset(context);
    ToastNotification.show(context, AppLocalizations.of(context).unableToAuthenticateNotification);
  }

  void _showResetAppConfirmationDialog() {
    setState(() { _tryGetTokenInBackground = false; });
    MyApp.showResetAppConfirmationDialog(context, () => setState(() { _tryGetTokenInBackground = true; }));
  }
}