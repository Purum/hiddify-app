import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../profile/notifier/active_profile_notifier.dart';
import '../../profile/overview/profiles_overview_notifier.dart';

class RemoveConnectionButton extends HookConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.read(activeProfileProvider);

    Future<void> onPressed() async {
      if (activeProfile.hasValue) {
        final profile = activeProfile.value;
        ref.read(profilesOverviewNotifierProvider.notifier).deleteProfile(profile!);
        Navigator.of(context).maybePop();
      }
    }
    if (activeProfile.value != null) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: onPressed,
          child: const Text("Очистить данные подключения"),
        ),
      );
    }

    return Container();

  }

}