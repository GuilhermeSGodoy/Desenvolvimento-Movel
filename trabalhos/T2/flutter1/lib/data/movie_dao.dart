import 'package:floor/floor.dart';
import 'movie.dart';

@dao
abstract class MovieDAO {
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertMovie(Movie movie);

  @Query('SELECT * FROM movies WHERE title = :title')
  Future<Movie?> getMovieByTitle(String title);

  @Query('SELECT * FROM movies WHERE listType = :listType')
  Future<List<Movie>> getMoviesByListType(String listType);

  @Query('SELECT COUNT(*) FROM movies WHERE listType = :listType')
  Future<int?> countMoviesInList(String listType);

  @Query('SELECT * FROM movies WHERE title = :title AND listType = :listType')
  Future<Movie?> getMovieByTitleAndListType(String title, String listType);

  @Query('DELETE FROM movies WHERE title = :title AND listType = :listType')
  Future<void> deleteMovieByTitleAndListType(String title, String listType);

  @Query('UPDATE Movie SET listType = :listType WHERE title = :title')
  Future<void> updateMovieListType(String title, String listType);
}
