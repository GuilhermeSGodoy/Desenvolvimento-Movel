import 'dart:io';

import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter1/custom_button.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _movieTitleController = TextEditingController();
  String _movieTitle = '';
  String _imdbRating = '';
  String _movieDetails = '';
  String? _posterUrl;
  bool _loading = false;

  Future<void> getMovieDetails(String title) async {
    setState(() {
      _loading = true;
    });

    try {
      final dio = Dio();

      dio.httpClientAdapter = IOHttpClientAdapter()
        ..createHttpClient = () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        };

      final response = await dio.get(
        'https://www.omdbapi.com/',
        queryParameters: {'t': title, 'apikey': '512c45da'},
      );

      final movie = response.data;
      if (movie != null && movie['Title'] != null) {
        setState(() {
          _movieTitle = movie['Title'];
          _imdbRating = movie['imdbRating'];
          _movieDetails = '${movie['Plot']}, ${movie['Year']}, ${movie['Rated']}, ${movie['Released']}, '
              '${movie['Runtime']}, ${movie['Genre']}, ${movie['Director']}, '
              '${movie['Writer']}, ${movie['Actors']}, ${movie['Awards']}';
          _posterUrl = movie['Poster'];
        });
      }
    } catch (e) {
      setState(() {
        _movieTitle = '';
        _imdbRating = '';
        _movieDetails = 'Error fetching movie details';
        _posterUrl = null;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }


  void clearMovieDetails() {
    setState(() {
      _movieTitle = '';
      _imdbRating = '';
      _movieDetails = '';
      _posterUrl = null;
      _movieTitleController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _movieTitleController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.movie_title,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              CustomButtom(
                text: AppLocalizations.of(context)!.search,
                padding: 10,
                iconData: Icons.search,
                spaceBetween: 10,
                callback: () {
                  if (_movieTitleController.text.isNotEmpty) {
                    getMovieDetails(_movieTitleController.text);
                  }
                },
              ),
              CustomButtom(
                text: AppLocalizations.of(context)!.clear,
                padding: 10,
                iconData: Icons.clear,
                spaceBetween: 10,
                callback: () {
                  clearMovieDetails();
                },
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : Column(
                children: [
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
                    Text(
                      _movieDetails,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    Text(AppLocalizations.of(context)!.no_movie_details),
                  ]
                ],
              ),
              const SizedBox(height: 20),
              // FloatingActionButton(
              //   onPressed: clearMovieDetails,
              //   tooltip: AppLocalizations.of(context)!.clear,
              //   child: const Icon(Icons.clear),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRatingColor() {
    final rating = double.tryParse(_imdbRating) ?? 0.0;
    if (rating > 7) {
      return Colors.green;
    } else if (rating >= 5) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}
