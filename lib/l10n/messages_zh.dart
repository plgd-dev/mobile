// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "configureCustomEndpointButton" : MessageLookupByLibrary.simpleMessage("自定义 plgd 云平台的端点"),
    "continueToPlgdCloudButton" : MessageLookupByLibrary.simpleMessage("继续前往 "),
    "customEndpointButtonCancel" : MessageLookupByLibrary.simpleMessage("取消"),
    "customEndpointButtonContinue" : MessageLookupByLibrary.simpleMessage("继续"),
    "devicesScreenTitle" : MessageLookupByLibrary.simpleMessage("设备"),
    "factoryResetButton" : MessageLookupByLibrary.simpleMessage("恢复出厂设置（设备将与云平台断开）"),
    "invalidConfigurationNotification" : MessageLookupByLibrary.simpleMessage("获得配置信息，但格式不正确"),
    "invalidEndpointNotification" : MessageLookupByLibrary.simpleMessage("端点的URL格式不正确"),
    "onboardButton" : MessageLookupByLibrary.simpleMessage("连接云平台"),
    "requestApplicationSetupNotification" : MessageLookupByLibrary.simpleMessage("请重置应用程序"),
    "resetApplicationDialogCancelButton" : MessageLookupByLibrary.simpleMessage("取消"),
    "resetApplicationDialogYesButton" : MessageLookupByLibrary.simpleMessage("是"),
    "unableToAuthenticateNotification" : MessageLookupByLibrary.simpleMessage("身份验证期间发生错误"),
    "unableToDiscoverDevicesNotification" : MessageLookupByLibrary.simpleMessage("设备发现过程出错"),
    "unableToDisownNotification" : MessageLookupByLibrary.simpleMessage("无法把设备恢复为出厂设置"),
    "unableToFetchConfigurationNotification" : MessageLookupByLibrary.simpleMessage("无法获得服务器配置信息"),
    "unableToInitializeClientNotification" : MessageLookupByLibrary.simpleMessage("plgd 客户端初始化出错"),
    "unableToOnboardNotification" : MessageLookupByLibrary.simpleMessage("设备连接 plgd 云平台时出错"),
    "unableToSetACLNotification" : MessageLookupByLibrary.simpleMessage("访问控制列表设置出错"),
    "unableToSetDeviceOwnershipNotification" : MessageLookupByLibrary.simpleMessage("无法设置设备的所有者")
  };
}
