import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:k0sha_vpn/core/localization/translations.dart';
import 'package:k0sha_vpn/features/common/nested_app_bar.dart';
import 'package:k0sha_vpn/features/settings/widgets/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/preferences/general_preferences.dart';
import '../widgets/app_version_info.dart';
import '../widgets/disable_pro_button.dart';
import '../widgets/remove_connection_button.dart';

class SettingsOverviewPage extends HookConsumerWidget {
  const SettingsOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final isPro = ref.watch(Preferences.proMode);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          NestedAppBar(
            title: Text(t.settings.pageTitle),
          ),
          SliverList.list(
            children: [
              SettingsSection(t.settings.general.sectionTitle),
              const GeneralSettingTiles(),
              RemoveConnectionButton(),
              if (isPro) ...[
                const PlatformSettingsTiles(),
                const SettingsDivider(),
                SettingsSection(t.settings.advanced.sectionTitle),
                const AdvancedSettingTiles(),
                DisableProButton(),
              ],
              AppVersionInfo(),
            ],
          ),
        ],
      ),
    );
  }
}
