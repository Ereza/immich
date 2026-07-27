import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:immich_mobile/extensions/build_context_extensions.dart';

enum ToastType { info, success, error }

class ImmichToast {
  static show({
    required BuildContext context,
    required String msg,
    ToastType toastType = .info,
    ToastGravity gravity = .BOTTOM,
    int durationInSecond = 3,
  }) {
    final fToast = FToast();
    fToast.init(context);

    Color getColor(ToastType type, BuildContext context) => switch (type) {
      .info => context.primaryColor,
      .success => const .fromARGB(255, 78, 140, 124),
      .error => const .fromARGB(255, 220, 48, 85),
    };

    Icon getIcon(ToastType type) => switch (type) {
      .info => .new(Icons.info_outline_rounded, color: context.primaryColor),
      .success => const .new(Icons.check_circle_rounded, color: Color.fromARGB(255, 78, 140, 124)),
      .error => const .new(Icons.error_outline_rounded, color: Color.fromARGB(255, 240, 162, 156)),
    };

    fToast.showToast(
      child: Container(
        padding: const .symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: const .all(.circular(16.0)),
          color: context.colorScheme.surfaceContainer,
          border: .all(color: context.colorScheme.outline.withValues(alpha: .5), width: 1),
        ),
        child: Row(
          mainAxisSize: .min,
          children: [
            getIcon(toastType),
            const SizedBox(width: 12.0),
            Flexible(
              child: Text(
                msg,
                style: TextStyle(color: getColor(toastType, context), fontWeight: .w600, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
      positionedToastBuilder: (context, child, gravity) {
        final isTop = gravity == .TOP;
        return Positioned(
          top: isTop ? 150 : null,
          bottom: isTop ? null : 150 + MediaQuery.of(context).viewInsets.bottom,
          left: MediaQuery.of(context).size.width / 2 - 150,
          right: MediaQuery.of(context).size.width / 2 - 150,
          child: IgnorePointer(child: child),
        );
      },
      gravity: gravity,
      toastDuration: Duration(seconds: durationInSecond),
    );
  }
}
