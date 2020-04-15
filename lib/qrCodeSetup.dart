import 'dart:async';
import 'dart:ui';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/userAuth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class QRCodeSetup extends StatefulWidget {
  @override
  _ScanState createState() => new _ScanState();
}

class _ScanState extends State<QRCodeSetup> {
  bool fetchingConfiguration = false;

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
                    child: fetchingConfiguration ? SpinKitDoubleBounce(color: Colors.white) : new FlatButton(
                      onPressed: _getCloudConfiguration,
                      color: Color(0xff006aa6),
                      splashColor: Color(0xff63bf4a),
                      textColor: Colors.white,
                      child: Text("Scan QR Code"),
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(28.0),
                        side: BorderSide(color: Color(0xff006aa6))),
                      padding: const EdgeInsets.all(18.0),
                    ),
                  )
                ],
              ),
            )]);
  }

  Future _getCloudConfiguration() async {
    var cloudDiscoveryUrl = await _scan();
    setState(() {
      fetchingConfiguration = true;
    });
    var isValidUrl = Uri.parse(cloudDiscoveryUrl).isAbsolute;
    if (!isValidUrl) {
      Fluttertoast.showToast(
        msg: "Invalid QR code",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Color(0xff006aa6),
        textColor: Colors.white,
        fontSize: 16.0
      );
      setState(() {
        fetchingConfiguration = false;
      });
      return;
    }
    var response = await http.get(cloudDiscoveryUrl);
    var storage = await SharedPreferences.getInstance();
    var configurationStored = await storage.setString("gocf.dev/cloud-configuration", response.body);
    if (!configurationStored) {
      print('unable to persist configuraiton');
      return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => UserAuth()));
  }

  Future<String> _scan() {
    try {
      return BarcodeScanner.scan();
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        //'The user did not grant the camera permission!';
      } else {
        // 'Unknown error: $e');
      }
    } on FormatException{
      // 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      // 'Unknown error: $e');
    }
    return Future.value("");
  }
}