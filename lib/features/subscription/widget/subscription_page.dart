import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:k0sha_vpn/core/router/router.dart';
import 'package:k0sha_vpn/features/profile/notifier/active_profile_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../profile/details/profile_details_notifier.dart';
import '../../profile/overview/profiles_overview_notifier.dart';

class SubscriptionPage extends HookConsumerWidget {
  const SubscriptionPage({
    super.key,
    required this.url,
  });

  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAnyProfile = ref.watch(hasAnyProfileProvider);
    final activeProfile = ref.watch(activeProfileProvider);

    final provider = profileDetailsNotifierProvider('new');
    final notifier = ref.watch(provider.notifier);

    void removeProfile() {
      final profile = activeProfile.value;
      ref.read(profilesOverviewNotifierProvider.notifier).deleteProfile(profile!);
    }
    void createProfile() {
      notifier.setField(url: url);
      notifier.save();
      const HomeRoute().replace(context);
    }

    useEffect(() {
      switch (hasAnyProfile) {
        case AsyncData(value: true):
          removeProfile();
      }
      WidgetsBinding.instance
          .addPostFrameCallback((_) => createProfile());
    }, []);

    return Scaffold(
      body:Container(),
    );
  }
}
