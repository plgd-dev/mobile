import 'package:flutter/material.dart';
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
        return WebView(
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
            if (url.startsWith(authOrigin)) { 
              // in case redirect url is requested, expected content will be already present
              _controller.evaluateJavascript("(function(){OAuth.postMessage(document.documentElement.innerText)})();");
            } else if (!url.contains('/authorize?')) { // other url, not OAuth2.0 related requests user authentication
              this.promptForCredentials();
            }
          },
          gestureNavigationEnabled: true,
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