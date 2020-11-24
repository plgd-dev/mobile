import 'package:client/appConstants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  bool _loadingInProgress = false;

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
          children: [
            Visibility(
              visible: _loadingInProgress,
              maintainState: true,
              child: SpinKitRing(color: AppConstants.blueMainColor, size: 30, lineWidth: 2.0)
            ),
            Visibility(
              visible: !_loadingInProgress,
              maintainState: true,
              child: InAppWebView(
                initialUrl: authUrl,
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
                onLoadError: (InAppWebViewController controller, String url, int code, String message) {
                  if (code == 102) { // apple signin returns 102 what is not an error
                    return;
                  }
                  errorOccured();
                },
                onLoadHttpError: (InAppWebViewController controller, String url, int statusCode, String description) {
                  errorOccured();
                },
                onLoadStop: (InAppWebViewController controller, String url) async {
                  // in case redirect url is requested, expected content will be already present
                  if (url.startsWith(authOrigin)) { 
                    _controller.evaluateJavascript(source: "(function(){window.flutter_inappwebview.callHandler('handleOAuthResponse', document.documentElement.innerText)})();");
                    return;
                  }

                  // other url, not OAuth2.0 related are promting user to login
                  if (!url.contains('/authorize?')) {
                    setState(() { _loadingInProgress = false; });
                    this.promptForCredentials();
                    return;
                  }
                },
                onLoadStart: (InAppWebViewController controller, String url) {
                  if (url.startsWith(authOrigin))
                    setState(() { _loadingInProgress = true; });
                },
                onReceivedServerTrustAuthRequest: (InAppWebViewController controller, ServerTrustChallenge challenge) async {
                  return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
                }
              )
            )
          ]
        );
      }
    );
  }
}