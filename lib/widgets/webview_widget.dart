import 'dart:collection' show UnmodifiableListView;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart' show logger, webViewEnvironment;

class WebViewWidget extends StatelessWidget {
  final GlobalKey webViewKey;
  final InAppWebViewController? controller;
  final InAppWebViewSettings settings;
  final PullToRefreshController? pullToRefreshController;
  final double progress;
  final TextEditingController urlController;
  final void Function(InAppWebViewController) onWebViewCreated;
  final void Function(String) onUrlChanged;

  const WebViewWidget({
    super.key,
    required this.webViewKey,
    required this.controller,
    required this.settings,
    required this.pullToRefreshController,
    required this.progress,
    required this.urlController,
    required this.onWebViewCreated,
    required this.onUrlChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          InAppWebView(
            key: webViewKey,
            webViewEnvironment: webViewEnvironment,
            initialUserScripts: UnmodifiableListView<UserScript>([]),
            initialSettings: settings,
            pullToRefreshController: pullToRefreshController,
            onWebViewCreated: (controller) async {
              onWebViewCreated(controller);
            },
            onLoadStart: (controller, url) {
              onUrlChanged(url.toString());
              urlController.text = url.toString();
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
              onUrlChanged(url.toString());
              urlController.text = url.toString();
            },
            onReceivedError: (controller, request, error) {
              pullToRefreshController?.endRefreshing();
            },
            onProgressChanged: (controller, progress) {
              if (progress == 100) {
                pullToRefreshController?.endRefreshing();
              }
              // No setState here, parent should handle progress
            },
            onUpdateVisitedHistory: (controller, url, isReload) {
              onUrlChanged(url.toString());
              urlController.text = url.toString();
            },
            onConsoleMessage: (controller, consoleMessage) {
              logger.d(consoleMessage);
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
