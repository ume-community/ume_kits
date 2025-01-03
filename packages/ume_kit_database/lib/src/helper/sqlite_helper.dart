import 'dart:io';

import 'package:ume_kit_database/src/data/databases.dart';
import 'package:ume_kit_database/src/data/sql_database.dart';
import 'package:ume_kit_database/src/helper/helpers.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteHelper implements UmeDatabaseHelper {
  SqliteHelper();

  late SqliteDatabase sqliteDatabase;
  final defaultUpdateConditions = 'default_conditions';

  /// delete the db, create the folder and returns its path
  Future<String> initDeleteDb(String dbName, {deleteDB = true}) async {
    final databasePath = await getDatabasesPath();
    // print(databasePath);
    final path = join(databasePath, dbName);

    // make sure the folder exists
    // ignore: avoid_slow_async_io
    if (await Directory(dirname(path)).exists()) {
      if (deleteDB) {
        await deleteDatabase(path);
      } else {
        return path;
      }
    } else {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    }
    return path;
  }

  ///
  ///Key is tableName
  ///SqliteUpdate is update
  final Map<TableName, SqliteUpdateConditions?> updateMap = {
    "default_conditions": SqliteUpdateConditions(
        updateNeedWhere: 'id = ?', updateNeedColumnKey: ['id'])
  };

  void addSqliteUpdateConditions(
      Map<String, SqliteUpdateConditions> conditions) {
    updateMap.addAll(conditions);
  }

  Future<List<TableData>> findAllTableData(UMEDatabase umeDatabase) async {
    List<TableData> list = [];
    if (umeDatabase is SqliteDatabase) {
      var tables = await umeDatabase.db
          ?.rawQuery("select * from Sqlite_master where type = 'table'");
      if (tables == null) {
        return [];
      }

      //{type: table, name: test, tbl_name: test, rootpage: 4, sql: CREATE TABLE test (column_1 INTEGER, column_2 INTEGER)}
      for (var tableMap in tables) {
        dynamic type = tableMap['type'];
        dynamic name = tableMap['name'];
        dynamic tableName = tableMap['tbl_name'];
        dynamic rootPage = tableMap['rootpage'];
        dynamic sql = tableMap['sql'];
        assert(tableName != null, "tableName is not can null");
        // print(tableMap);
        var columnData = await sqliteDatabase.db
            ?.rawQuery("PRAGMA table_info([$tableName])");
        assert(columnData != null, "");
        List<SqliteTableColumData> _columnData = [];
        for (var columnMap in columnData!) {
          var stc = _sqliteTableColumnInfo(columnMap);
          _columnData.add(stc);
        }
        var td = SqliteTableData(tableName,
            type: type,
            name: name,
            rootPage: rootPage,
            createSql: sql,
            columnData: _columnData);
        list.add(td);
      }
    }
    return list;
  }

  SqliteTableColumData _sqliteTableColumnInfo(Map<String, Object?> columnMap) {
    var cid = columnMap['cid'];
    var name = columnMap['name'];
    var type = columnMap['type'];
    var notNull = columnMap['notnull'];
    var defaultValue = columnMap['dflt_value'];
    var pk = columnMap['pk'];
    if (cid != null) {}

    return SqliteTableColumData(
        cid: int.tryParse(cid.toString()) ?? 0,
        defaultValue: defaultValue,
        name: name == null ? '' : name.toString(),
        notNull: int.tryParse(notNull.toString()) ?? 0,
        pk: int.tryParse(pk.toString()) ?? 0,
        type: type.toString());
  }

  Future<List<Map<String, Object?>>> findSingleTableAllData(
      String tableName) async {
    var datas = await sqliteDatabase.db!.query(tableName);
    return datas;
  }

  Future<void> updateData(String tableName,
      {required List<Map<String, Object?>> updateMaps,
      String? where,
      List<String>? whereArgs}) async {
    for (var map in updateMaps) {
      await sqliteDatabase.db
          ?.update(tableName, map, where: where, whereArgs: whereArgs);
      // print(d);
    }
  }
}
