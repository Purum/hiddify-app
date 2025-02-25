import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:k0sha_vpn/core/localization/translations.dart';
import 'package:k0sha_vpn/core/model/failures.dart';
import 'package:k0sha_vpn/core/theme/theme_extensions.dart';
import 'package:k0sha_vpn/core/widget/animated_text.dart';
import 'package:k0sha_vpn/features/config_option/data/config_option_repository.dart';
import 'package:k0sha_vpn/features/config_option/notifier/config_option_notifier.dart';
import 'package:k0sha_vpn/features/connection/model/connection_status.dart';
import 'package:k0sha_vpn/features/connection/notifier/connection_notifier.dart';
import 'package:k0sha_vpn/features/connection/widget/experimental_feature_notice.dart';
import 'package:k0sha_vpn/features/profile/notifier/active_profile_notifier.dart';
import 'package:k0sha_vpn/features/proxy/active/active_proxy_notifier.dart';
import 'package:k0sha_vpn/utils/alerts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// TODO: rewrite
class ConnectionButton extends HookConsumerWidget {
  const ConnectionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final connectionStatus = ref.watch(connectionNotifierProvider);
    final activeProxy = ref.watch(activeProxyNotifierProvider);
    final delay = activeProxy.valueOrNull?.urlTestDelay ?? 0;

    final requiresReconnect = ref.watch(configOptionNotifierProvider).valueOrNull;
    final today = DateTime.now();

    ref.listen(
      connectionNotifierProvider,
      (_, next) {
        if (next case AsyncError(:final error)) {
          CustomAlertDialog.fromErr(t.presentError(error)).show(context);
        }
        if (next case AsyncData(value: Disconnected(:final connectionFailure?))) {
          CustomAlertDialog.fromErr(t.presentError(connectionFailure)).show(context);
        }
      },
    );

    final buttonTheme = Theme.of(context).extension<ConnectionButtonTheme>()!;

    Future<bool> showExperimentalNotice() async {
      final hasExperimental = ref.read(ConfigOptions.hasExperimentalFeatures);
      final canShowNotice = !ref.read(disableExperimentalFeatureNoticeProvider);
      if (hasExperimental && canShowNotice && context.mounted) {
        return await const ExperimentalFeatureNoticeDialog().show(context) ?? false;
      }
      return true;
    }

    const startIcon = Icon(
      Icons.play_arrow_rounded,
      size: 80,
      color: Colors.green,
    );
    const stopIcon = Icon(
      Icons.stop_rounded,
      size: 80,
      color: Colors.red,
    );

    return _ConnectionButton(
      onTap: switch (connectionStatus) {
        AsyncData(value: Disconnected()) || AsyncError() => () async {
            if (await showExperimentalNotice()) {
              return await ref.read(connectionNotifierProvider.notifier).toggleConnection();
            }
          },
        AsyncData(value: Connected()) => () async {
            if (requiresReconnect == true && await showExperimentalNotice()) {
              return await ref.read(connectionNotifierProvider.notifier).reconnect(await ref.read(activeProfileProvider.future));
            }
            return await ref.read(connectionNotifierProvider.notifier).toggleConnection();
          },
        _ => () {},
      },
      enabled: switch (connectionStatus) {
        AsyncData(value: Connected()) || AsyncData(value: Disconnected()) || AsyncError() => true,
        _ => false,
      },
      label: switch (connectionStatus) {
        AsyncData(value: Connected()) when requiresReconnect == true => t.connection.reconnect,
        AsyncData(value: Connected()) when delay <= 0 || delay >= 65000 => t.connection.connecting,
        AsyncData(value: final status) => status.present(t),
        _ => "",
      },
      buttonColor: switch (connectionStatus) {
        AsyncData(value: Connected()) when requiresReconnect == true => Colors.teal,
        AsyncData(value: Connected()) when delay <= 0 || delay >= 65000 => Color.fromARGB(255, 185, 176, 103),
        AsyncData(value: Connected()) => buttonTheme.connectedColor!,
        AsyncData(value: _) => buttonTheme.idleColor!,
        _ => Colors.red,
      },
      image: switch (connectionStatus) {
        AsyncData(value: Connected()) when requiresReconnect == true => startIcon,
        AsyncData(value: Connected()) => stopIcon,
        AsyncData(value: _) => startIcon,
        _ => const CircularProgressIndicator(),
      },
      useImage: today.day >= 19 && today.day <= 23 && today.month == 3,
    );
  }
}

class _ConnectionButton extends StatelessWidget {
  const _ConnectionButton({
    required this.onTap,
    required this.enabled,
    required this.label,
    required this.buttonColor,
    required this.image,
    required this.useImage,
  });

  final VoidCallback onTap;
  final bool enabled;
  final String label;
  final Color buttonColor;
  final Widget image;
  final bool useImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Semantics(
          button: true,
          enabled: enabled,
          label: label,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  blurRadius: 16,
                  color: buttonColor.withOpacity(0.5),
                ),
              ],
            ),
            width: 148,
            height: 148,
            child: Material(
              key: const ValueKey("home_connection_button"),
              shape: const CircleBorder(),
              color: Colors.white,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: TweenAnimationBuilder(
                    tween: ColorTween(end: buttonColor),
                    duration: const Duration(milliseconds: 250),
                    builder: (context, value, child) {
                      return image;
                    },
                  ),
                ),
              ),
            ).animate(target: enabled ? 0 : 1).blurXY(end: 1),
          ).animate(target: enabled ? 0 : 1).scaleXY(end: .88, curve: Curves.easeIn),
        ),
        const Gap(16),
        ExcludeSemantics(
          child: AnimatedText(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
