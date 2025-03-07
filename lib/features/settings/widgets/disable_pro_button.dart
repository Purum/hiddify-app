import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/preferences/general_preferences.dart';

class DisableProButton extends HookConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    Future<void> onPressed() async {
      await ref.read(Preferences.proMode.notifier).update(false);
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: const Text('Выключить Про режим'),
      ),
    );
  }

}