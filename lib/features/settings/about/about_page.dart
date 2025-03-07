import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:k0sha_vpn/core/app_info/app_info_provider.dart';
import 'package:k0sha_vpn/core/directories/directories_provider.dart';
import 'package:k0sha_vpn/core/localization/translations.dart';
import 'package:k0sha_vpn/core/model/constants.dart';
import 'package:k0sha_vpn/core/model/failures.dart';
import 'package:k0sha_vpn/core/widget/adaptive_icon.dart';
import 'package:k0sha_vpn/features/app_update/notifier/app_update_notifier.dart';
import 'package:k0sha_vpn/features/app_update/notifier/app_update_state.dart';
import 'package:k0sha_vpn/features/app_update/widget/new_version_dialog.dart';
import 'package:k0sha_vpn/features/common/nested_app_bar.dart';
import 'package:k0sha_vpn/gen/assets.gen.dart';
import 'package:k0sha_vpn/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AboutPage extends HookConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final appInfo = ref.watch(appInfoProvider).requireValue;
    final appUpdate = ref.watch(appUpdateNotifierProvider);

    ref.listen(
      appUpdateNotifierProvider,
      (_, next) async {
        if (!context.mounted) return;
        switch (next) {
          case AppUpdateStateAvailable(:final versionInfo) ||
                AppUpdateStateIgnored(:final versionInfo):
            return NewVersionDialog(
              appInfo.presentVersion,
              versionInfo,
              canIgnore: false,
            ).show(context);
          case AppUpdateStateError(:final error):
            return CustomToast.error(t.presentShortError(error)).show(context);
          case AppUpdateStateNotAvailable():
            return CustomToast.success(t.appUpdate.notAvailableMsg)
                .show(context);
        }
      },
    );

    final conditionalTiles = [
      if (appInfo.release.allowCustomUpdateChecker)
        ListTile(
          title: Text(t.about.checkForUpdate),
          trailing: switch (appUpdate) {
            AppUpdateStateChecking() => const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(),
              ),
            _ => const Icon(FluentIcons.arrow_sync_24_regular),
          },
          onTap: () async {
            await ref.read(appUpdateNotifierProvider.notifier).check();
          },
        ),
      if (PlatformUtils.isDesktop)
        ListTile(
          title: Text(t.settings.general.openWorkingDir),
          trailing: const Icon(FluentIcons.open_folder_24_regular),
          onTap: () async {
            final path =
                ref.watch(appDirectoriesProvider).requireValue.workingDir.uri;
            await UriUtils.tryLaunch(path);
          },
        ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          NestedAppBar(
            title: Text(t.about.pageTitle),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Assets.images.icons.vPNLogo60px.image(),
                  const Gap(16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.general.appTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Gap(4),
                      Text(
                        "${t.about.version} ${appInfo.presentVersion}",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                ...conditionalTiles,
                if (conditionalTiles.isNotEmpty) const Divider(),
                ListTile(
                  title: Text(t.about.telegramChannel),
                  trailing: const Icon(FluentIcons.open_24_regular),
                  onTap: () async {
                    await UriUtils.tryLaunch(
                      Uri.parse(Constants.telegramChannelUrl),
                    );
                  },
                ),
                ListTile(
                  title: Text(t.about.privacyPolicy),
                  trailing: const Icon(FluentIcons.open_24_regular),
                  onTap: () async {
                    await UriUtils.tryLaunch(
                      Uri.parse(Constants.privacyPolicyUrl),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
