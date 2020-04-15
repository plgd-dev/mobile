import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class OAuthLogin extends StatefulWidget {
  final bool tryInBackground;
  final String authUrl;
  final String redirectUrl;

  final Function promptForCredentials;
  final Function(String) authCompleted;

  OAuthLogin({Key key, this.authUrl, this.redirectUrl, this.promptForCredentials, this.authCompleted, this.tryInBackground}) : super(key: key);
  
  @override
  _OAuthLoginState createState() => new _OAuthLoginState(tryInBackground, authUrl, redirectUrl, promptForCredentials, authCompleted);
}

class _OAuthLoginState extends State<OAuthLogin> {
  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  final String authUrl;
  final String redirectUrl;
  final Function promptForCredentials;
  final Function(String) authCompleted;

  bool tryInBackground;
  StreamSubscription<WebViewStateChanged> _onStateChanged;

  _OAuthLoginState(this.tryInBackground, this.authUrl, this.redirectUrl, this.promptForCredentials, this.authCompleted);

  @override
  void dispose() {
    _onStateChanged.cancel();
    flutterWebviewPlugin.close();
    flutterWebviewPlugin.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _onStateChanged = flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) async {
      if (state.type == WebViewState.finishLoad) {
        if (state.url.startsWith(redirectUrl)) {
          var content = await flutterWebviewPlugin.evalJavascript("document.documentElement.innerText");
          authCompleted(content);
        } else if (this.tryInBackground) {
          this.promptForCredentials();
          setState(() { tryInBackground = false; });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Center(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: tryInBackground ? 0.0 : constraints.maxWidth,
            height: tryInBackground ? 0.0 : constraints.maxHeight,
            child: WebviewScaffold(
              appBar: tryInBackground ? null : new AppBar(title: const Text('test asd ')),
              // clearCookies: true,
              // clearCache: true,
              url: authUrl,
              userAgent: "Mozilla/5.0 Google",
              withJavascript: true)
          )
        );
      }
    );
  }
}