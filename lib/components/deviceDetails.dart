import 'dart:convert';

import 'package:client/appLocalizations.dart';
import 'package:client/components/toastNotification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:client/appConstants.dart';
import 'package:client/models/device.dart';
import 'package:client/services/ocfClient.dart';

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
    return WillPopScope(
      onWillPop: () async => !_userRequestInProgress,
      child: GestureDetector(
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
            OCFClient.getCodeRequestWidget(context, false, _tryGetCodeInBackground, (response) => _onboard(response, context), _cancelOnboarding)
          ]
        )
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
        AppLocalizations.of(context).onboardButton,
        Icons.cloud_done
      );
    } else if (device.ownershipStatus == 'owned') {
      return _getFlatButton(
        Colors.red,
        Colors.red.withAlpha(120),
        () async => await _factoryReset(),
        AppLocalizations.of(context).factoryResetButton,
        Icons.cloud_off
      );
    }
    return _getFlatButton(
      Colors.red,
      Colors.red.withAlpha(120),
      null,
      AppLocalizations.of(context).factoryResetButton,
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

  void _onboard(String response, BuildContext context) async {
    var deviceID = await OCFClient.ownDevice(this.widget.device.id);
    if (deviceID == null) {
      _cancelOnboarding();
      ToastNotification.show(context, AppLocalizations.of(context).unableToSetDeviceOwnershipNotification);
      return;
    }

    if (!await OCFClient.setAccessForCloud(deviceID)) {
      _cancelOnboarding();
      ToastNotification.show(context, AppLocalizations.of(context).unableToSetACLNotification);
      return;
    }

    Map<String, dynamic> jsonResponse = jsonDecode(response);
    String authCode = jsonResponse['code'];
    if (!await OCFClient.onboardDevice(deviceID, authCode)) {
      _cancelOnboarding();
      ToastNotification.show(context, AppLocalizations.of(context).unableToOnboardNotification);
      return;
    }

    await Future.delayed(const Duration(seconds: 13));
    Navigator.of(context).pop(true);
  }

  Future _factoryReset() async {
    setState(() { _userRequestInProgress = true; });
    if (!await OCFClient.disownDevice(this.widget.device.id)) {
      setState(() { _userRequestInProgress = false; });
      ToastNotification.show(context, AppLocalizations.of(context).unableToDisownNotification);
    } else {
      await Future.delayed(const Duration(seconds: 3));
      Navigator.of(context).pop(true);
    }
  }

  void _cancelOnboarding() {
    setState(() {
      _userRequestInProgress = false;
      _tryGetCodeInBackground = false;
    });
  }
}