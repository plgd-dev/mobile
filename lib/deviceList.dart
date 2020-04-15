import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'device.dart';

class DeviceList extends StatefulWidget {

  DeviceList({Key key, this.devices, this.offboard, this.onOwn, this.onOnboard}) : super(key: key);

  final List<Device> devices;
  final FutureOr<bool> Function() offboard;
  final Function onOwn;
  final Function onOnboard;

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
      child: ListTile(title: Text('${device.name}'), subtitle: Text('${device.id}')),//VerticalListItem(items[index]),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'More',
          color: Colors.grey.shade200,
          icon: Icons.more_horiz,
          onTap: () => _showSnackBar(context, 'More'),
          closeOnTap: false,
        ),
        IconSlideAction(
          caption: device.isOnboarded ? 'Offboard' : 'Onboard',
          color: device.isOnboarded ? Colors.blueGrey : Colors.blue.shade700,
          icon: device.isOnboarded ? Icons.cloud_off : Icons.cloud_done,
          onTap: () => widget.offboard(),
          closeOnTap: false,
        ),
        IconSlideAction(
          caption: device.isOwned ? 'Disown' : 'Own',
          color: device.isOwned ? Colors.red : Colors.green,
          icon: device.isOwned ? Icons.link_off : Icons.link,
          onTap: () => widget.offboard(),
            //Scaffold.of(context).showSnackBar(SnackBar(content: Text("Onboard"))),
        ),
      ],
    );
  }

  void _showSnackBar(BuildContext context, String text) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

}

// class DeviceListItem extends StatelessWidget {
//   DeviceListItem(this.item);
//   final Device item;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () =>
//           Slidable.of(context)?.renderingMode == SlidableRenderingMode.none
//               ? Slidable.of(context)?.open()
//               : Slidable.of(context)?.close(),
//       child: Container(
//         color: Colors.white,
//         child: ListTile(
//           leading: CircleAvatar(
//             backgroundColor: item.color,
//             child: Text('${item.index}'),
//             foregroundColor: Colors.white,
//           ),
//           title: Text(item.title),
//           subtitle: Text(item.subtitle),
//         ),
//       ),
//     );
//   }
// }