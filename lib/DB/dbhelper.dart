import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

class DBhelper {
  static const String tableName = "funds_table";
  static const String reportTableName = 'fund_report_table';
  static const String _dbName = 'fundMinder.db';
  static const String budgetTableName = 'budget_table';
  static const String goalTableName = 'goal_table';
  static const String sliderValues = 'slide_val_table';

  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, _dbName), version: 1,
        onCreate: (db, version) {
      db.execute(
          'CREATE TABLE $tableName(id TEXT PRIMARY KEY,title TEXT,amount REAL, date TEXT, category TEXT, currency TEXT, expense TEXT)');
      db.execute(
          'CREATE TABLE $reportTableName(id INTEGER PRIMARY KEY,date TEXT, profit TEXT, expense TEXT, earn TEXT)');
      db.execute(
          'CREATE TABLE $budgetTableName(id TEXT PRIMARY KEY,amount REAL, firstdate TEXT, lastdate TEXT, category TEXT)');
      db.execute(
          'CREATE TABLE $goalTableName(id TEXT PRIMARY KEY,title TEXT,date TEXT,amount REAL,savings REAL)');

      db.execute('CREATE TABLE $sliderValues(svalues TEXT)');
    });
  }

  static Future<void> insert(String tbleName, Map<String, dynamic> data) async {
    final db = await DBhelper.database();
    try {
      db.insert(
        tbleName,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (err) {
      rethrow;
    }
  }

  static Future<void> updateTable(String tbleName, Map<String, dynamic> data,
      String? field, dynamic fieldVal) async {
    final db = await DBhelper.database();

    (field == null || fieldVal == null)
        ? await db.update(tbleName, data)
        : await db
            .update(tbleName, data, where: '$field = ?', whereArgs: [fieldVal]);
  }

  static Future<dynamic> addNewColumn(String columneName) async {
    var db = await DBhelper.database();
    var count = await db
        .execute("ALTER TABLE $tableName ADD COLUMN $columneName TEXT;");

    return count;
  }

  static Future<List<Map<String, Object?>>> getData(String tableName) async {
    final db = await DBhelper.database();
    return db.query(tableName);
  }

  static Future<void> deleteData(
      String tableName, String? field, String? arg) async {
    final db = await DBhelper.database();
    try {
      await db.delete(tableName, where: '$field = ?', whereArgs: [arg]);
    } catch (err) {
      rethrow;
    }
  }

  static Future<void> delete() async {
    final dbPath = await sql.getDatabasesPath();
    sql.deleteDatabase('$dbPath/fundMinder.db');
  }
}
