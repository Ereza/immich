import 'package:flutter/material.dart';
import 'package:immich_mobile/extensions/build_context_extensions.dart';

class DragHandle extends StatelessWidget {
  const DragHandle({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const .symmetric(vertical: 12),
    child: Center(
      child: Container(
        width: 32,
        height: 4,
        decoration: BoxDecoration(borderRadius: const .all(.circular(2)), color: context.colorScheme.onSurfaceVariant),
      ),
    ),
  );
}
