import 'package:flutter1/data/app_database.dart';
import 'package:flutter1/data/movie.dart';

class MovieRepository {
  Future<void> saveMovieToDatabase(Movie movie) async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    final movieDao = database.movieDao;
    movieDao.insertMovie(movie);
  }
}
