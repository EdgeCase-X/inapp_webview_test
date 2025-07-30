import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewTabWidget extends StatelessWidget {
  final TextEditingController urlController;
  final FocusNode urlFocusNode;
  final InAppWebViewController? mainWebViewController;
  final double progress;
  final Function(String) onUrlSubmitted;
  final Widget mainWebView;

  const WebViewTabWidget({
    super.key,
    required this.urlController,
    required this.urlFocusNode,
    required this.mainWebViewController,
    required this.progress,
    required this.onUrlSubmitted,
    required this.mainWebView,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextField(
          decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
          controller: urlController,
          focusNode: urlFocusNode,
          keyboardType: TextInputType.url,
          onSubmitted: onUrlSubmitted,
        ),
        mainWebView,
        OverflowBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Icon(Icons.arrow_back),
              onPressed: () {
                mainWebViewController?.goBack();
              },
            ),
            ElevatedButton(
              child: Icon(Icons.arrow_forward),
              onPressed: () {
                mainWebViewController?.goForward();
              },
            ),
            ElevatedButton(
              child: Icon(Icons.refresh),
              onPressed: () {
                mainWebViewController?.reload();
              },
            ),
          ],
        ),
      ],
    );
  }
}
