import 'package:flutter/material.dart';
import 'package:immich_mobile/extensions/build_context_extensions.dart';
import 'package:immich_mobile/extensions/translate_extensions.dart';
import 'package:immich_mobile/widgets/map/map_thumbnail.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class MapThemePicker extends StatelessWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) onThemeChange;

  const MapThemePicker({super.key, required this.themeMode, required this.onThemeChange});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const .only(bottom: 20),
          child: Center(
            child: Text(
              "map_settings_theme_settings".t(context: context),
              style: context.textTheme.bodyLarge!.copyWith(fontWeight: .w500, height: 1.5),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: .spaceEvenly,
          crossAxisAlignment: .start,
          children: [
            _BorderedMapThumbnail(
              name: "Light",
              mode: .light,
              shouldHighlight: themeMode == .light,
              onThemeChange: onThemeChange,
            ),
            _BorderedMapThumbnail(
              name: "Dark",
              mode: .dark,
              shouldHighlight: themeMode == .dark,
              onThemeChange: onThemeChange,
            ),
            _BorderedMapThumbnail(
              name: "System",
              mode: .system,
              shouldHighlight: themeMode == .system,
              onThemeChange: onThemeChange,
            ),
          ],
        ),
      ],
    );
  }
}

class _BorderedMapThumbnail extends StatelessWidget {
  final ThemeMode mode;
  final String name;
  final bool shouldHighlight;
  final Function(ThemeMode) onThemeChange;

  const _BorderedMapThumbnail({
    required this.mode,
    required this.name,
    required this.shouldHighlight,
    required this.onThemeChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: .fromBorderSide(
              BorderSide(width: 4, color: shouldHighlight ? context.colorScheme.onSurface : Colors.transparent),
            ),
            borderRadius: const .all(.circular(20)),
          ),
          child: MapThumbnail(
            zoom: 2,
            centre: const LatLng(47, 5),
            onTap: (_, __) => onThemeChange(mode),
            themeMode: mode,
            showAttribution: false,
          ),
        ),
        Padding(
          padding: const .only(top: 10),
          child: Text(name, style: context.textTheme.bodyMedium?.copyWith(fontWeight: shouldHighlight ? .bold : null)),
        ),
      ],
    );
  }
}
