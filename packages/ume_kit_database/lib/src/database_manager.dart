import 'package:ume_kit_database/src/data/shared_preferences_database.dart';
import 'package:ume_kit_database/src/helper/hive_helper.dart';
import 'package:ume_kit_database/src/helper/shared_preferences_helper.dart';
import 'package:ume_kit_database/src/helper/sqlite_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'data/databases.dart';
import 'data/hive_database.dart';
import 'data/sql_database.dart';

class DatabaseManager {
  DatabaseManager._();
  static DatabaseManager get _instance => DatabaseManager._();
  factory DatabaseManager() => _instance;
  late List<UMEDatabase> databases = [];

  late SqliteHelper sqliteHelper;
  late HiveHelper hiveHelper;
  late SharedPreferencesHelper sharedPreferencesHelper;

  ///使用hive数据库 路径可以为空
  ///
  Future<void> openDatabases({required List<UMEDatabase> databases}) async {
    for (var data in databases) {
      if (data is SqliteDatabase) {
        SqliteDatabase sqliteDatabase = data;
        sqliteHelper = SqliteHelper();
        var path = await sqliteHelper.initDeleteDb(data.databaseName,
            deleteDB: data.isDeleteDB);
        var db = await openDatabase(path,
            version: 1,
            onCreate: data.onCreate,
            onConfigure: data.onConfigure,
            onDowngrade: data.onDowngrade,
            onOpen: data.onOpen,
            onUpgrade: data.onUpgrade,
            readOnly: false);
        sqliteDatabase.db = db;
        sqliteHelper.sqliteDatabase = sqliteDatabase;
        this.databases.add(sqliteDatabase);
        if (sqliteDatabase.updateMap.isNotEmpty) {
          for (var sum in sqliteDatabase.updateMap) {
            sqliteHelper.addSqliteUpdateConditions(sum);
          }
        }
      } else if (data is HiveDatabase) {
        hiveHelper = HiveHelper();
        HiveDatabase hiveDatabase = data;
        this.databases.add(hiveDatabase);
      } else if (data is SharedPreferencesDatabase) {
        sharedPreferencesHelper =
            SharedPreferencesHelper(data.sharedPreferences);
        SharedPreferencesDatabase sharedPreferencesDatabase = data;
        if (sharedPreferencesDatabase.deleteDB()) {
          await sharedPreferencesDatabase.sharedPreferences.clear();
        }
        this.databases.add(sharedPreferencesDatabase);
      }
    }
  }
}

enum DatabaseType { sqlite, hive, sharedPreferences, objectDB, customDB }

class DatabasesItem {
  DatabasesItem(this.databasesType, {required this.name, required this.path});
  final String name;
  final String? path;
  final DatabaseType databasesType;
}
