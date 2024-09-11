import 'package:json_annotation/json_annotation.dart';

part 'movie_response.g.dart';

@JsonSerializable()
class MovieResponse {
  final String? title;
  final String? year;
  final String? rated;
  final String? released;
  final String? runtime;
  final String? genre;
  final String? director;
  final String? writer;
  final String? actors;
  final String? plot;
  final String? language;
  final String? country;
  final String? awards;
  final String? poster;
  final String? imdbRating;

  MovieResponse({
    this.title,
    this.year,
    this.rated,
    this.released,
    this.runtime,
    this.genre,
    this.director,
    this.writer,
    this.actors,
    this.plot,
    this.language,
    this.country,
    this.awards,
    this.poster,
    this.imdbRating,
  });

  factory MovieResponse.fromJson(Map<String, dynamic> json) {
    return MovieResponse(
      title: json['Title'] as String? ?? '',
      year: json['Year'] as String? ?? '',
      rated: json['Rated'] as String? ?? '',
      released: json['Released'] as String? ?? '',
      runtime: json['Runtime'] as String? ?? '',
      genre: json['Genre'] as String? ?? '',
      director: json['Director'] as String? ?? '',
      writer: json['Writer'] as String? ?? '',
      actors: json['Actors'] as String? ?? '',
      plot: json['Plot'] as String? ?? '',
      language: json['Language'] as String? ?? '',
      country: json['Country'] as String? ?? '',
      awards: json['Awards'] as String? ?? '',
      poster: json['Poster'] as String? ?? '',
      imdbRating: json['imdbRating'] as String? ?? '',
    );
  }


  Map<String, dynamic> toJson() => _$MovieResponseToJson(this);
}
