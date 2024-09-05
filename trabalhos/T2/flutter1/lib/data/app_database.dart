import 'package:floor/floor.dart';
import 'movie.dart';
import 'movie_dao.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'app_database.g.dart';

@Database(version: 1, entities: [Movie])
abstract class AppDatabase extends FloorDatabase {
  MovieDAO get movieDao;
}
