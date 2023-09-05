import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:rich_clipboard/rich_clipboard.dart';
import 'package:pasteboard/pasteboard.dart';

class AppFlowyClipboardData {
  const AppFlowyClipboardData({
    this.text,
    this.html,
    this.imageBytes,
  });
  final String? text;
  final String? html;
  final Uint8List? imageBytes;
}

class AppFlowyClipboard {
  static AppFlowyClipboardData? _mockData;

  static Future<void> setData({
    String? text,
    String? html,
  }) async {
    // https://github.com/BringingFire/rich_clipboard/issues/13
    // Wrapping a `<html><body>` tag for html in Windows,
    //  otherwise it will raise an exception
    if (!kIsWeb && Platform.isWindows && html != null) {
      if (!html.startsWith('<html><body>')) {
        html = '<html><body>$html</body></html>';
      }
    }

    return RichClipboard.setData(
      RichClipboardData(
        text: text,
        html: html,
      ),
    );
  }

  static Future<AppFlowyClipboardData> getData() async {
    if (_mockData != null) {
      return _mockData!;
    }

    final imageBytes = await Pasteboard.image;

    if (imageBytes != null) {
      return AppFlowyClipboardData(
        text: null,
        html: null,
        imageBytes: imageBytes,
      );
    }

    final data = await RichClipboard.getData();
    final text = data.text;
    var html = data.html;

    // https://github.com/BringingFire/rich_clipboard/issues/13
    // Remove all the fragment symbol in Windows.
    if (!kIsWeb && Platform.isWindows && html != null) {
      html = html
          .replaceAll('<!--StartFragment-->', '')
          .replaceAll('<!--EndFragment-->', '');
    }

    return AppFlowyClipboardData(
      text: text,
      html: html,
    );
  }

  @visibleForTesting
  static void mockSetData(AppFlowyClipboardData? data) {
    _mockData = data;
  }
}
