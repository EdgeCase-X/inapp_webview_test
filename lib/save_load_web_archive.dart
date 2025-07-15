import 'dart:collection' show UnmodifiableListView;

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'
    show
        InAppWebView,
        InAppWebViewController,
        InAppWebViewSettings,
        NavigationActionPolicy,
        PullToRefreshController,
        PullToRefreshSettings,
        URLRequest,
        UserScript,
        WebUri;
import 'package:inapp_webview_test/main.dart' show myDrawer, webViewEnvironment;
import 'package:inapp_webview_test/web_archive_manager.dart';
import 'package:url_launcher/url_launcher.dart' show canLaunchUrl, launchUrl;

class SaveLoadWebArchive extends StatefulWidget {
  const SaveLoadWebArchive({super.key});

  @override
  State<SaveLoadWebArchive> createState() => _SaveLoadWebArchiveState();
}

class _SaveLoadWebArchiveState extends State<SaveLoadWebArchive> {
  final GlobalKey saveWebViewKey = GlobalKey();
  final GlobalKey loadWebViewKey = GlobalKey();

  InAppWebViewController? saveWebViewController;
  InAppWebViewController? loadWebViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    allowFileAccessFromFileURLs: true,
    allowFileAccess: true,
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
  );

  PullToRefreshController? pullToRefreshController;

  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  static const String archiveFileName = 'archive2.mht';

  @override
  void initState() {
    super.initState();

    pullToRefreshController =
        kIsWeb ||
                ![
                  TargetPlatform.iOS,
                  TargetPlatform.android,
                ].contains(defaultTargetPlatform)
            ? null
            : PullToRefreshController(
              settings: PullToRefreshSettings(color: Colors.blue),
              onRefresh: () async {
                if (defaultTargetPlatform == TargetPlatform.android) {
                  saveWebViewController?.reload();
                } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                  saveWebViewController?.loadUrl(
                    urlRequest: URLRequest(
                      url: await saveWebViewController?.getUrl(),
                    ),
                  );
                }
              },
            );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("InAppBrowser")),
      drawer: myDrawer(context: context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
              controller: urlController,
              keyboardType: TextInputType.text,
              onSubmitted: (value) {
                var url = WebUri(value);
                if (url.scheme.isEmpty) {
                  url = WebUri(
                    (!kIsWeb
                            ? "https://www.google.com/search?q="
                            : "https://www.bing.com/search?q=") +
                        value,
                  );
                }
                saveWebViewController?.loadUrl(
                  urlRequest: URLRequest(url: url),
                );
              },
            ),
            saveWebView(),
            Expanded(
              flex: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final success = await WebArchiveManager.saveWebArchive(
                        saveWebViewController,
                        archiveFileName,
                      );
                      if (success) {
                        print("WebView archived to: $archiveFileName");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Archive saved!')),
                        );
                      } else {
                        print("ERROR: Error archiving WebView.");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to save archive!')),
                        );
                      }
                    },
                    child: Text("Archive"),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final success = await WebArchiveManager.loadWebArchive(
                        loadWebViewController,
                        archiveFileName,
                      );
                      if (success) {
                        print("Loaded archive from: $archiveFileName");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Archive loaded!')),
                        );
                      } else {
                        print("ERROR: Could not load archive.");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to load archive!')),
                        );
                      }
                    },
                    child: Text("Load archive"),
                  ),
                ],
              ),
            ),
            loadWebView(),
          ],
        ),
      ),
    );
  }

  Widget saveWebView() => Expanded(
    child: Stack(
      children: [
        InAppWebView(
          key: saveWebViewKey,
          webViewEnvironment: webViewEnvironment,
          initialUrlRequest: URLRequest(url: WebUri('https://flutter.dev')),
          initialUserScripts: UnmodifiableListView<UserScript>([]),
          initialSettings: settings,
          pullToRefreshController: pullToRefreshController,
          onWebViewCreated: (controller) async {
            saveWebViewController = controller;
          },
          onLoadStart: (controller, url) {
            setState(() {
              this.url = url.toString();
              urlController.text = this.url;
            });
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            var uri = navigationAction.request.url!;

            if (![
              "http",
              "https",
              "file",
              "chrome",
              "data",
              "javascript",
              "about",
            ].contains(uri.scheme)) {
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
                return NavigationActionPolicy.CANCEL;
              }
            }

            return NavigationActionPolicy.ALLOW;
          },
          onLoadStop: (controller, url) {
            pullToRefreshController?.endRefreshing();
            setState(() {
              this.url = url.toString();
              urlController.text = this.url;
            });
          },
          onReceivedError: (controller, request, error) {
            pullToRefreshController?.endRefreshing();
          },
          onProgressChanged: (controller, progress) {
            if (progress == 100) {
              pullToRefreshController?.endRefreshing();
            }
            setState(() {
              this.progress = progress / 100;
              urlController.text = url;
            });
          },
          onUpdateVisitedHistory: (controller, url, isReload) {
            setState(() {
              this.url = url.toString();
              urlController.text = this.url;
            });
          },
          onConsoleMessage: (controller, consoleMessage) {
            print(consoleMessage);
          },
        ),
        progress < 1.0 ? LinearProgressIndicator(value: progress) : Container(),
      ],
    ),
  );

  Widget loadWebView() => Expanded(
    child: Stack(
      children: [
        InAppWebView(
          key: loadWebViewKey,
          webViewEnvironment: webViewEnvironment,
          initialUserScripts: UnmodifiableListView<UserScript>([]),
          initialSettings: settings,
          pullToRefreshController: pullToRefreshController,
          onWebViewCreated: (controller) async {
            loadWebViewController = controller;
          },
          onLoadStart: (controller, url) {
            setState(() {
              this.url = url.toString();
              urlController.text = this.url;
            });
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            var uri = navigationAction.request.url!;

            if (![
              "http",
              "https",
              "file",
              "chrome",
              "data",
              "javascript",
              "about",
            ].contains(uri.scheme)) {
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
                return NavigationActionPolicy.CANCEL;
              }
            }

            return NavigationActionPolicy.ALLOW;
          },
          onLoadStop: (controller, url) {
            pullToRefreshController?.endRefreshing();
            setState(() {
              this.url = url.toString();
              urlController.text = this.url;
            });
          },
          onReceivedError: (controller, request, error) {
            pullToRefreshController?.endRefreshing();
          },
          onProgressChanged: (controller, progress) {
            if (progress == 100) {
              pullToRefreshController?.endRefreshing();
            }
            setState(() {
              this.progress = progress / 100;
              urlController.text = url;
            });
          },
          onUpdateVisitedHistory: (controller, url, isReload) {
            setState(() {
              this.url = url.toString();
              urlController.text = this.url;
            });
          },
          onConsoleMessage: (controller, consoleMessage) {
            print(consoleMessage);
          },
        ),
        progress < 1.0 ? LinearProgressIndicator(value: progress) : Container(),
      ],
    ),
  );
}
