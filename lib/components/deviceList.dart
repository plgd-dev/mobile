import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:my_app/components/oauthHandler.dart';
import 'package:my_app/models/device.dart';
import 'package:my_app/services/ocfClient.dart';
import 'deviceDetails.dart';

class DeviceList extends StatefulWidget {

  DeviceList({Key key, this.devices}) : super(key: key);

  final List<Device> devices;

  @override
  State<StatefulWidget> createState() {
    return new _DeviceListState();
  }
}

class _DeviceListState extends State<DeviceList> {

  @override
  Widget build(BuildContext context) {
    return _buildDeviceList(context, widget.devices);
  }

  ListView _buildDeviceList(context, List<Device> devices) {
    return new ListView.builder(
      itemCount: devices.length,
      itemBuilder: (context, index) {
        return _getSlidable(devices, index);
      },
    );
  }

  Widget _getSlidable(List<Device> devices, int index) {
    var device = devices[index];
    return Slidable(
      key: Key(device.id),
      dismissal: SlidableDismissal(
        child: SlidableDrawerDismissal(),
        onWillDismiss: (actionType) {
          return showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Delete'),
                      content: Text('Item will be deleted'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        FlatButton(
                          child: Text('Ok'),
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ],
                    );
                  },
                );
          //return offboard();
        },
        onDismissed: (actionType) {
          Scaffold.of(context).showSnackBar(SnackBar(content: Text('Device offboarded')));
          setState(() {
            devices.removeAt(index);
          });
        },
      ),
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: ListTile(
        title: Text('${device.name}'),
        subtitle: Text('${device.id}'),
        onTap: (){
          showModalBottomSheet(
            context: context,
            isScrollControlled:false,
            backgroundColor: Colors.transparent,
            builder: (context) => DeviceDetails(device: device)
          );
        },
      ),//VerticalListItem(items[index]),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: device.isOwnedBy('') ? 'OFFBOARD' : 'ONBOARD',
          color: device.isOwnedBy('') ? Colors.blueGrey : Colors.green,
          icon: device.isOwnedBy('') ? Icons.cloud_off : Icons.cloud_done,
          onTap: () async => await _onOnboardOffboardAction(device),
          closeOnTap: false,
        ),
      ],
    );
  }

  Future _onOnboardOffboardAction(Device device) async {
    if (device.isSecured && !device.ownership.owned) {
      await OCFClient.ownDevice(device.id);
      // if token expired, if err
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => OAuthHandler(authUrl: "https://portal.try.plgd.cloud/api/authz/code", promptForCredentials: _onPromptForCredentials, authCompleted: (String response) async {
      Map<String, dynamic> jsonResponse = jsonDecode(response);
      String authCode = jsonResponse['code'];
      await OCFClient.onboardDevice(device.id, "auth0", "coaps+tcp://try.plgd.cloud:5684", authCode, "adebc667-1f2b-41e3-bf5c-6d6eabc68cc6");
      Navigator.of(context).pop();
    })));
  }
  
  void _onPromptForCredentials() {
  }
}