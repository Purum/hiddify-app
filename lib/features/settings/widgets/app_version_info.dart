import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/app_info/app_info_provider.dart';
import '../../../core/localization/translations.dart';
import '../../../core/preferences/general_preferences.dart';

const tapsNeeded = 20;

class AppVersionInfo extends HookConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final version = ref.watch(appInfoProvider).requireValue.presentVersion;

    final counter = useState(0);

    Future<void> makeDeveloper() async {
      await ref.read(Preferences.proMode.notifier).update(true);
    }

    void onTap() {
      counter.value ++;
      if (counter.value >= tapsNeeded) {
        makeDeveloper();
      }
    }

    return Semantics(
      label: t.about.version,
      button: false,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 20,
          ),
          child: Text(
            version,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      )
    );
  }

}
