import 'package:flutter/material.dart';
import 'package:flutter1/view_model/movie_list_view_model.dart';
import 'package:provider/provider.dart';
import '../data/movie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter1/utils/show_snackbar.dart';
import 'package:flutter1/utils/consts.dart';

class MovieListPage extends StatelessWidget {
  final String listType;
  final Function(Movie) onMovieSelected;

  const MovieListPage({super.key, required this.listType, required this.onMovieSelected});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MovieListViewModel()..fetchMovies(listType),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getAppBarTitle(context, listType)),
        ),
        body: Consumer<MovieListViewModel>(
          builder: (context, viewModel, _) {
            final movies = viewModel.movies;

            if (movies.isEmpty) {
              return Center(child: Text(AppLocalizations.of(context)!.no_movies_found));
            }

            return ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: InkWell(
                    onTap: () {
                      onMovieSelected(movie);
                      Navigator.pop(context);
                    },
                    onLongPress: () => _showRemoveDialog(context, viewModel, movie),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Image.network(
                            movie.posterUrl!,
                            width: 50,
                            height: 75,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Center(
                              child: Text(
                                movie.title,
                                style: Theme.of(context).textTheme.headlineSmall,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: _getRatingColor(movie.rating.toString()),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              movie.rating.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, MovieListViewModel viewModel, Movie movie) {
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
                viewModel.removeMovie(movie);
                Navigator.of(context).pop();
                showSnackbar(context, '${AppLocalizations.of(context)!.removed_movie} ${movie.listType}');
              },
            ),
          ],
        );
      },
    );
  }

  String _getAppBarTitle(BuildContext context, String listType) {
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

  Color _getRatingColor(String imdbRating) {
    final rating = double.tryParse(imdbRating) ?? 0.0;
    if (rating > 7) {
      return Colors.green;
    } else if (rating >= 5) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}
