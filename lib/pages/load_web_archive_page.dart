import 'dart:collection' show UnmodifiableListView;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:inapp_webview_test/main.dart' show webViewEnvironment;
import 'package:url_launcher/url_launcher.dart' show canLaunchUrl, launchUrl;
import 'package:inapp_webview_test/tools/web_archive_manager.dart';

class LoadWebArchivePage extends StatefulWidget {
  final String archiveFileName;
  const LoadWebArchivePage({super.key, required this.archiveFileName});

  @override
  State<LoadWebArchivePage> createState() => _LoadWebArchivePageState();
}

class _LoadWebArchivePageState extends State<LoadWebArchivePage> {
  final GlobalKey loadWebViewKey = GlobalKey();
  InAppWebViewController? loadWebViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    allowsInlineMediaPlayback: true,
    allowFileAccessFromFileURLs: true,
    allowFileAccess: true,
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
  );
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load the archive when the webview is created
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Archived WebView")),
      body: Stack(
          children: [
            InAppWebView(
              key: loadWebViewKey,
              webViewEnvironment: webViewEnvironment,
              initialUserScripts: UnmodifiableListView<UserScript>([]),
              initialSettings: settings,
              onWebViewCreated: (controller) async {
                loadWebViewController = controller;
                await WebArchiveManager.loadWebArchive(
                  loadWebViewController,
                  widget.archiveFileName,
                );
              },
              onLoadStart: (controller, url) {
                setState(() {
                  urlController.text = url.toString();
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
                setState(() {
                  urlController.text = url.toString();
                });
              },
              onReceivedError: (controller, request, error) {},
              onProgressChanged: (controller, progress) {
                setState(() {
                  this.progress = progress / 100;
                  urlController.text = urlController.text;
                });
              },
              onUpdateVisitedHistory: (controller, url, isReload) {
                setState(() {
                  urlController.text = url.toString();
                });
              },
              onConsoleMessage: (controller, consoleMessage) {
                print(consoleMessage);
              },
            ),
            progress < 1.0
                ? LinearProgressIndicator(value: progress)
                : Container(),
          ],
      ),
    );
  }
}
