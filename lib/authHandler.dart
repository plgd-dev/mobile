import 'dart:async';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'oauthLogin.dart';


class AuthHandler {
  final BuildContext context;
  Completer _completer;
  ProgressDialog pr;

  AuthHandler(this.context);

  void _tryAuth() {
    pr = new ProgressDialog(context, type: ProgressDialogType.Normal);
    pr.style(message: "Authorizing request", progressWidget: CircularProgressIndicator());
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (BuildContext context, _, __) =>
        
        Scaffold(
          backgroundColor: Colors.white.withOpacity(0.70),
          body: OAuthLogin(authUrl: "https://portal.try.plgd.cloud/api/authz/token", redirectUrl: "https://portal.try.plgd.cloud/api/authz/callback", promptForCredentials: _onPromptForCredentials, authCompleted: _onAuthCompleted, tryInBackground: true)
        )));
      
    pr.show();
  }

  void _onAuthCompleted(String response) {
    print(response);
    Navigator.of(context).pop();
    if (_completer != null && !_completer.isCompleted) {
      _completer.complete(response);
    }
  }

  void _onPromptForCredentials() {
    pr.hide();
    // if (authRequested) {
    //   Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => new LoginScreen(authUrl: "https://portal.try.plgd.cloud/api/authz/token", redirectUrl: "https://portal.try.plgd.cloud/api/authz/callback", onAuthCompleted: _onAuthCompleted, onAuthRequested: _onAuthRequested, hidden: false)));
    // }
  }

  Future<String> getToken() {
    if (_completer != null && !_completer.isCompleted)
      throw ErrorDescription("One auth request in time is allowed");
    _completer = new Completer();
    _tryAuth();
    return _completer.future;
  }

  Future<String> getAuthorizationCode(String deviceId) {
    if (_completer != null && !_completer.isCompleted)
      throw ErrorDescription("One auth request in time is allowed");
    _completer = new Completer();
    _tryAuth();
    return _completer.future;
  }
}