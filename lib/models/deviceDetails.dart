class DeviceDetails {
  String id;
  Device device;
  bool isSecured;
  Ownership ownership;
  List<Resources> resources;
  List<Endpoints> endpoints;

  DeviceDetails(
      {this.id,
      this.device,
      this.isSecured,
      this.ownership,
      this.resources,
      this.endpoints});

  DeviceDetails.fromJson(Map<String, dynamic> json) {
    id = json['ID'];

    device =
        json['Device'] != null ? new Device.fromJson(json['Device']) : null;
    isSecured = json['IsSecured'];
    ownership = json['Ownership'] != null
        ? new Ownership.fromJson(json['Ownership'])
        : null;
    if (json['Resources'] != null) {
      resources = new List<Resources>();
      json['Resources'].forEach((v) {
        resources.add(new Resources.fromJson(v));
      });
    }
    if (json['Endpoints'] != null) {
      endpoints = new List<Endpoints>();
      json['Endpoints'].forEach((v) {
        endpoints.add(new Endpoints.fromJson(v));
      });
    }
  }
}

class LocalizedString {
  String language;
  String value;
  LocalizedString({
    this.language,
    this.value,
  });
  LocalizedString.fromJson(Map<String, dynamic> json) {
    language = json['language'];
    value = json['value'];
  }
}

class Device {
  String id;
  List<String> resourceTypes;
  List<String> interfaces;
  String name;
  List<LocalizedString> manufacturerName;
  String modelNumber;

  Device(
      {this.id,
      this.resourceTypes,
      this.interfaces,
      this.name,
      this.manufacturerName,
      this.modelNumber});

  Device.fromJson(Map<String, dynamic> json) {
    id = json['di'];
    resourceTypes = json['rt'].cast<String>();
    interfaces = json['if'].cast<String>();
    name = json['n'];
    if (json['dmn'] != null) {
      manufacturerName = new List<LocalizedString>();
      json['dmn'].forEach((v) {
        manufacturerName.add(new LocalizedString.fromJson(v));
      });
    }
    modelNumber = json['dmno'];
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
    interfaces = json['if'].cast<String>();
    resourceTypes = json['rt'].cast<String>();
  }
}

class Resources {
  String id;
  String href;
  List<String> resourceTypes;
  List<String> interfaces;
  List<Endpoints> endpoints;
  String anchor;
  String deviceID;
  int instanceID;
  String title;
  List<String> supportedContentTypes;

  Resources(
      {this.id,
      this.href,
      this.resourceTypes,
      this.interfaces,
      this.endpoints,
      this.anchor,
      this.deviceID,
      this.instanceID,
      this.title,
      this.supportedContentTypes});

  Resources.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    href = json['href'];
    resourceTypes = json['rt'].cast<String>();
    interfaces = json['if'].cast<String>();
    if (json['eps'] != null) {
      endpoints = new List<Endpoints>();
      json['eps'].forEach((v) {
        endpoints.add(new Endpoints.fromJson(v));
      });
    }
    anchor = json['anchor'];
    deviceID = json['di'];
    instanceID = json['ins'];
    title = json['title'];
    supportedContentTypes = json['type'];
  }
}

class Endpoints {
  String uRI;
  int priority;

  Endpoints({this.uRI, this.priority});

  Endpoints.fromJson(Map<String, dynamic> json) {
    uRI = json['ep'];
    priority = json['pri'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ep'] = this.uRI;
    data['pri'] = this.priority;
    return data;
  }
}
