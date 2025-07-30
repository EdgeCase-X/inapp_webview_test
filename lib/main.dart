import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'
    show InAppWebViewController, WebViewEnvironment;
import 'package:inapp_webview_test/pages/main_page.dart' show MainPage;
import 'package:logger/logger.dart' show DateTimeFormat, Logger;
import 'package:logger/web.dart' show PrettyPrinter;

WebViewEnvironment? webViewEnvironment;

Logger logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2, // Number of method calls to be displayed
    errorMethodCount: 8, // Number of method calls if stacktrace is provided
    lineLength: 120, // Width of the output
    colors: true, // Colorful log messages
    printEmojis: true, // Print an emoji for each log message
    // Should each log print contain a timestamp
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

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
