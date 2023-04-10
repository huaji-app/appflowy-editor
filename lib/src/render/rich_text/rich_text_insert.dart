import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/extensions/text_style_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:appflowy_editor/src/extensions/url_launcher_extension.dart';

class RichTextInsertBuilder extends TextInsertBuilder {
  RichTextInsertBuilder();

  GestureRecognizer _buildTapHrefGestureRecognizer(
      TextInsertContext context, String href, Selection selection) {
    Timer? timer;
    var tapCount = 0;
    final tapGestureRecognizer = TapGestureRecognizer()
      ..onTap = () async {
        // implement a simple double tap logic
        tapCount += 1;
        timer?.cancel();

        if (tapCount == 2 || !context.editorState.editable) {
          tapCount = 0;
          safeLaunchUrl(href);
          return;
        }

        timer = Timer(const Duration(milliseconds: 200), () {
          tapCount = 0;
          context.editorState.service.selectionService
              .updateSelection(selection);
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            showLinkMenu(
              context.context,
              context.editorState,
              customSelection: selection,
            );
          });
        });
      };
    return tapGestureRecognizer;
  }

  @override
  InlineSpan build(TextInsertContext context) {
    final style = context.editorState.editorStyle;
    var textStyle = style.textStyle!;
    GestureRecognizer? recognizer;
    final attributes = context.textInsert.attributes;
    if (attributes != null) {
      if (attributes.bold == true) {
        textStyle = textStyle.combine(style.bold);
      }
      if (attributes.italic == true) {
        textStyle = textStyle.combine(style.italic);
      }
      if (attributes.underline == true) {
        textStyle = textStyle.combine(style.underline);
      }
      if (attributes.strikethrough == true) {
        textStyle = textStyle.combine(style.strikethrough);
      }
      if (attributes.href != null) {
        textStyle = textStyle.combine(style.href);
        recognizer = _buildTapHrefGestureRecognizer(
          context,
          attributes.href!,
          Selection.single(
            path: context.textNode.path,
            startOffset: context.offset,
            endOffset: context.offset + context.textInsert.length,
          ),
        );
      }
      if (attributes.code == true) {
        textStyle = textStyle.combine(style.code);
      }
      if (attributes.backgroundColor != null) {
        textStyle = textStyle.combine(
          TextStyle(backgroundColor: attributes.backgroundColor),
        );
      }
      if (attributes.color != null) {
        textStyle = textStyle.combine(
          TextStyle(color: attributes.color),
        );
      }
    }

    return TextSpan(
      text: context.textInsert.text,
      style: textStyle,
      recognizer: recognizer,
    );
  }
}
