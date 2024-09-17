import 'package:flutter/material.dart';
import 'package:flutter1/custom_button.dart';
import 'package:flutter1/data/movie.dart';
import 'package:flutter1/utils/show_snackbar.dart';
import 'package:flutter1/utils/consts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'movie_list_page.dart';
import 'movie_service.dart';
import 'movie_repository.dart';
import 'movie_response.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _movieTitleController = TextEditingController();
  String _movieTitle = '';
  String? _imdbRating = '';
  String? _posterUrl;
  bool _loading = false;
  Movie? currentMovie;
  MovieResponse? currentMovieResponse;

  final List<Movie> wantToWatchMovies = [];
  final List<Movie> watchedMovies = [];
  final List<Movie> favoriteMovies = [];

  final MovieService movieService = MovieService();
  final MovieRepository movieRepository = MovieRepository();

  Future<void> getMovieDetails(String title) async {
    setState(() {
      _loading = true;
    });

    try {
      final movieResponse = await movieService.fetchMovieDetails(title);

      if (movieResponse != null) {
        setState(() {
          currentMovieResponse = movieResponse;
          _movieTitle = movieResponse.title!;
          _imdbRating = movieResponse.imdbRating;
          _posterUrl = movieResponse.poster;

          currentMovie = Movie(
            title: movieResponse.title!,
            year: movieResponse.year,
            posterUrl: movieResponse.poster,
            rating: movieResponse.imdbRating,
            listType: '',
          );
        });
      } else {
        _showError(AppLocalizations.of(context)!.no_movies_details_found);
      }
    } catch (e) {
      _showError('${AppLocalizations.of(context)!.error_fetching_movie_details} $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showError(String message) {
    setState(() {
      _movieTitle = '';
      _imdbRating = '';
      _posterUrl = null;
      currentMovie = null;
      currentMovieResponse = null;
    });
  }

  void clearMovieDetails() {
    setState(() {
      _movieTitle = '';
      _imdbRating = '';
      _posterUrl = null;
      _movieTitleController.clear();
      currentMovie = null;
      currentMovieResponse = null;
    });
  }

  void showAddMovieOptions(BuildContext context) {
    if (_movieTitle.isNotEmpty && currentMovie != null) {
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
    setState(() {
      movie.listType = listType;
    });

    final result = await movieRepository.saveMovieToDatabase(movie);

    if (result == constAdded) {
      showSnackbar(context, '${AppLocalizations.of(context)!.added_movie} $listType');
    } else if (result == constDuplicate) {
      showSnackbar(context, '${AppLocalizations.of(context)!.already_added_movie} $listType');
    }

    _updateMoviesList(listType);
  }

  Future<void> _updateMoviesList(String listType) async {
    List<Movie> moviesFromDb = await movieRepository.getMoviesByListType(listType);

    setState(() {
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
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: clearMovieDetails,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _movieTitleController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.movie_title,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      if (_movieTitleController.text.isNotEmpty) {
                        getMovieDetails(_movieTitleController.text);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieListPage(
                          listType: constWantToWatch,
                          onMovieSelected: (movie) async {
                            setState(() {
                              currentMovie = movie;
                              _movieTitle = movie.title;
                              _imdbRating = movie.rating;
                              _posterUrl = movie.posterUrl;
                            });

                            await getMovieDetails(movie.title);
                          },
                        ),
                      ),
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.want_to_watch),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieListPage(
                          listType: constWatched,
                          onMovieSelected: (movie) async {
                            setState(() {
                              currentMovie = movie;
                              _movieTitle = movie.title;
                              _imdbRating = movie.rating;
                              _posterUrl = movie.posterUrl;
                            });

                            await getMovieDetails(movie.title);
                          },
                        ),
                      ),
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.watched),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieListPage(
                          listType: constFavorites,
                          onMovieSelected: (movie) async {
                            setState(() {
                              currentMovie = movie;
                              _movieTitle = movie.title;
                              _imdbRating = movie.rating;
                              _posterUrl = movie.posterUrl;
                            });

                            await getMovieDetails(movie.title);
                          },
                        ),
                      ),
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.favorites),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: _loading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (_movieTitle.isNotEmpty) ...[
                        Text(
                          _movieTitle,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${AppLocalizations.of(context)!.imdb_rating}: $_imdbRating',
                          style: TextStyle(
                            fontSize: 18,
                            color: _getRatingColor(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_posterUrl != null)
                          Image.network(_posterUrl!),
                        const SizedBox(height: 10),
                        if (currentMovieResponse != null) ...[
                          Text(
                            '${AppLocalizations.of(context)!.plot}: ${currentMovieResponse!.plot ?? AppLocalizations.of(context)!.n_a}',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${AppLocalizations.of(context)!.year}: ${currentMovieResponse!.year ?? AppLocalizations.of(context)!.n_a}',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${AppLocalizations.of(context)!.rated}: ${currentMovieResponse!.rated ?? AppLocalizations.of(context)!.n_a}',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${AppLocalizations.of(context)!.release}: ${currentMovieResponse!.released ?? AppLocalizations.of(context)!.n_a}',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${AppLocalizations.of(context)!.runtime}: ${currentMovieResponse!.runtime ?? AppLocalizations.of(context)!.n_a}',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${AppLocalizations.of(context)!.genre}: ${currentMovieResponse!.genre ?? AppLocalizations.of(context)!.n_a}',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${AppLocalizations.of(context)!.director}: ${currentMovieResponse!.director ?? AppLocalizations.of(context)!.n_a}',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${AppLocalizations.of(context)!.writer}: ${currentMovieResponse!.writer ?? AppLocalizations.of(context)!.n_a}',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${AppLocalizations.of(context)!.actors}: ${currentMovieResponse!.actors ?? AppLocalizations.of(context)!.n_a}',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${AppLocalizations.of(context)!.awards}: ${currentMovieResponse!.awards ?? AppLocalizations.of(context)!.n_a}',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ] else if (_movieTitleController.text.isNotEmpty) ...[
                        Text(AppLocalizations.of(context)!.no_movie_details),
                      ]
                    ],
                  ),

                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _movieTitle.isNotEmpty
          ? FloatingActionButton(
        onPressed: () => showAddMovieOptions(context),
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  Color _getRatingColor() {
    final rating = double.tryParse(_imdbRating!) ?? 0.0;
    if (rating > 7) {
      return Colors.green;
    } else if (rating >= 5) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}
