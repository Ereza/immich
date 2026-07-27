import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:immich_mobile/extensions/build_context_extensions.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/delete_trash_action_button.widget.dart';
import 'package:immich_mobile/presentation/widgets/action_buttons/restore_trash_action_button.widget.dart';

class TrashBottomBar extends ConsumerWidget {
  const TrashBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: .bottomCenter,
      child: Container(
        color: context.themeData.canvasColor,
        padding: const .symmetric(vertical: 8),
        child: const SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: .spaceEvenly,
            children: [
              DeleteTrashActionButton(source: .timeline),
              RestoreTrashActionButton(source: .timeline),
            ],
          ),
        ),
      ),
    );
  }
}
