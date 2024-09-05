import 'package:flutter/material.dart';

class MovieDetailsPage extends StatelessWidget {
  final String movieTitle;

  const MovieDetailsPage({required this.movieTitle, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movieTitle),
      ),
      body: Center(
        child: Text('Details for $movieTitle'),
      ),
    );
  }
}
