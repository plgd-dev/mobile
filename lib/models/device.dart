import 'dart:convert';

import 'package:client/services/ocfClient.dart';

class Device {
  String id;
  List<String> resourceTypes;
  List<String> interfaces;
  String name;
  String manufacturerName;
  String modelNumber;
  bool isSecured;
  bool isOwned;
  Ownership ownership;
  List<Resources> resources;

  Device(
      {this.id,
      this.resourceTypes,
      this.interfaces,
      this.name,
      this.manufacturerName,
      this.modelNumber,
      this.isSecured,
      this.ownership,
      this.isOwned,
      this.resources});

  bool isOwnedByMe() {
    if (!this.isSecured || this.ownership == null || !this.ownership.owned) {
      return false;
    }
    if (this.ownership.deviceOwner == OCFClient.ownerId) {
      return true;
    }
    return false;
  }

  Future<void> loadOwnership() async {
    var content = await OCFClient.getResource(this.id, '/oic/sec/doxm');
    if (content != null && content.isNotEmpty) {
      var data = jsonDecode(content);
      this.ownership = Ownership.fromJson(data);
    }
  }

  Device.fromJson(Map<String, dynamic> json) {
    id = json['ID'];
    if (json['Details'] != null) {
      resourceTypes = json['Details']['rt'] != null ? json['Details']['rt'].cast<String>() : '';
      interfaces = json['Details']['if'] != null ? json['Details']['if'].cast<String>() : '';
      name = json['Details']['n'];
      manufacturerName = json['Details']['dmn'];
      modelNumber = json['Details']['dmno'];
    }
    isSecured = json['IsSecured'];
    ownership = json['Ownership'] != null ? new Ownership.fromJson(json['Ownership']) : null;
    isOwned = json['OwnershipStatus'] != 'readytobeowned';
    if (json['Resources'] != null) {
      resources = new List<Resources>();
      json['Resources'].forEach((v) {
        resources.add(new Resources.fromJson(v));
      });
    }
  }
}

class Ownership {
  String resourceOwner;
  List<int> supportedOwnerTransferMethods;
  String deviceOwner;
  String deviceID;
  bool owned;
  String name;
  String instanceID;
  int supportedCredentialTypes;
  int selectedOwnerTransferMethod;
  List<String> interfaces;
  List<String> resourceTypes;

  Ownership(
      {this.resourceOwner,
      this.supportedOwnerTransferMethods,
      this.deviceOwner,
      this.deviceID,
      this.owned,
      this.name,
      this.instanceID,
      this.supportedCredentialTypes,
      this.selectedOwnerTransferMethod,
      this.interfaces,
      this.resourceTypes});

  Ownership.fromJson(Map<String, dynamic> json) {
    resourceOwner = json['rowneruuid'];
    supportedOwnerTransferMethods = json['oxms'].cast<int>();
    deviceOwner = json['devowneruuid'];
    deviceID = json['deviceuuid'];
    owned = json['owned'];
    name = json['n'];
    instanceID = json['id'];
    supportedCredentialTypes = json['sct'];
    selectedOwnerTransferMethod = json['oxmsel'];
    interfaces = json['if']?.cast<String>();
    resourceTypes = json['rt']?.cast<String>();
  }
}

class Resources {
  String href;
  List<String> resourceTypes;
  List<String> interfaces;

  Resources(
      {this.href,
      this.resourceTypes,
      this.interfaces});

  Resources.fromJson(Map<String, dynamic> json) {
    href = json['href'];
    resourceTypes = json['rt'].cast<String>();
    interfaces = json['if'].cast<String>();
  }
}
