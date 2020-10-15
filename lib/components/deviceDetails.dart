import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:my_app/appConstants.dart';
import 'package:my_app/models/device.dart';

class DeviceDetails extends StatefulWidget {
  DeviceDetails({Key key, this.device}) : super(key: key);

  final Device device;
  
  @override
  _DeviceDetailsWidgetState createState() => _DeviceDetailsWidgetState();
}

class _DeviceDetailsWidgetState extends State<DeviceDetails> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        Container(
          child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 20)
        ),
        Padding(
          padding: EdgeInsets.only(top: 25),
          child: Text(widget.device.name, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
        ),
        Padding(
          padding: EdgeInsets.only(top: 45, bottom: 10, left: 15, right: 15),
          child: FlatButton(
            onPressed: () {},
            color: widget.device.isOwnedBy(AppConstants.noDeviceOwner) ? Colors.redAccent : Colors.green,
            splashColor: AppConstants.yellowMainColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0)
            ),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.device.isOwnedBy(AppConstants.noDeviceOwner) ? Icons.cloud_off : Icons.cloud_done,
                  color: Colors.white
                ),
                SizedBox(width: 10),
                Text(
                  widget.device.isOwnedBy(AppConstants.noDeviceOwner) ? AppConstants.buttonFactoryReset : AppConstants.buttonOnboard,
                  style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: AppConstants.topBarFont)
                )
              ]
            )
          )
        )
      ]
    );
  }
}