import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'uptime_notifier.g.dart';

@riverpod
class UptimeNotifier extends _$UptimeNotifier {
  @override
  UptimeNotifierState build() => const UptimeNotifierState.stopped();

  void start() {
    state = UptimeNotifierState.started();
  }
  void stop() {
    state = const UptimeNotifierState.stopped();
  }
}

sealed class UptimeNotifierState {
  const UptimeNotifierState._();

  factory UptimeNotifierState.started() = UptimeNotifierStateStarted._;

  const factory UptimeNotifierState.stopped() = UptimeNotifierStateStopped._;

  String getTime() => "";
}

class UptimeNotifierStateStopped extends UptimeNotifierState {
  const UptimeNotifierStateStopped._() : super._();
}

class UptimeNotifierStateStarted extends UptimeNotifierState {
  UptimeNotifierStateStarted._() : super._();

  final DateTime startedAt = DateTime.now();

  @override
  String getTime() {
    final difference = DateTime.now().difference(startedAt!);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;
    return "${stringify(hours)}:${stringify(minutes)}:${stringify(seconds)}";
  }

  String stringify(int val) {
    return val.toString().padLeft(2, '0');
  }
}
