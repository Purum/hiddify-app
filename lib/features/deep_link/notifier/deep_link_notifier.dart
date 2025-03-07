import 'dart:io';

import 'package:k0sha_vpn/utils/utils.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'deep_link_notifier.g.dart';

typedef NewProfileLink = ({String? url, String? name});

RegExp pattern = RegExp(r'^https?://\w*\.k0sha\.org/sub/');

@Riverpod(keepAlive: true)
class DeepLinkNotifier extends _$DeepLinkNotifier
    with ProtocolListener, InfraLogger {
  @override
  Future<NewProfileLink?> build() async {
    if (Platform.isLinux) return null;

    for (final protocol in LinkParser.protocols) {
      await protocolHandler.register(protocol);
    }
    protocolHandler.addListener(this);
    ref.onDispose(() {
      protocolHandler.removeListener(this);
    });

    final initialPayload = await protocolHandler.getInitialUrl();
    if (initialPayload != null) {
      loggy.debug('initial payload: [$initialPayload]');
      final link = LinkParser.deep(initialPayload);
      return link;
    }
    return null;
  }

  @override
  void onProtocolUrlReceived(String url) {
    super.onProtocolUrlReceived(url);
    loggy.debug("url received: [$url]");
    ProfileLink? link;
    if (pattern.hasMatch(url)) {
       link = LinkParser.simple(url);
    } else {
      link = LinkParser.deep(url);
    }
    if (link == null) {
      loggy.debug("link was not valid");
      return;
    }
    update((_) => link);
  }
}
