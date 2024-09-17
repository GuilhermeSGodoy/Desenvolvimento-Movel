import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class MovieDetailsPage extends StatelessWidget {
  final String movieTitle;

  const MovieDetailsPage({required this.movieTitle, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movieTitle),
      ),
      body: Center(
        child: Text('${AppLocalizations.of(context)!.details_for}: $movieTitle'),
      ),
    );
  }
}
