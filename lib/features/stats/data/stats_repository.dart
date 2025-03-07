import 'package:fpdart/fpdart.dart';
import 'package:k0sha_vpn/core/utils/exception_handler.dart';
import 'package:k0sha_vpn/features/stats/model/stats_entity.dart';
import 'package:k0sha_vpn/features/stats/model/stats_failure.dart';
import 'package:k0sha_vpn/singbox/service/singbox_service.dart';
import 'package:k0sha_vpn/utils/custom_loggers.dart';

abstract interface class StatsRepository {
  Stream<Either<StatsFailure, StatsEntity>> watchStats();
}

class StatsRepositoryImpl
    with ExceptionHandler, InfraLogger
    implements StatsRepository {
  StatsRepositoryImpl({required this.singbox});

  final SingboxService singbox;

  @override
  Stream<Either<StatsFailure, StatsEntity>> watchStats() {
    return singbox
        .watchStats()
        .map(
          (event) => StatsEntity(
            uplink: event.uplink,
            downlink: event.downlink,
            uplinkTotal: event.uplinkTotal,
            downlinkTotal: event.downlinkTotal,
          ),
        )
        .handleExceptions(StatsUnexpectedFailure.new);
  }
}
