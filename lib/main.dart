import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'
    show InAppLocalhostServer, InAppWebViewController, WebViewEnvironment;
import 'package:inapp_webview_test/pages/main_page.dart' show MainPage;

final localhostServer = InAppLocalhostServer(documentRoot: 'assets');
WebViewEnvironment? webViewEnvironment;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);

  runApp(const EdgeCasePOC());
}

class EdgeCasePOC extends StatelessWidget {
  const EdgeCasePOC({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EdgeCaseX POC', home: const MainPage(),
    );
  }
}
