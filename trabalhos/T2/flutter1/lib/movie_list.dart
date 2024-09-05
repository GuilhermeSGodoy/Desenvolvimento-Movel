// import 'package:flutter/material.dart';
// import 'data/app_database.dart';
// import 'data/movie.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//
// import 'movie_details.dart';
//
// class MovieListPage extends StatefulWidget {
//   final AppDatabase database;
//   final String listType;
//
//   const MovieListPage({required this.database, required this.listType, Key? key}) : super(key: key);
//
//   @override
//   State<MovieListPage> createState() => _MovieListPageState();
// }
//
// class _MovieListPageState extends State<MovieListPage> {
//   List<Movie> _movies = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchMovies();
//   }
//
//   Future<void> fetchMovies() async {
//     final movies = await widget.database.movieDao.getMoviesByListType(widget.listType);
//     setState(() {
//       _movies = movies;
//     });
//   }
//
//   void showMovieDetails(String title) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MovieDetailsPage(movieTitle: title),
//       ),
//     );
//   }
//
//   void showRemoveDialog(Movie movie) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(AppLocalizations.of(context)!.remove_movie_title),
//           content: Text(AppLocalizations.of(context)!.remove_movie_message),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: Text(AppLocalizations.of(context)!.no),
//             ),
//             TextButton(
//               onPressed: () {
//                 removeMovie(movie);
//                 Navigator.pop(context);
//               },
//               child: Text(AppLocalizations.of(context)!.yes),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> removeMovie(Movie movie) async {
//     await widget.database.movieDao.deleteMovieByTitleAndListType(movie.title, movie.listType);
//     fetchMovies();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(AppLocalizations.of(context)!.movie_removed_from_list)),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(AppLocalizations.of(context)!.movie_list),
//       ),
//       body: _movies.isEmpty
//           ? Center(child: Text(AppLocalizations.of(context)!.no_movies))
//           : ListView.builder(
//         itemCount: _movies.length,
//         itemBuilder: (context, index) {
//           final movie = _movies[index];
//           return ListTile(
//             title: Text(movie.title),
//             trailing: IconButton(
//               icon: const Icon(Icons.delete),
//               onPressed: () => showRemoveDialog(movie),
//             ),
//             onTap: () => showMovieDetails(movie.title),
//           );
//         },
//       ),
//     );
//   }
// }
