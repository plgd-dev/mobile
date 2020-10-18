import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:my_app/appConstants.dart';
import 'package:my_app/models/device.dart';
import 'package:my_app/services/ocfClient.dart';

class DeviceDetails extends StatefulWidget {
  DeviceDetails({Key key, this.device}) : super(key: key);

  final Device device;
  
  @override
  _DeviceDetailsWidgetState createState() => _DeviceDetailsWidgetState();
}

class _DeviceDetailsWidgetState extends State<DeviceDetails> {
  bool _userRequestInProgress = false;
  bool _tryGetCodeInBackground = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _userRequestInProgress ? null : Navigator.of(context).pop(),
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 85),
            child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 20)
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 65),
            child: Text(widget.device.name, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10, left: 15, right: 15),
            child: _getActionButton(this.widget.device)
          ),
          OCFClient.getCodeRequestWidget(context, false, _tryGetCodeInBackground, (response) => _onboardDevice(response, context), _cancelOnboarding)
        ]
      )
    );
  }

  Widget _getActionButton(Device device) {
    if (device.ownershipStatus == 'readytobeowned') {
      return _getFlatButton(
        Colors.green,
        Colors.green.withAlpha(120),
        () { 
          setState(() { 
            _userRequestInProgress = true; 
            _tryGetCodeInBackground = true;
          });
        },
        AppConstants.buttonOnboard,
        Icons.cloud_done
      );
    } else if (device.ownershipStatus == 'owned') {
      return _getFlatButton(
        Colors.red,
        Colors.red.withAlpha(120),
        () async {
          setState(() { _userRequestInProgress = true; });
          await OCFClient.disownDevice(device.id);
          Navigator.of(context).pop(true);
        },
        AppConstants.buttonFactoryReset,
        Icons.cloud_off
      );
    }
    return _getFlatButton(
      Colors.red,
      Colors.red.withAlpha(120),
      null,
      AppConstants.buttonFactoryReset,
      Icons.cloud_off
    );
  }
  
  Widget _getFlatButton(Color activeColor, Color disabledColor, Function onPressed, String buttonText, IconData icon) {
    return FlatButton(
      onPressed: _userRequestInProgress ? null : onPressed,
      color: activeColor,
      splashColor: AppConstants.yellowMainColor,
      disabledColor: disabledColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _userRequestInProgress ? 
            SizedBox(width: 20, height: 20, child: SpinKitRing(color: Colors.white, size: 20, lineWidth: 2.0))
            : Icon(icon, color: onPressed == null ? Colors.white60 : Colors.white),
          SizedBox(width: 10),
          Text(buttonText, style: TextStyle(color: onPressed == null ? Colors.white60 : Colors.white, fontSize: 16, fontFamily: AppConstants.topBarFont))
        ]
      )
    );
  }

  void _onboardDevice(String response, BuildContext context) async {
    var deviceID = await OCFClient.ownDevice(this.widget.device.id);
    await OCFClient.setAccessForCloud(deviceID);
    Map<String, dynamic> jsonResponse = jsonDecode(response);
    String authCode = jsonResponse['code'];
    await OCFClient.onboardDevice(deviceID, authCode);
    Navigator.of(context).pop(true);
  }

  void _cancelOnboarding() {
    setState(() {
      _userRequestInProgress = false;
      _tryGetCodeInBackground = false;
    });
  }
}