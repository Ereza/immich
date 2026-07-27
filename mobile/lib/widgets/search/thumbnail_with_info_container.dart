import 'package:flutter/material.dart';
import 'package:immich_mobile/extensions/build_context_extensions.dart';
import 'package:immich_mobile/extensions/theme_extensions.dart';

class ThumbnailWithInfoContainer extends StatelessWidget {
  const ThumbnailWithInfoContainer({
    super.key,
    this.onTap,
    this.borderRadius = 10,
    required this.label,
    required this.child,
  });

  final VoidCallback? onTap;
  final double borderRadius;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: .bottomLeft,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: .circular(borderRadius),
              gradient: LinearGradient(
                colors: [context.colorScheme.surfaceContainer, context.colorScheme.surfaceContainer.darken(amount: .1)],
                begin: .topCenter,
                end: .bottomCenter,
              ),
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: .circular(borderRadius),
              color: Colors.white,
              gradient: LinearGradient(
                begin: .topCenter,
                end: .bottomCenter,
                colors: [
                  Colors.transparent,
                  label == '' ? Colors.black.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.5),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
            child: child,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8) + const .only(bottom: 8),
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: .bold, fontSize: 14),
              maxLines: 2,
              softWrap: false,
              overflow: .ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
