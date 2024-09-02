import 'package:floor/floor.dart';
import '../model/Person.dart';
import 'PersonDAO.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:async';

part 'AppDatabase.g.dart';

@Database(version: 1, entities: [Person])
abstract class AppDatabase extends FloorDatabase {
  PersonDAO get personDao;
}
