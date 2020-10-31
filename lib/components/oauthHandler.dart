import 'package:client/appConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OAuthHandler extends StatefulWidget {
  final String authUrl;
  final Function promptForCredentials;
  final Function(String) authCompleted;

  OAuthHandler({Key key, this.authUrl, this.promptForCredentials, this.authCompleted}) : super(key: key);
  
  @override
  _OAuthHandlerState createState() => new _OAuthHandlerState(authUrl, promptForCredentials, authCompleted);
}

class _OAuthHandlerState extends State<OAuthHandler> {
  final String authUrl;
  final Function promptForCredentials;
  final Function(String) authCompleted;
  String authOrigin;
  WebViewController _controller;
  bool _loadingInProgress = false;

  _OAuthHandlerState(this.authUrl, this.promptForCredentials, this.authCompleted);

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
              child: WebView(
                initialUrl: authUrl,
                userAgent: "Mozilla/5.0 Google",
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                },
                javascriptChannels: <JavascriptChannel>[
                  _extractData(context),
                ].toSet(),
                onPageFinished: (String url) {
                  // in case redirect url is requested, expected content will be already present
                  if (url.startsWith(authOrigin)) { 
                    _controller.evaluateJavascript("(function(){OAuth.postMessage(document.documentElement.innerText)})();");
                    return;
                  }

                  // other url, not OAuth2.0 related are promting user to login
                  if (!url.contains('/authorize?')) {
                    setState(() { _loadingInProgress = false; });
                    this.promptForCredentials();
                    return;
                  }
                },
                onPageStarted: (_) => { setState(() { _loadingInProgress = true; }) },
                gestureNavigationEnabled: true,
              )
            )
          ]
        );
      }
    );
  }

  JavascriptChannel _extractData(BuildContext context) {
    return JavascriptChannel(
          name: 'OAuth',
          onMessageReceived: (JavascriptMessage message) {
            authCompleted(message.message);
          },
       );
    }
}