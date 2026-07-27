import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:immich_mobile/domain/models/feature_message.model.dart';
import 'package:immich_mobile/extensions/build_context_extensions.dart';
import 'package:immich_mobile/generated/translations.g.dart';
import 'package:immich_mobile/presentation/widgets/feature_message/feature_message_placeholder.widget.dart';

@RoutePage()
class WhatsNewPage extends StatelessWidget {
  const WhatsNewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final highlights = visibleFeatureMessageHighlights;
    return Scaffold(
      appBar: AppBar(centerTitle: false, title: Text(context.t.whats_new)),
      body: ListView.separated(
        padding: const .only(top: 16, bottom: 64),
        itemCount: highlights.length,
        separatorBuilder: (_, __) => const SizedBox(height: 24),
        itemBuilder: (_, index) => _HighlightCard(highlight: highlights[index]),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final FeatureHighlight highlight;

  const _HighlightCard({required this.highlight});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Padding(
      padding: const .symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: const .all(.circular(18)),
              border: .all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: ClipRRect(
              borderRadius: const .all(.circular(18)),
              child: SizedBox(
                width: .infinity,
                height: 256,
                child: highlight.image == null
                    ? const FeatureMessagePlaceholder()
                    : Image.asset(
                        highlight.image!,
                        fit: .contain,
                        errorBuilder: (context, _, __) => const FeatureMessagePlaceholder(),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(highlight.titleKey.tr(), style: context.textTheme.titleMedium?.copyWith(fontWeight: .w600)),
          const SizedBox(height: 4),
          Text(
            highlight.bodyKey.tr(),
            style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
