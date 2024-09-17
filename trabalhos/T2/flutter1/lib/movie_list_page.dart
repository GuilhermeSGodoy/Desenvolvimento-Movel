import 'package:flutter/material.dart';
import 'package:flutter1/utils/show_snackbar.dart';
import 'data/movie.dart';
import 'movie_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter1/utils/consts.dart';

class MovieListPage extends StatefulWidget {
  final String listType;
  final Function(Movie) onMovieSelected;

  const MovieListPage({super.key, required this.listType, required this.onMovieSelected});

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  final MovieRepository movieRepository = MovieRepository();
  List<Movie> movies = [];

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    final fetchedMovies = await movieRepository.getMoviesByListType(widget.listType);
    setState(() {
      movies = fetchedMovies;
    });
  }

  Future<void> _removeMovie(Movie movie) async {
    await movieRepository.deleteMovie(movie.listType, movie.title);
    _fetchMovies();
    showSnackbar(context, '${AppLocalizations.of(context)!.removed_movie} ${widget.listType}');
  }

  void _showRemoveDialog(Movie movie) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.remove_movie),
          content: Text('${AppLocalizations.of(context)!.remove_movie} "${movie.title}" ?'),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.remove_movie),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.remove),
              onPressed: () {
                _removeMovie(movie);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(widget.listType)),
      ),
      body: movies.isEmpty
          ? Center(child: Text(AppLocalizations.of(context)!.no_movies_found))
          : ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return ListTile(
            title: Text(movie.title),
            onTap: () {
              widget.onMovieSelected(movie);
              Navigator.pop(context);
            },
            onLongPress: () => _showRemoveDialog(movie),
          );
        },
      ),
    );
  }

  String _getAppBarTitle(String listType) {
    switch (listType) {
      case constWantToWatch:
        return AppLocalizations.of(context)!.want_to_watch;
      case constWatched:
        return AppLocalizations.of(context)!.watched;
      case constFavorites:
        return AppLocalizations.of(context)!.favorites;
      default:
        return AppLocalizations.of(context)!.movie_title;
    }
  }
}
