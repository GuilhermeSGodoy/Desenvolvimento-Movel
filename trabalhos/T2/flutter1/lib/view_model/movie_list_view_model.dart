import 'package:flutter/material.dart';
import '../data/movie.dart';
import '../data/movie_repository.dart';

class MovieListViewModel extends ChangeNotifier {
  final MovieRepository _movieRepository = MovieRepository();
  List<Movie> _movies = [];

  List<Movie> get movies => _movies;

  Future<void> fetchMovies(String listType) async {
    _movies = await _movieRepository.getMoviesByListType(listType);
    notifyListeners();
  }

  Future<void> removeMovie(Movie movie) async {
    await _movieRepository.deleteMovie(movie.listType, movie.title);
    fetchMovies(movie.listType);
  }
}
