import 'package:flutter/material.dart';
import 'package:flutter1/custom_button.dart';
import 'package:flutter1/data/movie.dart';
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
        _showError('${AppLocalizations.of(context)!.no_movies_details_found}');
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
                    saveMovie(currentMovie!, 'WantToWatch');
                    Navigator.of(context).pop();
                  },
                ),
                CustomButton(
                  text: AppLocalizations.of(context)!.watched,
                  padding: 10,
                  iconData: Icons.check_circle_outline,
                  spaceBetween: 10,
                  callback: () {
                    saveMovie(currentMovie!, 'Watched');
                    Navigator.of(context).pop();
                  },
                ),
                CustomButton(
                  text: AppLocalizations.of(context)!.favorites,
                  padding: 10,
                  iconData: Icons.favorite_outline,
                  spaceBetween: 10,
                  callback: () {
                    saveMovie(currentMovie!, 'Favorites');
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

    if (result == 'added') {
      _showSnackbar('${AppLocalizations.of(context)!.added_movie} $listType');
    } else if (result == 'duplicate') {
      _showSnackbar('${AppLocalizations.of(context)!.already_added_movie} $listType');
    }

    _updateMoviesList(listType);
  }

  Future<void> _updateMoviesList(String listType) async {
    List<Movie> moviesFromDb = await movieRepository.getMoviesByListType(listType);

    setState(() {
      switch (listType) {
        case 'WantToWatch':
          wantToWatchMovies.clear();
          wantToWatchMovies.addAll(moviesFromDb);
          break;
        case 'Watched':
          watchedMovies.clear();
          watchedMovies.addAll(moviesFromDb);
          break;
        case 'Favorites':
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
                        builder: (context) => MovieListPage(listType: 'WantToWatch'),
                      ),
                    );
                  },
                  child: Text('${AppLocalizations.of(context)!.want_to_watch}'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieListPage(listType: 'Watched'),
                      ),
                    );
                  },
                  child: Text('${AppLocalizations.of(context)!.watched}'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieListPage(listType: 'Favorites'),
                      ),
                    );
                  },
                  child: Text('${AppLocalizations.of(context)!.favorites}'),
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
                          'IMDb Rating: $_imdbRating',
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
                            'Plot: ${currentMovieResponse!.plot ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Year: ${currentMovieResponse!.year ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Rated: ${currentMovieResponse!.rated ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Released: ${currentMovieResponse!.released ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Runtime: ${currentMovieResponse!.runtime ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Genre: ${currentMovieResponse!.genre ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Director: ${currentMovieResponse!.director ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Writer: ${currentMovieResponse!.writer ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Actors: ${currentMovieResponse!.actors ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Awards: ${currentMovieResponse!.awards ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ] else ...[
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

  // jogar pra um utils pq usa aqui e no movie_list
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
