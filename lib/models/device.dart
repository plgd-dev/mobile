class Device {
  String id;
  List<String> resourceTypes;
  List<String> interfaces;
  String name;
  String manufacturerName;
  String modelNumber;
  bool isSecured;
  Ownership ownership;
  CloudConfiguration cloudConfiguration;
  List<Resources> resources;
  List<Endpoints> endpoints;

  Device(
      {this.id,
      this.resourceTypes,
      this.interfaces,
      this.name,
      this.manufacturerName,
      this.modelNumber,
      this.isSecured,
      this.ownership,
      this.cloudConfiguration,
      this.resources,
      this.endpoints});
  
  bool isOwnedBy(String ownerId) {
    if (!this.isSecured || !this.ownership.owned) {
      return false;
    }
    if (this.ownership.deviceOwner == ownerId) {
      return false;
    }
    return true;
  }

  bool isOnboardable() {
    return
      this.cloudConfiguration == null ||
      this.cloudConfiguration.provisioningStatus != 'registering' ||
      this.cloudConfiguration.provisioningStatus != 'registered';
  }

  Device.fromJson(Map<String, dynamic> json) {
    id = json['ID'];
    if (json['Device'] != null) {
      resourceTypes = json['Device']['rt'] != null ? json['Device']['rt'].cast<String>() : '';
      interfaces = json['Device']['if'] != null ? json['Device']['if'] .cast<String>() : '';
      name = json['Device']['n'];
      manufacturerName = json['Device']['dmn'];
      modelNumber = json['Device']['dmno'];
    } else {
      resourceTypes = json['Device']['rt'].cast<String>();
      interfaces = json['Device']['if'].cast<String>();
      name = json['Device']['n'];
      manufacturerName = json['Device']['dmn'];
      modelNumber = json['Device']['dmno'];
    }
    isSecured = json['IsSecured'];
    ownership = json['Ownership'] != null ? new Ownership.fromJson(json['Ownership']) : null;
    cloudConfiguration = json['Details'] != null ? new CloudConfiguration.fromJson(json['Details']) : null;
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

class CloudConfiguration {
	String authorizationProvider;
	String cloudID;
	String cloudURL;
	int lastErrorCode;
	String provisioningStatus;

	CloudConfiguration({this.authorizationProvider, this.cloudID, this.cloudURL, this.lastErrorCode, this.provisioningStatus});

	CloudConfiguration.fromJson(Map<String, dynamic> json) {
		authorizationProvider = json['apn'];
		cloudID = json['sid'];
		cloudURL = json['cis'];
		lastErrorCode = json['clec'];
		provisioningStatus = json['cps'];
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
  String supportedContentTypes;

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
