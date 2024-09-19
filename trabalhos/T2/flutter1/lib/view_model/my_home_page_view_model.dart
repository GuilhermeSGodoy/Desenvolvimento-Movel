import 'package:flutter/material.dart';
import 'package:flutter1/custom_button.dart';
import 'package:flutter1/data/movie.dart';
import 'package:flutter1/movie_repository.dart';
import 'package:flutter1/movie_response.dart';
import 'package:flutter1/movie_service.dart';
import 'package:flutter1/utils/consts.dart';
import 'package:flutter1/utils/show_snackbar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyHomePageViewModel extends ChangeNotifier {
  final BuildContext context;
  MyHomePageViewModel({required this.context});

  final TextEditingController movieTitleController = TextEditingController();
  String movieTitle = '';
  String? imdbRating = '';
  String? posterUrl;
  bool loading = false;
  Movie? currentMovie;
  MovieResponse? currentMovieResponse;

  final List<Movie> wantToWatchMovies = [];
  final List<Movie> watchedMovies = [];
  final List<Movie> favoriteMovies = [];

  final MovieService movieService = MovieService();
  final MovieRepository movieRepository = MovieRepository();

  Future<void> getMovieDetails(String title) async {
    loading = true;
    notifyListeners();

    try {
      final movieResponse = await movieService.fetchMovieDetails(title);

      if (movieResponse != null) {
        currentMovieResponse = movieResponse;
        movieTitle = movieResponse.title!;
        imdbRating = movieResponse.imdbRating;
        posterUrl = movieResponse.poster;

        currentMovie = Movie(
          title: movieResponse.title!,
          year: movieResponse.year,
          posterUrl: movieResponse.poster,
          rating: movieResponse.imdbRating,
          listType: '',
        );
      } else {
        _showError(AppLocalizations.of(context)!.no_movies_details_found);
      }
    } catch (e) {
      _showError('${AppLocalizations.of(context)!.error_fetching_movie_details} $e');
    } finally {
      loading = false;
      movieTitleController.clear();
      notifyListeners();
    }
  }

  void _showError(String message) {
    movieTitle = '';
    imdbRating = '';
    posterUrl = null;
    currentMovie = null;
    currentMovieResponse = null;
    showSnackbar(context, message);
    notifyListeners();
  }

  void clearMovieDetails() {
    movieTitle = '';
    imdbRating = '';
    posterUrl = null;
    movieTitleController.clear();
    currentMovie = null;
    currentMovieResponse = null;
    notifyListeners();
  }

  void showAddMovieOptions() {
    if (movieTitle.isNotEmpty && currentMovie != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.add_to_list_title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CustomButton(
                  text: AppLocalizations.of(context)!.want_to_watch,
                  padding: 10,
                  iconData: Icons.bookmark_add_outlined,
                  spaceBetween: 10,
                  callback: () {
                    saveMovie(currentMovie!, constWantToWatch);
                    Navigator.of(context).pop();
                  },
                ),
                CustomButton(
                  text: AppLocalizations.of(context)!.watched,
                  padding: 10,
                  iconData: Icons.check_circle_outline,
                  spaceBetween: 10,
                  callback: () {
                    saveMovie(currentMovie!, constWatched);
                    Navigator.of(context).pop();
                  },
                ),
                CustomButton(
                  text: AppLocalizations.of(context)!.favorites,
                  padding: 10,
                  iconData: Icons.favorite_outline,
                  spaceBetween: 10,
                  callback: () {
                    saveMovie(currentMovie!, constFavorites);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void saveMovie(Movie movie, String listType) async {
    movie.listType = listType;

    final result = await movieRepository.saveMovieToDatabase(movie);

    if (result == constAdded) {
      showSnackbar(context, '${AppLocalizations.of(context)!.added_movie} $listType');
    } else if (result == constDuplicate) {
      showSnackbar(context, '${AppLocalizations.of(context)!.already_added_movie} $listType');
    }

    await _updateMoviesList(listType);
  }

  Future<void> _updateMoviesList(String listType) async {
    List<Movie> moviesFromDb = await movieRepository.getMoviesByListType(listType);

    switch (listType) {
      case constWantToWatch:
        wantToWatchMovies.clear();
        wantToWatchMovies.addAll(moviesFromDb);
        break;
      case constWatched:
        watchedMovies.clear();
        watchedMovies.addAll(moviesFromDb);
        break;
      case constFavorites:
        favoriteMovies.clear();
        favoriteMovies.addAll(moviesFromDb);
        break;
    }

    notifyListeners();
  }

  Color getRatingColor() {
    final rating = double.tryParse(imdbRating ?? '') ?? 0.0;
    if (rating > 7) {
      return Colors.green;
    } else if (rating >= 5) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  @override
  void dispose() {
    movieTitleController.dispose();
    super.dispose();
  }
}
