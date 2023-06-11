import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:rich_clipboard/rich_clipboard.dart';

const _kHtmlDescriptionTemplate =
    '''
Version:0.9
StartHTML:0000000000
EndHTML:0000000000
StartFragment:0000000000
EndFragment:0000000000
''';

class AppFlowyClipboardData {
  const AppFlowyClipboardData({
    required this.text,
    required this.html,
  });
  final String? text;
  final String? html;
}

class AppFlowyClipboard {
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
    final data = await RichClipboard.getData();
    final text = data.text;
    var html = data.html;

    // https://github.com/BringingFire/rich_clipboard/issues/13
    // Remove all the fragment symbol in Windows.
    if (!kIsWeb && Platform.isWindows && html != null) {
      html = html
          .replaceAll('<!--StartFragment-->', '')
          .replaceAll('<!--EndFragment-->', '')
          .replaceAll(RegExp(r'Version:\d\.\d\n?'), '')
          .replaceAll(RegExp(r'StartHTML:\d{10}\n?'), '')
          .replaceAll(RegExp(r'EndHTML:\d{10}\n?'), '')
          .replaceAll(RegExp(r'StartFragment:\d{10}\n?'), '')
          .replaceAll(RegExp(r'EndFragment:\d{10}\n?'), '');
    }

    return AppFlowyClipboardData(
      text: text,
      html: html,
    );
  }
}
