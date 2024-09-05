import 'movie_dao.dart';
import 'movie.dart';

class MovieRepository {
  final MovieDAO movieDao;

  MovieRepository({required this.movieDao});

  Future<void> addMovie(Movie movie) async {
    await movieDao.insertMovie(movie);
  }

  Future<Movie?> getMovieByTitle(String title) async {
    return await movieDao.getMovieByTitle(title);
  }

  Future<List<Movie>> getMoviesByListType(String listType) async {
    return await movieDao.getMoviesByListType(listType);
  }

  Future<int?> countMoviesInList(String listType) async {
    return await movieDao.countMoviesInList(listType);
  }

  Future<void> deleteMovie(String title, String listType) async {
    await movieDao.deleteMovieByTitleAndListType(title, listType);
  }
}
