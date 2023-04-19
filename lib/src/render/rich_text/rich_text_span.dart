import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/extensions/text_style_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:appflowy_editor/src/extensions/url_launcher_extension.dart';

const _kRichTextDebugMode = false;

class RichTextSpanBuilder extends TextSpanBuilder {
  RichTextSpanBuilder();

  @override
  TextSpan build(TextSpanContext context) {
    final widget = context.state.widget;

    GestureRecognizer _buildTapHrefGestureRecognizer(
        String href, Selection selection) {
      Timer? timer;
      var tapCount = 0;
      final tapGestureRecognizer = TapGestureRecognizer()
        ..onTap = () async {
          // implement a simple double tap logic
          tapCount += 1;
          timer?.cancel();

          if (tapCount == 2 || !widget.editorState.editable) {
            tapCount = 0;
            safeLaunchUrl(href);
            return;
          }

          timer = Timer(const Duration(milliseconds: 200), () {
            tapCount = 0;
            widget.editorState.service.selectionService
                .updateSelection(selection);
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              showLinkMenu(
                context.state.context,
                widget.editorState,
                customSelection: selection,
              );
            });
          });
        };
      return tapGestureRecognizer;
    }

    var offset = 0;
    List<InlineSpan> textSpans = [];
    final textInserts = widget.textNode.delta.whereType<TextInsert>();
    for (final textInsert in textInserts) {
      final style = widget.editorState.editorStyle;
      var textStyle = style.textStyle!;
      GestureRecognizer? recognizer;
      final attributes = textInsert.attributes;
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
            attributes.href!,
            Selection.single(
              path: widget.textNode.path,
              startOffset: offset,
              endOffset: offset + textInsert.length,
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

      textSpans.add(TextSpan(
        text: textInsert.text,
        style: textStyle,
        recognizer: recognizer,
      ));
      offset += textInsert.length;
    }
    if (_kRichTextDebugMode) {
      textSpans.add(
        TextSpan(
          text: '${widget.textNode.path}',
          style: const TextStyle(
            backgroundColor: Colors.red,
            fontSize: 16.0,
          ),
        ),
      );
    }
    return TextSpan(
      children: textSpans,
    );
  }
}
