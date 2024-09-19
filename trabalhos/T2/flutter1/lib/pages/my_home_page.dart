import 'package:flutter/material.dart';
import 'package:flutter1/utils/consts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'movie_list_page.dart';
import '../view_model/my_home_page_view_model.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyHomePageViewModel(context: context),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Consumer<MyHomePageViewModel>(
          builder: (context, viewModel, child) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Search Bar
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: viewModel.clearMovieDetails,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: viewModel.movieTitleController,
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
                            if (viewModel.movieTitleController.text.isNotEmpty) {
                              viewModel.getMovieDetails(viewModel.movieTitleController.text);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // List Buttons
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
                                  viewModel.currentMovie = movie;
                                  viewModel.movieTitle = movie.title;
                                  viewModel.imdbRating = movie.rating;
                                  viewModel.posterUrl = movie.posterUrl;
                                  await viewModel.getMovieDetails(movie.title);
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
                                  viewModel.currentMovie = movie;
                                  viewModel.movieTitle = movie.title;
                                  viewModel.imdbRating = movie.rating;
                                  viewModel.posterUrl = movie.posterUrl;
                                  await viewModel.getMovieDetails(movie.title);
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
                                  viewModel.currentMovie = movie;
                                  viewModel.movieTitle = movie.title;
                                  viewModel.imdbRating = movie.rating;
                                  viewModel.posterUrl = movie.posterUrl;
                                  await viewModel.getMovieDetails(movie.title);
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
                  // Movie Details
                  Expanded(
                    child: viewModel.loading
                        ? const Center(
                      child: CircularProgressIndicator(),
                    )
                        : viewModel.movieTitle.isEmpty
                        ? Center(
                      child: Text(
                        AppLocalizations.of(context)!.search_for_a_movie,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    )
                        : SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        margin: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (viewModel.movieTitle.isNotEmpty) ...[
                              Center(
                                child: Text(
                                  viewModel.movieTitle,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                  softWrap: true,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: viewModel.getRatingColor(),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${AppLocalizations.of(context)!.imdb_rating}: ${viewModel.imdbRating}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    softWrap: true,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (viewModel.posterUrl != null)
                                Image.network(viewModel.posterUrl!),
                              const SizedBox(height: 10),
                              if (viewModel.currentMovieResponse != null) ...[
                                _buildDetailRow(
                                  context,
                                  AppLocalizations.of(context)!.plot,
                                  viewModel.currentMovieResponse!.plot,
                                ),
                                _buildDetailRow(
                                  context,
                                  AppLocalizations.of(context)!.year,
                                  viewModel.currentMovieResponse!.year,
                                ),
                                _buildDetailRow(
                                  context,
                                  AppLocalizations.of(context)!.rated,
                                  viewModel.currentMovieResponse!.rated,
                                ),
                                _buildDetailRow(
                                  context,
                                  AppLocalizations.of(context)!.release,
                                  viewModel.currentMovieResponse!.released,
                                ),
                                _buildDetailRow(
                                  context,
                                  AppLocalizations.of(context)!.runtime,
                                  viewModel.currentMovieResponse!.runtime,
                                ),
                                _buildDetailRow(
                                  context,
                                  AppLocalizations.of(context)!.genre,
                                  viewModel.currentMovieResponse!.genre,
                                ),
                                _buildDetailRow(
                                  context,
                                  AppLocalizations.of(context)!.director,
                                  viewModel.currentMovieResponse!.director,
                                ),
                                _buildDetailRow(
                                  context,
                                  AppLocalizations.of(context)!.writer,
                                  viewModel.currentMovieResponse!.writer,
                                ),
                                _buildDetailRow(
                                  context,
                                  AppLocalizations.of(context)!.actors,
                                  viewModel.currentMovieResponse!.actors,
                                ),
                                _buildDetailRow(
                                  context,
                                  AppLocalizations.of(context)!.awards,
                                  viewModel.currentMovieResponse!.awards,
                                ),
                              ],
                            ] else ...[
                              Center(
                                child: Text(AppLocalizations.of(context)!.no_movie_details),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: Consumer<MyHomePageViewModel>(
          builder: (context, viewModel, child) {
            return viewModel.movieTitle.isNotEmpty
                ? FloatingActionButton(
              onPressed: viewModel.showAddMovieOptions,
              backgroundColor: Colors.blue.shade700,
              child: const Icon(Icons.add, color: Colors.white),
            )
                : SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              '$label: ${value ?? AppLocalizations.of(context)!.n_a}',
              style: const TextStyle(fontSize: 16),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
