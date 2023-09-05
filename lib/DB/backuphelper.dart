import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:funds_minder/DB/dbhelper.dart';

class BackUpHelper {
  static Future<String> backUpToServer() async {
    final FirebaseDatabase database = FirebaseDatabase.instance;
    try {
      // Perform anonymous sign-in
      var user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DatabaseReference userDataRef =
            database.ref().child('users').child(user.uid);
        database.ref().child('user').child(user.uid).remove();

        final localData = await _fetchDataFromDatabase();
        String jsonData = jsonEncode(localData);
        userDataRef.set(jsonData);
        return "Backup Successful";
      } else {
        return "Check connection.Try Again!";
      }
    } catch (e) {
      return "Something is wrong. pls try again!";
    }
  }

  static Future<String> restoreFromServer() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    List<Map<String, dynamic>> mapList = [];
    final FirebaseDatabase database = FirebaseDatabase.instance;

    try {
      User? user = auth.currentUser;
      if (user != null) {
        final dataSnapShot =
            await database.ref().child('users').child(user.uid).once();

        if (dataSnapShot.snapshot.value == null) {
          return "No backup found. Perform a backup.";
        }
        final List<dynamic> dataMap =
            jsonDecode(dataSnapShot.snapshot.value as String);

        if (dataMap.isNotEmpty) {
          for (var data in dataMap) {
            if (data is Map<String, dynamic>) {
              mapList.add(data);
            }
          }
          await _updateLocalDatabase(mapList);
          return "Restore Successfull";
        }
        return "Restore Successfull";
      }
      return "Check connection.Try Again!";
    } catch (e) {
      return "Something is wrong. pls try again!";
    }
  }

  static Future<List<Map<String, dynamic>>> _fetchDataFromDatabase() async {
    try {
      List<Map<String, dynamic>> tData =
          await DBhelper.getData(DBhelper.tableName);
      List<Map<String, dynamic>> rData =
          await DBhelper.getData(DBhelper.reportTableName);
      List<Map<String, dynamic>> bData =
          await DBhelper.getData(DBhelper.budgetTableName);
      List<Map<String, dynamic>> gData =
          await DBhelper.getData(DBhelper.goalTableName);
      List<Map<String, dynamic>> sData =
          await DBhelper.getData(DBhelper.sliderValues);

      List<Map<String, dynamic>> combinedData = [];
      combinedData.addAll(tData);
      combinedData.addAll(rData);
      combinedData.addAll(bData);
      combinedData.addAll(gData);
      combinedData.addAll(sData);

      return combinedData;
    } catch (e) {
      return [];
    }
  }

  static Future<bool> _updateLocalDatabase(
      List<Map<String, dynamic>> restoreData) async {
    try {
      await DBhelper.delete();

      for (final record in restoreData) {
        if (record.containsKey('currency')) {
          await DBhelper.insert(DBhelper.tableName, record);
        } else if (record.containsKey('earn')) {
          await DBhelper.insert(DBhelper.reportTableName, record);
        } else if (record.containsKey('firstdate')) {
          await DBhelper.insert(DBhelper.budgetTableName, record);
        } else if (record.containsKey('savings')) {
          await DBhelper.insert(DBhelper.goalTableName, record);
        } else {
          await DBhelper.insert(DBhelper.sliderValues, record);
        }
      }
      return true;
    } catch (err) {
      return false;
    }
  }
}
