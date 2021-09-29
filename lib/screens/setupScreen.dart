import 'dart:async';
import 'dart:ui';

import 'package:client/appConstants.dart';
import 'package:client/appLocalizations.dart';
import 'package:client/components/oauthHelper.dart';
import 'package:client/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:client/components/toastNotification.dart';
import 'package:client/models/cloudConfiguration.dart';
import 'package:client/services/ocfClient.dart';
import 'package:google_fonts/google_fonts.dart';

class SetupScreen extends StatefulWidget {
  @override
  _SetupState createState() => new _SetupState();
}

class _SetupState extends State<SetupScreen> {
  bool _setupInProgress = false;
  bool _tryGetTokenInBackground = false;
  CloudConfiguration _cloudConfiguration;

  @override
  initState() {
    super.initState();
    _cloudConfiguration = CloudConfiguration.getSelected(CloudConfiguration.load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Builder(
        builder: (context) => Stack(
          children: <Widget>[
            Container(
              alignment: Alignment.topCenter,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
                child: Image(
                  image: AssetImage('assets/logo.png'),
                  width: 240
                )
              )
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 35, left: 20, right: 20),
                  child: _setupInProgress ? SpinKitDoubleBounce(color: AppConstants.mainColor) : FlatButton(
                    onPressed: () async => setState(() {
                      _setupInProgress = true;
                      _tryGetTokenInBackground = true;
                    }),
                    color: AppConstants.mainColor,
                    splashColor: AppConstants.yellowMainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: AppConstants.mainColor)
                    ),
                    padding: const EdgeInsets.all(18.0),
                    child: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: AppLocalizations.of(context).continueToPlgdCloudButton, style: GoogleFonts.mulish()),
                          TextSpan(
                            text: _cloudConfiguration.customName, 
                            style: GoogleFonts.mulish(fontWeight: FontWeight.bold, color: AppConstants.yellowMainColor)
                          )
                        ],
                      ),
                    )
                  )
                )
              )
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 15, left: 20, right: 20),
                child: _setupInProgress ? null : RichText(
                  text: TextSpan(
                    style: GoogleFonts.mulish(fontStyle: FontStyle.italic, fontSize: 12),
                    children: <TextSpan>[
                      TextSpan(
                        text: AppLocalizations.of(context).configureCustomEndpointButton,
                        style: GoogleFonts.mulish(color: AppConstants.mainColor, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                           ..onTap = () => Navigator.of(context).pushNamed('/configuration')
                            .then((cloudConfiguration) { setState(() { _cloudConfiguration = cloudConfiguration; }); })
                      )
                    ],
                  ),
                )
              )
            ),
            OAuthHelper.getApplicationTokenRequestWidget(context, _cloudConfiguration, false, _tryGetTokenInBackground, _initializeOCFClient, _restartSetup, _onHttpError)
          ]
        )
      )
    );
  }

  Future _initializeOCFClient(String accessToken) async {
    var isInitialized = await OCFClient.initialize(_cloudConfiguration, accessToken);
    if (isInitialized) {
      Navigator.of(context).pushNamedAndRemoveUntil('/devices', (route) => false);
    } else {
      setState(() {
        _setupInProgress = false;
        _tryGetTokenInBackground = false;
      });
      ToastNotification.show(context, AppLocalizations.of(context).unableToInitializeClientNotification);
      await MyApp.reset(context);
    }
  }

  void _onHttpError() {
    setState(() {
        _setupInProgress = false;
        _tryGetTokenInBackground = false;
      });
    ToastNotification.show(context, AppLocalizations.of(context).unableToAuthenticateNotification);
  }

  void _restartSetup() {
    setState(() {
      _setupInProgress = false;
      _tryGetTokenInBackground = false;
    });
  }
}