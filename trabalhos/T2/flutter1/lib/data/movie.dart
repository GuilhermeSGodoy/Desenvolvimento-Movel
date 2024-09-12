import 'package:floor/floor.dart';

@Entity(tableName: 'movies')
class Movie {
  @PrimaryKey(autoGenerate: true)
  int? id;
  final String title;
  String listType;
  final String? posterUrl;
  final String? year;
  final String? rating;

  Movie({
    this.id,
    required this.title,
    required this.listType,
    this.posterUrl,
    this.year,
    this.rating,
  });
}
