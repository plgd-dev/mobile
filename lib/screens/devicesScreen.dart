import 'dart:async';

import 'package:client/appLocalizations.dart';
import 'package:client/components/toastNotification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:client/components/deviceDetails.dart';
import 'package:client/components/topBar.dart';
import 'package:client/models/device.dart';
import 'package:client/services/ocfClient.dart';

import '../appConstants.dart';

class DevicesScreen extends StatefulWidget {
  DevicesScreen({Key key}) : super(key: key);

  @override
  _DevicesState createState() => _DevicesState();
}

class _DevicesState extends State<DevicesScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  List<Device> _deviceList = new List<Device>();

  @override
  initState() {
    super.initState();
    if (_deviceList.isEmpty)
      WidgetsBinding.instance.addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TopBar(context, AppLocalizations.of(context).devicesScreenTitle,
        showLogout: true,
      ),
      body: DefaultTabController(
        length: 1,
        child: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          Container(
            child: Center(
              child: RefreshIndicator(
                key: _refreshIndicatorKey,
                displacement: 150,
                child: ListView.builder(
                  itemCount: _deviceList.length,
                  itemBuilder: (context, index) {
                    return _getSlidable(_deviceList, index);
                  }
                ),
                onRefresh: _refreshDevices,
              )
            ),
          )
        ])
      )
    );
  }

  Widget _getSlidable(List<Device> devices, int index) {
    var device = devices[index];
    return Slidable(
      key: Key(device.id),
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: ListTile(
        title: _getListTitle(device),
        subtitle: Text('${device.id}'),
        onTap: () async {
          var refreshDevices = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: false,
            enableDrag: false,
            backgroundColor: Colors.transparent,
            builder: (context) => FractionallySizedBox(
              heightFactor: 1,
              child: DeviceDetails(device: device)
            )
          );
          if (refreshDevices == true)
            _refreshIndicatorKey.currentState.show();
        }
      )
    );
  }

  Widget _getListTitle(Device device) {
    if (device.ownershipStatus == 'readytobeowned') {
      return Row(
        children: [
          Icon(Icons.fiber_new_rounded, size: 25, color: AppConstants.yellowMainColor),
          Text(' ${device.name}')
        ]
      );
    } else if (device.ownershipStatus == 'owned') {
      return Row(
        children: [
          Icon(Icons.lock_outline, size: 20, color: Colors.green),
          Text(' ${device.name}')
        ]
      );
    }
    return Row(
      children: [
        Icon(Icons.lock_outline, size: 20, color: Colors.red),
        Text(' ${device.name}')
      ]
    );
  }

  Future _refreshDevices() async {
    var devices = await OCFClient.discoverDevices();
    if (devices == null) {
      ToastNotification.show(context, AppLocalizations.of(context).unableToDiscoverDevicesNotification);
      return;
    }
    setState(() {
      _deviceList = devices;
    });
  }
}