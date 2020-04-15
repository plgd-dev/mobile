import 'dart:async';
import 'dart:ui';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'oauthLogin.dart';

class UserAuth extends StatefulWidget {
  @override
  _UserAuthState createState() => new _UserAuthState();
}

class _UserAuthState extends State<UserAuth> {
  bool authenticationInProgress = false;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(color: Colors.white),
              child: SvgPicture.asset("assets/logo-long.svg", alignment: Alignment.bottomCenter, fit: BoxFit.scaleDown)
            )
          ),
          Scaffold(
            backgroundColor: Colors.black38.withOpacity(0.80),
            body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text("asd asd asd as asd ads ", textAlign: TextAlign.center,style: TextStyle(color: Colors.white),),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.0),
                    child: authenticationInProgress ? SpinKitDoubleBounce(color: Colors.white) : new FlatButton(
                      onPressed: _authenticateUser,
                      color: Color(0xff006aa6),
                      splashColor: Color(0xff63bf4a),
                      textColor: Colors.white,
                      child: Text("Authenticate"),
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(28.0),
                        side: BorderSide(color: Color(0xff006aa6))),
                      padding: const EdgeInsets.all(18.0),
                    ),
                  )
                ],
              ),
            )
            ]);
  }

  void _authenticateUser() {
    // Navigator.of(context).push(PageRouteBuilder(
    //   opaque: false,
    //   pageBuilder: (BuildContext context, _, __) =>    
    //     Scaffold(
    //       backgroundColor: Colors.white.withOpacity(0.70),
    //       body: 
    //     )));
      
    setState(() {
      authenticationInProgress = true;
    });
    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => Visibility(visible: authenticationInProgress, child: OAuthLogin(authUrl: "https://portal.try.plgd.cloud/api/authz/token", redirectUrl: "https://portal.try.plgd.cloud/api/authz/callback", promptForCredentials: _onPromptForCredentials, authCompleted: _onAuthCompleted, tryInBackground: false))));
  }

  void _onAuthCompleted(String response) {
    print(response);
    //Navigator.of(context).pop();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => DevicesPage(title: 'asd')));
  }

  void _onPromptForCredentials() {
  }

    // var storage = await SharedPreferences.getInstance();
    // var configurationStored = await storage.setString("gocf.dev/cloud-configuration", response.body);
    // if (!configurationStored) {
    //   print('unable to persist configuraiton');
    //   return;
    // }
    //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => DevicesPage(title: 'asd')));
}