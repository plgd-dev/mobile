import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/components/deviceList.dart';
import 'package:my_app/components/topBar.dart';
import 'package:my_app/models/device.dart';
import 'package:my_app/services/ocfClient.dart';
import '../appConstants.dart';

class DevicesScreen extends StatefulWidget {
  DevicesScreen({Key key}) : super(key: key);

  @override
  _DevicesState createState() => _DevicesState();
}

class _DevicesState extends State<DevicesScreen> with SingleTickerProviderStateMixin {
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
                displacement: 150,
                child: DeviceList(devices: _deviceList),
                onRefresh: _refreshDevices,
              )
            ),
          ),
          Text('not available')
        ])
    );
  }

  Future _refreshDevices() async {
    try {
      if (!OCFClient.isInitialized()) {
        await OCFClient.initialize();
      }
      
      var devices = await OCFClient.discoverDevices();
      setState(() {
        _deviceList = devices;
      });
    } on PlatformException catch (e) {
      print("PlatformException: ${e.message}");
    }
  }
}