import 'dart:io';
import 'package:dio/dio.dart';
import 'movie_response.dart';
import 'package:dio/io.dart';

class MovieService {
  Future<MovieResponse?> fetchMovieDetails(String title) async {
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
        return MovieResponse.fromJson(movie);
      }
    } catch (e) {
      print('Erro ao buscar detalhes do filme: $e');
      return null;
    }
    return null;
  }
}
