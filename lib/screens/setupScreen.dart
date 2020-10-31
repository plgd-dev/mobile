import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:client/appConstants.dart';
import 'package:client/appLocalizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/io_client.dart';
import 'package:client/components/toastNotification.dart';
import 'package:client/models/cloudConfiguration.dart';
import 'package:client/services/ocfClient.dart';

class SetupScreen extends StatefulWidget {
  @override
  _SetupState createState() => new _SetupState();
}

class _SetupState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _setupInProgress = false;
  bool _tryGetTokenInBackground = false;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Builder(
        builder: (context) => Stack(
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
                  child: _setupInProgress ? SpinKitDoubleBounce(color: AppConstants.blueMainColor) : FlatButton(
                    onPressed: () async => await _getCloudConfiguration(context, AppConstants.defautPlgdCloudEndpoint),
                    color: AppConstants.blueMainColor,
                    splashColor: AppConstants.yellowMainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      side: BorderSide(color: AppConstants.blueMainColor)
                    ),
                    padding: const EdgeInsets.all(18.0),
                    child: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: AppLocalizations.of(context).continueToPlgdCloudButton),
                          TextSpan(
                            text: AppConstants.tryPlgdCloudEndpoint, 
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.yellowMainColor)
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
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 10),
                    children: <TextSpan>[
                      TextSpan(
                        text: AppLocalizations.of(context).configureCustomEndpointButton,
                        style: TextStyle(color: AppConstants.blueMainColor, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _showCustomEndpointDialog()
                      )
                    ],
                  ),
                )
              )
            ),
            OCFClient.getTokenRequestWidget(context, false, _tryGetTokenInBackground, _initializeOCFClient, _restartSetup)
          ]
        )
      )
    );
  }

  Future _getCloudConfiguration(BuildContext context, Uri cloudEndpoint) async {
    setState(() {
      _setupInProgress = true;
    });

    String configurationResponse;
    var httpClient = HttpClient()..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    var ioClient = new IOClient(httpClient);  
    try {
      var response = await ioClient.get(cloudEndpoint).timeout(const Duration(seconds: 10));
      configurationResponse = response.body;
    } on Exception catch (_) {
      ToastNotification.show(context, AppLocalizations.of(context).unableToFetchConfigurationNotification);
      setState(() {
        _setupInProgress = false;
      });
      return;
    }

    if (!CloudConfiguration.isValid(configurationResponse)) {
      ToastNotification.show(context, AppLocalizations.of(context).invalidConfigurationNotification);
      setState(() {
        _setupInProgress = false;
      });
      return;
    }

    OCFClient.cloudConfiguration = CloudConfiguration.fromJson(configurationResponse);
    setState(() {
      _tryGetTokenInBackground = true;
    });
  }

  Future _initializeOCFClient(String response) async {
    var isInitialized = await OCFClient.initialize(response);
    if (isInitialized) {
      Navigator.of(context).pushNamedAndRemoveUntil('/devices', (route) => false);
    } else {
      setState(() {
        _setupInProgress = false;
        _tryGetTokenInBackground = false;
      });
      ToastNotification.show(context, AppLocalizations.of(context).unableToInitializeClientNotification);
    }
  }

  void _restartSetup() {
    setState(() {
      _setupInProgress = false;
      _tryGetTokenInBackground = false;
    });
  }

  Future _showCustomEndpointDialog() async {
  TextEditingController controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      child: AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Form(
            key: _formKey,
            child: Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  validator: (url) {
                    Pattern pattern = r'[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)';
                    RegExp regex = RegExp(pattern);
                    if (!regex.hasMatch(url))
                      return AppLocalizations.of(context).invalidEndpointNotification;
                    else
                      return null;
                  },
                  controller: controller,
                  keyboardType: TextInputType.url,
                  autofocus: true,
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.cloud, color: AppConstants.blueMainColor),
                    prefixText: 'https://',
                    hintText: 'plgd.cloud',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppConstants.blueMainColor),
                    ) 
                  )
                )
              )
            ]
          )
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              AppLocalizations.of(context).customEndpointButtonCancel,
              style: TextStyle(color: AppConstants.blueMainColor)
            ),
            onPressed: () {
              Navigator.pop(context);
            }
          ),
          FlatButton(
            child: Text(
              AppLocalizations.of(context).customEndpointButtonContinue,
              style: TextStyle(color: AppConstants.blueMainColor)
            ),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                Navigator.pop(context);
                _getCloudConfiguration(context, Uri.parse('https://' + controller.text + AppConstants.cloudConfigurationPath));
              }
            }
          )
        ]
      )
    );
  }
}