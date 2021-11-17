import 'package:client/appConstants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class OAuthHandler extends StatefulWidget {
  final String authUrl;
  final Function promptForCredentials;
  final Function(String) authCompleted;
  final Function errorOccured;

  OAuthHandler({Key key, this.authUrl, this.promptForCredentials, this.authCompleted, this.errorOccured}) : super(key: key);
  
  @override
  _OAuthHandlerState createState() => new _OAuthHandlerState(authUrl, promptForCredentials, authCompleted, errorOccured);
}

class _OAuthHandlerState extends State<OAuthHandler> {
  final String authUrl;
  final Function promptForCredentials;
  final Function(String) authCompleted;
  final Function errorOccured;
  String authOrigin;
  InAppWebViewController _controller;

  _OAuthHandlerState(this.authUrl, this.promptForCredentials, this.authCompleted, this.errorOccured);

  @override
  initState() {
    super.initState();
    authOrigin = Uri.parse(authUrl).origin;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          children: [InAppWebView(
                initialUrlRequest: URLRequest(url: Uri.parse(authUrl)),
                initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      userAgent: 'Mozilla/5.0 Google'
                    )
                ),
                gestureRecognizers: Set()
                  ..add(Factory<VerticalDragGestureRecognizer>(
                    () => VerticalDragGestureRecognizer()
                  )
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                  _controller = controller;
                  _controller.addJavaScriptHandler(handlerName:'handleOAuthResponse', callback: (args) {
                    authCompleted(args[0]);
                  });

                },
                onLoadError: (InAppWebViewController controller, Uri url, int code, String message) {
                  if (code == 102) { // apple signin returns 102 what is not an error
                    return;
                  }
                  if (url.toString().startsWith(AppConstants.authRedirectUri)) {
                    var code = url.queryParameters['code'];
                    authCompleted(code);
                    return;
                  }
                    
                  errorOccured();
                },
                onLoadHttpError: (InAppWebViewController controller, Uri url, int statusCode, String description) {
                  errorOccured();
                },
                onLoadStop: (InAppWebViewController controller, Uri url) async {
                  if (url.toString().startsWith(AppConstants.authRedirectUri)) {
                    // valid redirect url is handled on onLoadError as custom scheme is not supported
                    // but in case of android also onLoadStop is invoked
                    return;
                  }
                  // other url, not OAuth2.0 related are promting user to login
                  if (!url.toString().contains('/authorize?') && this.promptForCredentials != null) {
                    this.promptForCredentials();
                    return;
                  }
                },
                onReceivedServerTrustAuthRequest: (controller, challenge) async {
                  return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
                }
              )
          ]
        );
      }
    );
  }
}