import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:my_app/components/oauthHandler.dart';
import 'package:my_app/models/cloudConfiguration.dart';
import 'package:my_app/services/ocfClient.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../appConstants.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashState createState() => new _SplashState();
}

class _SplashState extends State<SplashScreen> {
  CloudConfiguration _cloudConfiguration;
  bool _tryAuthInBackground = true;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _getCloudConfiguration(),
      builder: (context, configurationRetrieved) => Scaffold(
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
            Visibility(
              visible: false,
              maintainState: configurationRetrieved.hasData && _tryAuthInBackground,
              child: OAuthHandler(
                authUrl: _cloudConfiguration?.accessTokenUrl,
                promptForCredentials: _showLoginModal,
                authCompleted: _onAuthCompleted
              )
            )
          ]
        )
      )
    );
  }
  
  Future<bool> _getCloudConfiguration() async {
    var storage = await SharedPreferences.getInstance();
    var jsonConfiguration = storage.getString(OCFClient.cloudConfigurationStorageKey);
    _cloudConfiguration = CloudConfiguration.fromJson(jsonConfiguration);
    return true;
  }

  void _onAuthCompleted(String response) {
    OCFClient.setTokenResponse(response);
    Navigator.of(context).pushNamedAndRemoveUntil('/devices', (route) => false);
  }

  void _showLoginModal() {
    setState(() { _tryAuthInBackground = false; });
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.95,
        child: Container(
          margin: const EdgeInsets.only(top: 5, left: 15, right: 15),
          child: Stack(
            alignment: AlignmentDirectional.topCenter,
            children: [
              Container(
                height: 3,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.all(Radius.circular(50))
                )
              ),
              Padding(
                padding: EdgeInsets.only(top: 7),
                child: OAuthHandler(
                  authUrl: _cloudConfiguration.accessTokenUrl,
                  authCompleted: _onAuthCompleted
                )
              )
            ]
          )
        )
      )
    ).whenComplete(() => _showResetAppConfigurationDialog());
  }

  void _showResetAppConfigurationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(AppConstants.resetApplicationDialogText),
          actions: <Widget>[
            FlatButton(
              child: Text(AppConstants.resetApplicationDialogCancelButton),
              onPressed: () {
                setState(() { _tryAuthInBackground = true; });
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