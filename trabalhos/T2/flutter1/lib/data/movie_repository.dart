import 'package:flutter1/data/app_database.dart';
import 'package:flutter1/data/movie.dart';

class MovieRepository {
  Future<String> saveMovieToDatabase(Movie movie) async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    final movieDao = database.movieDao;

    final existingMovie = await movieDao.getMovieByTitle(movie.title);

    if (existingMovie != null && existingMovie.listType == movie.listType) {
      return 'duplicate';
    } else if (existingMovie != null && existingMovie.listType != movie.listType) {
      movie.id = existingMovie.id;
      await movieDao.updateMovieListType(movie.title, movie.listType);
      return 'updated';
    } else {
      await movieDao.insertMovie(movie);
      return 'added';
    }
  }

  Future<List<Movie>> getMoviesByListType(String listType) async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    final movieDao = database.movieDao;
    return movieDao.getMoviesByListType(listType);
  }

  Future<Movie?> getMovieByTitle(String title) async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    final movieDao = database.movieDao;
    return movieDao.getMovieByTitle(title);
  }

  Future<void> deleteMovie(String listType, String title) async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    final movieDao = database.movieDao;
    await movieDao.deleteMovieByTitleAndListType(title, listType);
  }

  Future<void> insertMovie(Movie movie) async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    final movieDao = database.movieDao;
    await movieDao.insertMovie(movie);
  }

  Future<void> updateMovieListType(Movie movie) async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    final movieDao = database.movieDao;
    await movieDao.updateMovieListType(movie.title, movie.listType);
  }
}
