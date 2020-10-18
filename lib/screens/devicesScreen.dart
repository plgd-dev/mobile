import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(onTap);
  }

  @override
    void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  TabController _tabController;
  onTap() {
    if (_tabController.index == 1) {
      setState(() { _tabController.index = 0; });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TopBar(context, AppConstants.devicesScreenTitle,
        showLogout: true,
        // TODO: uncomment when remote devices will be supported
        // bottom: TabBar(
        //   isScrollable: false,
        //   indicatorWeight: 4.0,
        //   controller: _tabController,
        //   onTap: (int _index) {
        //     if (_index == 1) {
        //       setState(() { _tabController.index = 0; });
        //     }
        //   },
        //   tabs: <Widget>[
        //     Text('LOCAL', style: TextStyle(color: Colors.white, fontFamily: AppConstants.topBarFont)),
        //     Row(children: <Widget>[
        //       Spacer(),
        //       Text('REMOTE   ', style: TextStyle(color: Colors.grey, fontFamily: AppConstants.topBarFont)),
        //       Expanded(
        //         child: Align(
        //           alignment: Alignment.centerLeft,
        //           child: Icon(Icons.lock, size: 13,)
        //         ),
        //       )
        //     ])
        //   ]
        // )
      ),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _tabController,
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
          ),
          Text('not available')
        ])
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
    try {
      var devices = await OCFClient.discoverDevices();
      setState(() {
        _deviceList = devices;
      });
    } on PlatformException catch (e) {
      print("PlatformException: ${e.message}");
    }
  }
}