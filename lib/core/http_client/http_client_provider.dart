import 'package:flutter/foundation.dart';
import 'package:k0sha_vpn/core/app_info/app_info_provider.dart';
import 'package:k0sha_vpn/core/http_client/dio_http_client.dart';
import 'package:k0sha_vpn/features/config_option/data/config_option_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'http_client_provider.g.dart';

@Riverpod(keepAlive: true)
DioHttpClient httpClient(HttpClientRef ref) {
  final client = DioHttpClient(
    timeout: const Duration(seconds: 15),
    userAgent: ref.watch(appInfoProvider).requireValue.userAgent,
    debug: kDebugMode,
  );

  ref.listen(
    ConfigOptions.mixedPort,
    (_, next) async {
      client.setProxyPort(next);
    },
    fireImmediately: true,
  );
  return client;
}
