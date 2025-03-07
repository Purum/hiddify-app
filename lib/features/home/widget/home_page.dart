import 'package:dartx/dartx.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:k0sha_vpn/core/app_info/app_info_provider.dart';
import 'package:k0sha_vpn/core/localization/translations.dart';
import 'package:k0sha_vpn/core/model/failures.dart';
import 'package:k0sha_vpn/core/router/router.dart';
import 'package:k0sha_vpn/features/common/nested_app_bar.dart';
import 'package:k0sha_vpn/features/home/widget/connection_button.dart';
import 'package:k0sha_vpn/features/home/widget/empty_profiles_home_body.dart';
import 'package:k0sha_vpn/features/profile/notifier/active_profile_notifier.dart';
import 'package:k0sha_vpn/features/profile/widget/profile_tile.dart';
import 'package:k0sha_vpn/features/proxy/active/active_proxy_delay_indicator.dart';
import 'package:k0sha_vpn/features/proxy/active/active_proxy_footer.dart';
import 'package:k0sha_vpn/features/proxy/active/active_proxy_notifier.dart';
import 'package:k0sha_vpn/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../core/model/constants.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final hasAnyProfile = ref.watch(hasAnyProfileProvider);
    final activeProfile = ref.watch(activeProfileProvider);

    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomScrollView(
            slivers: [
              NestedAppBar(
                title: const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: Constants.appName),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () => const SettingsRoute().push(context),
                    icon: const Icon(FluentIcons.settings_24_regular),
                    tooltip: t.profile.add.buttonText,
                  ),
                ],
              ),
              switch (activeProfile) {
                AsyncData(value: final profile?) => MultiSliver(
                    children: [
                      // ProfileTile(profile: profile, isMain: true),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Stack(
                          children: [
                            Container(
                              constraints: const BoxConstraints.expand(),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ConnectionButton(),
                                  ActiveProxyDelayIndicator(),
                                ],
                              ),
                            ),
                            if (MediaQuery.sizeOf(context).width < 840) const ActiveProxyFooter(),
                          ],
                        ),
                      ),
                    ],
                  ),
                AsyncData() => switch (hasAnyProfile) {
                    AsyncData(value: true) => const EmptyActiveProfileHomeBody(),
                    _ => const EmptyProfilesHomeBody(),
                  },
                AsyncError(:final error) => SliverErrorBodyPlaceholder(t.presentShortError(error)),
                _ => const SliverToBoxAdapter(),
              },
            ],
          ),
        ],
      ),
    );
  }
}
