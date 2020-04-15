import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/qrCodeSetup.dart';
import 'package:my_app/services/ocfClient.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'authHandler.dart';
import 'device.dart';
import 'deviceList.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _isCloudSetUp(), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // indicatorColor: Colors.red,
        // accentColor: Colors.green
      ),
      home: snapshot.hasData ? new DevicesPage(title: 'Go-OCF') : new QRCodeSetup(),
      initialRoute: '/'
    );
      });
      }
  
}

  Future<String> _isCloudSetUp() async {
    var prefs = await SharedPreferences.getInstance();
    return null;
}

class DevicesPage extends StatefulWidget {
  DevicesPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  List<Device> _deviceList = new List<Device>();
  AuthHandler _authHandler;

  @override
  initState() {
    super.initState();
    _authHandler = new AuthHandler(context);
  }

  // static const platform = const MethodChannel('gocf.dev/gonative');
  // Future<void> _incrementCounter() async {
  //   String devices;
  //   try {
  //     devices =
  //         await platform.invokeMethod('increment', _devices);
  //   } on PlatformException catch (e) {
  //     print("PlatformException: ${e.message}");
  //   }
  //   if (devices != null) {
  //     setState(() {
  //       _devices = devices;
  //     });
  //   }
  

  @override
  Widget build(BuildContext context) {
    // https://api.flutter.dev/flutter/material/RefreshIndicatorState-class.html 
    // show loading directly after application starts
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Container(
        child: new Center(
          child: new RefreshIndicator(
            child: new DeviceList(devices: _deviceList, offboard: _offboard,),
            onRefresh: _refreshDevices,
          )
        ),
      ),
    );
  }

  Future<void> _refreshDevices() async
  {
    try {
      var isInitialized = await OCFClient.initialize();
      var devices = await OCFClient.getDevices();
      // _deviceList.add(new Device(devices, "not onboarded", null, null));
      return true;
    } on PlatformException catch (e) {
      print("PlatformException: ${e.message}");
    }
  }

  FutureOr<bool> _offboard() async {
    try {
      var token = await _authHandler.getToken();
    } catch (err) {
      print(err);
    }
    // final _formKey = GlobalKey<FormState>();
    // showDialog(
    //             context: context,
    //             builder: (BuildContext context) {
    //               return AlertDialog(
    //                 content: LoginScreen(authUrl: "https://portal.try.plgd.cloud/api/authz/token", redirectUrl: "https://portal.try.plgd.cloud/api/authz/callback", onAuthCompleted: onAuthCompleted, onAuthRequested: onAuthRequested, hidden: true,),
    //                 contentPadding: EdgeInsets.all(5),
    //               );
    //             });
      // Navigator.of(context).push(
      //   MaterialPageRoute(builder: (BuildContext context) => LoginScreen(authUrl: "https://portal.try.plgd.cloud/api/authz/token", redirectUrl: "https://portal.try.plgd.cloud/api/authz/callback", onAuthCompleted: onAuthCompleted, )),
        
      //   );
    return true;
  }
}
