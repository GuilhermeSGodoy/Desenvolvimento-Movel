// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MovieResponse _$MovieResponseFromJson(Map<String, dynamic> json) =>
    MovieResponse(
      title: json['title'] as String?,
      year: json['year'] as String?,
      rated: json['rated'] as String?,
      released: json['released'] as String?,
      runtime: json['runtime'] as String?,
      genre: json['genre'] as String?,
      director: json['director'] as String?,
      writer: json['writer'] as String?,
      actors: json['actors'] as String?,
      plot: json['plot'] as String?,
      language: json['language'] as String?,
      country: json['country'] as String?,
      awards: json['awards'] as String?,
      poster: json['poster'] as String?,
      imdbRating: json['imdbRating'] as String?,
    );

Map<String, dynamic> _$MovieResponseToJson(MovieResponse instance) =>
    <String, dynamic>{
      'title': instance.title,
      'year': instance.year,
      'rated': instance.rated,
      'released': instance.released,
      'runtime': instance.runtime,
      'genre': instance.genre,
      'director': instance.director,
      'writer': instance.writer,
      'actors': instance.actors,
      'plot': instance.plot,
      'language': instance.language,
      'country': instance.country,
      'awards': instance.awards,
      'poster': instance.poster,
      'imdbRating': instance.imdbRating,
    };
