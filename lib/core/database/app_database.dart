import 'package:drift/drift.dart';
// ignore: depend_on_referenced_packages
import 'package:drift_dev/api/migrations.dart';
import 'package:flutter/foundation.dart';
import 'package:k0sha_vpn/core/database/connection/database_connection.dart';
import 'package:k0sha_vpn/core/database/converters/duration_converter.dart';
import 'package:k0sha_vpn/core/database/schema_versions.dart';
import 'package:k0sha_vpn/core/database/tables/database_tables.dart';
// import 'package:k0sha_vpn/features/geo_asset/data/geo_asset_data_mapper.dart';
// import 'package:k0sha_vpn/features/geo_asset/model/default_geo_assets.dart';
import 'package:k0sha_vpn/features/geo_asset/model/geo_asset_entity.dart';
import 'package:k0sha_vpn/features/profile/model/profile_entity.dart';
import 'package:k0sha_vpn/utils/custom_loggers.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [ProfileEntries, GeoAssetEntries])
class AppDatabase extends _$AppDatabase with InfraLogger {
  AppDatabase({required QueryExecutor connection}) : super(connection);

  AppDatabase.connect() : super(openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _prePopulateGeoAssets();
      },
      onUpgrade: stepByStep(
        // add type column to profile entries table
        // make url column nullable
        from1To2: (m, schema) async {
          await m.alterTable(
            TableMigration(
              schema.profileEntries,
              columnTransformer: {
                schema.profileEntries.type: const Constant<String>("remote"),
              },
              newColumns: [schema.profileEntries.type],
            ),
          );
        },
        from2To3: (m, schema) async {
          await m.createTable(schema.geoAssetEntries);
          await _prePopulateGeoAssets();
        },
        from3To4: (m, schema) async {
          // TODO: check if column exists, if not then add column
          try {
            await m.addColumn(profileEntries, profileEntries.testUrl);
          } on Exception catch (err) {
            loggy.debug(err);
          }
        },
      ),
      beforeOpen: (details) async {
        if (kDebugMode) {
          await validateDatabaseSchema();
        }
      },
    );
  }

  Future<void> _prePopulateGeoAssets() async {
    loggy.debug("populating default geo assets");
    await transaction(() async {
      // final geoAssets = defaultGeoAssets.map((e) => e.toEntry());
      // for (final geoAsset in geoAssets) {
      //   await into(geoAssetEntries)
      //       .insert(geoAsset, mode: InsertMode.insertOrIgnore);
      // }
    });
  }
}
