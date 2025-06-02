import 'package:flutter/material.dart';

class FilmCard extends StatefulWidget {
  const FilmCard({super.key});

  @override
  State<FilmCard> createState() => _FilmCardState();
}

class _FilmCardState extends State<FilmCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(
              0.1,
            ), // Couleur de l’ombre avec opacité
            offset: Offset(0, 4), // Décalage vertical de l’ombre
            blurRadius: 8, // Flou de l’ombre
            spreadRadius: 1, // Expansion de l’ombre
          ),
        ],
      ),
    );
  }
}
