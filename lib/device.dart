import 'package:flutter_slidable/flutter_slidable.dart';

class Device {
  final String id;
  final String name;
  final String ownerID;
  final String cloudURL;
  
  bool get isOwned {
    return ownerID != null && ownerID.isNotEmpty;
  }

  bool get isOnboarded {
    return cloudURL != null && cloudURL.isNotEmpty;
  }

  Device(this.id, this.name, this.ownerID, this.cloudURL);
}