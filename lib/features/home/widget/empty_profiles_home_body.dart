import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:k0sha_vpn/core/localization/translations.dart';
import 'package:k0sha_vpn/core/model/failures.dart';
import 'package:k0sha_vpn/core/router/router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../utils/alerts.dart';
import '../../../utils/custom_text_form_field.dart';
import '../../../utils/validators.dart';
import '../../profile/details/profile_details_notifier.dart';

class EmptyProfilesHomeBody extends HookConsumerWidget {
  const EmptyProfilesHomeBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final provider = profileDetailsNotifierProvider('new');
    final notifier = ref.watch(provider.notifier);

    ref.listen(
      provider.selectAsync((data) => data.save),
          (_, next) async {
        switch (await next) {
          case AsyncData():
            CustomToast.success(t.profile.save.successMsg).show(context);
            WidgetsBinding.instance.addPostFrameCallback(
                  (_) {
                if (context.mounted) context.pop();
              },
            );
          case AsyncError(:final error):
            final String action;
            if (ref.read(provider) case AsyncData(value: final data) when data.isEditing) {
              action = t.profile.save.failureMsg;
            } else {
              action = t.profile.add.failureMsg;
            }
            CustomAlertDialog.fromErr(t.presentError(error, action: action)).show(context);
        }
      },
    );

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Перейдите по ссылке в Telegram',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
              ),
            ),
          ),
          const Gap(15),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'или вставьте ссылку ниже',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          const Gap(10),

          Form(
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: CustomTextFormField(
                    onChanged: (value) => notifier.setField(url: value),
                    validator: (value) => (value != null && !isUrl(value)) ? t.profile.detailsForm.invalidUrlMsg : null,
                    label: t.profile.detailsForm.urlLabel,
                    hint: t.profile.detailsForm.urlHint,
                  ),
                ),
                ElevatedButton(
                  onPressed: notifier.save,
                  child: Text(t.profile.save.buttonText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyActiveProfileHomeBody extends HookConsumerWidget {
  const EmptyActiveProfileHomeBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(t.home.noActiveProfileMsg),
          const Gap(16),
          OutlinedButton(
            onPressed: () => const ProfilesOverviewRoute().push(context),
            child: Text(t.profile.overviewPageTitle),
          ),
        ],
      ),
    );
  }
}
