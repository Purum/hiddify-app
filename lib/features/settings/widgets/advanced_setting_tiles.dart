import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:k0sha_vpn/core/localization/translations.dart';
import 'package:k0sha_vpn/core/preferences/general_preferences.dart';
import 'package:k0sha_vpn/core/router/router.dart';
import 'package:k0sha_vpn/features/per_app_proxy/model/per_app_proxy_mode.dart';
import 'package:k0sha_vpn/features/settings/notifier/platform_settings_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AdvancedSettingTiles extends HookConsumerWidget {
  const AdvancedSettingTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final debug = ref.watch(debugModeNotifierProvider);
    final perAppProxy = ref.watch(Preferences.perAppProxyMode).enabled;
    final disableMemoryLimit = ref.watch(Preferences.disableMemoryLimit);

    return Column(
      children: [
        ListTile(
          title: Text(t.config.pageTitle),
          leading: const Icon(FluentIcons.box_edit_20_regular),
          onTap: () {
            const ConfigOptionsRoute().push(context);
          },
        ),
        ListTile(
          title: Text(t.logs.pageTitle),
          leading: const Icon(FluentIcons.document_text_20_regular),
          onTap: () {
            const LogsOverviewRoute().push(context);
          },
        ),

        if (Platform.isAndroid) ...[
          ListTile(
            title: Text(t.settings.network.perAppProxyPageTitle),
            leading: const Icon(FluentIcons.apps_list_detail_24_regular),
            trailing: Switch(
              value: perAppProxy,
              onChanged: (value) async {
                final newMode = perAppProxy ? PerAppProxyMode.off : PerAppProxyMode.exclude;
                await ref.read(Preferences.perAppProxyMode.notifier).update(newMode);
                if (!perAppProxy && context.mounted) {
                  await const PerAppProxyRoute().push(context);
                }
              },
            ),
            onTap: () async {
              if (!perAppProxy) {
                await ref.read(Preferences.perAppProxyMode.notifier).update(PerAppProxyMode.exclude);
              }
              if (context.mounted) await const PerAppProxyRoute().push(context);
            },
          ),
        ],
        SwitchListTile(
          title: Text(t.settings.advanced.memoryLimit),
          subtitle: Text(t.settings.advanced.memoryLimitMsg),
          value: !disableMemoryLimit,
          secondary: const Icon(FluentIcons.developer_board_24_regular),
          onChanged: (value) async {
            await ref.read(Preferences.disableMemoryLimit.notifier).update(!value);
          },
        ),
        if (Platform.isIOS)
          ListTile(
            title: Text(t.settings.advanced.resetTunnel),
            leading: const Icon(FluentIcons.arrow_reset_24_regular),
            onTap: () async {
              await ref.read(resetTunnelProvider.notifier).run();
            },
          ),
        SwitchListTile(
          title: Text(t.settings.advanced.debugMode),
          value: debug,
          secondary: const Icon(FluentIcons.window_dev_tools_24_regular),
          onChanged: (value) async {
            if (value) {
              await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(t.settings.advanced.debugMode),
                    content: Text(t.settings.advanced.debugModeMsg),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).maybePop(true),
                        child: Text(
                          MaterialLocalizations.of(context).okButtonLabel,
                        ),
                      ),
                    ],
                  );
                },
              );
            }
            await ref.read(debugModeNotifierProvider.notifier).update(value);
          },
        ),
      ],
    );
  }
}
