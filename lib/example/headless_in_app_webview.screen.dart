import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:inapp_webview_test/main.dart' show myDrawer, webViewEnvironment;

class HeadlessInAppWebViewExampleScreen extends StatefulWidget {
  const HeadlessInAppWebViewExampleScreen({super.key});

  @override
  _HeadlessInAppWebViewExampleScreenState createState() =>
      _HeadlessInAppWebViewExampleScreenState();
}

class _HeadlessInAppWebViewExampleScreenState
    extends State<HeadlessInAppWebViewExampleScreen> {
  HeadlessInAppWebView? headlessWebView;
  String url = "";

  @override
  void initState() {
    super.initState();

    var url =
        !kIsWeb
            ? WebUri("https://flutter.dev")
            : WebUri("http://localhost:${Uri.base.port}/page.html");

    headlessWebView = HeadlessInAppWebView(
      webViewEnvironment: webViewEnvironment,
      initialUrlRequest: URLRequest(url: url),
      initialSettings: InAppWebViewSettings(isInspectable: kDebugMode),
      onWebViewCreated: (controller) {
        print('HeadlessInAppWebView created!');
      },
      onConsoleMessage: (controller, consoleMessage) {
        print("CONSOLE MESSAGE: ${consoleMessage.message}");
      },
      onLoadStart: (controller, url) {
        setState(() {
          this.url = url.toString();
        });
      },
      onLoadStop: (controller, url) {
        setState(() {
          this.url = url.toString();
        });
      },
      onUpdateVisitedHistory: (controller, url, isReload) {
        setState(() {
          this.url = url.toString();
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    headlessWebView?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("HeadlessInAppWebView")),
      drawer: myDrawer(context: context),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "CURRENT URL\n${(url.length > 50) ? "${url.substring(0, 50)}..." : url}",
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await headlessWebView?.dispose();
                  await headlessWebView?.run();
                },
                child: Text("Run HeadlessInAppWebView"),
              ),
            ),
            Container(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (headlessWebView?.isRunning() ?? false) {
                    await headlessWebView?.webViewController
                        ?.evaluateJavascript(
                          source: """console.log('Here is the message!');""",
                        );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'HeadlessInAppWebView is not running. Click on "Run HeadlessInAppWebView"!',
                        ),
                      ),
                    );
                  }
                },
                child: Text("Send console.log message"),
              ),
            ),
            Container(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  headlessWebView?.dispose();
                  setState(() {
                    url = "";
                  });
                },
                child: Text("Dispose HeadlessInAppWebView"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
