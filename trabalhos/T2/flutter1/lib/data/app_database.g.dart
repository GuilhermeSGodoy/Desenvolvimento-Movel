// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  MovieDAO? _movieDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `movies` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT NOT NULL, `listType` TEXT NOT NULL, `posterUrl` TEXT, `year` TEXT, `rating` TEXT)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  MovieDAO get movieDao {
    return _movieDaoInstance ??= _$MovieDAO(database, changeListener);
  }
}

class _$MovieDAO extends MovieDAO {
  _$MovieDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _movieInsertionAdapter = InsertionAdapter(
            database,
            'movies',
            (Movie item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'listType': item.listType,
                  'posterUrl': item.posterUrl,
                  'year': item.year,
                  'rating': item.rating
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Movie> _movieInsertionAdapter;

  @override
  Future<Movie?> getMovieByTitle(String title) async {
    return _queryAdapter.query('SELECT * FROM movies WHERE title = ?1',
        mapper: (Map<String, Object?> row) => Movie(
            id: row['id'] as int?,
            title: row['title'] as String,
            listType: row['listType'] as String,
            posterUrl: row['posterUrl'] as String?,
            year: row['year'] as String?,
            rating: row['rating'] as String?),
        arguments: [title]);
  }

  @override
  Future<List<Movie>> getMoviesByListType(String listType) async {
    return _queryAdapter.queryList('SELECT * FROM movies WHERE listType = ?1',
        mapper: (Map<String, Object?> row) => Movie(
            id: row['id'] as int?,
            title: row['title'] as String,
            listType: row['listType'] as String,
            posterUrl: row['posterUrl'] as String?,
            year: row['year'] as String?,
            rating: row['rating'] as String?),
        arguments: [listType]);
  }

  @override
  Future<int?> countMoviesInList(String listType) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM movies WHERE listType = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [listType]);
  }

  @override
  Future<Movie?> getMovieByTitleAndListType(
    String title,
    String listType,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM movies WHERE title = ?1 AND listType = ?2',
        mapper: (Map<String, Object?> row) => Movie(
            id: row['id'] as int?,
            title: row['title'] as String,
            listType: row['listType'] as String,
            posterUrl: row['posterUrl'] as String?,
            year: row['year'] as String?,
            rating: row['rating'] as String?),
        arguments: [title, listType]);
  }

  @override
  Future<void> deleteMovieByTitleAndListType(
    String title,
    String listType,
  ) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM movies WHERE title = ?1 AND listType = ?2',
        arguments: [title, listType]);
  }

  @override
  Future<void> insertMovie(Movie movie) async {
    await _movieInsertionAdapter.insert(movie, OnConflictStrategy.ignore);
  }
}
