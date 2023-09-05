import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> onDelete(
  TextEditingDeltaDeletion deletion,
  EditorState editorState,
  List<String> blockTypes,
) async {
  Log.input.debug('onDelete: $deletion');

  final selection = editorState.selection;
  if (selection == null) {
    return;
  }

  // IME
  if (selection.isSingle) {
    final node = editorState.getNodeAtPath(selection.start.path);
    if (node?.delta != null &&
        (deletion.composing.isValid || !deletion.deletedRange.isCollapsed)) {
      final node = editorState.getNodesInSelection(selection).first;
      final start = deletion.deletedRange.start;
      final length = deletion.deletedRange.end - start;
      final transaction = editorState.transaction;
      transaction.deleteText(node, start, length);
      await editorState.apply(transaction);
      return;
    }
    // 处理前一个元素是自定义 Node 的情况
    final lastNode = node?.previous;

    if (blockTypes.contains(lastNode?.type)) {
      final transaction = editorState.transaction;
      transaction.deleteNode(lastNode!);
      await editorState.apply(transaction);
      backspaceCommand.execute(editorState);
      return;
    }
  }

  // use backspace command instead.
  if (KeyEventResult.ignored ==
      convertToParagraphCommand.execute(editorState)) {
    backspaceCommand.execute(editorState);
  }
}
