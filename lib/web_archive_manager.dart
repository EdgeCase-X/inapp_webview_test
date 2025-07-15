import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';

/// Utility class for saving and loading web archives.
class WebArchiveManager {
  /// Saves the current content of the [controller] as a web archive to [fileName] in external storage.
  static Future<bool> saveWebArchive(
    InAppWebViewController? controller,
    String fileName,
  ) async {
    if (controller == null) return false;
    final directory = await getExternalStorageDirectory();
    if (directory == null) return false;
    final filePath = '${directory.path}/$fileName';
    final result = await controller.saveWebArchive(
      filePath: filePath,
      autoname: false,
    );
    return result != null && File(filePath).existsSync();
  }

  /// Loads a web archive file [fileName] from external storage into the [controller].
  static Future<bool> loadWebArchive(
    InAppWebViewController? controller,
    String fileName,
  ) async {
    if (controller == null) return false;
    final directory = await getExternalStorageDirectory();
    if (directory == null) return false;
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    if (!file.existsSync()) return false;
    final data = await file.readAsString();
    await controller.loadData(
      data: data,
      mimeType: 'multipart/related', // for .mht/.webarchive files
      encoding: 'utf-8',
      baseUrl: WebUri('file://$filePath'),
    );
    return true;
  }
}
