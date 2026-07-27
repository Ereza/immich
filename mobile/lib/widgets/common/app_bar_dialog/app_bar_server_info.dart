import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' hide Store;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:immich_mobile/extensions/build_context_extensions.dart';
import 'package:immich_mobile/extensions/theme_extensions.dart';
import 'package:immich_mobile/models/server_info/server_info.model.dart';
import 'package:immich_mobile/providers/locale_provider.dart';
import 'package:immich_mobile/providers/server_info.provider.dart';
import 'package:immich_mobile/providers/user.provider.dart';
import 'package:immich_mobile/utils/url_helper.dart';
import 'package:immich_mobile/widgets/common/app_bar_dialog/server_update_notification.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppBarServerInfo extends HookConsumerWidget {
  const AppBarServerInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    ServerInfo serverInfoState = ref.watch(serverInfoProvider);
    final user = ref.watch(currentUserProvider);
    final bool showVersionWarning = ref.watch(versionWarningPresentProvider(user));

    final appInfo = useState({});

    getPackageInfo() async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      appInfo.value = {"version": packageInfo.version, "buildNumber": packageInfo.buildNumber};
    }

    useEffect(() {
      getPackageInfo();
      return null;
    }, []);

    const divider = Divider(thickness: 1);

    return Padding(
      padding: const .symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        crossAxisAlignment: .center,
        children: [
          if (showVersionWarning) ...[const ServerUpdateNotification(), divider],
          _ServerInfoItem(
            label: "server_info_box_app_version".tr(),
            text: "${appInfo.value["version"]} build.${appInfo.value["buildNumber"]}",
          ),
          divider,
          _ServerInfoItem(
            label: "server_version".tr(),
            text: serverInfoState.serverVersion.major > 0 ? "${serverInfoState.serverVersion}" : "--",
          ),
          divider,
          _ServerInfoItem(label: "server_info_box_server_url".tr(), text: getServerUrl() ?? '--', tooltip: true),
          if (serverInfoState.latestVersion != null) ...[
            divider,
            _ServerInfoItem(
              label: "latest_version".tr(),
              text: serverInfoState.latestVersion!.major > 0 ? "${serverInfoState.latestVersion!}" : "--",
              tooltip: true,
              icon: serverInfoState.versionStatus == .serverOutOfDate
                  ? const Icon(Icons.info, color: Color.fromARGB(255, 243, 188, 106), size: 12)
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _ServerInfoItem extends StatelessWidget {
  final String label;
  final String text;
  final bool tooltip;
  final Icon? icon;

  static const titleFontSize = 12.0;
  static const contentFontSize = 11.0;

  const _ServerInfoItem({required this.label, required this.text, this.tooltip = false, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        if (icon != null) ...[icon as Widget, const SizedBox(width: 8)],
        Text(
          label,
          style: TextStyle(fontSize: titleFontSize, color: context.textTheme.labelSmall?.color, fontWeight: .w500),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _maybeTooltip(
            context,
            Text(
              text,
              style: TextStyle(
                fontSize: contentFontSize,
                color: context.colorScheme.onSurfaceSecondary,
                fontWeight: .w500,
                overflow: .ellipsis,
              ),
              textAlign: .end,
            ),
          ),
        ),
      ],
    );
  }

  Widget _maybeTooltip(BuildContext context, Widget child) => tooltip
      ? Tooltip(
          verticalOffset: 0,
          decoration: BoxDecoration(
            color: context.primaryColor.withValues(alpha: 0.9),
            borderRadius: const .all(.circular(10)),
          ),
          textStyle: TextStyle(color: context.colorScheme.onPrimary, fontWeight: .bold),
          message: text,
          preferBelow: false,
          triggerMode: .tap,
          child: child,
        )
      : child;
}
