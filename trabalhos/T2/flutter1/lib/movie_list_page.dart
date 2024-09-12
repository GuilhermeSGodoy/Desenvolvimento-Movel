import 'package:flutter/material.dart';
import 'data/movie.dart';
import 'movie_repository.dart';

class MovieListPage extends StatefulWidget {
  final String listType;

  const MovieListPage({super.key, required this.listType});

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

  Future<void> _addMovie(Movie movie) async {
    final result = await movieRepository.saveMovieToDatabase(movie);

    if (result == 'added') {
      _fetchMovies();
      _showSnackbar('Filme adicionado à lista ${widget.listType}');
    } else if (result == 'duplicate') {
      _showSnackbar('O filme já foi inserido na lista ${widget.listType}');
    }
  }

  Future<void> _removeMovie(Movie movie) async {
    await movieRepository.deleteMovie(movie.listType, movie.title ?? '');
    _fetchMovies(); // Atualiza a lista de filmes após a remoção
    _showSnackbar('Filme removido da lista ${widget.listType}');
  }

  void _showRemoveDialog(Movie movie) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remover Filme'),
          content: Text('Deseja remover "${movie.title}" da lista?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Remover'),
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

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listType),
      ),
      body: movies.isEmpty
          ? const Center(child: Text('Nenhum filme encontrado.'))
          : ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(movies[index].title ?? 'Sem título'),
            onLongPress: () => _showRemoveDialog(movies[index]),
          );
        },
      ),
    );
  }
}
