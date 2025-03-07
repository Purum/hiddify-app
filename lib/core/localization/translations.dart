import 'package:k0sha_vpn/core/localization/locale_preferences.dart';
import 'package:k0sha_vpn/gen/translations.g.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:k0sha_vpn/gen/translations.g.dart';

part 'translations.g.dart';

@Riverpod(keepAlive: true)
TranslationsEn translations(TranslationsRef ref) =>
    ref.watch(localePreferencesProvider).build();
